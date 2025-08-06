# Standard Card Design System

This document outlines the standardized card system implemented to ensure consistent UI across all screens in the Wisme Research App.

## Card Components

### 1. StandardCard
**Purpose**: Default card for most content containers
**Features**: 
- Consistent border radius (12px)
- Standard background color (AppColors.backgroundCard)
- Subtle border with transparency
- Optional highlighting and tap functionality
- Customizable padding and margins

**Usage**:
```dart
StandardCard(
  child: YourContent(),
  // Optional parameters:
  padding: EdgeInsets.all(20),
  margin: EdgeInsets.symmetric(vertical: 8),
  onTap: () => doSomething(),
  isHighlighted: true,
)
```

### 2. AccentCard
**Purpose**: Cards that need color emphasis (warnings, success, special content)
**Features**:
- Same base design as StandardCard
- Colored border for visual emphasis
- No gradients (keeps design minimal)

**Usage**:
```dart
AccentCard(
  accentColor: Colors.orange, // or AppColors.accentGreen
  child: YourContent(),
)
```

### 3. MetricCard
**Purpose**: Displaying metrics and statistics
**Features**:
- Icon + title + value layout
- Consistent typography
- Built-in tap functionality

**Usage**:
```dart
MetricCard(
  title: 'Users',
  value: '42',
  icon: Icons.people_outline,
  iconColor: Colors.white70,
  onTap: () => showDetails(),
)
```

## Design Principles

### ✅ DO:
- Use StandardCard for most content containers
- Use AccentCard sparingly for emphasis
- Keep borders subtle and minimal
- Use consistent border radius (12px)
- Maintain proper spacing between cards

### ❌ DON'T:
- Use complex gradients (keep it minimal)
- Mix different card styles on the same screen
- Use excessive elevation/shadows
- Create custom card containers without using the system

## Migration Notes

The following screens have been updated to use the standardized card system:
- ✅ Analytics Dashboard (`analytics_dashboard_screen.dart`)
- ✅ Welcome Screen (`welcome_screen.dart`)  
- ✅ Learning Method Comparison (`learning_method_comparison_screen.dart`)

## Files Updated

### New Files:
- `lib/widgets/standard_cards.dart` - Contains all standardized card components

### Modified Files:
- `lib/analytics/analytics_dashboard_screen.dart` - All cards updated to use StandardCard/AccentCard
- `lib/onboarding/welcome_screen.dart` - Research points now use StandardCard
- `lib/feedback/learning_method_comparison_screen.dart` - Forms use StandardCard

### Benefits:
1. **Consistency**: All cards look and behave the same way
2. **Maintainability**: Changes to card design happen in one place
3. **Performance**: No unnecessary gradients or complex decorations
4. **Modern**: Clean, minimal design that looks professional
5. **Accessibility**: Consistent touch targets and visual hierarchy

## Future Development

When creating new screens:
1. Import `../widgets/standard_cards.dart`
2. Use StandardCard instead of Container with BoxDecoration
3. Use AccentCard only when you need color emphasis
4. Use MetricCard for displaying statistics

This system ensures a cohesive, professional appearance across the entire research application.
