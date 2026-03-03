import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Provider-based State Management Examples
/// 
/// This file demonstrates how to use Provider for scalable state management
/// in Flutter applications. Includes examples for common use cases like
/// authentication, shopping cart, favorites, and app settings.

// ==================== AUTHENTICATION STATE ====================

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _initializeAuth();
  }

  void _initializeAuth() {
    _auth.authStateChanges().listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      _setLoading(true);
      _clearError();
      
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      
    } catch (e) {
      _setError('Failed to sign in: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> registerWithEmailAndPassword(String email, String password) async {
    try {
      _setLoading(true);
      _clearError();
      
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      
    } catch (e) {
      _setError('Failed to register: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      _setError('Failed to sign out: ${e.toString()}');
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

// ==================== SHOPPING CART STATE ====================

class CartItem {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.quantity = 1,
  });

  CartItem copyWith({
    String? id,
    String? name,
    double? price,
    String? imageUrl,
    int? quantity,
  }) {
    return CartItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      quantity: quantity ?? this.quantity,
    );
  }

  double get total => price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'quantity': quantity,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'],
      name: map['name'],
      price: map['price'],
      imageUrl: map['imageUrl'],
      quantity: map['quantity'],
    );
  }
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  bool _isLoading = false;

  // Getters
  List<CartItem> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  double get totalAmount => _items.fold(0, (sum, item) => sum + item.total);
  bool get isEmpty => _items.isEmpty;

  void addItem(CartItem item) {
    final existingIndex = _items.indexWhere((existingItem) => existingItem.id == item.id);
    
    if (existingIndex >= 0) {
      _items[existingIndex] = _items[existingIndex].copyWith(
        quantity: _items[existingIndex].quantity + item.quantity,
      );
    } else {
      _items.add(item);
    }
    
    notifyListeners();
    _saveToFirestore();
  }

  void removeItem(String itemId) {
    _items.removeWhere((item) => item.id == itemId);
    notifyListeners();
    _saveToFirestore();
  }

  void updateQuantity(String itemId, int quantity) {
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index >= 0) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index] = _items[index].copyWith(quantity: quantity);
      }
      notifyListeners();
      _saveToFirestore();
    }
  }

  void incrementQuantity(String itemId) {
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index >= 0) {
      _items[index] = _items[index].copyWith(
        quantity: _items[index].quantity + 1,
      );
      notifyListeners();
      _saveToFirestore();
    }
  }

  void decrementQuantity(String itemId) {
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index >= 0) {
      final currentQuantity = _items[index].quantity;
      if (currentQuantity > 1) {
        _items[index] = _items[index].copyWith(
          quantity: currentQuantity - 1,
        );
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
      _saveToFirestore();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
    _saveToFirestore();
  }

  Future<void> _saveToFirestore() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('cart')
            .doc('items')
            .set({
              'items': _items.map((item) => item.toMap()).toList(),
              'updatedAt': FieldValue.serverTimestamp(),
            });
      }
    } catch (e) {
      debugPrint('Error saving cart to Firestore: $e');
    }
  }

  Future<void> loadFromFirestore() async {
    try {
      _setLoading(true);
      
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('cart')
            .doc('items')
            .get();
        
        if (doc.exists) {
          final data = doc.data()!;
          final itemsList = (data['items'] as List<dynamic>?)
              ?.map((item) => CartItem.fromMap(item as Map<String, dynamic>))
              .toList() ?? [];
          
          _items.clear();
          _items.addAll(itemsList);
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error loading cart from Firestore: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}

// ==================== FAVORITES STATE ====================

class FavoritesProvider extends ChangeNotifier {
  final Set<String> _favoriteIds = {};
  bool _isLoading = false;

  // Getters
  Set<String> get favoriteIds => Set.unmodifiable(_favoriteIds);
  bool get isLoading => _isLoading;
  int get favoriteCount => _favoriteIds.length;
  bool get isEmpty => _favoriteIds.isEmpty;

  bool isFavorite(String itemId) => _favoriteIds.contains(itemId);

  void toggleFavorite(String itemId) {
    if (_favoriteIds.contains(itemId)) {
      _favoriteIds.remove(itemId);
    } else {
      _favoriteIds.add(itemId);
    }
    notifyListeners();
    _saveToFirestore();
  }

  void addToFavorites(String itemId) {
    if (!_favoriteIds.contains(itemId)) {
      _favoriteIds.add(itemId);
      notifyListeners();
      _saveToFirestore();
    }
  }

  void removeFromFavorites(String itemId) {
    if (_favoriteIds.contains(itemId)) {
      _favoriteIds.remove(itemId);
      notifyListeners();
      _saveToFirestore();
    }
  }

  void clearFavorites() {
    _favoriteIds.clear();
    notifyListeners();
    _saveToFirestore();
  }

  Future<void> _saveToFirestore() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('favorites')
            .doc('items')
            .set({
              'favoriteIds': _favoriteIds.toList(),
              'updatedAt': FieldValue.serverTimestamp(),
            });
      }
    } catch (e) {
      debugPrint('Error saving favorites to Firestore: $e');
    }
  }

  Future<void> loadFromFirestore() async {
    try {
      _setLoading(true);
      
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('favorites')
            .doc('items')
            .get();
        
        if (doc.exists) {
          final data = doc.data()!;
          final favoriteList = (data['favoriteIds'] as List<dynamic>?)
              ?.map((id) => id.toString())
              .toSet() ?? <String>{};
          
          _favoriteIds.clear();
          _favoriteIds.addAll(favoriteList);
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error loading favorites from Firestore: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}

// ==================== APP SETTINGS STATE ====================

enum AppTheme { light, dark, system }

enum AppLanguage { english, spanish, french, german, chinese }

class SettingsProvider extends ChangeNotifier {
  AppTheme _theme = AppTheme.system;
  AppLanguage _language = AppLanguage.english;
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _biometricEnabled = false;
  double _fontSize = 14.0;
  bool _autoBackupEnabled = true;

  // Getters
  AppTheme get theme => _theme;
  AppLanguage get language => _language;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get darkModeEnabled => _darkModeEnabled;
  bool get biometricEnabled => _biometricEnabled;
  double get fontSize => _fontSize;
  bool get autoBackupEnabled => _autoBackupEnabled;

  // Theme setters
  void setTheme(AppTheme theme) {
    _theme = theme;
    notifyListeners();
    _saveToFirestore();
  }

  void setLanguage(AppLanguage language) {
    _language = language;
    notifyListeners();
    _saveToFirestore();
  }

  void toggleNotifications() {
    _notificationsEnabled = !_notificationsEnabled;
    notifyListeners();
    _saveToFirestore();
  }

  void toggleDarkMode() {
    _darkModeEnabled = !_darkModeEnabled;
    notifyListeners();
    _saveToFirestore();
  }

  void toggleBiometric() {
    _biometricEnabled = !_biometricEnabled;
    notifyListeners();
    _saveToFirestore();
  }

  void setFontSize(double fontSize) {
    _fontSize = fontSize.clamp(10.0, 24.0);
    notifyListeners();
    _saveToFirestore();
  }

  void toggleAutoBackup() {
    _autoBackupEnabled = !_autoBackupEnabled;
    notifyListeners();
    _saveToFirestore();
  }

  void resetToDefaults() {
    _theme = AppTheme.system;
    _language = AppLanguage.english;
    _notificationsEnabled = true;
    _darkModeEnabled = false;
    _biometricEnabled = false;
    _fontSize = 14.0;
    _autoBackupEnabled = true;
    notifyListeners();
    _saveToFirestore();
  }

  Future<void> _saveToFirestore() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('settings')
            .doc('preferences')
            .set({
              'theme': _theme.name,
              'language': _language.name,
              'notificationsEnabled': _notificationsEnabled,
              'darkModeEnabled': _darkModeEnabled,
              'biometricEnabled': _biometricEnabled,
              'fontSize': _fontSize,
              'autoBackupEnabled': _autoBackupEnabled,
              'updatedAt': FieldValue.serverTimestamp(),
            });
      }
    } catch (e) {
      debugPrint('Error saving settings to Firestore: $e');
    }
  }

  Future<void> loadFromFirestore() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('settings')
            .doc('preferences')
            .get();
        
        if (doc.exists) {
          final data = doc.data()!;
          
          _theme = AppTheme.values.firstWhere(
            (theme) => theme.name == data['theme'],
            orElse: () => AppTheme.system,
          );
          
          _language = AppLanguage.values.firstWhere(
            (lang) => lang.name == data['language'],
            orElse: () => AppLanguage.english,
          );
          
          _notificationsEnabled = data['notificationsEnabled'] ?? true;
          _darkModeEnabled = data['darkModeEnabled'] ?? false;
          _biometricEnabled = data['biometricEnabled'] ?? false;
          _fontSize = (data['fontSize'] as num?)?.toDouble() ?? 14.0;
          _autoBackupEnabled = data['autoBackupEnabled'] ?? true;
          
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error loading settings from Firestore: $e');
    }
  }
}

