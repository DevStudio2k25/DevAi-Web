# DevAi - Example Generated Output

## Sample Input (Prompt Form)
- **Project Name:** TaskMaster
- **Project Description:** A task management app with reminders and team collaboration
- **Platform:** App
- **Tech Stack:** Flutter

---

## Generated Output (Chat Result Screen)

### # Project Description

TaskMaster is a comprehensive task management application designed to streamline personal and team productivity. This Flutter-based mobile app combines intuitive task organization with powerful collaboration features, making it perfect for individuals, small teams, and large organizations alike. TaskMaster helps users break down complex projects into manageable tasks, set priorities, track progress, and collaborate seamlessly with team members in real-time.

The app features a clean, modern interface that makes task management effortless. Users can create tasks with detailed descriptions, set due dates, add tags, attach files, and assign tasks to team members. The intelligent reminder system ensures that no deadline is missed, with customizable notifications that adapt to user preferences. TaskMaster also includes analytics and reporting features that provide insights into productivity patterns, helping users optimize their workflow and achieve their goals more efficiently.

### # Pages/Screens

1. **Splash Screen** - Initial loading screen with TaskMaster branding and smooth animations
2. **Onboarding Screens** - 3-4 slides introducing key features with interactive tutorials
3. **Login/Signup Screen** - Authentication with email, Google, and Apple sign-in options
4. **Home Dashboard** - Overview of today's tasks, upcoming deadlines, and quick actions
5. **Task List Screen** - Comprehensive view of all tasks with filtering and sorting options
6. **Task Detail Screen** - Detailed view of individual tasks with comments, attachments, and subtasks
7. **Create/Edit Task Screen** - Form to create new tasks or edit existing ones
8. **Calendar View** - Monthly/weekly calendar showing tasks and deadlines
9. **Team Workspace** - Collaborative space for team projects and shared tasks
10. **Project Management Screen** - Organize tasks into projects with progress tracking
11. **Analytics Dashboard** - Visual reports and productivity insights
12. **Notifications Screen** - List of all notifications and reminders
13. **Settings Screen** - App preferences, account settings, and customization options
14. **Profile Screen** - User profile with stats, achievements, and activity history

### # Key Features

- **Smart Task Organization** - Create tasks with priorities, tags, categories, and custom labels. Organize tasks into projects and sub-projects with drag-and-drop functionality
- **Intelligent Reminders** - Set multiple reminders per task with smart scheduling. Get location-based reminders and recurring task notifications
- **Team Collaboration** - Invite team members, assign tasks, share projects, and collaborate in real-time. Built-in chat for task discussions
- **File Attachments** - Attach documents, images, and files to tasks. Support for cloud storage integration (Google Drive, Dropbox)
- **Progress Tracking** - Visual progress bars, completion percentages, and milestone tracking. Gantt chart view for project timelines
- **Advanced Filtering** - Filter tasks by date, priority, assignee, tags, and custom criteria. Save custom filter presets
- **Productivity Analytics** - Track time spent on tasks, completion rates, and productivity trends. Generate weekly/monthly reports
- **Offline Mode** - Full functionality offline with automatic sync when connection is restored

### # UI Design

**Theme & Style:**
TaskMaster features a modern, minimalist design with a focus on clarity and usability. The interface uses a card-based layout with subtle shadows and smooth animations. The design follows Material Design 3 principles with custom adaptations for enhanced user experience.

**Color Palette:**
- Primary: #6366F1 (Indigo) - Used for primary actions, headers, and key UI elements
- Secondary: #8B5CF6 (Purple) - Used for accents, highlights, and secondary actions
- Success: #10B981 (Green) - Task completion, success states
- Warning: #F59E0B (Amber) - Upcoming deadlines, warnings
- Error: #EF4444 (Red) - Overdue tasks, errors
- Background: #F9FAFB (Light Gray) - Main background
- Surface: #FFFFFF (White) - Cards, dialogs, elevated surfaces
- Text Primary: #111827 (Dark Gray)
- Text Secondary: #6B7280 (Medium Gray)

**Layout Patterns:**
- Bottom navigation bar with 5 main sections (Home, Tasks, Calendar, Team, Profile)
- Floating Action Button (FAB) for quick task creation
- Swipeable cards for task actions (complete, edit, delete)
- Collapsible sections and expandable lists
- Modal bottom sheets for quick actions
- Pull-to-refresh for data updates

