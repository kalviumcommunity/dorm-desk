# dormdesk - Reusable Widgets & Modular Design

A Flutter project demonstrating custom reusable widgets, modular design patterns, and component-based architecture for scalable Flutter applications.

## Learning Objectives Demonstrated

### 1. Understanding Custom Widgets

#### Stateless vs Stateful Custom Widgets
- **StatelessWidget**: For static layouts that don't change after being built
- **StatefulWidget**: For widgets that change over time with user interaction

#### Benefits of Custom Widgets:
- **Code Reusability**: Write once, use everywhere
- **Consistency**: Maintain uniform design across the app
- **Maintainability**: Update in one place, reflect everywhere
- **Team Collaboration**: Shared components for parallel development

### 2. Custom Widget Implementations

#### InfoCard Widget (Stateless)
```dart
class InfoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color? iconColor;
  final VoidCallback? onTap;
  final bool showArrow;

  const InfoCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.iconColor,
    this.onTap,
    this.showArrow = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (iconColor ?? Theme.of(context).colorScheme.primary)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(subtitle),
                  ],
                ),
              ),
              if (showArrow) const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
```

#### LikeButton Widget (Stateful)
```dart
class LikeButton extends StatefulWidget {
  final int initialLikes;
  final Function(int)? onLikeChanged;
  final bool showCount;

  const LikeButton({
    this.initialLikes = 0,
    this.onLikeChanged,
    this.showCount = true,
    super.key,
  });

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> with TickerProviderStateMixin {
  late bool _isLiked;
  late int _likeCount;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _isLiked = false;
    _likeCount = widget.initialLikes;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      if (_isLiked) {
        _likeCount++;
        _animationController.forward().then((_) {
          _animationController.reverse();
        });
      } else {
        _likeCount--;
      }
    });
    widget.onLikeChanged?.call(_likeCount);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _animationController.value,
              child: IconButton(
                icon: Icon(
                  _isLiked ? Icons.favorite : Icons.favorite_border,
                  color: _isLiked ? Colors.red : Colors.grey,
                ),
                onPressed: _toggleLike,
              ),
            );
          },
        ),
        if (widget.showCount)
          Text(
            '$_likeCount',
            style: TextStyle(
              color: _isLiked ? Colors.red : Colors.grey,
              fontWeight: _isLiked ? FontWeight.bold : FontWeight.normal,
            ),
          ),
      ],
    );
  }
}
```

