import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/prompt_request.dart';
import '../models/prompt_response.dart';
import '../constants/app_constants.dart';

class CommunityPromptDetailScreen extends StatefulWidget {
  final String promptId;
  final PromptRequest request;
  final PromptResponse response;
  final String displayName;
  final String? photoURL;
  final int views;
  final int likes;

  const CommunityPromptDetailScreen({
    super.key,
    required this.promptId,
    required this.request,
    required this.response,
    required this.displayName,
    this.photoURL,
    required this.views,
    required this.likes,
  });

  @override
  State<CommunityPromptDetailScreen> createState() =>
      _CommunityPromptDetailScreenState();
}

class _CommunityPromptDetailScreenState
    extends State<CommunityPromptDetailScreen> {
  bool _isLiked = false;
  bool _isCopied = false;
  bool _checkingLikeStatus = true;
  bool _isContentUnlocked = false;
  bool _isUnlocking = false;
  bool _checkingUnlockStatus = true;
  int _userTokens = 0;
  late Stream<DocumentSnapshot> _promptStream;
  late Stream<DocumentSnapshot> _userTokenStream;
  Stream<DocumentSnapshot>? _likeStatusStream;
  Stream<DocumentSnapshot>? _unlockStatusStream;

  @override
  void initState() {
    super.initState();
    _setupStreams();
    _checkIfAlreadyUnlocked();
  }

  void _setupStreams() {
    // Set up stream for real-time prompt updates
    _promptStream = FirebaseFirestore.instance
        .collection('community_prompts')
        .doc(widget.promptId)
        .snapshots();

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      // Set up stream for real-time like status updates
      _likeStatusStream = FirebaseFirestore.instance
          .collection('user_likes')
          .doc(userId)
          .collection('liked_prompts')
          .doc(widget.promptId)
          .snapshots();

      // Set up stream for user tokens
      _userTokenStream = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .snapshots();

      // Set up stream for unlock status
      _unlockStatusStream = FirebaseFirestore.instance
          .collection('user_unlocked')
          .doc(userId)
          .collection('unlocked_prompts')
          .doc(widget.promptId)
          .snapshots();
    } else {
      setState(() {
        _checkingLikeStatus = false;
        _checkingUnlockStatus = false;
      });
    }
  }

  Future<void> _checkIfAlreadyUnlocked() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      setState(() {
        _checkingUnlockStatus = false;
      });
      return;
    }

    try {
      final unlockDoc = await FirebaseFirestore.instance
          .collection('user_unlocked')
          .doc(userId)
          .collection('unlocked_prompts')
          .doc(widget.promptId)
          .get();

      setState(() {
        _isContentUnlocked = unlockDoc.exists;
        _checkingUnlockStatus = false;
      });
    } catch (e) {
      print('Error checking unlock status: $e');
      setState(() {
        _checkingUnlockStatus = false;
      });
    }
  }

  Future<void> _toggleLike() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You need to be logged in to like prompts'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _checkingLikeStatus = true;
    });

    try {
      final userLikesRef = FirebaseFirestore.instance
          .collection('user_likes')
          .doc(userId)
          .collection('liked_prompts')
          .doc(widget.promptId);

      final promptRef = FirebaseFirestore.instance
          .collection('community_prompts')
          .doc(widget.promptId);

      // Check current state to determine action
      final likeDoc = await userLikesRef.get();
      final bool currentlyLiked = likeDoc.exists;

      // Use a batch to ensure atomicity
      final batch = FirebaseFirestore.instance.batch();

      if (currentlyLiked) {
        // Unlike: Remove from user_likes and decrement count
        batch.delete(userLikesRef);
        batch.update(promptRef, {'likes': FieldValue.increment(-1)});
      } else {
        // Like: Add to user_likes and increment count
        batch.set(userLikesRef, {'timestamp': FieldValue.serverTimestamp()});
        batch.update(promptRef, {'likes': FieldValue.increment(1)});
      }

      await batch.commit();
      setState(() {
        _checkingLikeStatus = false;
      });
    } catch (e) {
      print('Error toggling like: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating like status: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      setState(() {
        _checkingLikeStatus = false;
      });
    }
  }

  Future<void> _unlockContent() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You need to be logged in to unlock content'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_userTokens < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You need at least 1 token to unlock this content'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _isUnlocking = true;
    });

    try {
      // Use a batch to ensure atomicity
      final batch = FirebaseFirestore.instance.batch();

      // Deduct 1 token from user's account
      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId);

      batch.update(userRef, {'tokens': FieldValue.increment(-1)});

      // Add prompt to user's unlocked prompts collection
      final unlockedPromptRef = FirebaseFirestore.instance
          .collection('user_unlocked')
          .doc(userId)
          .collection('unlocked_prompts')
          .doc(widget.promptId);

      batch.set(unlockedPromptRef, {
        'timestamp': FieldValue.serverTimestamp(),
        'promptId': widget.promptId,
      });

      await batch.commit();

      setState(() {
        _isContentUnlocked = true;
        _isUnlocking = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Content unlocked! 1 token used'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error unlocking content: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error unlocking content: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: Duration(seconds: 2),
        ),
      );
      setState(() {
        _isUnlocking = false;
      });
    }
  }

  void _copyPrompt() {
    final promptText = _formatPromptForCopy();
    Clipboard.setData(ClipboardData(text: promptText));

    setState(() {
      _isCopied = true;
    });

    // Reset copy status after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isCopied = false;
        });
      }
    });
  }

  String _formatPromptForCopy() {
    return '''
PROJECT: ${widget.request.projectName}
PLATFORM: ${widget.request.platform}
TECH STACK: ${widget.request.techStack}
DESCRIPTION: ${widget.request.topic}

PROJECT DESCRIPTION:
${widget.response.summary}

PAGES/SCREENS:
${widget.response.techStackExplanation}

KEY FEATURES:
${widget.response.features.map((f) => '- $f').join('\n')}

UI DESIGN:
${widget.response.uiLayout}

FOLDER STRUCTURE:
${widget.response.folderStructure}

Generated by DevAi
''';
  }

  String _formatPrompt() {
    return '''
# Project Description
${widget.response.summary}

# Pages/Screens
${widget.response.techStackExplanation}

# Key Features
${widget.response.features.map((f) => '- $f').join('\n')}

# UI Design
${widget.response.uiLayout}

# Folder Structure
```
${widget.response.folderStructure}
```
''';
  }

  String _formatLockedPreview() {
    // Show more content in the preview to give users a better idea
    return '''
# Project Description
${widget.response.summary}

# Pages/Screens
${widget.response.techStackExplanation.length > 150 ? widget.response.techStackExplanation.substring(0, 150) + '...' : widget.response.techStackExplanation}

# Key Features
${widget.response.features.take(2).map((f) => '- $f').join('\n')}
${widget.response.features.length > 2 ? '- ...' : ''}

# UI Design
${widget.response.uiLayout.length > 100 ? widget.response.uiLayout.substring(0, 100) + '...' : widget.response.uiLayout}

# Folder Structure
```
${widget.response.folderStructure.split('\n').take(5).join('\n')}
...
```
''';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return StreamBuilder<DocumentSnapshot>(
      stream: _promptStream,
      builder: (context, promptSnapshot) {
        // Initialize with widget values
        int currentViews = widget.views;
        int currentLikes = widget.likes;

        // Update with real-time data if available
        if (promptSnapshot.hasData &&
            promptSnapshot.data != null &&
            promptSnapshot.data!.exists) {
          final data = promptSnapshot.data!.data() as Map<String, dynamic>?;
          if (data != null) {
            currentViews = data['views'] as int? ?? widget.views;
            currentLikes = data['likes'] as int? ?? widget.likes;
          }
        }

        return StreamBuilder<DocumentSnapshot>(
          stream: _likeStatusStream,
          builder: (context, likeSnapshot) {
            // Update like status from stream
            if (likeSnapshot.connectionState == ConnectionState.active) {
              _isLiked =
                  likeSnapshot.hasData &&
                  likeSnapshot.data != null &&
                  likeSnapshot.data!.exists;
              _checkingLikeStatus = false;
            }

            return StreamBuilder<DocumentSnapshot>(
              stream: _userTokenStream,
              builder: (context, tokenSnapshot) {
                // Update token count from stream
                if (tokenSnapshot.hasData &&
                    tokenSnapshot.data != null &&
                    tokenSnapshot.data!.exists) {
                  final userData =
                      tokenSnapshot.data!.data() as Map<String, dynamic>?;
                  if (userData != null) {
                    _userTokens = userData['tokens'] as int? ?? 0;
                  }
                }

                return StreamBuilder<DocumentSnapshot>(
                  stream: _unlockStatusStream,
                  builder: (context, unlockSnapshot) {
                    // Update unlock status from stream
                    if (unlockSnapshot.connectionState ==
                        ConnectionState.active) {
                      _isContentUnlocked =
                          unlockSnapshot.hasData &&
                          unlockSnapshot.data != null &&
                          unlockSnapshot.data!.exists;
                      _checkingUnlockStatus = false;
                    }

                    // Show loading indicator while checking unlock status
                    if (_checkingUnlockStatus) {
                      return const Scaffold(
                        body: Center(child: CircularProgressIndicator()),
                      );
                    }

                    return Scaffold(
                      appBar: AppBar(
                        title: Text(
                          widget.request.projectName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        elevation: 0,
                        actions: [
                          // Token count display with Lottie animation
                          Container(
                            margin: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 8,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  colorScheme.primaryContainer,
                                  colorScheme.secondaryContainer,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.primary.withValues(
                                    alpha: 0.3,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: Lottie.asset(
                                    'assets/lottie/DevAi.json',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '$_userTokens',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_isContentUnlocked)
                            IconButton(
                              icon: Icon(
                                _isCopied
                                    ? Icons.check_circle
                                    : Icons.copy_rounded,
                                color: _isCopied ? Colors.green : null,
                              ),
                              onPressed: _copyPrompt,
                              tooltip: 'Copy prompt',
                            ),
                          IconButton(
                            icon: _checkingLikeStatus
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: colorScheme.onSurface.withValues(
                                        alpha: 0.6,
                                      ),
                                    ),
                                  )
                                : Icon(
                                    _isLiked
                                        ? Icons.favorite
                                        : Icons.favorite_border_rounded,
                                    color: _isLiked ? Colors.red : null,
                                  ),
                            onPressed: _checkingLikeStatus ? null : _toggleLike,
                            tooltip: _isLiked ? 'Unlike' : 'Like',
                          ),
                        ],
                      ),
                      // Remove the floating action button and place the unlock button in the center of the screen
                      body: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              colorScheme.primary.withValues(alpha: 0.05),
                              colorScheme.secondary.withValues(alpha: 0.05),
                            ],
                          ),
                        ),
                        child: SafeArea(
                          child: Stack(
                            children: [
                              Column(
                                children: [
                                  // User info card - Modern design
                                  Container(
                                    margin: const EdgeInsets.all(20),
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: colorScheme.surface,
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(
                                        color: colorScheme.outline.withValues(
                                          alpha: 0.2,
                                        ),
                                        width: 1.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: colorScheme.shadow.withValues(
                                            alpha: 0.1,
                                          ),
                                          blurRadius: 15,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        // Avatar with glow
                                        Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: colorScheme.primary
                                                    .withValues(alpha: 0.3),
                                                blurRadius: 10,
                                                spreadRadius: 2,
                                              ),
                                            ],
                                          ),
                                          child: CircleAvatar(
                                            radius: 28,
                                            backgroundColor:
                                                colorScheme.primaryContainer,
                                            backgroundImage:
                                                widget.photoURL != null
                                                ? NetworkImage(widget.photoURL!)
                                                : null,
                                            child: widget.photoURL == null
                                                ? Text(
                                                    widget.displayName[0]
                                                        .toUpperCase(),
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 20,
                                                      color: colorScheme
                                                          .onPrimaryContainer,
                                                    ),
                                                  )
                                                : null,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                widget.displayName,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 17,
                                                  color: colorScheme.onSurface,
                                                  letterSpacing: 0.3,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: colorScheme
                                                      .secondaryContainer
                                                      .withValues(alpha: 0.5),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  '${widget.request.platform} • ${widget.request.techStack}',
                                                  style: TextStyle(
                                                    color: colorScheme
                                                        .onSecondaryContainer,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 6,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: colorScheme
                                                    .surfaceContainerHighest,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.visibility_rounded,
                                                    size: 16,
                                                    color: colorScheme.onSurface
                                                        .withValues(alpha: 0.7),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '$currentViews',
                                                    style: TextStyle(
                                                      color: colorScheme
                                                          .onSurface
                                                          .withValues(
                                                            alpha: 0.7,
                                                          ),
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 6,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: _isLiked
                                                    ? Colors.red.withValues(
                                                        alpha: 0.1,
                                                      )
                                                    : colorScheme
                                                          .surfaceContainerHighest,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    _isLiked
                                                        ? Icons.favorite
                                                        : Icons.favorite_border,
                                                    size: 16,
                                                    color: _isLiked
                                                        ? Colors.red
                                                        : colorScheme.onSurface
                                                              .withValues(
                                                                alpha: 0.7,
                                                              ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '$currentLikes',
                                                    style: TextStyle(
                                                      color: _isLiked
                                                          ? Colors.red
                                                          : colorScheme
                                                                .onSurface
                                                                .withValues(
                                                                  alpha: 0.7,
                                                                ),
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Project details - Modern card
                                  Expanded(
                                    child: Container(
                                      margin: const EdgeInsets.fromLTRB(
                                        20,
                                        0,
                                        20,
                                        20,
                                      ),
                                      decoration: BoxDecoration(
                                        color: colorScheme.surface,
                                        borderRadius: BorderRadius.circular(24),
                                        border: Border.all(
                                          color: colorScheme.outline.withValues(
                                            alpha: 0.2,
                                          ),
                                          width: 1.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: colorScheme.shadow
                                                .withValues(alpha: 0.1),
                                            blurRadius: 15,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(24),
                                        child: Padding(
                                          padding: const EdgeInsets.all(24),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Project title and description
                                              Text(
                                                widget.request.projectName,
                                                style: TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                  color: colorScheme.primary,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                widget.request.topic,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: colorScheme.onSurface,
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                              // Prompt content
                                              Expanded(
                                                child: Stack(
                                                  children: [
                                                    SingleChildScrollView(
                                                      physics:
                                                          const BouncingScrollPhysics(),
                                                      child: MarkdownBody(
                                                        data: _isContentUnlocked
                                                            ? _formatPrompt()
                                                            : _formatLockedPreview(),
                                                        styleSheet: MarkdownStyleSheet(
                                                          p: AppConstants
                                                              .monoTextStyle
                                                              .copyWith(
                                                                height: 1.5,
                                                              ),
                                                          code: AppConstants
                                                              .monoTextStyle
                                                              .copyWith(
                                                                backgroundColor:
                                                                    colorScheme
                                                                        .surfaceVariant,
                                                                height: 1.5,
                                                              ),
                                                          codeblockDecoration:
                                                              BoxDecoration(
                                                                color: colorScheme
                                                                    .surfaceVariant,
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      8,
                                                                    ),
                                                              ),
                                                          h1: TextStyle(
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: colorScheme
                                                                .primary,
                                                            height: 2,
                                                          ),
                                                          listBullet: TextStyle(
                                                            color: colorScheme
                                                                .primary,
                                                            height: 1.5,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    if (!_isContentUnlocked)
                                                      Positioned(
                                                        bottom: 0,
                                                        left: 0,
                                                        right: 0,
                                                        child: Container(
                                                          height: 150,
                                                          decoration: BoxDecoration(
                                                            gradient: LinearGradient(
                                                              begin: Alignment
                                                                  .topCenter,
                                                              end: Alignment
                                                                  .bottomCenter,
                                                              colors: [
                                                                colorScheme
                                                                    .surface
                                                                    .withOpacity(
                                                                      0.0,
                                                                    ),
                                                                colorScheme
                                                                    .surface
                                                                    .withValues(
                                                                      alpha:
                                                                          0.9,
                                                                    ),
                                                              ],
                                                            ),
                                                          ),
                                                          child: Center(
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Icon(
                                                                  Icons.lock,
                                                                  size: 40,
                                                                  color: colorScheme
                                                                      .primary,
                                                                ),
                                                                const SizedBox(
                                                                  height: 8,
                                                                ),
                                                                Text(
                                                                  'Full Content Locked',
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        18,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: colorScheme
                                                                        .primary,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  height: 4,
                                                                ),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Text(
                                                                      'Unlock for ',
                                                                      style: TextStyle(
                                                                        fontSize:
                                                                            14,
                                                                        color: colorScheme
                                                                            .onSurface
                                                                            .withValues(
                                                                              alpha: 0.8,
                                                                            ),
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      width: 20,
                                                                      height:
                                                                          20,
                                                                      child: Lottie.asset(
                                                                        'assets/lottie/DevAi.json',
                                                                        fit: BoxFit
                                                                            .cover,
                                                                      ),
                                                                    ),
                                                                    Text(
                                                                      '1 token',
                                                                      style: TextStyle(
                                                                        fontSize:
                                                                            14,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color: colorScheme
                                                                            .primary,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
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
                                ],
                              ),
                              // Centered unlock button - Modern design
                              if (!_isContentUnlocked)
                                Positioned.fill(
                                  child: Center(
                                    child: Container(
                                      margin: const EdgeInsets.only(top: 100),
                                      child: FilledButton(
                                        onPressed: _isUnlocking
                                            ? null
                                            : _unlockContent,
                                        style: FilledButton.styleFrom(
                                          backgroundColor: _userTokens < 1
                                              ? colorScheme
                                                    .surfaceContainerHighest
                                              : colorScheme.primary,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 32,
                                            vertical: 18,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          elevation: 8,
                                        ),
                                        child: _isUnlocking
                                            ? const Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child:
                                                        CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          color: Colors.white,
                                                        ),
                                                  ),
                                                  SizedBox(width: 12),
                                                  Text('Unlocking...'),
                                                ],
                                              )
                                            : Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    _userTokens < 1
                                                        ? Icons.lock_rounded
                                                        : Icons
                                                              .lock_open_rounded,
                                                    size: 22,
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Text(
                                                    _userTokens < 1
                                                        ? 'Need 1 Token'
                                                        : 'Unlock Content',
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  if (_userTokens >= 1) ...[
                                                    const SizedBox(width: 12),
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 10,
                                                            vertical: 4,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white
                                                            .withValues(
                                                              alpha: 0.3,
                                                            ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          SizedBox(
                                                            width: 18,
                                                            height: 18,
                                                            child: Lottie.asset(
                                                              'assets/lottie/DevAi.json',
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 4,
                                                          ),
                                                          const Text(
                                                            '1',
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
