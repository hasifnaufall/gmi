# Dark Mode Implementation Guide for Quiz Files

This guide shows the pattern for implementing dark mode in all quiz files (animals_q.dart, colour_q.dart, fruits_q.dart, number_q.dart, verb_q.dart).

## ✅ Already Updated:
- alphabet_q.dart - COMPLETE
- animals_q.dart - PARTIAL (imports, modal sheet, _CompactQuizCard)

## 🔄 Pattern to Apply:

### 1. Add Imports (at top of file)
```dart
import 'package:provider/provider.dart';
import 'theme_manager.dart';
```

### 2. Update Modal Bottom Sheet
In `showXXXQuizSelection` function:
```dart
Future<void> showXXXQuizSelection(BuildContext context) {
  final themeManager = ThemeManager.of(context, listen: false);
  return showModalBottomSheet(
    // ...
    builder: (_) => Container(
      decoration: BoxDecoration(
        color: themeManager.isDarkMode ? const Color(0xFF2C2C2E) : Colors.white,
        // ...
```

Update drag handle color:
```dart
color: themeManager.isDarkMode 
    ? const Color(0xFF8E8E93) 
    : Colors.grey.shade300,
```

Update header gradient and text:
```dart
gradient: LinearGradient(
  colors: themeManager.isDarkMode
      ? const [Color(0xFF8B1F1F), Color(0xFFD23232)]
      : const [Color(0xFF69D3E4), Color(0xFF4FC3E4)],
  // ...
)
Text('Select Quiz Mode',
  style: GoogleFonts.montserrat(
    color: themeManager.isDarkMode 
        ? const Color(0xFFE8E8E8) 
        : const Color(0xFF1E1E1E),
```

### 3. Update _CompactQuizCard
Add themeManager to build method:
```dart
@override
Widget build(BuildContext context) {
  final themeManager = ThemeManager.of(context, listen: false);
  // ...
  gradient: LinearGradient(
    colors: themeManager.isDarkMode
        ? [const Color(0xFF3C3C3E), const Color(0xFF2C2C2E)]
        : [Colors.grey.shade50, Colors.grey.shade100],
```

Update text colors:
```dart
color: themeManager.isDarkMode 
    ? const Color(0xFFE8E8E8) 
    : const Color(0xFF1E1E1E),
```

### 4. Wrap Build Methods with Consumer<ThemeManager>
In `_buildMultipleChoiceQuiz()` and `_buildMixMatchQuiz()`:
```dart
Widget _buildMultipleChoiceQuiz() {
  // ...
  return Consumer<ThemeManager>(
    builder: (context, themeManager, child) {
      return WillPopScope(
        // ...
        child: Scaffold(
          backgroundColor: themeManager.backgroundColor,
```

### 5. Update Helper Methods to Accept ThemeManager
```dart
Widget _buildHeader(String title, ThemeManager themeManager) { // ... }
Widget _buildProgressBar(ThemeManager themeManager) { // ... }
Widget _buildQuestionCard(Map<String, dynamic> question, ThemeManager themeManager) { // ... }
Widget _buildOptionsGrid(List<String> options, int qIdx, ThemeManager themeManager) { // ... }
Widget _buildConfirmBar(List<String> options, ThemeManager themeManager) { // ... }
Widget _buildStableMixMatchProgress(int total, ThemeManager themeManager) { // ... }
Widget _buildMixMatchInstruction(ThemeManager themeManager) { // ... }
Widget _buildMatchingAreaStable({..., required ThemeManager themeManager}) { // ... }
```

