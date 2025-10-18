// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/prompt_request.dart';
import '../models/prompt_response.dart';
import '../services/gemini_service.dart';
import '../services/gemini_streaming_service.dart';
import '../services/storage_service.dart';
import '../services/auth_service.dart';

class AppProvider extends ChangeNotifier {
  // ignore: unused_field
  final StorageService _storageService;
  final GeminiService _geminiService;
  late final GeminiStreamingService _geminiStreamingService;
  final SharedPreferences _prefs;
  final AuthService _authService;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const _historyKey = 'prompt_history';

  bool _isLoading = false;
  bool _hasApiKey = false;
  int _tokens = 0;
  List<Map<String, dynamic>> _promptHistory = [];
  ThemeMode _themeMode = ThemeMode.system;
  String _themeStyle = 'windows11'; // 'classic' or 'windows11'

  AppProvider(
    this._storageService,
    this._geminiService,
    this._prefs,
    this._authService,
  ) {
    _geminiStreamingService = GeminiStreamingService(_storageService);
    _loadInitialData();
  }

  bool get isLoading => _isLoading;
  bool get hasApiKey => _hasApiKey;
  int get tokens => _tokens;
  GeminiService get geminiService => _geminiService;
  GeminiStreamingService get geminiStreamingService => _geminiStreamingService;
  List<Map<String, dynamic>> get promptHistory => _promptHistory;
  ThemeMode get themeMode => _themeMode;
  String get themeStyle => _themeStyle;

  Future<void> _loadInitialData() async {
    print('🔵 [INIT] _loadInitialData() called');

    // Load API key from Firestore if user is logged in
    if (_authService.isLoggedIn) {
      print('👤 [INIT] User is logged in, loading data...');

      final apiKey = await _authService.getUserApiKey();
      _hasApiKey = apiKey != null;
      if (_hasApiKey) {
        await _geminiService.initialize(apiKey: apiKey);
      }

      // Load tokens from Firestore
      print('🪙 [INIT] Loading tokens from Firestore...');
      final tokens = await _authService.getUserTokens();
      print('🪙 [INIT] Tokens loaded from Firestore: $tokens');
      _tokens = tokens;
      print('🪙 [INIT] Local tokens set to: $_tokens');

      await _loadPromptHistory();
    } else {
      print('⚠️ [INIT] User not logged in');

      // If not logged in, load from SharedPreferences as fallback
      _loadPromptHistoryFromPrefs();
    }

    _loadThemeMode();
    notifyListeners();
  }

  void _loadThemeMode() {
    final themeModeString = _prefs.getString('themeMode') ?? 'system';
    _themeMode = ThemeMode.values.firstWhere(
      (mode) => mode.toString() == 'ThemeMode.$themeModeString',
      orElse: () => ThemeMode.system,
    );

    // Load theme style
    _themeStyle = _prefs.getString('themeStyle') ?? 'windows11';
  }

  Future<void> setThemeStyle(String style) async {
    _themeStyle = style;
    await _prefs.setString('themeStyle', style);
    notifyListeners();
  }

  void _loadPromptHistoryFromPrefs() {
    final historyJson = _prefs.getStringList(_historyKey) ?? [];
    _promptHistory = historyJson
        .map((json) => jsonDecode(json) as Map<String, dynamic>)
        .toList();

    print('Loaded history from prefs: ${_promptHistory.length} items');
  }

