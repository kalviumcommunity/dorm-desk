import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ResponsiveHome extends StatefulWidget {
  final User user;
  
  const ResponsiveHome({super.key, required this.user});

  @override
  State<ResponsiveHome> createState() => _ResponsiveHomeState();
}

class _ResponsiveHomeState extends State<ResponsiveHome> {
  int _selectedIndex = 0;
  
  // Navigation items
  final List<NavigationItem> _navItems = [
    NavigationItem(
      icon: Icons.home,
      title: 'Home',
      description: 'Welcome to responsive design',
    ),
    NavigationItem(
      icon: Icons.dashboard,
      title: 'Dashboard',
      description: 'View your statistics and analytics',
    ),
    NavigationItem(
      icon: Icons.settings,
      title: 'Settings',
      description: 'Customize your experience',
    ),
    NavigationItem(
      icon: Icons.person,
      title: 'Profile',
      description: 'Manage your account',
    ),
  ];

  // Sample data cards
  final List<DataCard> _dataCards = [
    DataCard(
      title: 'Total Users',
      value: '1,234',
      icon: Icons.people,
      color: Colors.blue,
      change: '+12%',
    ),
    DataCard(
      title: 'Active Sessions',
      value: '456',
      icon: Icons.access_time,
      color: Colors.green,
      change: '+8%',
    ),
    DataCard(
      title: 'Revenue',
      value: '\$12,345',
      icon: Icons.attach_money,
      color: Colors.purple,
      change: '+23%',
    ),
    DataCard(
      title: 'Performance',
      value: '98.5%',
      icon: Icons.speed,
      color: Colors.orange,
      change: '+2%',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final orientation = MediaQuery.of(context).orientation;
    
    // Responsive breakpoints
    final bool isMobile = screenWidth < 600;
    final bool isTablet = screenWidth >= 600 && screenWidth < 1200;
    final bool isDesktop = screenWidth >= 1200;
    final bool isPortrait = orientation == Orientation.portrait;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Responsive Header
            _buildHeader(context, screenWidth, isMobile, isTablet, isDesktop),
            
            // Main Content Area
            Expanded(
              child: _buildMainContent(
                context, 
                screenWidth, 
                screenHeight, 
                isMobile, 
                isTablet, 
                isDesktop, 
                isPortrait
              ),
            ),
            
            // Responsive Footer
            _buildFooter(context, screenWidth, isMobile),
          ],
        ),
      ),
      // Floating Action Button for mobile
      floatingActionButton: isMobile 
        ? FloatingActionButton(
            onPressed: () => _showAddDialog(context),
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: const Icon(Icons.add, color: Colors.white),
          )
        : null,
    );
  }

  Widget _buildHeader(BuildContext context, double screenWidth, bool isMobile, bool isTablet, bool isDesktop) {
    if (isDesktop) {
      // Desktop Header - Full width navigation
      return Container(
        height: 80,
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Logo/Brand
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.dashboard,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 20),
            
            // Navigation Items
            Expanded(
              child: Row(
                children: _navItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: InkWell(
                      onTap: () => setState(() => _selectedIndex = index),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: _selectedIndex == index 
                            ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                            : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              item.icon,
                              color: _selectedIndex == index 
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey[600],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.title,
                              style: TextStyle(
                                color: _selectedIndex == index 
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey[600],
                                fontWeight: _selectedIndex == index 
                                  ? FontWeight.w600 
                                  : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            
            // User Profile Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      widget.user.email?.substring(0, 1).toUpperCase() ?? 'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.user.email ?? 'User',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Premium User',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else if (isTablet) {
      // Tablet Header - Medium width navigation
      return Container(
        height: 70,
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Logo
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.dashboard,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            
            // Navigation
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _navItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return InkWell(
                    onTap: () => setState(() => _selectedIndex = index),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: _selectedIndex == index 
                          ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                          : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            item.icon,
                            color: _selectedIndex == index 
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey[600],
                            size: 20,
                          ),
                          Text(
                            item.title,
                            style: TextStyle(
                              color: _selectedIndex == index 
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey[600],
                              fontSize: 11,
                              fontWeight: _selectedIndex == index 
                                ? FontWeight.w600 
                                : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      );
    } else {
      // Mobile Header - Compact
      return Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Menu Button
            IconButton(
              onPressed: () => _showMobileMenu(context),
              icon: const Icon(Icons.menu),
            ),
            
            // Logo
            Expanded(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    Icons.dashboard,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
            
            // Profile
            GestureDetector(
              onTap: () => _showProfileMenu(context),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  widget.user.email?.substring(0, 1).toUpperCase() ?? 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildMainContent(
    BuildContext context,
    double screenWidth,
    double screenHeight,
    bool isMobile,
    bool isTablet,
    bool isDesktop,
    bool isPortrait,
  ) {
    if (isDesktop) {
      // Desktop Layout - Sidebar + Main Content
      return Row(
        children: [
          // Sidebar
          Container(
            width: 280,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(2, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                // Sidebar Header
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Text(
                          widget.user.email?.substring(0, 1).toUpperCase() ?? 'U',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.user.email ?? 'User',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Premium Account',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Navigation Items
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _navItems.length,
                    itemBuilder: (context, index) {
                      final item = _navItems[index];
                      return ListTile(
                        leading: Icon(
                          item.icon,
                          color: _selectedIndex == index 
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey[600],
                        ),
                        title: Text(
                          item.title,
                          style: TextStyle(
                            color: _selectedIndex == index 
                              ? Theme.of(context).colorScheme.primary
                              : Colors.black87,
                            fontWeight: _selectedIndex == index 
                              ? FontWeight.w600 
                              : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(
                          item.description,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        selected: _selectedIndex == index,
                        selectedTileColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        onTap: () => setState(() => _selectedIndex = index),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Main Content Area
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.02),
              child: _buildContentGrid(context, screenWidth, isDesktop),
            ),
          ),
        ],
      );
    } else if (isTablet) {
      // Tablet Layout - Two Column
      return Padding(
        padding: EdgeInsets.all(screenWidth * 0.03),
        child: Column(
          children: [
            // Stats Cards Row
            _buildStatsCards(context, screenWidth, 2),
            const SizedBox(height: 20),
            
            // Content Grid
            Expanded(
              child: _buildContentGrid(context, screenWidth, isDesktop),
            ),
          ],
        ),
      );
    } else {
      // Mobile Layout - Single Column
      return Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          children: [
            // Stats Cards
            _buildStatsCards(context, screenWidth, 1),
            const SizedBox(height: 16),
            
            // Content List
            Expanded(
              child: _buildContentList(context, screenWidth),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildStatsCards(BuildContext context, double screenWidth, int columns) {
    final crossAxisCount = columns;
    final childAspectRatio = screenWidth > 800 ? 2.5 : 2.0;
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: _dataCards.length,
      itemBuilder: (context, index) {
        final card = _dataCards[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: card.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      card.icon,
                      color: card.color,
                      size: 20,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: card.change.startsWith('+') 
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      card.change,
                      style: TextStyle(
                        color: card.change.startsWith('+') 
                          ? Colors.green
                          : Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                card.title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              FittedBox(
                child: Text(
                  card.value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContentGrid(BuildContext context, double screenWidth, bool isDesktop) {
    final crossAxisCount = isDesktop ? 3 : 2;
    final childAspectRatio = isDesktop ? 1.2 : 1.0;
    
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Placeholder
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.image,
                      color: Theme.of(context).colorScheme.primary,
                      size: 40,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Content Item ${index + 1}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Description for content item ${index + 1} with more details',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContentList(BuildContext context, double screenWidth) {
    return ListView.builder(
      itemCount: 8,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.article,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            title: Text(
              'List Item ${index + 1}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Description for list item ${index + 1}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Tapped on item ${index + 1}'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildFooter(BuildContext context, double screenWidth, bool isMobile) {
    if (isMobile) {
      // Mobile Footer - Bottom Navigation
      return Container(
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _navItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return InkWell(
              onTap: () => setState(() => _selectedIndex = index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item.icon,
                      color: _selectedIndex == index 
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey[600],
                      size: 20,
                    ),
                    Text(
                      item.title,
                      style: TextStyle(
                        color: _selectedIndex == index 
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey[600],
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      );
    } else {
      // Tablet/Desktop Footer - Simple bar
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              ' 2024 Responsive App',
              style: TextStyle(color: Colors.grey[600]),
            ),
            Row(
              children: [
                TextButton(
                  onPressed: () {},
                  child: Text('Privacy'),
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: () {},
                  child: Text('Terms'),
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: () {},
                  child: Text('Contact'),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }

  void _showMobileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // User Info
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    widget.user.email?.substring(0, 1).toUpperCase() ?? 'U',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.user.email ?? 'User',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Premium User',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Menu Items
            ..._navItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return ListTile(
                leading: Icon(item.icon),
                title: Text(item.title),
                subtitle: Text(item.description),
                onTap: () {
                  setState(() => _selectedIndex = index);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  void _showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.user.email ?? 'User',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Edit Profile'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Item'),
        content: const TextField(
          decoration: InputDecoration(
            labelText: 'Item Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

// Helper classes
class NavigationItem {
  final IconData icon;
  final String title;
  final String description;

  NavigationItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class DataCard {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String change;

  DataCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.change,
  });
}