import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:simple_icons/simple_icons.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _version = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = 'Version ${packageInfo.version}';
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primary.withValues(alpha: 0.1),
              colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                floating: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: const Text(
                  'About DevAi',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              // Content
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // App Logo & Name
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.primary.withValues(
                                    alpha: 0.3,
                                  ),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Lottie.asset(
                              'assets/lottie/DevAi.json',
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'DevAi',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'AI-Powered Project Generator',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.7,
                                  ),
                                ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _version,
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Description
                    _buildCard(
                      context,
                      icon: Icons.info_outline,
                      title: 'What is DevAi?',
                      description:
                          'DevAi is an intelligent project planning assistant powered by Google Gemini AI. Generate comprehensive project documentation, architecture designs, and development roadmaps in minutes.',
                    ),
                    const SizedBox(height: 16),
                    // Features
                    _buildCard(
                      context,
                      icon: Icons.star_outline,
                      title: 'Key Features',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFeatureItem(
                            context,
                            '🤖 AI-Powered Generation',
                            'Smart project planning with Gemini AI',
                          ),
                          _buildDivider(context),
                          _buildFeatureItem(
                            context,
                            '📊 10-Phase Documentation',
                            'Complete project specs from overview to roadmap',
                          ),
                          _buildDivider(context),
                          _buildFeatureItem(
                            context,
                            '💡 140+ Project Ideas',
                            'Inspiration across gaming, web, mobile & more',
                          ),
                          _buildDivider(context),
                          _buildFeatureItem(
                            context,
                            '🌍 Community Sharing',
                            'Share and discover projects from others',
                          ),
                          _buildDivider(context),
                          _buildFeatureItem(
                            context,
                            '📝 History & Downloads',
                            'Save and export your generated projects',
                          ),
                          _buildDivider(context),
                          _buildFeatureItem(
                            context,
                            '🎯 Token System',
                            'Fair usage with token-based generation',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Tech Stack
                    _buildCard(
                      context,
                      icon: Icons.code,
                      title: 'Built With',
                      child: Column(
                        children: [
                          _buildTechItemWithIcon(
                            context,
                            icon: SimpleIcons.flutter,
                            iconColor: const Color(0xFF02569B),
                            title: 'Flutter',
                            description: 'Cross-platform UI framework',
                          ),
                          const SizedBox(height: 12),
                          _buildTechItemWithIcon(
                            context,
                            icon: SimpleIcons.firebase,
                            iconColor: const Color(0xFFFFCA28),
                            title: 'Firebase',
                            description: 'Backend & Authentication',
                          ),
                          const SizedBox(height: 12),
                          _buildTechItemWithIcon(
                            context,
                            icon: SimpleIcons.google,
                            iconColor: const Color(0xFF4285F4),
                            title: 'Google Gemini AI',
                            description: 'AI-powered project generation',
                          ),
                          const SizedBox(height: 12),
                          _buildTechItemWithIcon(
                            context,
                            icon: SimpleIcons.materialdesign,
                            iconColor: const Color(0xFF757575),
                            title: 'Material Design 3',
                            description: 'Modern UI/UX design system',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Developer Info
                    _buildCard(
                      context,
                      icon: Icons.person_outline,
                      title: 'Developer',
                      description: 'Made with ❤️ by DevStudio',
                    ),
                    const SizedBox(height: 16),
                    // Contact
                    _buildCard(
                      context,
                      icon: Icons.connect_without_contact,
                      title: 'Get in Touch',
                      child: Column(
                        children: [
                          _buildLinkButton(
                            context,
                            icon: Icons.email,
                            label: 'Email Us',
                            subtitle: 'devstudio2k25@gmail.com',
                            onTap: () =>
                                _launchURL('mailto:devstudio2k25@gmail.com'),
                          ),
                          const SizedBox(height: 8),
                          _buildLinkButton(
                            context,
                            icon: Icons.play_circle_outline,
                            label: 'YouTube Channel',
                            subtitle: 'Subscribe for tutorials & updates',
                            onTap: () => _launchURL(
                              'https://www.youtube.com/@DevStudio-2k25',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Footer
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'Made with ❤️ by DevStudio',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '© 2k25 DevAi. All rights reserved.',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? description,
    Widget? child,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: colorScheme.primary, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          if (description != null) ...[
            const SizedBox(height: 12),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
                height: 1.5,
              ),
            ),
          ],
          if (child != null) ...[const SizedBox(height: 12), child],
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Divider(
        color: colorScheme.outline.withValues(alpha: 0.2),
        thickness: 1,
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, String emoji, String text) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechItemWithIcon(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
