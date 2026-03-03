import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/riverpod_state_management.dart';

/// Riverpod State Management Demo Screen
/// 
/// This demo showcases Riverpod state management with real-world examples
/// including authentication, shopping cart, favorites, settings, and search.
class RiverpodDemoScreen extends ConsumerWidget {
  const RiverpodDemoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riverpod Demo'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const RiverpodInfoCard(),
            const SizedBox(height: 16),
            RiverpodCounterDemo(),
            const SizedBox(height: 16),
            RiverpodCartDemo(),
            const SizedBox(height: 16),
            RiverpodFavoritesDemo(),
            const SizedBox(height: 16),
            RiverpodSettingsDemo(),
            const SizedBox(height: 16),
            RiverpodSearchDemo(),
            const SizedBox(height: 16),
            RiverpodAuthDemo(),
          ],
        ),
      ),
    );
  }
}

class RiverpodInfoCard extends ConsumerWidget {
  const RiverpodInfoCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Riverpod State Management',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Riverpod is the successor to Provider, offering better type safety, '
              'compile-time safety, and improved testing capabilities. It provides '
              'a more robust and scalable solution for state management.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            _buildFeatureItem('✓ Type-safe and compile-time safe'),
            _buildFeatureItem('✓ Better for large and complex apps'),
            _buildFeatureItem('✓ Excellent testing support'),
            _buildFeatureItem('✓ Automatic dependency injection'),
            _buildFeatureItem('✓ Immutable state patterns'),
            _buildFeatureItem('✓ Better performance optimization'),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(text, style: const TextStyle(fontSize: 13)),
    );
  }
}

class RiverpodCounterDemo extends ConsumerWidget {
  const RiverpodCounterDemo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Counter Demo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Count: $count',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => ref.decrementCounter(),
                  child: const Icon(Icons.remove),
                ),
                ElevatedButton(
                  onPressed: () => ref.resetCounter(),
                  child: const Text('Reset'),
                ),
                ElevatedButton(
                  onPressed: () => ref.incrementCounter(),
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class RiverpodCartDemo extends ConsumerWidget {
  const RiverpodCartDemo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    final itemCount = ref.watch(cartItemCountProvider);
    final totalAmount = ref.watch(cartTotalAmountProvider);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Shopping Cart Demo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (cartState.isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Items: $itemCount'),
                      Text('Total: \$${totalAmount.toStringAsFixed(2)}'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          ref.read(cartProvider.notifier).addItem(const CartItem(
                            id: '1',
                            name: 'Sample Product',
                            price: 29.99,
                            imageUrl: 'https://via.placeholder.com/50',
                          ));
                        },
                        child: const Text('Add Item'),
                      ),
                      ElevatedButton(
                        onPressed: () => ref.read(cartProvider.notifier).clearCart(),
                        child: const Text('Clear Cart'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (cartState.items.isNotEmpty)
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        itemCount: cartState.items.length,
                        itemBuilder: (context, index) {
                          final item = cartState.items[index];
                          return ListTile(
                            title: Text(item.name),
                            subtitle: Text('\$${item.price} x ${item.quantity}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: () => ref.read(cartProvider.notifier).decrementQuantity(item.id),
                                ),
                                Text(item.quantity.toString()),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () => ref.read(cartProvider.notifier).incrementQuantity(item.id),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class RiverpodFavoritesDemo extends ConsumerWidget {
  const RiverpodFavoritesDemo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesState = ref.watch(favoritesProvider);
    final favoriteCount = ref.watch(favoriteCountProvider);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Favorites Demo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (favoritesState.isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Column(
                children: [
                  Text('Favorite Count: $favoriteCount'),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: ['Item 1', 'Item 2', 'Item 3', 'Item 4', 'Item 5'].map((item) {
                      final itemId = item.toLowerCase().replaceAll(' ', '_');
                      final isFavorite = ref.watch(isFavoriteProvider(itemId));
                      
                      return FilterChip(
                        label: Text(item),
                        selected: isFavorite,
                        onSelected: (selected) {
                          ref.read(favoritesProvider.notifier).toggleFavorite(itemId);
                        },
                        selectedColor: Colors.pink.shade100,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.read(favoritesProvider.notifier).clearFavorites(),
                    child: const Text('Clear All'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class RiverpodSettingsDemo extends ConsumerWidget {
  const RiverpodSettingsDemo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsProvider);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Settings Demo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Notifications'),
              value: settingsState.notificationsEnabled,
              onChanged: (value) => ref.read(settingsProvider.notifier).toggleNotifications(),
            ),
            SwitchListTile(
              title: const Text('Dark Mode'),
              value: settingsState.darkModeEnabled,
              onChanged: (value) => ref.read(settingsProvider.notifier).toggleDarkMode(),
            ),
            SwitchListTile(
              title: const Text('Biometric'),
              value: settingsState.biometricEnabled,
              onChanged: (value) => ref.read(settingsProvider.notifier).toggleBiometric(),
            ),
            const SizedBox(height: 16),
            Text('Font Size: ${settingsState.fontSize.toInt()}'),
            Slider(
              value: settingsState.fontSize,
              min: 10,
              max: 24,
              divisions: 14,
              onChanged: (value) => ref.read(settingsProvider.notifier).setFontSize(value),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(settingsProvider.notifier).resetToDefaults(),
              child: const Text('Reset to Defaults'),
            ),
          ],
        ),
      ),
    );
  }
}

class RiverpodSearchDemo extends ConsumerWidget {
  const RiverpodSearchDemo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(searchProvider);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Search Demo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Search...',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => ref.read(searchProvider.notifier).setQuery(value),
            ),
            const SizedBox(height: 16),
            if (searchState.hasQuery)
              Column(
                children: [
                  const Text('Suggestions:', style: TextStyle(fontWeight: FontWeight.bold)),
                  ...searchState.suggestions.map((suggestion) => ListTile(
                    title: Text(suggestion),
                    onTap: () {
                      ref.read(searchProvider.notifier).setQuery(suggestion);
                      ref.read(searchProvider.notifier).addToHistory(suggestion);
                    },
                  )),
                ],
              ),
            const SizedBox(height: 16),
            if (searchState.searchHistory.isNotEmpty)
              Column(
                children: [
                  const Text('Search History:', style: TextStyle(fontWeight: FontWeight.bold)),
                  ...searchState.searchHistory.map((history) => ListTile(
                    title: Text(history),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => ref.read(searchProvider.notifier).removeFromHistory(history),
                    ),
                    onTap: () => ref.read(searchProvider.notifier).setQuery(history),
                  )),
                ],
              ),
            ElevatedButton(
              onPressed: () => ref.read(searchProvider.notifier).clearHistory(),
              child: const Text('Clear History'),
            ),
          ],
        ),
      ),
    );
  }
}

