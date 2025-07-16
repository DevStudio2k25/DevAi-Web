import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../models/promo_code.dart';
import '../providers/app_provider.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/cached_network_image.dart';

class PromoCodeScreen extends StatefulWidget {
  const PromoCodeScreen({super.key});

  @override
  State<PromoCodeScreen> createState() => _PromoCodeScreenState();
}

class _PromoCodeScreenState extends State<PromoCodeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw 'User not authenticated';
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        throw 'User document not found';
      }

      setState(() {
        _userData = userDoc.data();
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load user data: $e';
      });
    }
  }

  void _showSuccessDialog(int tokenAmount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 150,
                height: 150,
                child: Lottie.asset(
                  'assets/lottie/DevAi.json',
                  fit: BoxFit.cover,
                  repeat: true,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Congratulations! 🎉',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'You received',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: Lottie.asset(
                      'assets/lottie/DevAi.json',
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$tokenAmount',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'DevTokens!',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: const Text('Awesome!'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _redeemPromoCode() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw 'User not authenticated';
      }

      if (_userData == null) {
        throw 'User data not loaded';
      }

      final code = _codeController.text.trim().toUpperCase();

      // Get the promo code document
      final promoCodeQuery = await FirebaseFirestore.instance
          .collection('promo_codes')
          .where('code', isEqualTo: code)
          .limit(1)
          .get();

      if (promoCodeQuery.docs.isEmpty) {
        throw 'Invalid promo code';
      }

      final promoCodeDoc = promoCodeQuery.docs.first;
      final promoCodeData = promoCodeDoc.data();

      // Basic validations
      if (promoCodeData['isActive'] != true) {
        throw 'This promo code is no longer active';
      }

      final expiresAt = (promoCodeData['expiresAt'] as Timestamp).toDate();
      if (DateTime.now().isAfter(expiresAt)) {
        throw 'This promo code has expired';
      }

      // Get the list of users who have already used this code
      final usedByUsers = List<String>.from(promoCodeData['usedByUsers'] ?? []);

      // Check if current user has already used this code
      if (usedByUsers.contains(userId)) {
        HapticFeedback.vibrate(); // Add vibration feedback
        setState(() {
          _errorMessage = 'You have already redeemed this code!';
          _isLoading = false;
        });
        return;
      }

      // If user hasn't used the code, proceed with redemption
      try {
        // First update the user's tokens
        final tokenAmount = promoCodeData['tokenAmount'] ?? 0;
        await FirebaseFirestore.instance.collection('users').doc(userId).update(
          {'tokens': FieldValue.increment(tokenAmount)},
        );

        // If token update successful, then add user to usedByUsers array
        await promoCodeDoc.reference.update({
          'usedByUsers': FieldValue.arrayUnion([userId]),
        });

        // Update local token count
        if (!mounted) return;
        final appProvider = context.read<AppProvider>();
        appProvider.addTokens(tokenAmount);

        // Vibrate for success
        HapticFeedback.mediumImpact();

        // Show success dialog
        if (!mounted) return;
        _showSuccessDialog(tokenAmount);

        // Clear the form
        _codeController.clear();

        // Reload user data
        _loadUserData();
      } catch (e) {
        // Vibrate for error
        HapticFeedback.vibrate();

        setState(() {
          _errorMessage = 'Failed to redeem code: ${e.toString()}';
        });
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      // Vibrate for error
      HapticFeedback.vibrate();

      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Redeem Promo Code')),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // User Profile Card
                if (_userData != null) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // Profile Image and Basic Info
                          Row(
                            children: [
                              // Profile Image
                              CachedCircleAvatar(
                                radius: 30,
                                backgroundColor: colorScheme.primaryContainer,
                                imageUrl: user?.photoURL,
                                child: Icon(
                                  Icons.person,
                                  size: 30,
                                  color: colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Name and ID
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user?.displayName ?? 'Anonymous User',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: colorScheme.onSurface,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'ID: ${user?.uid ?? 'Not available'}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: colorScheme.onSurface
                                                .withOpacity(0.7),
                                            fontFamily: 'JetBrainsMono',
                                          ),
                                    ),
                                    if (_userData?['tokens'] != null) ...[
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: Lottie.asset(
                                              'assets/lottie/DevAi.json',
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${_userData?['tokens'] ?? 0}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color: colorScheme.primary,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Greeting Message
                if (user?.displayName != null) ...[
                  RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(color: colorScheme.onSurface),
                      children: [
                        TextSpan(
                          text: 'Hey ',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: '${user!.displayName!.split(' ')[0]}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(text: ' 👋'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ready to redeem your DevTokens?',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Promo Code Form
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Info Card
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              SizedBox(
                                width: 100,
                                height: 100,
                                child: Lottie.asset(
                                  'assets/lottie/DevAi.json',
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Enter your promo code to get free tokens!',
                                style: Theme.of(context).textTheme.titleMedium,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Error Message
                      if (_errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: colorScheme.error,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(color: colorScheme.error),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Promo Code Input
                      TextFormField(
                        controller: _codeController,
                        decoration: InputDecoration(
                          labelText: 'Promo Code',
                          hintText: 'Enter your promo code',
                          prefixIcon: SizedBox(
                            width: 24,
                            height: 24,
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Lottie.asset(
                                'assets/lottie/DevAi.json',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        textCapitalization: TextCapitalization.characters,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a promo code';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Submit Button
                      FilledButton.icon(
                        onPressed: _isLoading ? null : _redeemPromoCode,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                        ),
                        icon: SizedBox(
                          width: 24,
                          height: 24,
                          child: Lottie.asset(
                            'assets/lottie/DevAi.json',
                            fit: BoxFit.cover,
                          ),
                        ),
                        label: const Text('Redeem Code'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
