import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';

/// Advanced UI States Handling Demo
/// 
/// This demo showcases sophisticated patterns for handling loading, error, and empty states
/// with real-world examples, custom animations, and production-ready implementations.
class AdvancedUIStatesDemo extends StatefulWidget {
  const AdvancedUIStatesDemo({super.key});

  @override
  State<AdvancedUIStatesDemo> createState() => _AdvancedUIStatesDemoState();
}

class _AdvancedUIStatesDemoState extends State<AdvancedUIStatesDemo> with TickerProviderStateMixin {
  // Advanced state management
  ViewState _viewState = ViewState.loading;
  List<DataItem> _items = [];
  String? _errorMessage;
  bool _isRefreshing = false;
  bool _isOffline = false;
  int _retryCount = 0;
  
  // Controllers for different scenarios
  late PageController _pageController;
  int _currentPage = 0;
  
  // Animation controllers
  late AnimationController _shimmerController;
  late AnimationController _pulseController;
  late AnimationController _dotsController;
  
  // Stream simulation
  Stream<List<DataItem>>? _dataStream;
  StreamSubscription<List<DataItem>>? _streamSubscription;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    // Initialize animation controllers
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    
    _dotsController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
    
    // Start initial loading
    _loadData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _shimmerController.dispose();
    _pulseController.dispose();
    _dotsController.dispose();
    _streamSubscription?.cancel();
    super.dispose();
  }

  // Advanced data loading with retry logic and offline support
  Future<void> _loadData({bool isRefresh = false, bool useStream = false}) async {
    if (isRefresh) {
      setState(() {
        _isRefreshing = true;
      });
    } else {
      setState(() {
        _viewState = ViewState.loading;
        _errorMessage = null;
        _retryCount = 0;
      });
    }

    try {
      // Simulate network delay with exponential backoff
      final delay = Duration(milliseconds: 1000 * (pow(2, _retryCount).toInt()));
      await Future.delayed(delay);

      // Simulate different scenarios
      final random = Random();
      final scenario = random.nextInt(10);

      if (_isOffline && random.nextBool()) {
        throw NetworkException('No internet connection. Please check your network settings.');
      }

      if (scenario == 0) {
        throw ServerException('Server error: Internal server error (500)');
      } else if (scenario == 1) {
        throw TimeoutException('Request timeout: Server took too long to respond');
      } else if (scenario == 2) {
        throw ValidationException('Invalid data format received from server');
      } else if (scenario == 3) {
        // Empty state
        setState(() {
          _viewState = ViewState.empty;
          _items = [];
          _errorMessage = null;
          _isRefreshing = false;
        });
        return;
      } else {
        // Success state
        final mockItems = List.generate(
          random.nextInt(8) + 3,
          (index) => DataItem(
            id: 'item_$index',
            title: 'Advanced Item ${index + 1}',
            description: 'This is an advanced data item with enhanced features.',
            timestamp: DateTime.now().subtract(Duration(hours: random.nextInt(24))),
            category: _getRandomCategory(),
            priority: _getRandomPriority(),
            isFavorite: random.nextBool(),
          ),
        );
        
        setState(() {
          _viewState = ViewState.loaded;
          _items = mockItems;
          _errorMessage = null;
          _isRefreshing = false;
          _retryCount = 0;
        });
      }
    } catch (e) {
      // Advanced error handling
      String userFriendlyMessage = _getUserFriendlyErrorMessage(e);
      
      setState(() {
        _viewState = ViewState.error;
        _errorMessage = userFriendlyMessage;
        _isRefreshing = false;
        _retryCount++;
      });
      
      // Log error for debugging
      _logError(e);
    }
  }

  // Stream-based data loading
  void _loadDataStream() {
    setState(() {
      _viewState = ViewState.loading;
      _errorMessage = null;
    });

    _dataStream = _createDataStream();
    
    _streamSubscription = _dataStream!.listen(
      (data) {
        if (mounted) {
          setState(() {
            if (data.isEmpty) {
              _viewState = ViewState.empty;
              _items = [];
            } else {
              _viewState = ViewState.loaded;
              _items = data;
            }
            _errorMessage = null;
          });
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _viewState = ViewState.error;
            _errorMessage = _getUserFriendlyErrorMessage(error);
          });
          _logError(error);
        }
      },
    );
  }

  Stream<List<DataItem>> _createDataStream() {
    return Stream.periodic(const Duration(seconds: 3), (count) {
      final random = Random();
      
      if (count == 0) {
        // Initial loading
        return <DataItem>[];
      } else if (random.nextBool()) {
        // Simulate error
        throw StreamException('Stream connection lost');
      } else if (random.nextInt(5) == 0) {
        // Empty data
        return <DataItem>[];
      } else {
        // Success data
        return List.generate(
          random.nextInt(6) + 2,
          (index) => DataItem(
            id: 'stream_item_$index',
            title: 'Stream Item ${index + 1}',
            description: 'Real-time data from stream',
            timestamp: DateTime.now(),
            category: _getRandomCategory(),
            priority: _getRandomPriority(),
            isFavorite: random.nextBool(),
          ),
        );
      }
    });
  }

  // Advanced retry logic with exponential backoff
  Future<void> _retryWithBackoff() async {
    if (_retryCount >= 3) {
      _showRetryLimitDialog();
      return;
    }
    
    await _loadData();
  }

  void _showRetryLimitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Retry Limit Reached'),
        content: const Text('You\'ve reached the maximum number of retry attempts. Please check your connection and try again later.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _retryCount = 0;
              });
              _loadData();
            },
            child: const Text('Reset & Retry'),
          ),
        ],
      ),
    );
  }

  // Error handling utilities
  String _getUserFriendlyErrorMessage(dynamic error) {
    if (error is NetworkException) {
      return '🌐 Network Error: ${error.message}';
    } else if (error is ServerException) {
      return '🔧 Server Error: ${error.message}';
    } else if (error is TimeoutException) {
      return '⏰ Timeout Error: ${error.message}';
    } else if (error is ValidationException) {
      return '⚠️ Data Error: ${error.message}';
    } else if (error is StreamException) {
      return '📡 Stream Error: ${error.message}';
    } else {
      return '❌ An unexpected error occurred. Please try again.';
    }
  }

  void _logError(dynamic error) {
    // In a real app, this would log to a service like Firebase Crashlytics
    debugPrint('Error occurred: $error');
    debugPrint('Stack trace: ${StackTrace.current}');
  }

  // Utility methods
  String _getRandomCategory() {
    final categories = ['Work', 'Personal', 'Shopping', 'Health', 'Education'];
    return categories[Random().nextInt(categories.length)];
  }

  Priority _getRandomPriority() {
    final priorities = [Priority.low, Priority.medium, Priority.high];
    return priorities[Random().nextInt(priorities.length)];
  }

  // UI Actions
  void _refreshData() {
    _loadData(isRefresh: true);
  }

  void _toggleOffline() {
    setState(() {
      _isOffline = !_isOffline;
    });
    
    if (!_isOffline) {
      _loadData();
    }
  }

  void _simulateSpecificError(String errorType) {
    switch (errorType) {
      case 'network':
        setState(() {
          _viewState = ViewState.error;
          _errorMessage = '🌐 Network Error: Unable to connect to server. Please check your internet connection.';
        });
        break;
      case 'server':
        setState(() {
          _viewState = ViewState.error;
          _errorMessage = '🔧 Server Error: The server is experiencing issues. Please try again later.';
        });
        break;
      case 'timeout':
        setState(() {
          _viewState = ViewState.error;
          _errorMessage = '⏰ Timeout Error: The request took too long to complete.';
        });
        break;
      case 'empty':
        setState(() {
          _viewState = ViewState.empty;
          _items = [];
          _errorMessage = null;
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced UI States'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Refresh Data',
          ),
          IconButton(
            icon: Icon(_isOffline ? Icons.wifi_off : Icons.wifi),
            onPressed: _toggleOffline,
            tooltip: _isOffline ? 'Go Online' : 'Go Offline',
          ),
          PopupMenuButton<String>(
            onSelected: _simulateSpecificError,
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'network',
                child: ListTile(
                  leading: Icon(Icons.wifi_off),
                  title: Text('Network Error'),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
              const PopupMenuItem(
                value: 'server',
                child: ListTile(
                  leading: Icon(Icons.error),
                  title: Text('Server Error'),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
              const PopupMenuItem(
                value: 'timeout',
                child: ListTile(
                  leading: Icon(Icons.timer),
                  title: Text('Timeout Error'),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
              const PopupMenuItem(
                value: 'empty',
                child: ListTile(
                  leading: Icon(Icons.inbox),
                  title: Text('Empty State'),
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
          _buildAdvancedStatesDemo(),
          _buildCustomLoadersDemo(),
          _buildStreamBuilderDemo(),
          _buildProductionPatternsDemo(),
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
            icon: Icon(Icons.layers),
            activeIcon: Icon(Icons.layers),
            label: 'Advanced',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.animation),
            activeIcon: Icon(Icons.animation),
            label: 'Loaders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.stream),
            activeIcon: Icon(Icons.stream),
            label: 'Streams',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.production_quantity_limits),
            activeIcon: Icon(Icons.production_quantity_limits),
            label: 'Production',
          ),
        ],
      ),
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
              Row(
                children: [
                  const Text(
                    'Advanced State Patterns',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (_isOffline)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'OFFLINE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (_retryCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Retry $_retryCount/3',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Advanced patterns with retry logic, error categorization, and offline support.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: _buildAdvancedStateContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdvancedStateContent() {
    switch (_viewState) {
      case ViewState.loading:
        return _buildAdvancedLoadingState();
      case ViewState.error:
        return _buildAdvancedErrorState();
      case ViewState.empty:
        return _buildAdvancedEmptyState();
      case ViewState.loaded:
        return _buildAdvancedLoadedState();
    }
  }

  Widget _buildAdvancedLoadingState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Advanced loading animation
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 + (_pulseController.value * 0.1),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cloud_download,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        const Text(
          'Loading your data...',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _isOffline ? 'Working in offline mode...' : 'Please wait while we fetch your content',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 16),
        // Loading progress indicator
        LinearProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).colorScheme.primary,
          ),
          backgroundColor: Colors.grey.shade200,
        ),
      ],
    );
  }

  Widget _buildAdvancedErrorState() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error icon with animation
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: _getErrorColor().withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getErrorIcon(),
                size: 80,
                color: _getErrorColor(),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _getErrorTitle(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _getErrorColor(),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Text(
                    _errorMessage ?? 'An unknown error occurred',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_retryCount > 0)
                    Text(
                      'Attempt $_retryCount of 3',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Advanced retry options
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _retryCount < 3 ? _retryWithBackoff : null,
                    icon: const Icon(Icons.refresh),
                    label: Text(_retryCount < 3 ? 'Retry' : 'Retry Limit Reached'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _retryCount = 0;
                          });
                          _loadData();
                        },
                        icon: const Icon(Icons.restore),
                        label: const Text('Reset Counter'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _toggleOffline,
                        icon: Icon(_isOffline ? Icons.wifi : Icons.wifi_off),
                        label: Text(_isOffline ? 'Go Online' : 'Go Offline'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Advanced empty state with illustration
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.grey.shade100,
                Colors.grey.shade200,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.inbox_outlined,
            size: 100,
            color: Colors.grey.shade400,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'No data available',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: const Text(
            'There are no items to display yet. This could be because:\n\n• You\'re offline\n• The server has no data\n• Filters are hiding all items\n• It\'s your first time using the app',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ),
        const SizedBox(height: 32),
        // Multiple action options
        Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh Data'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Opening settings...'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    icon: const Icon(Icons.settings),
                    label: const Text('Settings'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Opening help...'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    icon: const Icon(Icons.help_outline),
                    label: const Text('Get Help'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAdvancedLoadedState() {
    return Column(
      children: [
        // Header with stats
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Data Loaded Successfully',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_items.length} items loaded',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              if (_isRefreshing)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Advanced data list
        Expanded(
          child: ListView.builder(
            itemCount: _items.length,
            itemBuilder: (context, index) {
              final item = _items[index];
              return _buildAdvancedItemCard(item, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAdvancedItemCard(DataItem item, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _getPriorityColor(item.priority),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                if (item.isFavorite)
                  const Icon(Icons.favorite, color: Colors.red),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item.category,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  _formatTimestamp(item.timestamp),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
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
                'Advanced loading animations with shimmer effects, pulse animations, and custom indicators.',
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
                    _buildShimmerLoader(),
                    _buildPulseLoader(),
                    _buildDotsLoader(),
                    _buildWaveLoader(),
                    _buildGradientLoader(),
                    _buildMorphingLoader(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerLoader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Shimmer Effect',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Shimmer avatar
                  AnimatedBuilder(
                    animation: _shimmerController,
                    builder: (context, child) {
                      return Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.grey.shade300,
                              Colors.grey.shade100,
                              Colors.grey.shade300,
                            ],
                            stops: const [0.0, 0.5, 1.0],
                            begin: Alignment(-1.0 + _shimmerController.value * 2.0, 0.0),
                            end: Alignment(1.0 + _shimmerController.value * 2.0, 0.0),
                          ),
                          shape: BoxShape.circle,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  // Shimmer lines
                  ...List.generate(3, (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: AnimatedBuilder(
                      animation: _shimmerController,
                      builder: (context, child) {
                        return Container(
                          height: 12,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.grey.shade300,
                                Colors.grey.shade100,
                                Colors.grey.shade300,
                              ],
                              stops: const [0.0, 0.5, 1.0],
                              begin: Alignment(-1.0 + _shimmerController.value * 2.0, 0.0),
                              end: Alignment(1.0 + _shimmerController.value * 2.0, 0.0),
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        );
                      },
                    ),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPulseLoader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pulse Animation',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Center(
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 0.8 + (_pulseController.value * 0.4),
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue,
                              Colors.purple,
                            ],
                          ),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDotsLoader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dots Animation',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    return AnimatedBuilder(
                      animation: _dotsController,
                      builder: (context, child) {
                        final delay = index * 0.2;
                        final value = (_dotsController.value + delay) % 1.0;
                        return Transform.scale(
                          scale: 0.5 + (value * 0.5),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaveLoader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Wave Animation',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 80,
                      height: 6,
                      child: LinearProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                        backgroundColor: Colors.grey.shade200,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Loading...',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientLoader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gradient Loader',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Center(
                child: AnimatedBuilder(
                  animation: _shimmerController,
                  builder: (context, child) {
                    return Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.red,
                            Colors.orange,
                            Colors.yellow,
                            Colors.green,
                            Colors.blue,
                            Colors.indigo,
                            Colors.purple,
                          ],
                          stops: List.generate(7, (index) => index / 6.0),
                          begin: Alignment(_shimmerController.value - 1, _shimmerController.value - 1),
                          end: Alignment(_shimmerController.value + 1, _shimmerController.value + 1),
                        ),
                        shape: BoxShape.circle,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMorphingLoader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Morphing Shape',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Center(
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 0.8 + (_pulseController.value * 0.4),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.teal,
                          borderRadius: BorderRadius.circular(
                            25 * _pulseController.value,
                          ),
                        ),
                        child: const Icon(
                          Icons.refresh,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== STREAM BUILDER DEMO ====================

  Widget _buildStreamBuilderDemo() {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'StreamBuilder Patterns',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Real-time data streaming with proper state handling and error recovery.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _loadDataStream,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start Stream'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      _streamSubscription?.cancel();
                      setState(() {
                        _viewState = ViewState.loading;
                        _items = [];
                        _errorMessage = null;
                      });
                    },
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop Stream'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _buildStreamContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStreamContent() {
    if (_streamSubscription == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.stream,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Press "Start Stream" to begin real-time data streaming',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return StreamBuilder<List<DataItem>>(
      stream: _dataStream,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Connecting to stream...'),
                ],
              ),
            );
          case ConnectionState.active:
            if (snapshot.hasError) {
              return _buildStreamError(snapshot.error.toString());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildStreamEmpty();
            }
            return _buildStreamData(snapshot.data!);
          case ConnectionState.done:
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, size: 64, color: Colors.green),
                  SizedBox(height: 16),
                  Text('Stream completed'),
                ],
              ),
            );
          case ConnectionState.none:
            return const Center(
              child: Text('No stream connection'),
            );
        }
      },
    );
  }

  Widget _buildStreamError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Stream Error',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadDataStream,
              icon: const Icon(Icons.refresh),
              label: const Text('Restart Stream'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreamEmpty() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No stream data yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Waiting for real-time updates...',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreamData(List<DataItem> items) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.stream, color: Colors.green),
              const SizedBox(width: 12),
              const Text(
                'Live Stream Active',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const Spacer(),
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
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
                    'Live',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade600,
                      fontWeight: FontWeight.bold,
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

  // ==================== PRODUCTION PATTERNS DEMO ====================

  Widget _buildProductionPatternsDemo() {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Production Patterns',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Enterprise-ready patterns with caching, offline support, and error boundaries.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildProductionCard(
                        'Smart Caching',
                        'Intelligent data caching with automatic refresh and invalidation.',
                        Icons.cached,
                        Colors.blue,
                        () => _showCachingDemo(),
                      ),
                      _buildProductionCard(
                        'Offline Support',
                        'Seamless offline experience with sync when connection restored.',
                        Icons.offline_bolt,
                        Colors.green,
                        () => _showOfflineDemo(),
                      ),
                      _buildProductionCard(
                        'Error Boundaries',
                        'Graceful error handling with fallback UI and recovery.',
                        Icons.security,
                        Colors.orange,
                        () => _showErrorBoundaryDemo(),
                      ),
                      _buildProductionCard(
                        'Performance Monitoring',
                        'Real-time performance tracking and optimization.',
                        Icons.speed,
                        Colors.purple,
                        () => _showPerformanceDemo(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductionCard(
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
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
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  // Demo methods for production patterns
  void _showCachingDemo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Smart Caching'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Features:'),
            SizedBox(height: 8),
            Text('• Automatic data caching'),
            Text('• Cache invalidation strategies'),
            Text('• Background refresh'),
            Text('• Memory optimization'),
            Text('• Offline cache access'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showOfflineDemo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Offline Support'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Features:'),
            SizedBox(height: 8),
            Text('• Offline data storage'),
            Text('• Sync when online'),
            Text('• Conflict resolution'),
            Text('• Queue operations'),
            Text('• Progressive enhancement'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showErrorBoundaryDemo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error Boundaries'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Features:'),
            SizedBox(height: 8),
            Text('• Error isolation'),
            Text('• Fallback UI'),
            Text('• Error reporting'),
            Text('• Recovery mechanisms'),
            Text('• User-friendly messages'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPerformanceDemo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Performance Monitoring'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Features:'),
            SizedBox(height: 8),
            Text('• Real-time metrics'),
            Text('• Memory usage tracking'),
            Text('• CPU monitoring'),
            Text('• Network performance'),
            Text('• User experience analytics'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // ==================== UTILITY METHODS ====================

  Color _getErrorColor() {
    if (_errorMessage?.contains('Network') == true) {
      return Colors.orange;
    } else if (_errorMessage?.contains('Server') == true) {
      return Colors.red;
    } else if (_errorMessage?.contains('Timeout') == true) {
      return Colors.purple;
    } else {
      return Colors.grey;
    }
  }

  IconData _getErrorIcon() {
    if (_errorMessage?.contains('Network') == true) {
      return Icons.wifi_off;
    } else if (_errorMessage?.contains('Server') == true) {
      return Icons.error;
    } else if (_errorMessage?.contains('Timeout') == true) {
      return Icons.timer;
    } else {
      return Icons.error_outline;
    }
  }

  String _getErrorTitle() {
    if (_errorMessage?.contains('Network') == true) {
      return 'Network Error';
    } else if (_errorMessage?.contains('Server') == true) {
      return 'Server Error';
    } else if (_errorMessage?.contains('Timeout') == true) {
      return 'Timeout Error';
    } else {
      return 'Error Occurred';
    }
  }

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.high:
        return Colors.red;
      case Priority.medium:
        return Colors.orange;
      case Priority.low:
        return Colors.green;
    }
  }

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

enum ViewState {
  loading,
  loaded,
  error,
  empty,
}

enum Priority {
  low,
  medium,
  high,
}

class DataItem {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final String category;
  final Priority priority;
  final bool isFavorite;

  DataItem({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.category,
    required this.priority,
    required this.isFavorite,
  });
}

// ==================== CUSTOM EXCEPTIONS ====================

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
  
  @override
  String toString() => 'NetworkException: $message';
}

class ServerException implements Exception {
  final String message;
  ServerException(this.message);
  
  @override
  String toString() => 'ServerException: $message';
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);
  
  @override
  String toString() => 'TimeoutException: $message';
}

class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);
  
  @override
  String toString() => 'ValidationException: $message';
}

class StreamException implements Exception {
  final String message;
  StreamException(this.message);
  
  @override
  String toString() => 'StreamException: $message';
}