class RiverpodAuthDemo extends ConsumerWidget {
  const RiverpodAuthDemo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Authentication Demo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (authState.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (authState.isAuthenticated)
              Column(
                children: [
                  Text('Logged in as: ${authState.user?.email ?? "Unknown"}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.read(authProvider.notifier).signOut(),
                    child: const Text('Sign Out'),
                  ),
                ],
              )
            else
              Column(
                children: [
                  if (authState.hasError)
                    Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        authState.errorMessage!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  ElevatedButton(
                    onPressed: () => _showSignInDialog(context, ref),
                    child: const Text('Sign In'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _showSignUpDialog(context, ref),
                    child: const Text('Sign Up'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _showSignInDialog(BuildContext context, WidgetRef ref) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign In'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(authProvider.notifier).signInWithEmailAndPassword(
                emailController.text,
                passwordController.text,
              );
              Navigator.of(context).pop();
            },
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }

  void _showSignUpDialog(BuildContext context, WidgetRef ref) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Up'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(authProvider.notifier).registerWithEmailAndPassword(
                emailController.text,
                passwordController.text,
              );
              Navigator.of(context).pop();
            },
            child: const Text('Sign Up'),
          ),
        ],
      ),
    );
  }
}

// ==================== COMPARISON CARD ====================

class StateManagementComparison extends ConsumerWidget {
  const StateManagementComparison({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Provider vs Riverpod',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildComparisonRow(
              'Learning Curve',
              'Easy',
              'Moderate',
              Colors.green,
              Colors.orange,
            ),
            _buildComparisonRow(
              'Type Safety',
              'Basic',
              'Excellent',
              Colors.orange,
              Colors.green,
            ),
            _buildComparisonRow(
              'Performance',
              'Good',
              'Excellent',
              Colors.green,
              Colors.green,
            ),
            _buildComparisonRow(
              'Testing',
              'Good',
              'Excellent',
              Colors.orange,
              Colors.green,
            ),
            _buildComparisonRow(
              'Scalability',
              'Good',
              'Excellent',
              Colors.orange,
              Colors.green,
            ),
            _buildComparisonRow(
              'Documentation',
              'Extensive',
              'Growing',
              Colors.green,
              Colors.orange,
            ),
            _buildComparisonRow(
              'Community',
              'Large',
              'Growing',
              Colors.green,
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonRow(
    String feature,
    String providerRating,
    String riverpodRating,
    Color providerColor,
    Color riverpodColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(feature, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: providerColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Provider\n$providerRating',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: providerColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: riverpodColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Riverpod\n$riverpodRating',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: riverpodColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
