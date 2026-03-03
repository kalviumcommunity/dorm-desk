import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/provider_state_management.dart';

/// Provider State Management Demo Screen
/// 
/// This demo showcases Provider state management with real-world examples
/// including authentication, shopping cart, favorites, settings, and search.
class ProviderDemoScreen extends StatelessWidget {
  const ProviderDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => CounterProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LoadingProvider()),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Provider Demo'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ProviderInfoCard(),
              const SizedBox(height: 16),
              ProviderCounterDemo(),
              const SizedBox(height: 16),
              ProviderCartDemo(),
              const SizedBox(height: 16),
              ProviderFavoritesDemo(),
              const SizedBox(height: 16),
              ProviderSettingsDemo(),
              const SizedBox(height: 16),
              ProviderSearchDemo(),
              const SizedBox(height: 16),
              ProviderAuthDemo(),
            ],
          ),
        ),
      ),
    );
  }
}

class ProviderInfoCard extends StatelessWidget {
  const ProviderInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Provider State Management',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Provider is a simple and popular state management solution for Flutter. '
              'It uses InheritedWidget under the hood and provides an easy-to-use API '
              'for managing application state.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            _buildFeatureItem('✓ Simple to learn and implement'),
            _buildFeatureItem('✓ Good for small to medium apps'),
            _buildFeatureItem('✓ Minimal boilerplate'),
            _buildFeatureItem('✓ Good performance with selective rebuilds'),
            _buildFeatureItem('✓ Large community and ecosystem'),
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

class ProviderCounterDemo extends StatelessWidget {
  const ProviderCounterDemo({super.key});

  @override
  Widget build(BuildContext context) {
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
            Consumer<CounterProvider>(
              builder: (context, counter, child) {
                return Column(
                  children: [
                    Text(
                      'Count: ${counter.count}',
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: counter.decrement,
                          child: const Icon(Icons.remove),
                        ),
                        ElevatedButton(
                          onPressed: counter.reset,
                          child: const Text('Reset'),
                        ),
                        ElevatedButton(
                          onPressed: counter.increment,
                          child: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ProviderCartDemo extends StatelessWidget {
  const ProviderCartDemo({super.key});

  @override
  Widget build(BuildContext context) {
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
            Consumer<CartProvider>(
              builder: (context, cart, child) {
                if (cart.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Items: ${cart.itemCount}'),
                        Text('Total: \$${cart.totalAmount.toStringAsFixed(2)}'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            cart.addItem(CartItem(
                              id: '1',
                              name: 'Sample Product',
                              price: 29.99,
                              imageUrl: 'https://via.placeholder.com/50',
                            ));
                          },
                          child: const Text('Add Item'),
                        ),
                        ElevatedButton(
                          onPressed: cart.clearCart,
                          child: const Text('Clear Cart'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (cart.items.isNotEmpty)
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          itemCount: cart.items.length,
                          itemBuilder: (context, index) {
                            final item = cart.items[index];
                            return ListTile(
                              title: Text(item.name),
                              subtitle: Text('\$${item.price} x ${item.quantity}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove),
                                    onPressed: () => cart.decrementQuantity(item.id),
                                  ),
                                  Text(item.quantity.toString()),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () => cart.incrementQuantity(item.id),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ProviderFavoritesDemo extends StatelessWidget {
  const ProviderFavoritesDemo({super.key});

  @override
  Widget build(BuildContext context) {
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
            Consumer<FavoritesProvider>(
              builder: (context, favorites, child) {
                if (favorites.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                return Column(
                  children: [
                    Text('Favorite Count: ${favorites.favoriteCount}'),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      children: ['Item 1', 'Item 2', 'Item 3', 'Item 4', 'Item 5'].map((item) {
                        final itemId = item.toLowerCase().replaceAll(' ', '_');
                        final isFavorite = favorites.isFavorite(itemId);
                        
                        return FilterChip(
                          label: Text(item),
                          selected: isFavorite,
                          onSelected: (selected) {
                            favorites.toggleFavorite(itemId);
                          },
                          selectedColor: Colors.pink.shade100,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: favorites.clearFavorites,
                      child: const Text('Clear All'),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ProviderSettingsDemo extends StatelessWidget {
  const ProviderSettingsDemo({super.key});

  @override
  Widget build(BuildContext context) {
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
            Consumer<SettingsProvider>(
              builder: (context, settings, child) {
                return Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Notifications'),
                      value: settings.notificationsEnabled,
                      onChanged: (value) => settings.toggleNotifications(),
                    ),
                    SwitchListTile(
                      title: const Text('Dark Mode'),
                      value: settings.darkModeEnabled,
                      onChanged: (value) => settings.toggleDarkMode(),
                    ),
                    SwitchListTile(
                      title: const Text('Biometric'),
                      value: settings.biometricEnabled,
                      onChanged: (value) => settings.toggleBiometric(),
                    ),
                    const SizedBox(height: 16),
                    Text('Font Size: ${settings.fontSize.toInt()}'),
                    Slider(
                      value: settings.fontSize,
                      min: 10,
                      max: 24,
                      divisions: 14,
                      onChanged: (value) => settings.setFontSize(value),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: settings.resetToDefaults,
                      child: const Text('Reset to Defaults'),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ProviderSearchDemo extends StatelessWidget {
  const ProviderSearchDemo({super.key});

  @override
  Widget build(BuildContext context) {
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
            Consumer<SearchProvider>(
              builder: (context, search, child) {
                return Column(
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Search...',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: search.setQuery,
                    ),
                    const SizedBox(height: 16),
                    if (search.hasQuery)
                      Column(
                        children: [
                          const Text('Suggestions:', style: TextStyle(fontWeight: FontWeight.bold)),
                          ...search.suggestions.map((suggestion) => ListTile(
                            title: Text(suggestion),
                            onTap: () {
                              search.setQuery(suggestion);
                              search.addToHistory(suggestion);
                            },
                          )),
                        ],
                      ),
                    const SizedBox(height: 16),
                    if (search.searchHistory.isNotEmpty)
                      Column(
                        children: [
                          const Text('Search History:', style: TextStyle(fontWeight: FontWeight.bold)),
                          ...search.searchHistory.map((history) => ListTile(
                            title: Text(history),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => search.removeFromHistory(history),
                            ),
                            onTap: () => search.setQuery(history),
                          )),
                        ],
                      ),
                    ElevatedButton(
                      onPressed: search.clearHistory,
                      child: const Text('Clear History'),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ProviderAuthDemo extends StatelessWidget {
  const ProviderAuthDemo({super.key});

  @override
  Widget build(BuildContext context) {
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
            Consumer<AuthProvider>(
              builder: (context, auth, child) {
                if (auth.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (auth.isAuthenticated) {
                  return Column(
                    children: [
                      Text('Logged in as: ${auth.user?.email ?? "Unknown"}'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: auth.signOut,
                        child: const Text('Sign Out'),
                      ),
                    ],
                  );
                }
                
                return Column(
                  children: [
                    if (auth.errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          auth.errorMessage!,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                    ElevatedButton(
                      onPressed: () => _showSignInDialog(context, auth),
                      child: const Text('Sign In'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => _showSignUpDialog(context, auth),
                      child: const Text('Sign Up'),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSignInDialog(BuildContext context, AuthProvider auth) {
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
              auth.signInWithEmailAndPassword(
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

  void _showSignUpDialog(BuildContext context, AuthProvider auth) {
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
              auth.registerWithEmailAndPassword(
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
