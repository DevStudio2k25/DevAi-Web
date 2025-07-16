import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../screens/prompt_form_screen.dart';

class ProjectIdeasScreen extends StatefulWidget {
  const ProjectIdeasScreen({super.key});

  @override
  State<ProjectIdeasScreen> createState() => _ProjectIdeasScreenState();
}

class _ProjectIdeasScreenState extends State<ProjectIdeasScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  // Project ideas categorized
  final Map<String, List<Map<String, String>>> _categorizedIdeas = {
    'Agriculture': [
      {
        'name': 'CropTrack',
        'description': 'Crop monitoring and agricultural management',
      },
      {
        'name': 'FarmHelper',
        'description': 'Precision farming and crop health tracking',
      },
      {
        'name': 'MarketPrice',
        'description': 'Agricultural commodity price tracking',
      },
      {
        'name': 'WeatherFarm',
        'description': 'Hyper-local agricultural weather forecasting',
      },
      {
        'name': 'SeedExchange',
        'description': 'Seed trading and agricultural resource sharing',
      },
      {
        'name': 'IrrigationSmart',
        'description': 'Smart irrigation and water management system',
      },
      {
        'name': 'PestControl',
        'description': 'Crop pest and disease monitoring app',
      },
      {
        'name': 'FarmEquipment',
        'description': 'Agricultural equipment rental and marketplace',
      },
      {
        'name': 'OrganicTracker',
        'description': 'Organic farming certification and tracking',
      },
      {
        'name': 'AgroFinance',
        'description': 'Agricultural loan and financial management',
      },
      {
        'name': 'FarmToMarket',
        'description': 'Direct farmer to consumer marketplace',
      },
      {
        'name': 'AgriBusiness',
        'description': 'Agricultural business management platform',
      },
    ],
    'Automotive': [
      {
        'name': 'CarTrack',
        'description': 'Vehicle maintenance and service tracking app',
      },
      {
        'name': 'RoadTrip',
        'description': 'Road trip planning and navigation assistant',
      },
      {
        'name': 'FuelSaver',
        'description': 'Fuel efficiency tracking and cost optimization',
      },
      {
        'name': 'CarPool',
        'description': 'Carpooling and ride-sharing community app',
      },
      {
        'name': 'AutoDiag',
        'description': 'Car diagnostic and health monitoring tool',
      },
      {
        'name': 'RentalRide',
        'description': 'Car rental and sharing marketplace',
      },
      {
        'name': 'ElectricCharge',
        'description': 'Electric vehicle charging station finder',
      },
      {
        'name': 'AutoInsurance',
        'description': 'Vehicle insurance comparison and management',
      },
      {
        'name': 'ModTracker',
        'description': 'Vehicle modification and customization tracker',
      },
      {
        'name': 'AccidentAssist',
        'description': 'Roadside assistance and accident support app',
      },
      {
        'name': 'CarValuation',
        'description': 'Vehicle value estimation and market analysis',
      },
      {
        'name': 'DriveScore',
        'description': 'Safe driving behavior tracking and rewards',
      },
    ],
    'Community Service': [
      {
        'name': 'VolunteerHub',
        'description': 'Community volunteer coordination platform',
      },
      {
        'name': 'LocalHelp',
        'description': 'Neighborhood assistance and support network',
      },
      {
        'name': 'CharityTrack',
        'description': 'Donation tracking and impact measurement',
      },
      {
        'name': 'EmergencyAlert',
        'description': 'Community emergency response coordination',
      },
      {
        'name': 'SkillShare',
        'description': 'Community skill exchange and learning platform',
      },
      {
        'name': 'CommunityFund',
        'description': 'Local crowdfunding and community project support',
      },
      {
        'name': 'DisasterRelief',
        'description': 'Disaster response and support coordination',
      },
      {
        'name': 'LocalCleanup',
        'description': 'Community environmental cleanup organization',
      },
      {
        'name': 'FoodBank',
        'description': 'Local food donation and distribution platform',
      },
      {
        'name': 'MentoringConnect',
        'description': 'Community mentorship and guidance platform',
      },
      {
        'name': 'CommunityHealth',
        'description': 'Local health resources and support network',
      },
      {
        'name': 'SeniorSupport',
        'description': 'Community support services for elderly citizens',
      },
    ],
    'E-commerce': [
      {
        'name': 'ShopEase',
        'description': 'E-commerce platform with cart and payment integration',
      },
      {
        'name': 'FashionHub',
        'description': 'Fashion e-commerce app with virtual try-on',
      },
      {
        'name': 'GroceryGo',
        'description': 'Grocery delivery app with inventory management',
      },
      {
        'name': 'ArtMarket',
        'description': 'Marketplace for artists to sell their creations',
      },
      {
        'name': 'LocalCraft',
        'description': 'Platform for local artisans and handmade goods',
      },
      {
        'name': 'TechGear',
        'description': 'Electronics and gadgets marketplace with reviews',
      },
      {
        'name': 'BookBazaar',
        'description': 'Online bookstore with personalized recommendations',
      },
      {
        'name': 'VintageVault',
        'description': 'Vintage and antique items marketplace',
      },
      {
        'name': 'FarmersMarket',
        'description': 'Direct farm-to-consumer produce marketplace',
      },
      {
        'name': 'CustomGear',
        'description': 'Custom product design and manufacturing platform',
      },
      {
        'name': 'SustainStore',
        'description': 'Eco-friendly and sustainable products marketplace',
      },
      {
        'name': 'GamersMarket',
        'description': 'Gaming gear and collectibles e-commerce platform',
      },
    ],
    'Education': [
      {
        'name': 'LearnLang',
        'description': 'Language learning app with interactive lessons',
      },
      {
        'name': 'StudyBuddy',
        'description': 'Study planner and note-taking app for students',
      },
      {
        'name': 'KidsLearn',
        'description': 'Educational games and activities for children',
      },
      {
        'name': 'SkillShare',
        'description': 'Skill-sharing platform with video courses',
      },
      {
        'name': 'CodeCamp',
        'description': 'Coding tutorial and practice platform',
      },
      {
        'name': 'QuizMaster',
        'description': 'Interactive quiz and learning assessment app',
      },
      {
        'name': 'MathGenius',
        'description': 'Adaptive mathematics learning platform',
      },
      {
        'name': 'ScienceExplorer',
        'description': 'Interactive science learning and experiment app',
      },
      {
        'name': 'ArtSchool',
        'description': 'Online art and creativity learning platform',
      },
      {
        'name': 'MusicTutor',
        'description': 'Music learning and instrument practice app',
      },
      {
        'name': 'CareerPrep',
        'description': 'Professional skills and career development platform',
      },
      {
        'name': 'UniversityConnect',
        'description': 'Educational networking and resource sharing app',
      },
    ],
    'Entertainment': [
      {
        'name': 'MovieBuff',
        'description': 'Movie and TV show tracking and recommendation app',
      },
      {
        'name': 'GameStats',
        'description': 'Gaming statistics and achievement tracking app',
      },
      {
        'name': 'MusicMood',
        'description': 'Music player with mood-based playlists',
      },
      {
        'name': 'PodcastHub',
        'description': 'Podcast discovery and listening platform',
      },
      {
        'name': 'ComicVerse',
        'description': 'Digital comic book reading and collection app',
      },
      {
        'name': 'ArtistConnect',
        'description': 'Platform for independent artists and creators',
      },
      {
        'name': 'ConcertFinder',
        'description': 'Live music and event discovery platform',
      },
      {
        'name': 'StandupComedy',
        'description': 'Comedy show and performer discovery app',
      },
      {
        'name': 'ArtGallery',
        'description': 'Virtual art gallery and exhibition platform',
      },
      {
        'name': 'BookClubConnect',
        'description': 'Online book club and reading community',
      },
      {
        'name': 'StreamReview',
        'description': 'Streaming content review and recommendation app',
      },
      {
        'name': 'CreatorStudio',
        'description': 'Content creation and editing platform',
      },
    ],
    'Finance': [
      {
        'name': 'BudgetBuddy',
        'description': 'Personal finance manager with expense tracking',
      },
      {
        'name': 'InvestSmart',
        'description': 'Investment portfolio tracking and analysis app',
      },
      {
        'name': 'BillRemind',
        'description': 'Bill payment reminder and management app',
      },
      {
        'name': 'CryptoTrack',
        'description': 'Cryptocurrency portfolio and market tracking app',
      },
      {
        'name': 'SplitBill',
        'description': 'Group expense splitting and bill sharing app',
      },
      {
        'name': 'SaverPro',
        'description': 'Automated savings and financial goal tracking',
      },
      {
        'name': 'TaxHelper',
        'description': 'Tax preparation and financial planning app',
      },
      {
        'name': 'InsuranceTrack',
        'description': 'Insurance policy management and comparison',
      },
      {
        'name': 'RealEstateInvest',
        'description': 'Real estate investment tracking platform',
      },
      {
        'name': 'StudentLoanAid',
        'description': 'Student loan management and repayment tracker',
      },
      {
        'name': 'RetirementPlanner',
        'description': 'Comprehensive retirement savings and planning app',
      },
      {
        'name': 'MicroInvest',
        'description': 'Micro-investing and spare change investment platform',
      },
    ],
    'Food & Dining': [
      {
        'name': 'RecipeBook',
        'description': 'Recipe collection app with search and meal planning',
      },
      {
        'name': 'FoodDelivery',
        'description': 'Food delivery service with restaurant partnerships',
      },
      {
        'name': 'RestaurantFinder',
        'description': 'Restaurant discovery and reservation app',
      },
      {
        'name': 'CookingGuide',
        'description': 'Step-by-step cooking instructions and timer app',
      },
      {
        'name': 'NutriScan',
        'description': 'Nutritional information scanner and analyzer',
      },
      {
        'name': 'MealPrep',
        'description': 'Meal preparation and grocery list generator',
      },
      {
        'name': 'WinePairing',
        'description': 'Wine and food pairing recommendation app',
      },
      {
        'name': 'GlobalCuisine',
        'description': 'International recipe and cooking techniques app',
      },
      {
        'name': 'DietTracker',
        'description': 'Comprehensive diet and nutrition tracking platform',
      },
      {
        'name': 'CookingCommunity',
        'description': 'Social platform for home cooks and food enthusiasts',
      },
      {
        'name': 'AllergyHelper',
        'description': 'Allergy-friendly recipe and dining guide',
      },
      {
        'name': 'FarmToTable',
        'description': 'Local farm produce and seasonal ingredient app',
      },
    ],
    'Gaming': [
      {
        'name': 'GameArena',
        'description': 'Multiplayer gaming tournament platform',
      },
      {
        'name': 'eSportsConnect',
        'description': 'eSports team formation and competition app',
      },
      {
        'name': 'GameReplay',
        'description': 'Game performance analysis and replay sharing',
      },
      {
        'name': 'StreamPro',
        'description': 'Game streaming and content creation tool',
      },
      {
        'name': 'GamerProfile',
        'description': 'Comprehensive gaming achievement tracker',
      },
      {
        'name': 'GameGuide',
        'description': 'Interactive game walkthrough and strategy app',
      },
      {
        'name': 'GameInventory',
        'description': 'Digital game collection and library management',
      },
      {
        'name': 'TournamentTracker',
        'description': 'Global gaming tournament discovery platform',
      },
      {
        'name': 'GameCommunity',
        'description': 'Multiplayer game social networking app',
      },
      {
        'name': 'GameRecommender',
        'description': 'Personalized game recommendation engine',
      },
      {
        'name': 'GameAchievement',
        'description': 'Cross-platform gaming achievement tracker',
      },
      {
        'name': 'IndieGameSpot',
        'description': 'Independent game discovery and support platform',
      },
    ],
    'Health & Fitness': [
      {
        'name': 'FitTrack',
        'description':
            'Fitness tracking app with workout plans and progress charts',
      },
      {
        'name': 'NutriLog',
        'description': 'Nutrition tracking and meal planning app',
      },
      {
        'name': 'MeditateNow',
        'description': 'Meditation and mindfulness app with guided sessions',
      },
      {
        'name': 'SleepBetter',
        'description': 'Sleep tracking and improvement app with analytics',
      },
      {
        'name': 'MentalWell',
        'description': 'Mental health tracking and support platform',
      },
      {
        'name': 'WorkoutBuddy',
        'description': 'AI-powered personal fitness coaching app',
      },
      {
        'name': 'PregnancyPal',
        'description': 'Comprehensive pregnancy tracking and support app',
      },
      {
        'name': 'ChronicCare',
        'description': 'Chronic condition management and tracking platform',
      },
      {
        'name': 'NutritionAI',
        'description': 'AI-powered personalized nutrition guidance',
      },
      {
        'name': 'YogaFlow',
        'description': 'Personalized yoga and wellness tracking app',
      },
      {
        'name': 'RehabTrack',
        'description': 'Physical rehabilitation progress tracking',
      },
      {
        'name': 'SeniorFitness',
        'description': 'Fitness and health app for senior citizens',
      },
    ],
    'Productivity': [
      {
        'name': 'TaskMaster',
        'description': 'Task management app with reminders and categories',
      },
      {
        'name': 'NoteTaker',
        'description': 'Note-taking app with categories and markdown support',
      },
      {
        'name': 'TimeTrack',
        'description': 'Time tracking and productivity analysis app',
      },
      {
        'name': 'MeetingPlanner',
        'description': 'Meeting scheduler and organizer app',
      },
      {
        'name': 'ProjectSync',
        'description': 'Collaborative project management platform',
      },
      {
        'name': 'FocusTimer',
        'description': 'Pomodoro technique and focus management app',
      },
      {
        'name': 'TeamCollab',
        'description': 'Team collaboration and communication platform',
      },
      {
        'name': 'EmailManager',
        'description': 'Advanced email organization and productivity tool',
      },
      {
        'name': 'HabitTracker',
        'description': 'Habit formation and personal development app',
      },
      {
        'name': 'DocumentScanner',
        'description': 'Advanced document scanning and organization',
      },
      {
        'name': 'WorkflowAutomator',
        'description': 'Personal and professional workflow automation',
      },
      {
        'name': 'GoalTracker',
        'description': 'Personal and professional goal setting platform',
      },
    ],
    'Social Media': [
      {
        'name': 'ConnectMe',
        'description': 'Social networking app with profiles and messaging',
      },
      {
        'name': 'PhotoShare',
        'description':
            'Photo sharing platform with filters and social features',
      },
      {
        'name': 'VideoHub',
        'description': 'Short video sharing platform with creator tools',
      },
      {
        'name': 'GroupChat',
        'description': 'Group messaging app with multimedia support',
      },
      {
        'name': 'MusicConnect',
        'description': 'Music-focused social network for artists and fans',
      },
      {
        'name': 'ArtistLink',
        'description': 'Collaborative platform for creative professionals',
      },
      {
        'name': 'TravelGram',
        'description': 'Travel experience sharing and social networking',
      },
      {
        'name': 'BookWorm',
        'description': 'Book lovers social network with reading challenges',
      },
      {
        'name': 'FanClub',
        'description': 'Celebrity and interest-based fan community app',
      },
      {
        'name': 'LocalConnect',
        'description': 'Neighborhood and community interaction platform',
      },
      {
        'name': 'PetSocial',
        'description': 'Social network for pet owners and animal lovers',
      },
      {
        'name': 'GamersUnite',
        'description': 'Gaming community and multiplayer social platform',
      },
    ],
    'Travel': [
      {
        'name': 'TravelPlanner',
        'description': 'Travel itinerary and trip planning application',
      },
      {
        'name': 'LocalGuide',
        'description': 'Local attractions and tour guide app',
      },
      {
        'name': 'PackList',
        'description': 'Travel packing list and checklist app',
      },
      {
        'name': 'TripShare',
        'description': 'Travel experience sharing and blogging platform',
      },
      {
        'name': 'BudgetTravel',
        'description': 'Budget-friendly travel planning and deals finder',
      },
      {
        'name': 'TravelBuddy',
        'description': 'Travel companion and safety tracking app',
      },
      {
        'name': 'LanguageTranslate',
        'description': 'Real-time travel language translation app',
      },
      {
        'name': 'AccommodationFinder',
        'description': 'Unique accommodation and homestay discovery',
      },
      {
        'name': 'RoadTripCompanion',
        'description': 'Comprehensive road trip planning and navigation',
      },
      {
        'name': 'BackpackerNetwork',
        'description': 'Backpacker community and travel resource sharing',
      },
      {
        'name': 'TravelInsurance',
        'description': 'Travel insurance comparison and booking app',
      },
      {
        'name': 'CulturalExchange',
        'description': 'Cultural learning and exchange travel platform',
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _categorizedIdeas.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _selectIdea(Map<String, String> idea) {
    // Navigate directly to PromptFormScreen and pass the selected idea
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PromptFormScreen(
          initialProjectName: idea['name'] ?? '',
          initialProjectDescription: idea['description'] ?? '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_tabController == null) return const SizedBox();

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
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
            const Text('Project Ideas by DevAi'),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController!,
          isScrollable: true,
          tabs: _categorizedIdeas.keys
              .map((category) => Tab(text: category))
              .toList(),
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
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
        child: SafeArea(
          child: TabBarView(
            controller: _tabController!,
            children: _categorizedIdeas.entries.map((entry) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.surface.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.key,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 16),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: entry.value.length,
                                itemBuilder: (context, index) {
                                  final idea = entry.value[index];
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    color: colorScheme.primaryContainer
                                        .withOpacity(0.5),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                        topLeft: index == 0
                                            ? const Radius.circular(40)
                                            : const Radius.circular(10),
                                        topRight: index == 0
                                            ? const Radius.circular(10)
                                            : const Radius.circular(40),
                                        bottomLeft:
                                            index == entry.value.length - 1
                                            ? const Radius.circular(40)
                                            : const Radius.circular(10),
                                        bottomRight:
                                            index == entry.value.length - 1
                                            ? const Radius.circular(10)
                                            : const Radius.circular(40),
                                      ),
                                    ),
                                    child: ListTile(
                                      leading: SizedBox(
                                        width: 50,
                                        height: 50,
                                        child: Lottie.asset(
                                          'assets/lottie/DevAi.json',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      title: Text(
                                        idea['name'] ?? '',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Text(idea['description'] ?? ''),
                                      onTap: () => _selectIdea(idea),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
