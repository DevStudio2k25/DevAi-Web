# DevAi Improvements Specification

## Overview
Complete overhaul of DevAi app to make it more advanced, user-friendly, and future-proof with seamless UX.

## Priority Issues to Fix

### 1. Color Palette Integration 🎨
**Current Problem:**
- Color palette appears as separate floating widget
- Not integrated into design phase content
- Changes don't update the actual prompt content
- Appears everywhere instead of only in design phase

**Solution:**
- Embed color palette INSIDE the design phase markdown content
- Show only when design phase (Phase 4) is visible
- Real-time color updates should modify the actual markdown text
- Save updated colors to history automatically
- Better UI with color picker and live preview

**Implementation:**
```dart
// In chat_result_streaming_screen.dart
- Parse design phase content for color codes
- Replace markdown section with interactive ColorPaletteCard
- Update _fullText when colors change
- Re-render markdown with new colors
```

### 2. Retry Failed - API Not Initialized 🔄
**Current Problem:**
- Retry button shows "Gemini API not initialized" error
- Service loses API key during retry

**Solution:**
- Ensure API key is re-initialized before retry
- Add proper error handling and user feedback
- Show countdown timer during retry cooldown
- Better error messages

### 3. Idea Page → Prompt Form Auto-Fill 💡
**Current Problem:**
- User has to manually re-enter platform and tech stack
- No connection between idea cards and prompt form

**Solution:**
- Add tags to idea cards showing platform & tech stack
- Clicking idea card navigates to prompt form with pre-filled data
- Pass platform, tech stack, project name, and description

**Implementation:**
```dart
// Navigate with parameters
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => PromptFormScreen(
      initialProjectName: idea.title,
      initialProjectDescription: idea.description,
      initialPlatform: idea.platform,
      initialTechStack: idea.techStack,
    ),
  ),
);
```

### 4. Community Projects - Better Cards 🌍
**Current Problem:**
- Basic card design
- No platform/tech stack tags
- Not optimized for Windows 11 design

**Solution:**
- Modern Windows 11 style cards with acrylic effect
- Show platform and tech stack badges
- Better typography and spacing
- Smooth animations

### 5. History Page - Modern Design 📚
**Current Problem:**
- Old design
- No filtering by platform/tech stack
- No search functionality

**Solution:**
- Add search bar
- Filter chips for platform and tech stack
- Modern card design matching community page
- Swipe to delete with confirmation

### 6. Windows 11 Design System 🪟
**Current Problem:**
- Generic Material Design
- Doesn't feel native on Windows 11

**Solution:**
- Implement Fluent Design principles
- Acrylic backgrounds
- Rounded corners (20px radius)
- Smooth animations (200-300ms)
- Proper shadows and depth
- Modern color scheme

## Detailed Task Breakdown

### Phase 1: Critical Fixes (Priority 1) ✅ COMPLETED
- [x] Fix retry API initialization issue
- [x] Integrate color palette into design phase content
- [x] Make color changes update actual markdown
- [x] Save color changes to history

### Phase 2: UX Improvements (Priority 2) ✅ COMPLETED
- [x] Add platform/tech stack tags to idea cards
- [x] Implement auto-fill from idea to prompt form
- [x] Add tags to community project cards
- [x] Improve history page with modern badges

### Phase 3: Design Overhaul (Priority 3) ✅ COMPLETED
- [x] Implement Windows 11 design system
- [x] Create Windows11Theme with light/dark modes
- [x] Add AcrylicCard and AnimatedAcrylicCard widgets
- [x] Update project ideas screen with animated cards
- [x] Smooth animations and hover effects

### Phase 4: Advanced Features (Priority 4) ✅ PARTIALLY COMPLETED
- [x] Theme Selector with Live Preview
- [x] Classic vs Windows 11 theme switcher
- [x] Real-time theme preview
- [x] Theme persistence in SharedPreferences
- [ ] Add project templates (Future)
- [ ] Implement favorites system (Future)
- [ ] Add export to PDF/Markdown (Future)
- [ ] Implement project versioning (Future)