### 6. Update _buildHeader
```dart
Widget _buildHeader(String title, ThemeManager themeManager) {
  return Row(
    children: [
      IconButton(
        icon: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: themeManager.isDarkMode
                  ? [const Color(0xFF3C3C3E), const Color(0xFF2C2C2E)]
                  : [const Color(0xFFFFFFFF), const Color(0xFFF0FDFA)],
            ),
            border: Border.all(color: themeManager.primary.withOpacity(0.3)),
          ),
          child: Icon(Icons.arrow_back_ios_new_rounded, color: themeManager.primary),
        ),
      ),
      Text(title, style: GoogleFonts.montserrat(color: themeManager.primary)),
      Container(
        decoration: BoxDecoration(gradient: themeManager.primaryGradient),
        child: Text("Lvl ${QuestStatus.level}"),
      ),
    ],
  );
}
```

### 7. Update _buildProgressBar
```dart
Widget _buildProgressBar(ThemeManager themeManager) {
  // ...
  Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: themeManager.isDarkMode
            ? [const Color(0xFF3C3C3E), const Color(0xFF2C2C2E)]
            : [Colors.white, Color(0xFFF0FDFA)],
      ),
      border: Border.all(color: themeManager.primary.withOpacity(0.3)),
    ),
  ),
  // Remaining segment color:
  color: themeManager.isDarkMode 
      ? const Color(0xFF636366) 
      : const Color(0xFFE0F2F1),
```

### 8. Update _buildQuestionCard
```dart
Widget _buildQuestionCard(Map<String, dynamic> question, ThemeManager themeManager) {
  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: themeManager.isDarkMode
            ? [const Color(0xFF3C3C3E), const Color(0xFF2C2C2E)]
            : [const Color(0xFFFFFFFF), const Color(0xFFF0FDFA)],
      ),
      border: Border.all(color: themeManager.primary.withOpacity(0.3)),
    ),
    child: Column(
      children: [
        Text("What sign is shown?",
          style: GoogleFonts.montserrat(color: themeManager.primary)),
        Container(
          decoration: BoxDecoration(
            color: themeManager.isDarkMode 
                ? const Color(0xFF636366) 
                : Colors.white,
```

### 9. Update OptionCard Widget
Add themeManager parameter:
```dart
class OptionCard extends StatelessWidget {
  final ThemeManager themeManager;
  const OptionCard({
    required this.themeManager,
    // ...
  });
  
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      decoration: BoxDecoration(
        gradient: isSelected || isPending
            ? LinearGradient(
                colors: themeManager.isDarkMode
                    ? [const Color(0xFF3C3C3E), const Color(0xFF2C2C2E)]
                    : [const Color(0xFFFFFFFF), const Color(0xFFF0FDFA)],
              )
            : LinearGradient(
                colors: themeManager.isDarkMode
                    ? [const Color(0xFF2C2C2E), const Color(0xFF1C1C1E)]
                    : [const Color(0xFFFFFFFF), const Color(0xFFFAFAFA)],
              ),
        border: Border.all(
          color: isSelected
              ? themeManager.primary
              : (isPending 
                  ? themeManager.secondary 
                  : (themeManager.isDarkMode 
                      ? const Color(0xFF636366) 
                      : const Color(0xFFE3E6EE))),
        ),
      ),
      child: // ...
        Container(
          decoration: BoxDecoration(gradient: themeManager.primaryGradient),
          child: Text(number.toString()),
        ),
        Text(option,
          style: GoogleFonts.montserrat(
            color: isSelected || isPending
                ? themeManager.primary
                : themeManager.textPrimary,
```

### 10. Update Dialogs
In `_CleanConfirmDialog`, `_GreatWorkDialog`, `_BonusRoundDialog`:
```dart
@override
Widget build(BuildContext context) {
  final themeManager = ThemeManager.of(context, listen: false);
  return Dialog(
    child: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: themeManager.isDarkMode
              ? [const Color(0xFF2C2C2E), const Color(0xFF1C1C1E)]
              : [const Color(0xFFFAFAFA), const Color(0xFFF0FDFA)],
        ),
        border: Border.all(color: themeManager.primary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: themeManager.primaryGradient,
            ),
          ),
          Text(title, style: GoogleFonts.montserrat(color: themeManager.textPrimary)),
          Text(message, style: GoogleFonts.montserrat(
            color: themeManager.isDarkMode 
                ? const Color(0xFF8E8E93) 
                : const Color(0xFF6B7280))),
          // Buttons
          Container(
            decoration: BoxDecoration(gradient: themeManager.primaryGradient),
          ),
```