#### ServiceRequestCard Widget (Stateless)
```dart
class ServiceRequestCard extends StatelessWidget {
  final String title;
  final String description;
  final String priority;
  final IconData icon;
  final String status;
  final VoidCallback? onTap;
  final int? likes;

  const ServiceRequestCard({
    required this.title,
    required this.description,
    required this.priority,
    required this.icon,
    required this.status,
    this.onTap,
    this.likes,
    super.key,
  });

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high': return Colors.red;
      case 'medium': return Colors.orange;
      case 'low': return Colors.green;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(description, maxLines: 2, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(priority).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      priority,
                      style: TextStyle(
                        color: _getPriorityColor(priority),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (likes != null) ...[
                    Icon(Icons.favorite_border, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('$likes'),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

#### QuickActionButton Widget (Stateless)
```dart
class QuickActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final VoidCallback? onPressed;
  final double? width;
  final double? height;

  const QuickActionButton({
    required this.label,
    required this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.onPressed,
    this.width,
    this.height,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height ?? 120,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.primary,
          foregroundColor: foregroundColor ?? Theme.of(context).colorScheme.onPrimary,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.all(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: foregroundColor ?? Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
```

### 3. Widget Reusability Across Multiple Screens

#### Usage in ResponsiveHome Screen
```dart
// Quick Actions Section
QuickActionButton(
  label: 'Plumbing',
  icon: Icons.plumbing,
  onPressed: () => _showServiceDetails('Plumbing'),
  width: 100,
),

// Service Requests Section
ServiceRequestCard(
  title: 'Leaky Faucet',
  description: 'Kitchen sink faucet is dripping continuously',
  priority: 'Medium',
  icon: Icons.plumbing,
  status: 'In Progress',
  likes: 3,
  onTap: () => _showServiceDetails('Plumbing'),
),

// Info Cards Section
InfoCard(
  title: 'Room Maintenance',
  subtitle: 'Submit and track maintenance requests',
  icon: Icons.build,
  onTap: () => _showServiceDetails('Maintenance'),
),
```

#### Usage in Services Screen
```dart
// Service Categories
InfoCard(
  title: 'Maintenance',
  subtitle: 'Room repairs and fixtures',
  icon: Icons.build,
  iconColor: Colors.blue,
  onTap: () => _showCategoryDetails('Maintenance'),
),

// Recent Requests
ServiceRequestCard(
  title: 'Broken Window',
  description: 'Window pane cracked in Room 302',
  priority: 'High',
  icon: Icons.window,
  status: 'Pending',
  likes: 5,
  onTap: () => _showRequestDetails('Broken Window'),
),

// Interactive Like Button
LikeButton(
  initialLikes: 42,
  onLikeChanged: (likes) => setState(() => _totalLikes = likes),
),
```

#### Usage in User Input Form
```dart
// Quick Links Section
InfoCard(
  title: 'Dormitory Rules',
  subtitle: 'View community guidelines and policies',
  icon: Icons.gavel,
  iconColor: Theme.of(context).colorScheme.primary,
  onTap: () => _showRules(),
),

// Form Feedback
LikeButton(
  initialLikes: 0,
  showCount: true,
  onLikeChanged: (likes) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Thanks for the feedback! $likes likes')),
    );
  },
),
```

### 4. Modular Design Benefits

#### Code Organization
```
lib/
├── widgets/           # Reusable custom widgets
│   ├── info_card.dart
│   ├── like_button.dart
│   ├── service_request_card.dart
│   └── quick_action_button.dart
├── screens/           # Screen implementations
│   ├── responsive_home.dart
│   ├── services_screen.dart
│   └── user_input_form.dart
└── services/          # Business logic
    ├── auth_service.dart
    └── firestore_service.dart
```

#### Reusability Metrics
- **InfoCard**: Used in 3 different screens with 8+ variations
- **LikeButton**: Used in 2 screens with consistent behavior
- **ServiceRequestCard**: Used in 2 screens with different data
- **QuickActionButton**: Used in 1 screen with 4 variations

#### Consistency Achieved
- **Visual Design**: Same styling across all instances
- **Interaction Patterns**: Consistent tap behavior and feedback
- **Animation**: Uniform transitions and micro-interactions
- **Accessibility**: Consistent semantic structure

### 5. Advanced Widget Features

#### Animation Integration
```dart
// LikeButton with scale animation
AnimatedBuilder(
  animation: _scaleAnimation,
  builder: (context, child) {
    return Transform.scale(
      scale: _scaleAnimation.value,
      child: IconButton(
        icon: Icon(_isLiked ? Icons.favorite : Icons.favorite_border),
        onPressed: _toggleLike,
      ),
    );
  },
),
```

#### Customizable Properties
```dart
// Flexible styling options
InfoCard(
  title: 'Custom Title',
  subtitle: 'Custom subtitle',
  icon: Icons.star,
  iconColor: Colors.purple,  // Custom color
  onTap: customAction,      // Custom behavior
  showArrow: false,        // Hide arrow
),
```

#### State Management
```dart
// Callback-based state communication
LikeButton(
  initialLikes: 10,
  onLikeChanged: (newCount) {
    // Handle like count changes
    updateDatabase(newCount);
    refreshUI();
  },
),
```

### 6. Testing and Verification

#### Widget Testing Strategy
- **Unit Tests**: Test individual widget logic
- **Widget Tests**: Test widget rendering and interactions
- **Integration Tests**: Test widget usage in screens
- **Visual Tests**: Ensure consistent appearance

#### Reusability Verification
- **Multiple Screens**: Same widget works in different contexts
- **Data Variations**: Handles different data gracefully
- **Theme Adaptation**: Respects app theme changes
- **Performance**: No performance degradation with reuse

## App Features Demonstrating Reusable Widgets

### 1. **Modular Widget Library**
- **4 custom widgets** with different complexity levels
- **Consistent API design** across all widgets
- **Flexible customization** options for each widget
- **Proper documentation** and usage examples

### 2. **Multi-Screen Integration**
- **ResponsiveHome**: Uses all 4 widget types
- **ServicesScreen**: Demonstrates advanced widget usage
- **UserInputForm**: Shows widgets in form context
- **Consistent behavior** across all screens

### 3. **Interactive Features**
- **LikeButton**: Animated like functionality with callbacks
- **InfoCard**: Tap interactions with navigation
- **ServiceRequestCard**: Priority-based visual indicators
- **QuickActionButton**: Horizontal scrolling action buttons

### 4. **Design Consistency**
- **Unified styling** across all widget instances
- **Consistent spacing** and typography
- **Theme integration** with Material Design 3
- **Accessibility compliance** with proper semantics

## Widget Usage Examples

### Before Custom Widgets (Code Duplication)
```dart
// Screen 1 - Repeated card code
Card(
  margin: EdgeInsets.all(12),
  child: ListTile(
    leading: Icon(Icons.person, color: Colors.blue),
    title: Text('Profile'),
    subtitle: Text('View details'),
  ),
),

// Screen 2 - Similar card code
Card(
  margin: EdgeInsets.all(12),
  child: ListTile(
    leading: Icon(Icons.settings, color: Colors.green),
    title: Text('Settings'),
    subtitle: Text('Manage preferences'),
  ),
),
```

### After Custom Widgets (DRY Code)
```dart
// Any screen - Reusable widget
InfoCard(
  title: 'Profile',
  subtitle: 'View details',
  icon: Icons.person,
  iconColor: Colors.blue,
  onTap: () => navigateToProfile(),
),

InfoCard(
  title: 'Settings',
  subtitle: 'Manage preferences',
  icon: Icons.settings,
  iconColor: Colors.green,
  onTap: () => navigateToSettings(),
),
```

## Video Explanation

*[Link to your 1-2 minute reusable widgets video here]*

## Getting Started

This project demonstrates custom widget creation and modular design in Flutter applications.

For help getting started with custom widgets:
- [Flutter Widget Basics](https://docs.flutter.dev/development/ui/widgets-intro)
- [Building Custom Widgets](https://docs.flutter.dev/development/ui/widgets)
- [State Management](https://docs.flutter.dev/development/data-and-backend/state-mgmt)

## Key Learnings

### How Reusable Widgets Improve Code Organization
- **DRY Principle**: Don't Repeat Yourself - write once, use everywhere
- **Single Responsibility**: Each widget has one clear purpose
- **Separation of Concerns**: UI logic separated from business logic
- **Easier Maintenance**: Changes in one place affect all instances

### Why Modularity is Important in Team Development
- **Parallel Development**: Team members can work on different widgets simultaneously
- **Consistent Design**: Shared components ensure visual consistency
- **Faster Development**: Reuse existing widgets instead of rewriting
- **Easier Testing**: Isolated widgets are easier to test individually
- **Code Reviews**: Smaller, focused components are easier to review

### Challenges in Refactoring to Widgets
- **Identifying Reusable Patterns**: Finding common UI patterns to extract
- **API Design**: Creating flexible but simple widget interfaces
- **State Management**: Deciding between stateless and stateful widgets
- **Performance**: Ensuring widgets don't introduce performance issues
- **Documentation**: Creating clear usage examples and guidelines

### Best Practices for Widget Design
- **Flexible Parameters**: Allow customization through constructor parameters
- **Callback Functions**: Enable parent widgets to handle interactions
- **Theme Integration**: Respect app theme and system settings
- **Accessibility**: Include semantic labels and proper contrast
- **Error Handling**: Gracefully handle edge cases and invalid inputs