// ==================== SEARCH STATE ====================

class SearchProvider extends ChangeNotifier {
  String _query = '';
  List<String> _searchHistory = [];
  bool _isLoading = false;
  List<String> _suggestions = [];

  // Getters
  String get query => _query;
  List<String> get searchHistory => List.unmodifiable(_searchHistory);
  bool get isLoading => _isLoading;
  List<String> get suggestions => List.unmodifiable(_suggestions);
  bool get hasQuery => _query.isNotEmpty;

  void setQuery(String query) {
    _query = query;
    notifyListeners();
    _generateSuggestions();
  }

  void clearQuery() {
    _query = '';
    _suggestions.clear();
    notifyListeners();
  }

  void addToHistory(String query) {
    if (query.trim().isNotEmpty && !_searchHistory.contains(query)) {
      _searchHistory.insert(0, query);
      if (_searchHistory.length > 10) {
        _searchHistory.removeLast();
      }
      notifyListeners();
      _saveHistory();
    }
  }

  void removeFromHistory(String query) {
    _searchHistory.remove(query);
    notifyListeners();
    _saveHistory();
  }

  void clearHistory() {
    _searchHistory.clear();
    notifyListeners();
    _saveHistory();
  }

  void _generateSuggestions() {
    if (_query.isEmpty) {
      _suggestions.clear();
    } else {
      _suggestions = _searchHistory
          .where((item) => item.toLowerCase().contains(_query.toLowerCase()))
          .take(5)
          .toList();
    }
    notifyListeners();
  }

