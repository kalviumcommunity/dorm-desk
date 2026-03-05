import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';

/// Comprehensive UI States Handling Demo
/// 
/// This demo showcases proper handling of loading, error, and empty states
/// in Flutter applications with best practices for user experience.
class UIStatesDemo extends StatefulWidget {
  const UIStatesDemo({super.key});

  @override
  State<UIStatesDemo> createState() => _UIStatesDemoState();
}

class _UIStatesDemoState extends State<UIStatesDemo> {
  // State management for different scenarios
  DataState _dataState = DataState.loading;
  List<DataItem> _items = [];
  String? _errorMessage;
  bool _isRefreshing = false;

  // Controllers for different scenarios
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // Simulate initial loading
    _loadData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Simulate data loading with different states
  Future<void> _loadData({bool isRefresh = false}) async {
    if (isRefresh) {
      setState(() {
        _isRefreshing = true;
      });
    } else {
      setState(() {
        _dataState = DataState.loading;
        _errorMessage = null;
      });
    }

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Simulate different scenarios
    final random = Random();
    final scenario = random.nextInt(10);

    if (scenario == 0) {
      // Error state
      setState(() {
        _dataState = DataState.error;
        _errorMessage = 'Failed to load data: Network connection lost. Please check your internet connection and try again.';
        _isRefreshing = false;
      });
    } else if (scenario == 1) {
      // Empty state
      setState(() {
        _dataState = DataState.empty;
        _items = [];
        _errorMessage = null;
        _isRefreshing = false;
      });
    } else {
      // Success state with data
      final mockItems = List.generate(
        scenario == 2 ? 0 : random.nextInt(8) + 3,
        (index) => DataItem(
          id: 'item_$index',
          title: 'Sample Item ${index + 1}',
          description: 'This is a sample data item for demonstration purposes.',
          timestamp: DateTime.now().subtract(Duration(hours: random.nextInt(24))),
        ),
      );
      
      setState(() {
        _dataState = DataState.loaded;
        _items = mockItems;
        _errorMessage = null;
        _isRefreshing = false;
      });
    }
  }

  void _refreshData() {
    _loadData(isRefresh: true);
  }

  void _retryLoad() {
    _loadData();
  }

  void _simulateError() {
    setState(() {
      _dataState = DataState.error;
      _errorMessage = 'Simulated error: This is a test error message for demonstration.';
    });
  }

  void _simulateEmpty() {
    setState(() {
      _dataState = DataState.empty;
      _items = [];
      _errorMessage = null;
    });
  }

