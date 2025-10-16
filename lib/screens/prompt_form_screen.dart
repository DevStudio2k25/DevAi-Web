import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../constants/app_constants.dart';
import '../models/prompt_request.dart';
import '../models/prompt_response.dart';
import '../providers/app_provider.dart';
import '../screens/chat_result_screen.dart';
import '../screens/project_ideas_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/all_users_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/no_tokens_dialog.dart';

class PromptFormScreen extends StatefulWidget {
  final String? initialProjectName;
  final String? initialProjectDescription;

  const PromptFormScreen({
    super.key,
    this.initialProjectName,
    this.initialProjectDescription,
  });

  @override
  State<PromptFormScreen> createState() => _PromptFormScreenState();
}

class _PromptFormScreenState extends State<PromptFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _topicController = TextEditingController();
  final _nameController = TextEditingController();
  String _selectedPlatform = AppConstants.platforms.first;
  String _selectedTechStack = AppConstants.techStacks['App']!.first;
  List<Map<String, dynamic>> _topUsers = [];
  bool _loadingTopUsers = false;
  bool _isLoading = false;
  String _prompt = '';
  bool _shareWithCommunity = false; // Default to not sharing with community

  // Stream for total user count
  Stream<int> get _userCountStream => FirebaseFirestore.instance
      .collection('users')
      .snapshots()
      .map((snapshot) => snapshot.size);

  // Stream for user tokens
  Stream<int> get _userTokensStream {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return Stream.value(0);

    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.data()?['tokens'] ?? 0);
  }

  @override
  void initState() {
    super.initState();
    _fetchTopUsers();

    // Pre-fill controllers if initial values are provided
    if (widget.initialProjectName != null) {
      _nameController.text = widget.initialProjectName!;
    }
    if (widget.initialProjectDescription != null) {
      _topicController.text = widget.initialProjectDescription!;
    }
  }

  @override
  void dispose() {
    _topicController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _fetchTopUsers() async {
    setState(() {
      _loadingTopUsers = true;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .orderBy('projectCount', descending: true)
          .limit(10)
          .get();

      setState(() {
        _topUsers = snapshot.docs.map((doc) {
          return {
            'id': doc.id,
            'displayName': doc.data()['displayName'] ?? 'Anonymous',
            'photoURL': doc.data()['photoURL'],
            'projectCount': doc.data()['projectCount'] ?? 0,
          };
        }).toList();
        _loadingTopUsers = false;
      });
    } catch (e) {
      print('Error fetching top users: $e');
      setState(() {
        _loadingTopUsers = false;
      });
    }
  }

  void _updateTechStackOptions(String platform) {
    setState(() {
      _selectedPlatform = platform;
      _selectedTechStack = AppConstants.techStacks[platform]!.first;
    });
  }

  Future<void> _generatePrompt() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        // Check and deduct token first
        print('Checking and deducting token');
        final hasToken = await _checkAndDeductToken();
        if (!hasToken) {
          print('No token available or token deduction failed');
          return;
        }
        print('Token deducted successfully');

        final request = PromptRequest(
          topic: _topicController.text.trim(),
          platform: _selectedPlatform,
          techStack: _selectedTechStack,
          projectName: _nameController.text.trim(),
        );
        print('Created prompt request: ${request.projectName}');

        final projectName = _nameController.text.trim();

        print('Generating prompt via AppProvider');
        final Future<PromptResponse> responseFuture = Provider.of<AppProvider>(
          context,
          listen: false,
        ).generatePrompt(request, shareWithCommunity: _shareWithCommunity);

        if (!mounted) return;

        print('Navigating to ChatResultScreen');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatResultScreen.fromFuture(
              responseFuture: responseFuture,
              projectName: projectName,
            ),
          ),
        );
      } catch (e) {
        print('Error in _generatePrompt: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error generating prompt: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _navigateToProjectIdeas() async {
    final result = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(builder: (context) => const ProjectIdeasScreen()),
    );

    if (result != null) {
      setState(() {
        _nameController.text = result['name'] ?? '';
        _topicController.text = result['description'] ?? '';
      });
    }
  }

  Future<bool> _checkAndDeductToken() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return false;

    try {
      // Get user document
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      final tokens = userDoc.data()?['tokens'] ?? 0;

      if (tokens < 1) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => const NoTokensDialog(),
          );
        }
        return false;
      }

      // Deduct token
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'tokens': FieldValue.increment(-1),
      });

      return true;
    } catch (e) {
      print('Error checking/deducting token: $e');
      return false;
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    // Check and deduct token
    final hasToken = await _checkAndDeductToken();
    if (!hasToken) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      // Create prompt document
      await FirebaseFirestore.instance.collection('prompts').add({
        'userId': userId,
        'prompt': _prompt,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending',
      });

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error submitting prompt: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colorScheme.primary, colorScheme.secondary],
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.4),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _generatePrompt,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 26,
                    height: 26,
                    child: Lottie.asset(
                      'assets/lottie/DevAi.json',
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Generate',
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.onPrimary.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 14,
                          height: 14,
                          child: Lottie.asset(
                            'assets/lottie/DevAi.json',
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '1',
                          style: TextStyle(
                            color: colorScheme.onPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primary.withOpacity(0.8),
                    colorScheme.secondary.withOpacity(0.9),
                  ],
                ),
              ),
            ),
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 40,
                  height: 40,
                  child: Lottie.asset(
                    'assets/lottie/DevAi.json',
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 10),
                const Text('DevAi'),
                const Spacer(),
                // Token count display
                StreamBuilder<int>(
                  stream: _userTokensStream,
                  builder: (context, snapshot) {
                    final tokens = snapshot.data ?? 0;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Lottie.asset(
                              'assets/lottie/DevAi.json',
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$tokens',
                            style: TextStyle(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primary.withOpacity(0.8),
                    colorScheme.secondary.withOpacity(0.9),
                  ],
                ),
              ),
              child: Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surface.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'What would you like to build?',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          color: colorScheme.onSurface,
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 24),
                                  TextFormField(
                                    controller: _nameController,
                                    decoration: InputDecoration(
                                      labelText: 'Project Name',
                                      hintText: 'e.g., TaskMaster, FitTrack',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(
                                          color: colorScheme.outline,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(
                                          color: colorScheme.outline.withValues(
                                            alpha: 0.3,
                                          ),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(
                                          color: colorScheme.primary,
                                          width: 2,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: colorScheme.surface.withValues(
                                        alpha: 0.5,
                                      ),
                                      prefixIcon: Icon(
                                        Icons.title_rounded,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Please enter a project name';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 24),
                                  TextFormField(
                                    controller: _topicController,
                                    decoration: InputDecoration(
                                      labelText: 'Project Description',
                                      hintText:
                                          'e.g., A task management app with reminders',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(
                                          color: colorScheme.outline,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(
                                          color: colorScheme.outline.withValues(
                                            alpha: 0.3,
                                          ),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(
                                          color: colorScheme.primary,
                                          width: 2,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: colorScheme.surface.withValues(
                                        alpha: 0.5,
                                      ),
                                      prefixIcon: Icon(
                                        Icons.lightbulb_outline_rounded,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Please enter a project description';
                                      }
                                      return null;
                                    },
                                    maxLines: 3,
                                  ),
                                  const SizedBox(height: 24),
                                  _buildCustomDropdown(
                                    label: 'Platform',
                                    value: _selectedPlatform,
                                    items: AppConstants.platforms,
                                    icon: Icons.devices,
                                    onChanged: (value) {
                                      if (value != null) {
                                        _updateTechStackOptions(value);
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 24),
                                  _buildCustomDropdown(
                                    label: 'Tech Stack',
                                    value: _selectedTechStack,
                                    items: AppConstants
                                        .techStacks[_selectedPlatform]!,
                                    icon: Icons.code,
                                    onChanged: (value) {
                                      if (value != null) {
                                        setState(() {
                                          _selectedTechStack = value;
                                        });
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 24),
                                  // Share with Community Toggle
                                  Container(
                                    decoration: BoxDecoration(
                                      color: colorScheme.surface.withOpacity(
                                        0.5,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: colorScheme.outline.withOpacity(
                                          0.3,
                                        ),
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.people,
                                          color: colorScheme.primary,
                                          size: 24,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Share with Community',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: colorScheme.onSurface,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Allow others to see and learn from your prompt',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: colorScheme.onSurface
                                                      .withOpacity(0.7),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Switch(
                                          value: _shareWithCommunity,
                                          onChanged: (value) {
                                            setState(() {
                                              _shareWithCommunity = value;
                                            });
                                          },
                                          activeColor: colorScheme.primary,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomDropdown({
    required String label,
    required String value,
    required List<String> items,
    required IconData icon,
    required void Function(String?) onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Theme(
      data: Theme.of(context).copyWith(
        popupMenuTheme: PopupMenuThemeData(
          elevation: 15,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: colorScheme.outline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: colorScheme.primary, width: 2),
          ),
          filled: true,
          fillColor: colorScheme.surface.withValues(alpha: 0.5),
          prefixIcon: Icon(icon, color: colorScheme.primary),
        ),
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Container(
              constraints: const BoxConstraints(minWidth: 200),
              child: Text(
                item,
                style: TextStyle(
                  fontWeight: item == value ? FontWeight.bold : FontWeight.w500,
                  color: item == value
                      ? colorScheme.primary
                      : colorScheme.onSurface,
                  fontSize: 16,
                ),
              ),
            ),
          );
        }).toList(),
        onChanged: onChanged,
        icon: Icon(
          Icons.arrow_drop_down_circle_rounded,
          color: colorScheme.primary,
        ),
        iconSize: 26,
        elevation: 16,
        dropdownColor: colorScheme.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        menuMaxHeight: 300,
        style: TextStyle(color: colorScheme.onSurface, fontSize: 16),
      ),
    );
  }
}

// New screen to handle the loading state and response
class ResultScreen extends StatelessWidget {
  final Future<PromptResponse> responseFuture;
  final String projectName;

  const ResultScreen({
    super.key,
    required this.responseFuture,
    required this.projectName,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PromptResponse>(
      future: responseFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingScreen(context);
        } else if (snapshot.hasError) {
          return _buildErrorScreen(context, snapshot.error.toString());
        } else if (snapshot.hasData) {
          return ChatResultScreen(
            response: snapshot.data!,
            projectName: projectName,
          );
        } else {
          return _buildErrorScreen(context, "Unknown error occurred");
        }
      },
    );
  }

  Widget _buildLoadingScreen(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(projectName),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.8),
              Theme.of(context).colorScheme.secondary.withOpacity(0.9),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surface.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 60,
                              height: 60,
                              child: Lottie.asset(
                                'assets/lottie/DevAi.json',
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'DevAi',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const CircularProgressIndicator(),
                        const SizedBox(height: 24),
                        Text(
                          'Generating your project...',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'This might take a moment',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.7),
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorScreen(BuildContext context, String error) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Error'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.8),
              Theme.of(context).colorScheme.secondary.withOpacity(0.9),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Theme.of(context).colorScheme.error,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error Occurred',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Go Back'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