  Future<void> _saveHistory() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('search')
            .doc('history')
            .set({
              'history': _searchHistory,
              'updatedAt': FieldValue.serverTimestamp(),
            });
      }
    } catch (e) {
      debugPrint('Error saving search history: $e');
    }
  }

  Future<void> loadHistory() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('search')
            .doc('history')
            .get();
        
        if (doc.exists) {
          final data = doc.data()!;
          _searchHistory = (data['history'] as List<dynamic>?)
              ?.map((item) => item.toString())
              .toList() ?? [];
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error loading search history: $e');
    }
  }
}

// ==================== UTILITY PROVIDERS ====================

class CounterProvider extends ChangeNotifier {
  int _count = 0;

  int get count => _count;

  void increment() {
    _count++;
    notifyListeners();
  }

  void decrement() {
    if (_count > 0) {
      _count--;
      notifyListeners();
    }
  }

  void reset() {
    _count = 0;
    notifyListeners();
  }

  void setValue(int value) {
    _count = value;
    notifyListeners();
  }
}

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setDarkMode(bool isDark) {
    _isDarkMode = isDark;
    notifyListeners();
  }
}

class LoadingProvider extends ChangeNotifier {
  bool _isLoading = false;
  String _loadingMessage = '';

  bool get isLoading => _isLoading;
  String get loadingMessage => _loadingMessage;

  void setLoading(bool loading, [String message = '']) {
    _isLoading = loading;
    _loadingMessage = message;
    notifyListeners();
  }

  void showLoading([String message = 'Loading...']) {
    setLoading(true, message);
  }

  void hideLoading() {
    setLoading(false);
  }
}

// ==================== PROVIDER FACTORY ====================

class ProviderFactory {
  static final Map<Type, dynamic> _providers = {};

  static T get<T extends ChangeNotifier>() {
    if (!_providers.containsKey(T)) {
      _providers[T] = _createProvider<T>();
    }
    return _providers[T] as T;
  }

  static T _createProvider<T extends ChangeNotifier>() {
    switch (T) {
      case AuthProvider:
        return AuthProvider() as T;
      case CartProvider:
        return CartProvider() as T;
      case FavoritesProvider:
        return FavoritesProvider() as T;
      case SettingsProvider:
        return SettingsProvider() as T;
      case SearchProvider:
        return SearchProvider() as T;
      case CounterProvider:
        return CounterProvider() as T;
      case ThemeProvider:
        return ThemeProvider() as T;
      case LoadingProvider:
        return LoadingProvider() as T;
      default:
        throw Exception('Provider not found for type: $T');
    }
  }

  static void dispose() {
    for (final provider in _providers.values) {
      if (provider is ChangeNotifier) {
        provider.dispose();
      }
    }
    _providers.clear();
  }
}
