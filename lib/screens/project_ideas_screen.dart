import 'package:flutter/material.dart';
import '../screens/prompt_form_screen.dart';

class ProjectIdeasScreen extends StatefulWidget {
  const ProjectIdeasScreen({super.key});

  @override
  State<ProjectIdeasScreen> createState() => _ProjectIdeasScreenState();
}

class _ProjectIdeasScreenState extends State<ProjectIdeasScreen> {
  String _searchQuery = '';
  String _selectedTag = 'All';

  final List<String> _tags = [
    'All',
    'AI/ML',
    'Blockchain',
    'IoT',
    'Cloud',
    'Mobile',
    'Web3',
    'AR/VR',
  ];

  final List<Map<String, dynamic>> _projects = [
    {
      'name': 'AI Code Review Assistant',
      'description':
          'Automated code review system using GPT-4 for pull requests',
      'tags': ['AI/ML', 'Cloud'],
    },
    {
      'name': 'Decentralized Social Network',
      'description': 'Web3-based social platform with NFT profiles',
      'tags': ['Blockchain', 'Web3'],
    },
    {
      'name': 'Real-time Collaboration IDE',
      'description': 'VS Code alternative with live coding and AI assistance',
      'tags': ['Cloud', 'AI/ML'],
    },
    {
      'name': 'Smart Home Automation Hub',
      'description': 'IoT platform for controlling home devices with ML',
      'tags': ['IoT', 'AI/ML'],
    },
    {
      'name': 'NFT Marketplace',
      'description': 'Ethereum-based marketplace for digital assets',
      'tags': ['Blockchain', 'Web3'],
    },
    {
      'name': 'AI Video Editor',
      'description': 'Automatic video editing with scene detection and effects',
      'tags': ['AI/ML', 'Cloud'],
    },
    {
      'name': 'Metaverse Meeting Platform',
      'description': 'VR workspace for remote team collaboration',
      'tags': ['AR/VR', 'Web3'],
    },
    {
      'name': 'Crypto Trading Bot',
      'description': 'Algorithmic trading bot with ML predictions',
      'tags': ['Blockchain', 'AI/ML'],
    },
    {
      'name': 'AI Health Diagnosis',
      'description': 'Medical image analysis using deep learning',
      'tags': ['AI/ML', 'Cloud'],
    },
    {
      'name': 'Decentralized Cloud Storage',
      'description': 'IPFS-based distributed file storage system',
      'tags': ['Blockchain', 'Cloud'],
    },
    {
      'name': 'AR Shopping Experience',
      'description': 'Virtual try-on for e-commerce using AR',
      'tags': ['AR/VR', 'Mobile'],
    },
    {
      'name': 'AI Content Generator',
      'description': 'Generate articles, images, and videos with AI',
      'tags': ['AI/ML', 'Cloud'],
    },
    {
      'name': 'Smart City Dashboard',
      'description': 'IoT-based city monitoring and analytics platform',
      'tags': ['IoT', 'Cloud'],
    },
    {
      'name': 'DeFi Lending Platform',
      'description': 'Decentralized finance protocol for crypto lending',
      'tags': ['Blockchain', 'Web3'],
    },
    {
      'name': 'AI Voice Assistant',
      'description': 'Custom voice AI with natural language processing',
      'tags': ['AI/ML', 'Mobile'],
    },
    {
      'name': 'Blockchain Supply Chain',
      'description': 'Transparent supply chain tracking with smart contracts',
      'tags': ['Blockchain', 'IoT'],
    },
    {
      'name': 'Real-time Translation App',
      'description': 'AI-powered instant language translation',
      'tags': ['AI/ML', 'Mobile'],
    },
    {
      'name': 'VR Training Simulator',
      'description': 'Immersive training platform for professionals',
      'tags': ['AR/VR', 'Cloud'],
    },
    {
      'name': 'AI Music Composer',
      'description': 'Generate original music using neural networks',
      'tags': ['AI/ML'],
    },
    {
      'name': 'Smart Agriculture System',
      'description': 'IoT sensors with AI for crop optimization',
      'tags': ['IoT', 'AI/ML'],
    },
    {
      'name': 'Web3 Gaming Platform',
      'description': 'Play-to-earn blockchain gaming ecosystem',
      'tags': ['Blockchain', 'Web3'],
    },
    {
      'name': 'AI Cybersecurity Tool',
      'description': 'Threat detection using machine learning',
      'tags': ['AI/ML', 'Cloud'],
    },
    {
      'name': 'Drone Delivery System',
      'description': 'Autonomous drone fleet management with AI',
      'tags': ['IoT', 'AI/ML'],
    },
    {
      'name': 'AR Navigation App',
      'description': 'Augmented reality indoor/outdoor navigation',
      'tags': ['AR/VR', 'Mobile'],
    },
    {
      'name': 'AI Resume Builder',
      'description': 'Smart resume optimization with ATS scoring',
      'tags': ['AI/ML'],
    },
    {
      'name': 'Blockchain Voting System',
      'description': 'Secure and transparent digital voting platform',
      'tags': ['Blockchain'],
    },
    {
      'name': 'AI Fitness Coach',
      'description': 'Personalized workout plans with computer vision',
      'tags': ['AI/ML', 'Mobile'],
    },
    {
      'name': 'Smart Energy Management',
      'description': 'IoT-based energy consumption optimization',
      'tags': ['IoT', 'Cloud'],
    },
    {
      'name': 'NFT Art Generator',
      'description': 'AI-powered generative art for NFTs',
      'tags': ['AI/ML', 'Blockchain'],
    },
    {
      'name': 'Cloud Gaming Platform',
      'description': 'Stream AAA games from cloud servers',
      'tags': ['Cloud'],
    },
  ];

  List<Map<String, dynamic>> get _filteredProjects {
    return _projects.where((project) {
      final matchesSearch =
          project['name'].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          project['description'].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );

      final matchesTag =
          _selectedTag == 'All' ||
          (project['tags'] as List).contains(_selectedTag);

      return matchesSearch && matchesTag;
    }).toList();
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
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Project Ideas',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_filteredProjects.length} trending projects',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
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
                        hintText: 'Search projects...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: colorScheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Tags
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _tags.length,
                        itemBuilder: (context, index) {
                          final tag = _tags[index];
                          final isSelected = _selectedTag == tag;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(tag),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedTag = tag;
                                });
                              },
                              backgroundColor: colorScheme.surface,
                              selectedColor: colorScheme.primary,
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : colorScheme.onSurface,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              // Projects List
              Expanded(
                child: _filteredProjects.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.3,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No projects found',
                              style: TextStyle(
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _filteredProjects.length,
                        itemBuilder: (context, index) {
                          final project = _filteredProjects[index];
                          return _buildProjectCard(context, project);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProjectCard(BuildContext context, Map<String, dynamic> project) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
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
              builder: (context) => PromptFormScreen(
                initialProjectName: project['name'] ?? '',
                initialProjectDescription: project['description'] ?? '',
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
              Text(
                project['name'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                project['description'],
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: (project['tags'] as List<String>).map((tag) {
                  return Container(
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
                      tag,
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
