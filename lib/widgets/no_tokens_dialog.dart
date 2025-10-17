import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class NoTokensDialog extends StatelessWidget {
  const NoTokensDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary.withValues(alpha: 0.9),
              colorScheme.secondary.withValues(alpha: 0.9),
            ],
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(8),
            bottomLeft: Radius.circular(8),
            bottomRight: Radius.circular(40),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 15,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Token Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: SizedBox(
                width: 48,
                height: 48,
                child: Lottie.asset(
                  'assets/lottie/DevAi.json',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Title
            Text(
              'No DevTokens Available',
              style: TextStyle(
                color: colorScheme.onPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            // Description
            Text(
              'You need at least 1 DevToken to generate a prompt.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onPrimary.withValues(alpha: 0.9),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            // Options
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildOption(
                  context,
                  'Get Tokens',
                  Icons.card_giftcard_rounded,
                  () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pushNamed(context, '/promo-code');
                  },
                ),
                const SizedBox(width: 16),
                _buildOption(
                  context,
                  'Close',
                  Icons.close_rounded,
                  () => Navigator.pop(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: colorScheme.surface.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.onPrimary.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: colorScheme.onPrimary, size: 24),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
