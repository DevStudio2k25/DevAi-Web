import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final SharedPreferences _prefs;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  static const int DEFAULT_TOKENS = 20; // Changed back to 20
  static const String DEVICE_ID_KEY = 'device_id';
  static const String BOUND_EMAIL_KEY = 'bound_email';

  AuthService(this._prefs);

  // Check if user is logged in
  bool get isLoggedIn => _auth.currentUser != null;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get device ID based on platform
  Future<String> getDeviceId() async {
    String deviceId = _prefs.getString(DEVICE_ID_KEY) ?? '';

    // If we already have a stored device ID, return it
    if (deviceId.isNotEmpty) {
      print('Using stored device ID: $deviceId');
      return deviceId;
    }

    // Otherwise generate a new device ID
    try {
      if (Platform.isAndroid) {
        // For Android, use Android ID
        final androidInfo = await _deviceInfoPlugin.androidInfo;
        deviceId = androidInfo.id;
        print('Generated new Android device ID: $deviceId');
        print(
          'Android device details: ${androidInfo.model}, ${androidInfo.brand}, ${androidInfo.device}',
        );
      } else {
        // For other platforms, generate a random ID
        deviceId = 'device_${DateTime.now().millisecondsSinceEpoch}';
        print('Generated fallback device ID: $deviceId');
      }

      // Store the device ID for future use
      await _prefs.setString(DEVICE_ID_KEY, deviceId);
      print('Stored device ID in SharedPreferences: $deviceId');
      return deviceId;
    } catch (e) {
      print('Error getting device ID: $e');
      // Fallback to timestamp if device info fails
      deviceId = 'fallback_${DateTime.now().millisecondsSinceEpoch}';
      await _prefs.setString(DEVICE_ID_KEY, deviceId);
      print('Stored fallback device ID due to error: $deviceId');
      return deviceId;
    }
  }

  // Check if this device is already bound to an account
  Future<bool> isDeviceBoundToAnotherAccount(String email) async {
    try {
      final deviceId = await getDeviceId();
      print('Checking if device $deviceId is bound to another account');

      // Check if we have a stored bound email
      final boundEmail = _prefs.getString(BOUND_EMAIL_KEY);
      if (boundEmail != null && boundEmail.isNotEmpty) {
        print('Found locally stored bound email: $boundEmail');
        // If the stored email matches the current one, allow login
        if (boundEmail == email) {
          print('Current email matches bound email, allowing login');
          return false;
        }
        // Otherwise, this device is bound to another account
        print(
          'Device is bound to different email: $boundEmail, current: $email',
        );
        return true;
      }

      // If no local binding, try to create one without checking Firestore first
      // This avoids permission issues before authentication
      try {
        print('Creating device binding for: $deviceId with email: $email');

        // Store the bound email locally first
        await _prefs.setString(BOUND_EMAIL_KEY, email);
        print('Stored bound email locally: $email');

        // Try to store in Firestore, but don't fail if it doesn't work
        try {
          await _firestore.collection('device_bindings').doc(deviceId).set({
            'email': email,
            'boundAt': FieldValue.serverTimestamp(),
            'deviceDetails': await _getDeviceDetails(),
          }, SetOptions(merge: true));
          print('Successfully created device binding in Firestore');
        } catch (e) {
          // Just log the error but continue - we'll rely on local storage
          print(
            'Error creating device binding in Firestore (non-critical): $e',
          );
        }

        return false;
      } catch (e) {
        print('Error binding device: $e');
        // In case of error, allow login to prevent lockouts
        return false;
      }
    } catch (e) {
      print('Error checking device binding: $e');
      // In case of error, allow login to prevent lockouts
      return false;
    }
  }

  // Get device details for better debugging
  Future<Map<String, dynamic>> _getDeviceDetails() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfoPlugin.androidInfo;
        return {
          'model': androidInfo.model,
          'brand': androidInfo.brand,
          'device': androidInfo.device,
          'isPhysicalDevice': androidInfo.isPhysicalDevice,
          'androidVersion': androidInfo.version.release,
          'sdkInt': androidInfo.version.sdkInt,
        };
      }
      return {'platform': 'unknown'};
    } catch (e) {
      print('Error getting device details: $e');
      return {'error': e.toString()};
    }
  }

  // Get user's tokens
  Future<int> getUserTokens() async {
    if (_auth.currentUser == null) return 0;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .get();

      if (doc.exists) {
        final tokens = doc.data()?['tokens'] as int? ?? DEFAULT_TOKENS;
        print('Retrieved user tokens: $tokens');
        return tokens;
      }
      print('User document not found, using default tokens: $DEFAULT_TOKENS');
      return DEFAULT_TOKENS;
    } catch (e) {
      print('Error getting tokens: $e');
      return 0;
    }
  }

  // Update user's tokens
  Future<bool> updateTokens(int newTokenCount) async {
    if (_auth.currentUser == null) return false;

    try {
      await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
        'tokens': newTokenCount,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('Updated user tokens to: $newTokenCount');
      return true;
    } catch (e) {
      print('Error updating tokens: $e');
      return false;
    }
  }

  // Get user's API key
  Future<String?> getUserApiKey() async {
    if (_auth.currentUser == null) return null;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .get();

      if (doc.exists) {
        return doc.data()?['apiKey'] as String?;
      }
      return null;
    } catch (e) {
      print('Error getting API key: $e');
      return null;
    }
  }

  // Save API key to Firestore
  Future<bool> saveApiKey(String apiKey) async {
    if (_auth.currentUser == null) return false;

    try {
      await _firestore.collection('users').doc(_auth.currentUser!.uid).set({
        'apiKey': apiKey,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      print('Saved API key for user: ${_auth.currentUser!.uid}');
      return true;
    } catch (e) {
      print('Error saving API key: $e');
      return false;
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      print('Starting Google Sign-In process');

      // Sign out from GoogleSignIn first to allow selecting account again
      try {
        await _googleSignIn.signOut();
        print('Signed out from previous Google session to allow new selection');
      } catch (e) {
        print('No previous Google session to sign out from: $e');
      }

      // Start the Google Sign In process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print('Google Sign-In cancelled by user');
        return null;
      }

      print('Google user signed in: ${googleUser.email}');

      // Check if this device is already bound to another account
      final isDeviceBound = await isDeviceBoundToAnotherAccount(
        googleUser.email,
      );
      if (isDeviceBound) {
        print('Device is bound to another account, throwing exception');
        throw Exception(
          'This device is already bound to another Google account. Please use that account to sign in.',
        );
      }

      // Get auth details
      print('Getting Google authentication details');
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      print('Signing in to Firebase with Google credentials');
      final userCredential = await _auth.signInWithCredential(credential);
      print('Firebase sign-in successful: ${userCredential.user?.uid}');

      // Check if this is an existing user or a new user
      final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
      print('Is new user: $isNewUser');

      // Save user data to Firestore
      if (userCredential.user != null) {
        final userRef = _firestore
            .collection('users')
            .doc(userCredential.user!.uid);
        final userDoc = await userRef.get();

        if (isNewUser || !userDoc.exists) {
          // For new users, set up the initial data
          print(
            'Setting up new user data with DEFAULT_TOKENS: $DEFAULT_TOKENS',
          );
          await userRef.set({
            'email': userCredential.user!.email,
            'displayName': userCredential.user!.displayName,
            'photoURL': userCredential.user!.photoURL,
            'lastLogin': FieldValue.serverTimestamp(),
            'createdAt': FieldValue.serverTimestamp(),
            'projectCount': 0, // Initialize project count
            'tokens': DEFAULT_TOKENS, // Initialize with default tokens
          }, SetOptions(merge: true));
        } else {
          // For existing users, just update the login timestamp
          print('Updating existing user login timestamp');
          await userRef.update({
            'lastLogin': FieldValue.serverTimestamp(),
            // Don't update tokens here to preserve the existing count
          });
        }

        // Save login state
        await _prefs.setBool('isLoggedIn', true);
      }

      return userCredential;
    } catch (e) {
      print('Error signing in with Google: $e');
      rethrow; // Rethrow to handle in UI
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      print('Signing out user');
      await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
      await _prefs.setBool('isLoggedIn', false);
      print('User signed out successfully');
      // Don't clear device binding on sign out
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  // Clear device binding (admin function or for troubleshooting)
  Future<void> clearDeviceBinding() async {
    try {
      print('Clearing device binding');
      final deviceId = await getDeviceId();

      // Clear from Firestore
      await _firestore.collection('device_bindings').doc(deviceId).delete();
      print('Deleted device binding from Firestore: $deviceId');

      // Clear from SharedPreferences
      await _prefs.remove(BOUND_EMAIL_KEY);
      print('Cleared bound email from SharedPreferences');

      print('Device binding cleared successfully');
    } catch (e) {
      print('Error clearing device binding: $e');
    }
  }
}