  void _clearError() {
    setState(() {
      _dataState = DataState.loading;
      _errorMessage = null;
    });
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UI States Handling Demo'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Refresh Data',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'error':
                  _simulateError();
                  break;
                case 'empty':
                  _simulateEmpty();
                  break;
                case 'clear':
                  _clearError();
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'error',
                child: ListTile(
                  leading: Icon(Icons.error_outline),
                  title: Text('Simulate Error'),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
              const PopupMenuItem(
                value: 'empty',
                child: ListTile(
                  leading: Icon(Icons.inbox_outlined),
                  title: Text('Simulate Empty'),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: ListTile(
                  leading: Icon(Icons.clear_all),
                  title: Text('Clear & Reload'),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ],
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        children: [
          _buildBasicStatesDemo(),
          _buildAdvancedStatesDemo(),
          _buildCustomLoadersDemo(),
          _buildRealWorldExample(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentPage,
        onTap: (index) {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outline),
            activeIcon: Icon(Icons.info),
            label: 'Basic',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Advanced',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.animation_outlined),
            activeIcon: Icon(Icons.animation),
            label: 'Loaders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.apps_outlined),
            activeIcon: Icon(Icons.apps),
            label: 'Real World',
          ),
        ],
      ),
    );
  }

  // ==================== BASIC STATES DEMO ====================

  Widget _buildBasicStatesDemo() {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Basic UI States',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Demonstrates fundamental loading, error, and empty states with proper UX patterns.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: _buildStateContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStateContent() {
    switch (_dataState) {
      case DataState.loading:
        return _buildLoadingState();
      case DataState.error:
        return _buildErrorState();
      case DataState.empty:
        return _buildEmptyState();
      case DataState.loaded:
        return _buildLoadedState();
    }
  }

  Widget _buildLoadingState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(
          valueColor: Colors.blue,
          strokeWidth: 4,
        ),
        const SizedBox(height: 24),
        const Text(
          'Loading data...',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Please wait while we fetch your content',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Oops! Something went wrong',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            _errorMessage ?? 'An unknown error occurred',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: _retryLoad,
          icon: const Icon(Icons.refresh),
          label: const Text('Retry'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.inbox_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'No data available',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'There are no items to display yet.\nTap the button below to get started!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: _loadData,
          icon: const Icon(Icons.add),
          label: const Text('Load Sample Data'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadedState() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Data Loaded Successfully',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_isRefreshing)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: _items.length,
            itemBuilder: (context, index) {
              final item = _items[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(item.title),
                  subtitle: Text(item.description),
                  trailing: Text(
                    _formatTimestamp(item.timestamp),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ==================== ADVANCED STATES DEMO ====================

  Widget _buildAdvancedStatesDemo() {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Advanced State Patterns',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Advanced patterns including skeleton loaders, shimmer effects, and progressive loading.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    _buildSkeletonCard(),
                    _buildShimmerCard(),
                    _buildProgressiveCard(),
                    _buildRetryCard(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 120,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildShimmerLine(width: double.infinity, height: 20),
            const SizedBox(height: 12),
            _buildShimmerLine(width: double.infinity, height: 14),
            const SizedBox(height: 8),
            _buildShimmerLine(width: 80, height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLine({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey.shade200,
            Colors.grey.shade100,
            Colors.grey.shade200,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildProgressiveCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const LinearProgressIndicator(
              value: 0.7,
              backgroundColor: Colors.grey.shade200,
              valueColor: Colors.blue,
            ),
            const SizedBox(height: 12),
            const Text(
              'Loading... 70% complete',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            const Text(
              'Downloading large file...',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRetryCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.wifi_off,
              size: 48,
              color: Colors.orange,
            ),
            const SizedBox(height: 12),
            const Text(
              'Connection Lost',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Unable to connect to server. Please check your internet connection.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _retryLoad,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Opening offline mode...'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    icon: const Icon(Icons.offline_bolt),
                    label: const Text('Offline Mode'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==================== CUSTOM LOADERS DEMO ====================

  Widget _buildCustomLoadersDemo() {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Custom Loading Animations',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Various loading animations for different contexts and use cases.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.2,
                  children: [
                    _buildPulseLoader(),
                    _buildBounceLoader(),
                    _buildWaveLoader(),
                    _buildDotsLoader(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPulseLoader() {
    return Card(
      child: Center(
        child: TweenAnimationBuilder(
          tween: Tween<double>(begin: 0.8, end: 1.2),
          duration: const Duration(seconds: 1),
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cloud_download,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBounceLoader() {
    return Card(
      child: Center(
        child: TweenAnimationBuilder(
          tween: Tween<double>(begin: -20, end: 20),
          duration: const Duration(milliseconds: 800),
          builder: (context, offset, child) {
            return Transform.translate(
              offset: Offset(0, offset),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.refresh,
                  color: Colors.white,
                  size: 25,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildWaveLoader() {
    return Card(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 60,
              height: 40,
              child: TweenAnimationBuilder(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(seconds: 2),
                builder: (context, progress, child) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: Colors.purple,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Processing...',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDotsLoader() {
    return Card(
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            return TweenAnimationBuilder(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 600 + (index * 200)),
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 12,
                    height: 12,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }

  // ==================== REAL WORLD EXAMPLE ====================

  Widget _buildRealWorldExample() {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Real-World Application',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Complete example showing how to handle UI states in a production app scenario.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: _buildRealWorldContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRealWorldContent() {
    return FutureBuilder<RealWorldData>(
      future: _simulateRealWorldData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildRealWorldLoading();
        }

        if (snapshot.hasError) {
          return _buildRealWorldError(snapshot.error.toString());
        }

        if (!snapshot.hasData) {
          return _buildRealWorldEmpty();
        }

        final data = snapshot.data!;
        return _buildRealWorldSuccess(data);
      },
    );
  }

  Future<RealWorldData> _simulateRealWorldData() async {
    await Future.delayed(const Duration(seconds: 2));
    
    final random = Random();
    final scenario = random.nextInt(10);
    
    if (scenario < 3) {
      throw Exception('Network timeout: Unable to reach server');
    }
    
    return RealWorldData(
      userProfile: UserProfile(
        name: 'John Doe',
        email: 'john.doe@example.com',
        avatar: 'https://picsum.photos/seed/user123/200',
        isPremium: random.nextBool(),
      ),
      notifications: List.generate(
        random.nextInt(5) + 1,
        (index) => Notification(
          id: 'notif_$index',
          title: 'Notification ${index + 1}',
          message: 'This is a sample notification message.',
          timestamp: DateTime.now().subtract(Duration(hours: random.nextInt(24))),
          isRead: random.nextBool(),
        ),
      ),
      settings: AppSettings(
        theme: random.nextBool() ? 'dark' : 'light',
        notifications: random.nextBool(),
        autoBackup: random.nextBool(),
        language: 'English',
      ),
    );
  }

  Widget _buildRealWorldLoading() {
    return Column(
      children: [
        // Header skeleton
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildSkeletonCircle(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSkeletonLine(width: 120, height: 20),
                    const SizedBox(height: 8),
                    _buildSkeletonLine(width: 80, height: 14),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(),
        // Content skeleton
        Expanded(
          child: ListView.builder(
            itemCount: 5,
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSkeletonLine(width: double.infinity, height: 16),
                      const SizedBox(height: 8),
                      _buildSkeletonLine(width: double.infinity, height: 12),
                      const SizedBox(height: 8),
                      _buildSkeletonLine(width: 100, height: 12),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSkeletonCircle() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildSkeletonLine({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildRealWorldError(String error) {
    return Column(
      children: [
        // Error header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            border: Border(bottom: BorderSide(color: Colors.red.shade200)),
          ),
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.red),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Connection Error',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Error content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.wifi_off,
                    size: 64,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Unable to connect to server',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    error,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _retryLoad,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry Connection'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Opening offline mode...'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        icon: const Icon(Icons.offline_bolt),
                        label: const Text('Offline Mode'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRealWorldEmpty() {
    return Column(
      children: [
        // Empty header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'No Data Available',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Start by adding your first item or check back later for new content.',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        const Divider(),
        // Empty content
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.inbox_outlined,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'No notifications yet',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'When you receive notifications, they\'ll appear here',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: 200,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Opening notification settings...'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    icon: const Icon(Icons.settings),
                    label: const Text('Notification Settings'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRealWorldSuccess(RealWorldData data) {
    return Column(
      children: [
        // Success header with user profile
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.outline)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundImage: NetworkImage(data.userProfile.avatar),
                backgroundColor: Colors.grey.shade300,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.userProfile.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      data.userProfile.email,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    if (data.userProfile.isPremium)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'PREMIUM',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Success content
        Expanded(
          child: ListView.builder(
            itemCount: data.notifications.length,
            itemBuilder: (context, index) {
              final notification = data.notifications[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: notification.isRead 
                        ? Colors.grey.shade300 
                        : Theme.of(context).colorScheme.primary,
                    child: Icon(
                      notification.isRead ? Icons.done : Icons.notifications,
                      color: notification.isRead ? Colors.grey.shade600 : Colors.white,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    notification.title,
                    style: TextStyle(
                      fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                      color: notification.isRead ? Colors.grey.shade600 : null,
                    ),
                  ),
                  subtitle: Text(notification.message),
                  trailing: Text(
                    _formatTimestamp(notification.timestamp),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ==================== UTILITY METHODS ====================

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

// ==================== DATA MODELS ====================

enum DataState {
  loading,
  loaded,
  error,
  empty,
}

class DataItem {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;

  DataItem({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
  });
}

class RealWorldData {
  final UserProfile userProfile;
  final List<Notification> notifications;
  final AppSettings settings;

  RealWorldData({
    required this.userProfile,
    required this.notifications,
    required this.settings,
  });
}

class UserProfile {
  final String name;
  final String email;
  final String avatar;
  final bool isPremium;

  UserProfile({
    required this.name,
    required this.email,
    required this.avatar,
    required this.isPremium,
  });
}

class Notification {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;

  Notification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.isRead,
  });
}

class AppSettings {
  final String theme;
  final bool notifications;
  final bool autoBackup;
  final String language;

  AppSettings({
    required this.theme,
    required this.notifications,
    required this.autoBackup,
    required this.language,
  });
}