### 11. Update Mix & Match Components
```dart
Widget _buildMixMatchInstruction(ThemeManager themeManager) {
  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: themeManager.isDarkMode
            ? [const Color(0xFF3C3C3E), const Color(0xFF2C2C2E)]
            : [const Color(0xFFFFFFFF), const Color(0xFFF0FDFA)],
      ),
    ),
    child: Row(
      children: [
        Container(decoration: BoxDecoration(gradient: themeManager.primaryGradient)),
        Text("Drag letters...", style: GoogleFonts.montserrat(color: themeManager.primary)),
```

### 12. Update Progress for Mix & Match
```dart
Widget _buildStableMixMatchProgress(int total, ThemeManager themeManager) {
  return Column(
    children: [
      LinearProgressIndicator(
        backgroundColor: themeManager.isDarkMode 
            ? const Color(0xFF636366) 
            : const Color(0xFFE0F2F1),
        valueColor: AlwaysStoppedAnimation(themeManager.primary),
      ),
      Text("$matched / $total matched",
        style: GoogleFonts.montserrat(
          color: themeManager.isDarkMode 
              ? const Color(0xFF8E8E93) 
              : Colors.black54)),
```

### 13. Update _buildConfirmBar
```dart
Widget _buildConfirmBar(List<String> options, ThemeManager themeManager) {
  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: themeManager.isDarkMode
            ? [const Color(0xFF3C3C3E), const Color(0xFF2C2C2E)]
            : [const Color(0xFFFFFFFF), const Color(0xFFF0FDFA)],
      ),
      border: Border.all(color: themeManager.primary),
    ),
    child: Row(
      children: [
        Container(decoration: BoxDecoration(gradient: themeManager.primaryGradient)),
        Text('Selected: ${options[idx]}',
          style: GoogleFonts.montserrat(color: themeManager.primary)),
        TextButton(
          child: Text('Cancel', style: GoogleFonts.montserrat(
            color: themeManager.isDarkMode 
                ? const Color(0xFF8E8E93) 
                : Colors.grey.shade600)),
        ),
```

## 🎨 Color Reference:

### Light Mode (Cyan/Turquoise):
- Primary: `Color(0xFF69D3E4)`, `Color(0xFF4FC3E4)`
- Background: `Color(0xFFCFFFF7)`
- Card: `Colors.white`, `Color(0xFFF0FDFA)`
- Text: `Color(0xFF2D5263)`, `Color(0xFF1E1E1E)`

### Dark Mode (Red Accent):
- Primary: `Color(0xFFD23232)`, `Color(0xFF8B1F1F)`
- Background: `Color(0xFF1C1C1E)`, `Color(0xFF2C2C2E)`
- Card: `Color(0xFF636366)`, `Color(0xFF8E8E93)`
- Text: `Color(0xFFE8E8E8)`
- Secondary Text: `Color(0xFF8E8E93)`

## 📋 Files to Update:
- [x] alphabet_q.dart - ✅ COMPLETE
- [ ] animals_q.dart - 🔄 IN PROGRESS (40% done)
- [ ] colour_q.dart - ⏳ PENDING
- [ ] fruits_q.dart - ⏳ PENDING
- [ ] number_q.dart - ⏳ PENDING
- [ ] verb_q.dart - ⏳ PENDING

## 🚀 Quick Application Steps:
1. Add imports at top
2. Update modal bottom sheet with themeManager
3. Update _CompactQuizCard
4. Wrap main build methods with Consumer<ThemeManager>
5. Add themeManager parameter to all helper methods
6. Update each helper method's colors/gradients
7. Update OptionCard to accept themeManager
8. Update all dialogs
9. Test in both light and dark modes

This pattern is consistent across all quiz files!
