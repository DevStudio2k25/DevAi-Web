// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/prompt_request.dart';
import '../models/prompt_response.dart';
import '../providers/app_provider.dart';
import '../screens/chat_result_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final provider = Provider.of<AppProvider>(context);
    final history = provider.promptHistory;
    final isLoading = provider.isLoading;

    final filteredHistory = _searchQuery.isEmpty
        ? history
        : history.where((item) {
            final request = PromptRequest.fromJson(
              item['request'] as Map<String, dynamic>,
            );
            return request.projectName.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                request.topic.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                );
          }).toList();

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
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'History',
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${filteredHistory.length} projects',
                              style: TextStyle(
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (history.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Clear History'),
                                  content: const Text(
                                    'Delete all history? This cannot be undone.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Cancel'),
                                    ),
                                    FilledButton(
                                      onPressed: () {
                                        context
                                            .read<AppProvider>()
                                            .clearHistory();
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Clear'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: const Text('Clear All'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Search Bar
                    TextField(
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search history...',
                        filled: true,
                        fillColor: colorScheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // History List
              Expanded(
                child: isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: colorScheme.primary,
                        ),
                      )
                    : filteredHistory.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _searchQuery.isEmpty ? '📝' : '🔍',
                              style: const TextStyle(fontSize: 64),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'No history yet'
                                  : 'No results found',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            if (_searchQuery.isEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Generate projects to see them here',
                                style: TextStyle(
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: filteredHistory.length,
                        itemBuilder: (context, index) {
                          final item = filteredHistory[index];
                          final request = PromptRequest.fromJson(
                            item['request'] as Map<String, dynamic>,
                          );
                          final response = PromptResponse.fromJson(
                            item['response'] as Map<String, dynamic>,
                          );
                          final timestamp = DateTime.parse(
                            item['timestamp'] as String,
                          );
                          final itemId = item['id'] as String?;

                          return _buildHistoryCard(
                            context,
                            request,
                            response,
                            timestamp,
                            itemId,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryCard(
    BuildContext context,
    PromptRequest request,
    PromptResponse response,
    DateTime timestamp,
    String? itemId,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dismissible(
      key: Key(itemId ?? timestamp.toString()),
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: colorScheme.error.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Text(
          'Delete',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Item'),
            content: const Text('Delete this project from history?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        if (itemId != null && mounted) {
          context.read<AppProvider>().deleteHistoryItem(itemId);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatResultScreen(
                  response: response,
                  projectName: request.projectName,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        request.projectName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      _formatDate(timestamp),
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  request.topic,
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withValues(
                          alpha: 0.5,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        request.platform,
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.secondaryContainer.withValues(
                          alpha: 0.5,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        request.techStack,
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Stats and Download Button
                Row(
                  children: [
                    // Word Count
                    Icon(
                      Icons.text_fields_rounded,
                      size: 14,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_getWordCount(_getFullText(response))} words',
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Character Count
                    Icon(
                      Icons.abc_rounded,
                      size: 14,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_getFullText(response).length} chars',
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Line Count
                    Icon(
                      Icons.format_list_numbered_rounded,
                      size: 14,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_getLineCount(_getFullText(response))} lines',
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const Spacer(),
                    // Download Button
                    IconButton(
                      onPressed: () =>
                          _downloadAsTextFile(context, request, response),
                      icon: Icon(
                        Icons.download_rounded,
                        size: 20,
                        color: colorScheme.primary,
                      ),
                      tooltip: 'Download as .txt',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      style: IconButton.styleFrom(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _getFullText(PromptResponse response) {
    return '''
${response.summary}

${response.techStackExplanation}

${response.features.map((f) => '- $f').join('\n')}

${response.uiLayout}

${response.folderStructure}
''';
  }

  int _getWordCount(String text) {
    return text
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .length;
  }

  int _getLineCount(String text) {
    return text.split('\n').length;
  }

  Future<void> _downloadAsTextFile(
    BuildContext context,
    PromptRequest request,
    PromptResponse response,
  ) async {
    try {
      print('📥 [DOWNLOAD] Starting download...');

      final fullText =
          '''
PROJECT: ${request.projectName}
PLATFORM: ${request.platform}
TECH STACK: ${request.techStack}
DESCRIPTION: ${request.topic}

═══════════════════════════════════════════════════════════

PROJECT DESCRIPTION:
${response.summary}

═══════════════════════════════════════════════════════════

PAGES/SCREENS:
${response.techStackExplanation}

═══════════════════════════════════════════════════════════

KEY FEATURES:
${response.features.map((f) => '- $f').join('\n')}

═══════════════════════════════════════════════════════════

UI DESIGN:
${response.uiLayout}

═══════════════════════════════════════════════════════════

FOLDER STRUCTURE:
${response.folderStructure}

═══════════════════════════════════════════════════════════

Generated by DevAi
''';

      // Get temporary directory
      final directory = await getTemporaryDirectory();
      final fileName =
          '${request.projectName.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.txt';
      final filePath = '${directory.path}/$fileName';

      print('📝 [DOWNLOAD] Writing to file: $filePath');

      // Write to file
      final file = File(filePath);
      await file.writeAsString(fullText);

      print('✅ [DOWNLOAD] File written successfully');

      // Share the file
      await Share.shareXFiles(
        [XFile(filePath)],
        subject: 'DevAi - ${request.projectName}',
        text: 'Project details generated by DevAi',
      );

      print('✅ [DOWNLOAD] File shared successfully');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File ready to save!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('❌ [DOWNLOAD] Error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error downloading file: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