  Future<void> _loadPromptHistory() async {
    if (!_authService.isLoggedIn) return;

    _isLoading = true;
    notifyListeners();

    try {
      final userId = _authService.currentUser!.uid;
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('history')
          .orderBy('timestamp', descending: true)
          .get();

      _promptHistory = snapshot.docs.map((doc) {
        final data = doc.data();

        // Convert any Firestore timestamps to ISO strings
        Map<String, dynamic> processedData = Map<String, dynamic>.from(data);

        // Handle request and response objects
        if (processedData['request'] != null) {
          final request = Map<String, dynamic>.from(
            processedData['request'] as Map,
          );
          if (request['timestamp'] != null && request['timestamp'] is! String) {
            try {
              request['timestamp'] = request['timestamp']
                  .toDate()
                  .toIso8601String();
            } catch (e) {
              request['timestamp'] = DateTime.now().toIso8601String();
            }
          }
          processedData['request'] = request;
        }

        // Handle response object
        if (processedData['response'] != null) {
          final response = Map<String, dynamic>.from(
            processedData['response'] as Map,
          );
          if (response['timestamp'] != null &&
              response['timestamp'] is! String) {
            try {
              response['timestamp'] = response['timestamp']
                  .toDate()
                  .toIso8601String();
            } catch (e) {
              response['timestamp'] = DateTime.now().toIso8601String();
            }
          }
          processedData['response'] = response;
        }

        // Handle main timestamp
        if (processedData['timestamp'] != null &&
            processedData['timestamp'] is! String) {
          try {
            processedData['timestamp'] = processedData['timestamp']
                .toDate()
                .toIso8601String();
          } catch (e) {
            processedData['timestamp'] = DateTime.now().toIso8601String();
          }
        }

        return {'id': doc.id, ...processedData};
      }).toList();

      print('Loaded history from Firestore: ${_promptHistory.length} items');
    } catch (e) {
      print('Error loading history from Firestore: $e');
      // Fallback to SharedPreferences if Firestore fails
      _loadPromptHistoryFromPrefs();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _savePromptHistoryToPrefs() async {
    try {
      final historyJson = _promptHistory.map((item) {
        // Make a deep copy and process any potential Timestamp objects
        final processedItem = _processFirestoreData(
          Map<String, dynamic>.from(item),
        );

        // Remove Firestore ID before saving to prefs
        final copy = Map<String, dynamic>.from(processedItem);
        copy.remove('id');

        // Try to encode and catch any errors
        try {
          return jsonEncode(copy);
        } catch (e) {
          print('Error encoding history item: $e');
          // Return a simplified version if encoding fails
          return jsonEncode({
            'error': 'Failed to encode item',
            'timestamp': DateTime.now().toIso8601String(),
          });
        }
      }).toList();

      await _prefs.setStringList(_historyKey, historyJson);
      print('Saved history to prefs: ${_promptHistory.length} items');
    } catch (e) {
      print('Error saving history to prefs: $e');
    }
  }

  Future<String?> _savePromptToFirestore(
    Map<String, dynamic> promptData,
  ) async {
    if (!_authService.isLoggedIn) return null;

    try {
      final userId = _authService.currentUser!.uid;
      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('history')
          .add(promptData);

      print('Saved prompt to Firestore with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('Error saving prompt to Firestore: $e');
      return null;
    }
  }

  Future<PromptResponse> generatePrompt(
    PromptRequest request, {
    bool shareWithCommunity = true,
  }) async {
    print('🔵 [APP PROVIDER] generatePrompt() called');
    print('🪙 [APP PROVIDER] Current tokens BEFORE generation: $_tokens');

    _isLoading = true;
    notifyListeners();

    try {
      print('🤖 [APP PROVIDER] Generating prompt for: ${request.projectName}');
      final response = await _geminiService.generatePrompt(request);
      print('✅ [APP PROVIDER] Received response from Gemini service');

      // Convert to ISO string for consistent storage
      final timestamp = DateTime.now().toIso8601String();
      print('Using timestamp: $timestamp');

      final promptData = {
        'request': request.toJson(),
        'response': response.toJson(),
        'timestamp': timestamp,
      };

      print('Prompt data prepared: ${promptData.keys}');

      // Save to Firestore if logged in
      String? docId;
      if (_authService.isLoggedIn) {
        print('User is logged in, saving to Firestore');
        docId = await _savePromptToFirestore(promptData);
        print('Saved to Firestore with ID: $docId');

        // Save to community collection if sharing is enabled
        print('🌍 [COMMUNITY] shareWithCommunity flag: $shareWithCommunity');
        if (shareWithCommunity) {
          print('🌍 [COMMUNITY] Sharing with community...');
          await _savePromptToCommunity(promptData);
          print('✅ [COMMUNITY] Saved to community collection');
        } else {
          print('🚫 [COMMUNITY] Not sharing (disabled by user)');
        }

        // Deduct 1 token from user
        await _deductToken();
        print('Token deducted');

        // Increment user's project count
        await _incrementUserProjectCount();
        print('Project count incremented');

        // Get the document we just created to ensure we have the correct data format
        try {
          final userId = _authService.currentUser!.uid;
          final docSnapshot = await _firestore
              .collection('users')
              .doc(userId)
              .collection('history')
              .doc(docId)
              .get();

          if (docSnapshot.exists) {
            final data = docSnapshot.data()!;

            // Process the data to convert any Timestamp objects to ISO strings
            final processedData = _processFirestoreData(data);

            // Use the processed data for local history
            if (docId != null) {
              processedData['id'] = docId;
            }

            _promptHistory.insert(0, processedData);
            print('Added processed data to local history');
          } else {
            // Fallback to original data if document not found
            if (docId != null) {
              promptData['id'] = docId;
            }
            _promptHistory.insert(0, promptData);
            print('Added original data to local history (document not found)');
          }
        } catch (e) {
          print('Error fetching saved document: $e');
          // Fallback to original data
          if (docId != null) {
            promptData['id'] = docId;
          }
          _promptHistory.insert(0, promptData);
          print('Added original data to local history (error fetching)');
        }
      } else {
        // Not logged in, use original data
        _promptHistory.insert(0, promptData);
        print('Added original data to local history (not logged in)');
      }

      print('Added to local history. Total items: ${_promptHistory.length}');

      // Also save to SharedPreferences as backup
      await _savePromptHistoryToPrefs();
      print('Saved to SharedPreferences');

      notifyListeners();
      return response;
    } catch (e) {
      print('Error generating prompt: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save prompt to community collection
  Future<void> _savePromptToCommunity(Map<String, dynamic> promptData) async {
    if (!_authService.isLoggedIn) return;

    try {
      final userId = _authService.currentUser!.uid;
      final user = await _firestore.collection('users').doc(userId).get();

      // Create community prompt data with user info
      final communityPromptData = {
        ...promptData,
        'userId': userId,
        'displayName': user.data()?['displayName'] ?? 'Anonymous',
        'photoURL': user.data()?['photoURL'],
        'createdAt': FieldValue.serverTimestamp(),
        'likes': 0,
        'views': 0,
      };

      // Save to community collection
      await _firestore.collection('community_prompts').add(communityPromptData);
    } catch (e) {
      print('Error saving prompt to community: $e');
    }
  }

  // Helper method to process Firestore data and convert Timestamp objects
  Map<String, dynamic> _processFirestoreData(Map<String, dynamic> data) {
    Map<String, dynamic> processedData = Map<String, dynamic>.from(data);

    // Process request object
    if (processedData['request'] != null) {
      final request = Map<String, dynamic>.from(
        processedData['request'] as Map,
      );
      if (request['timestamp'] != null && request['timestamp'] is! String) {
        try {
          request['timestamp'] = request['timestamp']
              .toDate()
              .toIso8601String();
        } catch (e) {
          request['timestamp'] = DateTime.now().toIso8601String();
        }
      }
      processedData['request'] = request;
    }

    // Process response object
    if (processedData['response'] != null) {
      final response = Map<String, dynamic>.from(
        processedData['response'] as Map,
      );
      if (response['timestamp'] != null && response['timestamp'] is! String) {
        try {
          response['timestamp'] = response['timestamp']
              .toDate()
              .toIso8601String();
        } catch (e) {
          response['timestamp'] = DateTime.now().toIso8601String();
        }
      }
      processedData['response'] = response;
    }

    // Process main timestamp
    if (processedData['timestamp'] != null &&
        processedData['timestamp'] is! String) {
      try {
        processedData['timestamp'] = processedData['timestamp']
            .toDate()
            .toIso8601String();
      } catch (e) {
        processedData['timestamp'] = DateTime.now().toIso8601String();
      }
    }

    return processedData;
  }

  Future<void> _deductToken() async {
    print('🪙 [TOKEN DEDUCTION] _deductToken() called');
    print(
      '🪙 [TOKEN DEDUCTION] Current local tokens BEFORE deduction: $_tokens',
    );

    if (!_authService.isLoggedIn) {
      print('⚠️ [TOKEN DEDUCTION] User not logged in, skipping deduction');
      return;
    }

    try {
      final userId = _authService.currentUser!.uid;
      print('👤 [TOKEN DEDUCTION] User ID: $userId');

      final userRef = _firestore.collection('users').doc(userId);

      print('🔄 [TOKEN DEDUCTION] Updating Firestore: decrementing by 1...');
      // Deduct 1 token from Firestore
      await userRef.update({'tokens': FieldValue.increment(-1)});
      print('✅ [TOKEN DEDUCTION] Firestore updated successfully');

      // Update local token count
      final oldTokens = _tokens;
      _tokens = _tokens - 1;
      if (_tokens < 0) _tokens = 0;

      print('🪙 [TOKEN DEDUCTION] Local tokens updated: $oldTokens → $_tokens');
      print('✅ [TOKEN DEDUCTION] Token deduction complete!');
    } catch (e) {
      print('❌ [TOKEN DEDUCTION] Error deducting token: $e');
      print('❌ [TOKEN DEDUCTION] Stack trace: ${StackTrace.current}');
    }
  }

  Future<void> _incrementUserProjectCount() async {
    if (!_authService.isLoggedIn) return;

    try {
      final userId = _authService.currentUser!.uid;
      final userRef = _firestore.collection('users').doc(userId);

      // Use transaction to safely increment the counter
      await _firestore.runTransaction((transaction) async {
        final userDoc = await transaction.get(userRef);

        if (userDoc.exists) {
          final currentCount = userDoc.data()?['projectCount'] as int? ?? 0;
          transaction.update(userRef, {
            'projectCount': currentCount + 1,
            'lastProjectTimestamp': FieldValue.serverTimestamp(),
          });
        } else {
          transaction.set(userRef, {
            'projectCount': 1,
            'lastProjectTimestamp': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
      });

      print('Incremented user project count');
    } catch (e) {
      print('Error incrementing user project count: $e');
    }
  }

  Future<void> deleteHistoryItem(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Delete from Firestore if logged in
      if (_authService.isLoggedIn) {
        final userId = _authService.currentUser!.uid;
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('history')
            .doc(id)
            .delete();

        print('Deleted history item from Firestore: $id');
      }

      // Remove from local history
      _promptHistory.removeWhere((item) => item['id'] == id);

      // Update SharedPreferences
      await _savePromptHistoryToPrefs();

      notifyListeners();
      print('Deleted history item: $id');
    } catch (e) {
      print('Error deleting history item: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearHistory() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Clear from Firestore if logged in
      if (_authService.isLoggedIn) {
        final userId = _authService.currentUser!.uid;
        final batch = _firestore.batch();

        final snapshot = await _firestore
            .collection('users')
            .doc(userId)
            .collection('history')
            .get();

        for (var doc in snapshot.docs) {
          batch.delete(doc.reference);
        }

        await batch.commit();
        print('Cleared all history from Firestore');
      }

      // Clear local history
      _promptHistory.clear();

      // Clear SharedPreferences
      await _prefs.remove(_historyKey);

      notifyListeners();
      print('History cleared');
    } catch (e) {
      print('Error clearing history: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _prefs.setString('themeMode', mode.toString().split('.').last);
    notifyListeners();
  }

  Future<bool> setApiKey(String apiKey) async {
    try {
      // Save API key to Firestore if logged in
      if (_authService.isLoggedIn) {
        final success = await _authService.saveApiKey(apiKey);
        if (!success) return false;
      }

      // Initialize Gemini service with the new API key
      await _geminiService.initialize(apiKey: apiKey);

      _hasApiKey = true;
      notifyListeners();
      return true;
    } catch (e) {
      print('Error setting API key: $e');
      return false;
    }
  }

  Future<void> reloadTokens() async {
    print('🔄 [RELOAD TOKENS] reloadTokens() called');

    if (!_authService.isLoggedIn) {
      print('⚠️ [RELOAD TOKENS] User not logged in');
      return;
    }

    try {
      print('🪙 [RELOAD TOKENS] Fetching tokens from Firestore...');
      final tokens = await _authService.getUserTokens();
      print('🪙 [RELOAD TOKENS] Tokens fetched: $tokens');

      _tokens = tokens;
      notifyListeners();

      print('✅ [RELOAD TOKENS] Tokens reloaded successfully: $_tokens');
    } catch (e) {
      print('❌ [RELOAD TOKENS] Error reloading tokens: $e');
    }
  }

  void setTokens(int tokens) {
    print('🪙 [SET TOKENS] setTokens() called');
    print('🪙 [SET TOKENS] Old tokens: $_tokens → New tokens: $tokens');
    _tokens = tokens;
    notifyListeners();
    print('✅ [SET TOKENS] Tokens updated and listeners notified');
  }

  void addTokens(int amount) {
    print('🪙 [ADD TOKENS] addTokens() called with amount: $amount');
    print(
      '🪙 [ADD TOKENS] Old tokens: $_tokens → New tokens: ${_tokens + amount}',
    );
    _tokens += amount;
    notifyListeners();
    print('✅ [ADD TOKENS] Tokens updated and listeners notified');
  }

  // Save streaming result to history
  Future<Map<String, bool>> saveStreamingResult(
    PromptRequest request,
    String fullText, {
    bool shareWithCommunity = false,
  }) async {
    print('💾 [STREAMING SAVE] saveStreamingResult() called');

    final result = {'saved': false, 'shared': false};

    if (!_authService.isLoggedIn) {
      print('⚠️ [STREAMING SAVE] User not logged in');
      return result;
    }

    try {
      // Create response object
      final response = PromptResponse(
        summary: fullText,
        techStackExplanation: '',
        features: [],
        uiLayout: '',
        folderStructure: '',
      );

      print('📝 [STREAMING SAVE] Created response object');

      // Prepare data
      final timestamp = DateTime.now().toIso8601String();
      final promptData = {
        'request': request.toJson(),
        'response': response.toJson(),
        'timestamp': timestamp,
      };

      print('📦 [STREAMING SAVE] Prepared prompt data');

      // Save to Firestore
      final userId = _authService.currentUser!.uid;
      print('👤 [STREAMING SAVE] User ID: $userId');

      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('history')
          .add(promptData);

      print('✅ [STREAMING SAVE] Saved to Firestore with ID: ${docRef.id}');
      result['saved'] = true;

      // Deduct token
      print('🪙 [STREAMING SAVE] Deducting token...');
      await _deductToken();
      print('✅ [STREAMING SAVE] Token deducted');

      // Save to community if enabled
      if (shareWithCommunity) {
        print('🌍 [STREAMING SAVE] Sharing with community...');
        await _savePromptToCommunity(promptData);
        result['shared'] = true;
        print('✅ [STREAMING SAVE] Shared with community');
      } else {
        print('🚫 [STREAMING SAVE] Community sharing disabled');
      }

      // Increment project count
      print('📊 [STREAMING SAVE] Incrementing project count...');
      await _incrementUserProjectCount();
      print('✅ [STREAMING SAVE] Project count incremented');

      // Reload history
      await _loadPromptHistory();
      print('🔄 [STREAMING SAVE] Reloaded history');

      print('✅ [STREAMING SAVE] Save complete!');
    } catch (e) {
      print('❌ [STREAMING SAVE] Error: $e');
    }

    return result;
  }
}