**Animations & Transitions:**
- Smooth page transitions with hero animations
- Micro-interactions on button presses and task completion
- Animated checkboxes with satisfying completion effects
- Slide-in animations for new tasks
- Fade transitions for screen changes
- Ripple effects on touch interactions

**Typography:**
- Headings: Poppins Bold (24-32px)
- Subheadings: Poppins SemiBold (18-20px)
- Body Text: Inter Regular (14-16px)
- Captions: Inter Regular (12px)

**Icons:**
- Material Icons Rounded for consistency
- Custom task status icons
- Animated icons for interactive elements

### # Folder Structure

```
taskmaster/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_constants.dart
│   │   │   ├── colors.dart
│   │   │   └── text_styles.dart
│   │   ├── theme/
│   │   │   ├── app_theme.dart
│   │   │   ├── light_theme.dart
│   │   │   └── dark_theme.dart
│   │   ├── utils/
│   │   │   ├── date_utils.dart
│   │   │   ├── validators.dart
│   │   │   └── helpers.dart
│   │   └── routes/
│   │       ├── app_router.dart
│   │       └── route_names.dart
│   │
│   ├── data/
│   │   ├── models/
│   │   │   ├── task_model.dart
│   │   │   ├── project_model.dart
│   │   │   ├── user_model.dart
│   │   │   ├── team_model.dart
│   │   │   └── notification_model.dart
│   │   ├── repositories/
│   │   │   ├── task_repository.dart
│   │   │   ├── project_repository.dart
│   │   │   ├── user_repository.dart
│   │   │   └── team_repository.dart
│   │   └── services/
│   │       ├── api_service.dart
│   │       ├── auth_service.dart
│   │       ├── notification_service.dart
│   │       ├── storage_service.dart
│   │       └── sync_service.dart
│   │
│   ├── presentation/
│   │   ├── screens/
│   │   │   ├── splash/
│   │   │   │   └── splash_screen.dart
│   │   │   ├── onboarding/
│   │   │   │   └── onboarding_screen.dart
│   │   │   ├── auth/
│   │   │   │   ├── login_screen.dart
│   │   │   │   └── signup_screen.dart
│   │   │   ├── home/
│   │   │   │   ├── home_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── task_summary_card.dart
│   │   │   │       ├── quick_actions.dart
│   │   │   │       └── upcoming_tasks.dart
│   │   │   ├── tasks/
│   │   │   │   ├── task_list_screen.dart
│   │   │   │   ├── task_detail_screen.dart
│   │   │   │   ├── create_task_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── task_card.dart
│   │   │   │       ├── task_filter.dart
│   │   │   │       └── priority_badge.dart
│   │   │   ├── calendar/
│   │   │   │   ├── calendar_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── calendar_view.dart
│   │   │   │       └── day_tasks.dart
│   │   │   ├── team/
│   │   │   │   ├── team_workspace_screen.dart
│   │   │   │   ├── project_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── team_member_card.dart
│   │   │   │       └── project_card.dart
│   │   │   ├── analytics/
│   │   │   │   ├── analytics_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── productivity_chart.dart
│   │   │   │       └── stats_card.dart
│   │   │   ├── notifications/
│   │   │   │   └── notifications_screen.dart
│   │   │   ├── settings/
│   │   │   │   └── settings_screen.dart
│   │   │   └── profile/
│   │   │       └── profile_screen.dart
│   │   │
│   │   └── widgets/
│   │       ├── common/
│   │       │   ├── custom_button.dart
│   │       │   ├── custom_text_field.dart
│   │       │   ├── loading_indicator.dart
│   │       │   └── empty_state.dart
│   │       └── animations/
│   │           ├── fade_animation.dart
│   │           └── slide_animation.dart
│   │
│   └── providers/
│       ├── task_provider.dart
│       ├── project_provider.dart
│       ├── auth_provider.dart
│       ├── theme_provider.dart
│       └── notification_provider.dart
│
├── assets/
│   ├── images/
│   │   ├── logo.png
│   │   ├── onboarding/
│   │   └── illustrations/
│   ├── icons/
│   └── animations/
│       └── lottie/
│
├── test/
│   ├── unit/
│   ├── widget/
│   └── integration/
│
├── pubspec.yaml
├── analysis_options.yaml
└── README.md
```
