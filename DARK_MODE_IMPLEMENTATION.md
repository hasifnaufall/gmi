# Dark Mode Implementation Guide

## Overview
Dark mode has been implemented using the Provider package and ThemeManager class. However, because many screens use hardcoded colors, each screen needs to be updated to respect the theme.

## What's Already Done

### 1. Theme Manager (`lib/theme_manager.dart`)
- ✅ Created with light and dark color schemes
- ✅ Persists user preference using SharedPreferences
- ✅ Provides helper method: `ThemeManager.of(context)`

### 2. Main App (`lib/main.dart`)
- ✅ Wrapped with ChangeNotifierProvider
- ✅ Both light and dark ThemeData configured
- ✅ Auto-switches based on user preference

### 3. Profile Screen (`lib/profile.dart`)
- ✅ Dark mode toggle added
- ✅ Beautiful switch UI with sun/moon icon
- ✅ Works correctly and saves preference

## How to Update Screens for Dark Mode

### Pattern to Follow:

```dart
// 1. Add imports at top of file
import 'package:provider/provider.dart';
import 'theme_manager.dart';

// 2. Wrap build method with Consumer
@override
Widget build(BuildContext context) {
  return Consumer<ThemeManager>(
    builder: (context, themeManager, child) {
      return Scaffold(
        // Use theme colors instead of hardcoded values
        backgroundColor: themeManager.backgroundColor,
        appBar: AppBar(
          backgroundColor: themeManager.primary,
          // ...
        ),
        body: Container(
          color: themeManager.surface,
          child: Text(
            'Hello',
            style: TextStyle(color: themeManager.textPrimary),
          ),
        ),
      );
    },
  );
}
```

### Available Theme Colors:

**From ThemeManager:**
- `themeManager.backgroundColor` - Main background color
- `themeManager.cardBackground` - Card/container background
- `themeManager.surface` - Surface color (like navbar)
- `themeManager.primary` - Primary accent color (cyan)
- `themeManager.secondary` - Secondary accent color
- `themeManager.textPrimary` - Main text color
- `themeManager.textSecondary` - Secondary/accent text color
- `themeManager.primaryGradient` - Gradient for headers
- `themeManager.backgroundGradient` - Gradient for backgrounds

### Replace These Hardcoded Colors:

| Hardcoded | Replace With |
|-----------|--------------|
| `Color(0xFFCFFFF7)` (mint bg) | `themeManager.backgroundColor` |
| `Colors.white` (cards) | `themeManager.cardBackground` |
| `Color(0xFF2D5263)` (text) | `themeManager.textPrimary` |
| `Color(0xFF69D3E4)` (cyan) | `themeManager.primary` |
| `Color(0xFF0891B2)` (dark cyan) | `themeManager.primary` |

## Screens That Need Updating:

1. ✅ **profile.dart** - DONE (has toggle)
2. ⏳ **quiz_category.dart** - PARTIALLY DONE (needs completion)
3. ❌ **alphabet_learn.dart** - TODO
4. ❌ **number_learn.dart** - TODO
5. ❌ **colour_learn.dart** - TODO
6. ❌ **fruits_learn.dart** - TODO
7. ❌ **animals_learn.dart** - TODO
8. ❌ **verb_learn.dart** - TODO
9. ❌ **alphabet_q.dart** - TODO
10. ❌ **number_q.dart** - TODO
11. ❌ **colour_q.dart** - TODO
12. ❌ **fruits_q.dart** - TODO
13. ❌ **animals_q.dart** - TODO
14. ❌ **verb_q.dart** - TODO
15. ❌ **quest.dart** - TODO
16. ❌ **leaderboard.dart** - TODO
17. ❌ **login.dart** - TODO
18. ❌ **signup.dart** - TODO

## Quick Start for Each Screen:

1. Add imports (provider + theme_manager)
2. Wrap build method with Consumer<ThemeManager>
3. Replace hardcoded colors with theme colors
4. Test in both light and dark mode

## Example: Complete Screen Update

```dart
// Before
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Color(0xFFCFFFF7),
    body: Container(
      color: Colors.white,
      child: Text(
        'Title',
        style: TextStyle(color: Color(0xFF2D5263)),
      ),
    ),
  );
}

// After
@override
Widget build(BuildContext context) {
  return Consumer<ThemeManager>(
    builder: (context, themeManager, child) {
      return Scaffold(
        backgroundColor: themeManager.backgroundColor,
        body: Container(
          color: themeManager.cardBackground,
          child: Text(
            'Title',
            style: TextStyle(color: themeManager.textPrimary),
          ),
        ),
      );
    },
  );
}
```

## Testing Dark Mode

1. Open app
2. Go to Profile
3. Toggle "Dark Mode" switch
4. Navigate to different screens
5. Verify all UI elements use appropriate dark colors

## Color Scheme Reference

### Light Mode:
- Background: #CFFFF7 (mint green)
- Cards: #FFFFFF (white)
- Text: #2D5263 (dark blue-grey)
- Primary: #69D3E4 (cyan)

### Dark Mode:
- Background: #0F1419 (very dark blue)
- Cards: #1A1F26 (dark grey)
- Text: #E3E6EE (light grey)
- Primary: #4FC3E4 (bright cyan)
