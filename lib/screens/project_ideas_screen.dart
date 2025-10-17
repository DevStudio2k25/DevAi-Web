import 'package:flutter/material.dart';
import 'prompt_form/prompt_form_screen.dart';

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
    'Web',
    'Web3',
    'AR/VR',
    'E-commerce',
    'Social',
    'Productivity',
    'Gaming',
    'Entertainment',
    'Education',
    'Health',
    'Finance',
    'Utility',
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
    // Normal Web & Mobile Apps
    {
      'name': 'Recipe Sharing Platform',
      'description': 'Social platform for sharing and discovering recipes',
      'tags': ['Web', 'Social'],
    },
    {
      'name': 'Expense Tracker App',
      'description': 'Personal finance management with budget tracking',
      'tags': ['Mobile', 'Productivity'],
    },
    {
      'name': 'Online Bookstore',
      'description': 'E-commerce platform for buying and selling books',
      'tags': ['Web', 'E-commerce'],
    },
    {
      'name': 'Fitness Tracker',
      'description': 'Track workouts, calories, and fitness goals',
      'tags': ['Mobile'],
    },
    {
      'name': 'Blog Platform',
      'description': 'Simple blogging platform with markdown support',
      'tags': ['Web'],
    },
    {
      'name': 'Todo List App',
      'description': 'Task management with categories and reminders',
      'tags': ['Mobile', 'Productivity'],
    },
    {
      'name': 'Weather App',
      'description': 'Real-time weather forecasts and alerts',
      'tags': ['Mobile'],
    },
    {
      'name': 'Restaurant Finder',
      'description': 'Discover nearby restaurants with reviews and ratings',
      'tags': ['Mobile', 'Web'],
    },
    {
      'name': 'Portfolio Website',
      'description': 'Personal portfolio showcase for developers/designers',
      'tags': ['Web'],
    },
    {
      'name': 'Chat Application',
      'description': 'Real-time messaging with group chats',
      'tags': ['Mobile', 'Web', 'Social'],
    },
    {
      'name': 'E-learning Platform',
      'description': 'Online courses with video lessons and quizzes',
      'tags': ['Web'],
    },
    {
      'name': 'Music Player',
      'description': 'Local music player with playlists and equalizer',
      'tags': ['Mobile'],
    },
    {
      'name': 'Job Board',
      'description': 'Job listing platform with application tracking',
      'tags': ['Web'],
    },
    {
      'name': 'Note Taking App',
      'description': 'Simple notes with tags and search functionality',
      'tags': ['Mobile', 'Productivity'],
    },
    {
      'name': 'Event Management System',
      'description': 'Create and manage events with RSVP tracking',
      'tags': ['Web'],
    },
    {
      'name': 'Photo Gallery App',
      'description': 'Organize and share photos with albums',
      'tags': ['Mobile'],
    },
    {
      'name': 'Online Quiz Platform',
      'description': 'Create and take quizzes with scoring system',
      'tags': ['Web'],
    },
    {
      'name': 'Habit Tracker',
      'description': 'Build good habits with daily tracking and streaks',
      'tags': ['Mobile', 'Productivity'],
    },
    {
      'name': 'Food Delivery App',
      'description': 'Order food from local restaurants',
      'tags': ['Mobile', 'E-commerce'],
    },
    {
      'name': 'News Aggregator',
      'description': 'Curated news from multiple sources',
      'tags': ['Web', 'Mobile'],
    },
    {
      'name': 'Appointment Booking System',
      'description': 'Schedule appointments for services and consultations',
      'tags': ['Web'],
    },
    {
      'name': 'Flashcard Study App',
      'description': 'Create and study flashcards for learning',
      'tags': ['Mobile'],
    },
    {
      'name': 'Real Estate Listing',
      'description': 'Property listings with search and filters',
      'tags': ['Web', 'E-commerce'],
    },
    {
      'name': 'Meditation Timer',
      'description': 'Guided meditation with ambient sounds',
      'tags': ['Mobile'],
    },
    {
      'name': 'Invoice Generator',
      'description': 'Create and manage professional invoices',
      'tags': ['Web', 'Productivity'],
    },
    {
      'name': 'Movie Review Platform',
      'description': 'Rate and review movies with recommendations',
      'tags': ['Web', 'Social'],
    },
    {
      'name': 'Parking Finder App',
      'description': 'Find and book parking spots nearby',
      'tags': ['Mobile'],
    },
    {
      'name': 'URL Shortener',
      'description': 'Shorten URLs with analytics tracking',
      'tags': ['Web'],
    },
    {
      'name': 'Grocery Shopping List',
      'description': 'Shared shopping lists with family members',
      'tags': ['Mobile', 'Productivity'],
    },
    {
      'name': 'Travel Planner',
      'description': 'Plan trips with itinerary and budget tracking',
      'tags': ['Web', 'Mobile'],
    },
    {
      'name': 'Podcast Player',
      'description': 'Stream and download podcasts',
      'tags': ['Mobile'],
    },
    {
      'name': 'Customer Support Portal',
      'description': 'Ticket management system for customer support',
      'tags': ['Web'],
    },
    {
      'name': 'QR Code Generator',
      'description': 'Generate and scan QR codes',
      'tags': ['Mobile', 'Web'],
    },
    {
      'name': 'Language Learning App',
      'description': 'Learn languages with vocabulary and exercises',
      'tags': ['Mobile'],
    },
    {
      'name': 'Inventory Management',
      'description': 'Track stock and manage warehouse inventory',
      'tags': ['Web'],
    },
    {
      'name': 'Calorie Counter',
      'description': 'Track daily food intake and nutrition',
      'tags': ['Mobile'],
    },
    {
      'name': 'Forum Community',
      'description': 'Discussion forum with threads and categories',
      'tags': ['Web', 'Social'],
    },
    {
      'name': 'Password Manager',
      'description': 'Securely store and manage passwords',
      'tags': ['Mobile', 'Web'],
    },
    {
      'name': 'Pet Care Tracker',
      'description': 'Track pet health, vet visits, and feeding schedule',
      'tags': ['Mobile'],
    },
    {
      'name': 'Donation Platform',
      'description': 'Crowdfunding and donation management system',
      'tags': ['Web'],
    },
    // Gaming & Entertainment
    {
      'name': 'Tic Tac Toe Game',
      'description': 'Classic tic-tac-toe with AI opponent',
      'tags': ['Gaming', 'Mobile'],
    },
    {
      'name': 'Memory Card Game',
      'description': 'Match pairs of cards with different difficulty levels',
      'tags': ['Gaming', 'Mobile'],
    },
    {
      'name': 'Quiz Game App',
      'description': 'Trivia quiz game with multiple categories',
      'tags': ['Gaming', 'Entertainment'],
    },
    {
      'name': 'Snake Game',
      'description': 'Classic snake game with leaderboard',
      'tags': ['Gaming', 'Mobile'],
    },
    {
      'name': 'Sudoku Puzzle',
      'description': 'Sudoku game with hints and difficulty levels',
      'tags': ['Gaming', 'Mobile'],
    },
    {
      'name': 'Chess Game',
      'description': 'Play chess online with friends or AI',
      'tags': ['Gaming', 'Web'],
    },
    {
      'name': 'Meme Generator',
      'description': 'Create and share custom memes',
      'tags': ['Entertainment', 'Mobile'],
    },
    {
      'name': 'GIF Maker',
      'description': 'Convert videos to GIFs with editing tools',
      'tags': ['Entertainment', 'Utility'],
    },
    {
      'name': 'Karaoke App',
      'description': 'Sing along with lyrics and record performances',
      'tags': ['Entertainment', 'Mobile'],
    },
    {
      'name': 'Joke & Quotes App',
      'description': 'Daily jokes and inspirational quotes',
      'tags': ['Entertainment', 'Mobile'],
    },
    // Education & Learning
    {
      'name': 'Dictionary App',
      'description': 'Offline dictionary with pronunciation and examples',
      'tags': ['Education', 'Mobile'],
    },
    {
      'name': 'Math Practice App',
      'description': 'Practice math problems with step-by-step solutions',
      'tags': ['Education', 'Mobile'],
    },
    {
      'name': 'Typing Speed Test',
      'description': 'Improve typing speed with practice tests',
      'tags': ['Education', 'Web'],
    },
    {
      'name': 'Periodic Table App',
      'description': 'Interactive periodic table with element details',
      'tags': ['Education', 'Mobile'],
    },
    {
      'name': 'Code Snippet Manager',
      'description': 'Save and organize code snippets',
      'tags': ['Productivity', 'Web'],
    },
    {
      'name': 'Study Timer (Pomodoro)',
      'description': 'Pomodoro technique timer for focused study',
      'tags': ['Education', 'Productivity'],
    },
    {
      'name': 'Whiteboard App',
      'description': 'Digital whiteboard for drawing and collaboration',
      'tags': ['Education', 'Web'],
    },
    // Health & Fitness
    {
      'name': 'Water Reminder',
      'description': 'Track daily water intake with reminders',
      'tags': ['Health', 'Mobile'],
    },
    {
      'name': 'BMI Calculator',
      'description': 'Calculate BMI and get health recommendations',
      'tags': ['Health', 'Mobile'],
    },
    {
      'name': 'Yoga Pose Guide',
      'description': 'Learn yoga poses with instructions and benefits',
      'tags': ['Health', 'Mobile'],
    },
    {
      'name': 'Sleep Tracker',
      'description': 'Monitor sleep patterns and quality',
      'tags': ['Health', 'Mobile'],
    },
    {
      'name': 'Meal Planner',
      'description': 'Plan weekly meals with grocery list generation',
      'tags': ['Health', 'Productivity'],
    },
    {
      'name': 'Step Counter',
      'description': 'Track daily steps and walking distance',
      'tags': ['Health', 'Mobile'],
    },
    // Finance & Business
    {
      'name': 'Budget Planner',
      'description': 'Monthly budget planning with expense categories',
      'tags': ['Finance', 'Productivity'],
    },
    {
      'name': 'Tip Calculator',
      'description': 'Calculate tips and split bills easily',
      'tags': ['Finance', 'Utility'],
    },
    {
      'name': 'Currency Converter',
      'description': 'Real-time currency exchange rates',
      'tags': ['Finance', 'Utility'],
    },
    {
      'name': 'Stock Portfolio Tracker',
      'description': 'Track stock investments and portfolio performance',
      'tags': ['Finance', 'Web'],
    },
    {
      'name': 'Loan Calculator',
      'description': 'Calculate EMI and loan repayment schedules',
      'tags': ['Finance', 'Utility'],
    },
    {
      'name': 'Receipt Scanner',
      'description': 'Scan and organize receipts for expense tracking',
      'tags': ['Finance', 'Mobile'],
    },
    // Utility & Tools
    {
      'name': 'Unit Converter',
      'description': 'Convert between different units of measurement',
      'tags': ['Utility', 'Mobile'],
    },
    {
      'name': 'Color Picker Tool',
      'description': 'Pick colors from images and generate palettes',
      'tags': ['Utility', 'Web'],
    },
    {
      'name': 'File Converter',
      'description': 'Convert files between different formats',
      'tags': ['Utility', 'Web'],
    },
    {
      'name': 'Barcode Scanner',
      'description': 'Scan barcodes and get product information',
      'tags': ['Utility', 'Mobile'],
    },
    {
      'name': 'Countdown Timer',
      'description': 'Create countdowns for important events',
      'tags': ['Utility', 'Mobile'],
    },
    {
      'name': 'Random Name Generator',
      'description': 'Generate random names for projects or characters',
      'tags': ['Utility', 'Web'],
    },
    {
      'name': 'Text to Speech',
      'description': 'Convert text to natural sounding speech',
      'tags': ['Utility', 'Mobile'],
    },
    {
      'name': 'Image Compressor',
      'description': 'Compress images without losing quality',
      'tags': ['Utility', 'Web'],
    },
    {
      'name': 'PDF Reader',
      'description': 'Read and annotate PDF documents',
      'tags': ['Utility', 'Mobile'],
    },
    {
      'name': 'Markdown Editor',
      'description': 'Write and preview markdown documents',
      'tags': ['Productivity', 'Web'],
    },
    // Social & Communication
    {
      'name': 'Anonymous Feedback App',
      'description': 'Collect anonymous feedback and suggestions',
      'tags': ['Social', 'Web'],
    },
    {
      'name': 'Birthday Reminder',
      'description': 'Never forget birthdays with smart reminders',
      'tags': ['Social', 'Mobile'],
    },
    {
      'name': 'Group Poll App',
      'description': 'Create polls and surveys for group decisions',
      'tags': ['Social', 'Web'],
    },
    {
      'name': 'Contact Manager',
      'description': 'Organize contacts with notes and tags',
      'tags': ['Productivity', 'Mobile'],
    },
    {
      'name': 'Video Call App',
      'description': 'Simple video calling with screen sharing',
      'tags': ['Social', 'Web'],
    },
    // Creative & Design
    {
      'name': 'Drawing App',
      'description': 'Digital drawing with brushes and layers',
      'tags': ['Entertainment', 'Mobile'],
    },
    {
      'name': 'Logo Maker',
      'description': 'Create simple logos with templates',
      'tags': ['Utility', 'Web'],
    },
    {
      'name': 'Collage Maker',
      'description': 'Create photo collages with layouts',
      'tags': ['Entertainment', 'Mobile'],
    },
    {
      'name': 'Wallpaper App',
      'description': 'Browse and download HD wallpapers',
      'tags': ['Entertainment', 'Mobile'],
    },
    {
      'name': 'Icon Generator',
      'description': 'Generate app icons in multiple sizes',
      'tags': ['Utility', 'Web'],
    },
    // Lifestyle & Personal
    {
      'name': 'Diary App',
      'description': 'Private digital diary with mood tracking',
      'tags': ['Productivity', 'Mobile'],
    },
    {
      'name': 'Dream Journal',
      'description': 'Record and analyze your dreams',
      'tags': ['Entertainment', 'Mobile'],
    },
    {
      'name': 'Gratitude Journal',
      'description': 'Daily gratitude practice with prompts',
      'tags': ['Health', 'Mobile'],
    },
    {
      'name': 'Book Reading Tracker',
      'description': 'Track books read with reviews and ratings',
      'tags': ['Entertainment', 'Mobile'],
    },
    {
      'name': 'Movie Watchlist',
      'description': 'Keep track of movies to watch',
      'tags': ['Entertainment', 'Mobile'],
    },
    {
      'name': 'Plant Care Reminder',
      'description': 'Watering schedule and plant care tips',
      'tags': ['Utility', 'Mobile'],
    },
    {
      'name': 'Outfit Planner',
      'description': 'Plan daily outfits with virtual wardrobe',
      'tags': ['Entertainment', 'Mobile'],
    },
    {
      'name': 'Gift Idea Tracker',
      'description': 'Save gift ideas for friends and family',
      'tags': ['Productivity', 'Mobile'],
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