## Technical Architecture

### Color Palette System
```dart
class ColorPaletteCard extends StatefulWidget {
  final Map<String, String> colors;
  final Function(Map<String, String>) onColorsChanged;
  final bool isEditable;
}

// Usage in markdown
# 4. UI Design System

## Color Palette
[COLOR_PALETTE_WIDGET]
Primary: #6366F1
Secondary: #8B5CF6
...
```

### Idea Card Model
```dart
class IdeaCard {
  final String title;
  final String description;
  final String platform;
  final String techStack;
  final List<String> tags;
}
```

### Navigation Flow
```
Idea Page → Click Card → Prompt Form (Pre-filled) → Generate → Result
Community → Click Project → View Details → Regenerate (Pre-filled)
History → Click Project → View Details → Edit & Regenerate
```

## UI/UX Guidelines

### Color Palette Widget
- Inline with design phase content
- Expandable/collapsible
- Color picker on tap
- Live preview
- Save button with confirmation
- Only visible in design phase section

### Card Design (Windows 11 Style)
```dart
Container(
  decoration: BoxDecoration(
    color: colorScheme.surface,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
        offset: Offset(0, 4),
      ),
    ],
  ),
  child: ...
)
```

### Tags/Badges
```dart
Container(
  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  decoration: BoxDecoration(
    gradient: LinearGradient(...),
    borderRadius: BorderRadius.circular(12),
  ),
  child: Row(
    children: [
      Icon(platformIcon, size: 16),
      SizedBox(width: 4),
      Text(platform),
    ],
  ),
)
```

## Success Criteria

### Color Palette
- ✅ Appears only in design phase
- ✅ Integrated into markdown content
- ✅ Real-time updates to markdown
- ✅ Saves to history automatically
- ✅ Beautiful, intuitive UI

### Retry Functionality
- ✅ No API initialization errors
- ✅ Proper countdown display
- ✅ Clear error messages
- ✅ Successful regeneration

### Auto-Fill Feature
- ✅ Tags visible on all cards
- ✅ One-click navigation with pre-filled form
- ✅ Smooth transition
- ✅ All fields populated correctly

### Modern Design
- ✅ Windows 11 aesthetic
- ✅ Consistent across all pages
- ✅ Smooth animations
- ✅ Professional look and feel

## Implementation Order

1. **Fix Retry Issue** (30 min)
2. **Redesign Color Palette** (1 hour)
3. **Add Tags to Cards** (30 min)
4. **Implement Auto-Fill** (45 min)
5. **Update History Page** (1 hour)
6. **Update Community Page** (1 hour)
7. **Windows 11 Design Polish** (2 hours)

## Files to Modify

### Critical
- `lib/screens/chat_result_streaming_screen.dart` - Color palette integration
- `lib/services/gemini_streaming_service.dart` - Fix retry API init
- `lib/widgets/color_palette_widget.dart` - Complete redesign

### Important
- `lib/screens/idea_page.dart` - Add tags and navigation
- `lib/screens/prompt_form/prompt_form_screen.dart` - Accept auto-fill params
- `lib/screens/history_page.dart` - Modern design + search/filter
- `lib/screens/community_page.dart` - Add tags and better cards

### Models
- `lib/models/idea.dart` - Add platform/techStack fields
- `lib/models/project.dart` - Ensure color data is saved

## Testing Checklist

- [ ] Color changes persist after save
- [ ] Retry works without errors
- [ ] Auto-fill populates all fields correctly
- [ ] Tags display correctly on all cards
- [ ] Search and filters work on history page
- [ ] App looks good on Windows 11
- [ ] All animations are smooth
- [ ] No performance issues

## Future Enhancements

- AI-powered color scheme suggestions
- Project templates library
- Collaborative features
- Export to Figma/Adobe XD
- Version control for projects
- Dark mode optimization
- Keyboard shortcuts
