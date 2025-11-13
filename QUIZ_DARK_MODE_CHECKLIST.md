# Quick Reference: Remaining Changes for animals_q.dart

## Helper Methods to Update:

### 1. _buildProgressBar() - Line ~952
**Signature:** Change to `Widget _buildProgressBar(ThemeManager themeManager)`
**Key Changes:**
- Container gradient: `themeManager.isDarkMode ? [Color(0xFF3C3C3E), Color(0xFF2C2C2E)] : [Colors.white, Color(0xFFF0FDFA)]`
- Border: `themeManager.primary.withOpacity(0.3)`
- Text color: `themeManager.primary`
- Progress indicator backgroundColor: `themeManager.isDarkMode ? Color(0xFF636366) : Color(0xFFE0F2F1)`
- Progress indicator valueColor: `themeManager.primary`

### 2. _buildQuestionCard() - Line ~1000+
**Signature:** Change to `Widget _buildQuestionCard(Map<String, dynamic> question, ThemeManager themeManager)`
**Key Changes:**
- Outer container gradient: `themeManager.isDarkMode ? [Color(0xFF3C3C3E), Color(0xFF2C2C2E)] : [Colors.white, Color(0xFFF0FDFA)]`
- Border: `themeManager.primary.withOpacity(0.3)`
- "What sign is shown?" text color: `themeManager.primary`
- Video/GIF container background: `themeManager.isDarkMode ? Color(0xFF636366) : Colors.white`

### 3. _buildOptionsGrid() - Line ~1050+
**Signature:** Change to `Widget _buildOptionsGrid(List<String> options, int qIdx, ThemeManager themeManager)`
**Key Changes:**
- Pass `themeManager: themeManager` to OptionCard widget

### 4. _buildConfirmBar() - Line ~1090+
**Signature:** Change to `Widget _buildConfirmBar(List<String> options, ThemeManager themeManager)`
**Key Changes:**
- Container gradient: `themeManager.isDarkMode ? [Color(0xFF3C3C3E), Color(0xFF2C2C2E)] : [Colors.white, Color(0xFFF0FDFA)]`
- Border: `themeManager.primary`
- Selected number container: `gradient: themeManager.primaryGradient`
- Selected text color: `themeManager.primary`
- Cancel button text color: `themeManager.isDarkMode ? Color(0xFF8E8E93) : Colors.grey.shade600`
- Confirm button gradient: `themeManager.primaryGradient`

### 5. _buildStableMixMatchProgress() - Line ~1060+
**Signature:** Change to `Widget _buildStableMixMatchProgress(int total, ThemeManager themeManager)`
**Key Changes:**
- LinearProgressIndicator backgroundColor: `themeManager.isDarkMode ? Color(0xFF636366) : Color(0xFFE0F2F1)`
- LinearProgressIndicator valueColor: `themeManager.primary`
- "X / Y matched" text color: `themeManager.isDarkMode ? Color(0xFF8E8E93) : Colors.black54`

### 6. _buildMixMatchInstruction() - Line ~1075+
**Signature:** Change to `Widget _buildMixMatchInstruction(ThemeManager themeManager)`
**Key Changes:**
- Container gradient: `themeManager.isDarkMode ? [Color(0xFF3C3C3E), Color(0xFF2C2C2E)] : [Colors.white, Color(0xFFF0FDFA)]`
- Border: `themeManager.primary.withOpacity(0.3)`
- Instruction icon container: `gradient: themeManager.primaryGradient`
- Instruction text color: `themeManager.primary`

### 7. _buildMatchingAreaStable() - Line ~1100+
**Signature:** Add parameter `required ThemeManager themeManager`
**Key Changes:**
- Video/GIF container background: `themeManager.isDarkMode ? Color(0xFF636366) : Colors.white`
- Border colors for matched/unmatched: Use `themeManager.primary` for matched items
- Letter container gradient when matched: `themeManager.primaryGradient`
- Letter container gradient when unmatched: `themeManager.isDarkMode ? [Color(0xFF2C2C2E), Color(0xFF1C1C1E)] : [Colors.grey.shade50, Colors.grey.shade100]`
- Border for unmatched: `themeManager.isDarkMode ? Color(0xFF636366) : Color(0xFFE3E6EE)`
- Text color: `themeManager.isDarkMode ? Color(0xFFE8E8E8) : Color(0xFF1E1E1E)`

## OptionCard Widget - Line ~1600+
**Signature:** Add parameter `required this.themeManager`
**Add field:** `final ThemeManager themeManager;`
**Key Changes:**
- Selected/Pending gradient: `themeManager.isDarkMode ? [Color(0xFF3C3C3E), Color(0xFF2C2C2E)] : [Colors.white, Color(0xFFF0FDFA)]`
- Default gradient: `themeManager.isDarkMode ? [Color(0xFF2C2C2E), Color(0xFF1C1C1E)] : [Colors.white, Colors.grey.shade50]`
- Border color when selected: `themeManager.primary`
- Border color when pending: `themeManager.secondary`
- Border color default: `themeManager.isDarkMode ? Color(0xFF636366) : Color(0xFFE3E6EE)`
- Number container gradient: `themeManager.primaryGradient`
- Text color when selected/pending: `themeManager.primary`
- Text color default: `themeManager.textPrimary`

## Dialogs to Update:

### 8. _CleanConfirmDialog - Line ~1400+
**In build method, add:** `final themeManager = ThemeManager.of(context, listen: false);`
**Key Changes:**
- Dialog container gradient: `themeManager.isDarkMode ? [Color(0xFF2C2C2E), Color(0xFF1C1C1E)] : [Colors.grey.shade50, Color(0xFFF0FDFA)]`
- Border: `themeManager.primary.withOpacity(0.3)`
- Header container: `gradient: themeManager.primaryGradient`
- Title text color: `themeManager.textPrimary`
- Message text color: `themeManager.isDarkMode ? Color(0xFF8E8E93) : Color(0xFF6B7280)`
- Cancel button border: `themeManager.isDarkMode ? Color(0xFF636366) : Colors.grey.shade300`
- Cancel button text color: `themeManager.isDarkMode ? Color(0xFF8E8E93) : Colors.grey.shade700`
- Confirm button gradient: `themeManager.primaryGradient`

### 9. _GreatWorkDialog - Line ~1500+
**In build method, add:** `final themeManager = ThemeManager.of(context, listen: false);`
**Same color changes as _CleanConfirmDialog**

### 10. _BonusRoundDialog - Line ~1550+
**In build method, add:** `final themeManager = ThemeManager.of(context, listen: false);`
**Same color changes as _CleanConfirmDialog**

---

## After Completing animals_q.dart:

Apply the same pattern to these files (all ~2400+ lines each):
1. **colour_q.dart** - Color quiz
2. **fruits_q.dart** - Fruits quiz  
3. **number_q.dart** - Number quiz
4. **verb_q.dart** - Verb quiz

Each file has the same structure, so you can use this guide for all of them!

## Search & Replace Patterns:
- `Widget _buildHeader(String title)` → `Widget _buildHeader(String title, ThemeManager themeManager)`
- `Widget _buildProgressBar()` → `Widget _buildProgressBar(ThemeManager themeManager)`
- `const Color(0xFF69D3E4)` → `themeManager.primary` (in most cases)
- `const Color(0xFFCFFFF7)` → `themeManager.backgroundColor`
- `Colors.white` → Check context, often becomes conditional
- `Colors.grey` → Usually becomes conditional with dark mode grays

Good luck! This is repetitive but systematic work. 🚀
