import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Riverpod-based State Management Examples
/// 
/// This file demonstrates how to use Riverpod for scalable state management
/// in Flutter applications. Includes examples for common use cases like
/// authentication, shopping cart, favorites, and app settings.

// ==================== AUTHENTICATION STATE ====================

// Auth state data class
@immutable
class AuthState {
  final User? user;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isAuthenticated => user != null;
  bool get hasError => errorMessage != null;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthState &&
        other.user == user &&
        other.isLoading == isLoading &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode => user.hashCode ^ isLoading.hashCode ^ errorMessage.hashCode;

  @override
  String toString() => 'AuthState(user: $user, isLoading: $isLoading, errorMessage: $errorMessage)';
}

// Auth provider
class AuthNotifier extends StateNotifier<AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthNotifier() : super(const AuthState()) {
    _initializeAuth();
  }

  void _initializeAuth() {
    _auth.authStateChanges().listen((user) {
      state = state.copyWith(user: user);
    });
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to sign in: ${e.toString()}',
      );
    }
  }

  Future<void> registerWithEmailAndPassword(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to register: ${e.toString()}',
      );
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to sign out: ${e.toString()}',
      );
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

// Provider instances
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).user;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

// ==================== SHOPPING CART STATE ====================

// Cart item data class
@immutable
class CartItem {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final int quantity;

  const CartItem({
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItem &&
        other.id == id &&
        other.name == name &&
        other.price == price &&
        other.imageUrl == imageUrl &&
        other.quantity == quantity;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        price.hashCode ^
        imageUrl.hashCode ^
        quantity.hashCode;
  }
}

// Cart state data class
@immutable
class CartState {
  final List<CartItem> items;
  final bool isLoading;

  const CartState({
    this.items = const [],
    this.isLoading = false,
  });

  CartState copyWith({
    List<CartItem>? items,
    bool? isLoading,
  }) {
    return CartState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
  double get totalAmount => items.fold(0, (sum, item) => sum + item.total);
  bool get isEmpty => items.isEmpty;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartState &&
        listEquals(other.items, items) &&
        other.isLoading == isLoading;
  }

  @override
  int get hashCode => items.hashCode ^ isLoading.hashCode;

  @override
  String toString() => 'CartState(items: ${items.length}, isLoading: $isLoading)';
}

// Cart notifier
class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState()) {
    _loadFromFirestore();
  }

  void addItem(CartItem item) {
    final existingIndex = state.items.indexWhere((existingItem) => existingItem.id == item.id);
    
    final updatedItems = List<CartItem>.from(state.items);
    
    if (existingIndex >= 0) {
      updatedItems[existingIndex] = updatedItems[existingIndex].copyWith(
        quantity: updatedItems[existingIndex].quantity + item.quantity,
      );
    } else {
      updatedItems.add(item);
    }
    
    state = state.copyWith(items: updatedItems);
    _saveToFirestore();
  }

  void removeItem(String itemId) {
    final updatedItems = state.items.where((item) => item.id != itemId).toList();
    state = state.copyWith(items: updatedItems);
    _saveToFirestore();
  }

  void updateQuantity(String itemId, int quantity) {
    final updatedItems = state.items.map((item) {
      if (item.id == itemId) {
        return quantity <= 0 ? null : item.copyWith(quantity: quantity);
      }
      return item;
    }).where((item) => item != null).cast<CartItem>().toList();
    
    state = state.copyWith(items: updatedItems);
    _saveToFirestore();
  }

  void incrementQuantity(String itemId) {
    final updatedItems = state.items.map((item) {
      if (item.id == itemId) {
        return item.copyWith(quantity: item.quantity + 1);
      }
      return item;
    }).toList();
    
    state = state.copyWith(items: updatedItems);
    _saveToFirestore();
  }

  void decrementQuantity(String itemId) {
    final updatedItems = state.items.map((item) {
      if (item.id == itemId) {
        final newQuantity = item.quantity - 1;
        return newQuantity > 0 ? item.copyWith(quantity: newQuantity) : null;
      }
      return item;
    }).where((item) => item != null).cast<CartItem>().toList();
    
    state = state.copyWith(items: updatedItems);
    _saveToFirestore();
  }

  void clearCart() {
    state = state.copyWith(items: []);
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
              'items': state.items.map((item) => item.toMap()).toList(),
              'updatedAt': FieldValue.serverTimestamp(),
            });
      }
    } catch (e) {
      debugPrint('Error saving cart to Firestore: $e');
    }
  }

  Future<void> _loadFromFirestore() async {
    try {
      state = state.copyWith(isLoading: true);
      
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
          
          state = state.copyWith(items: itemsList, isLoading: false);
        } else {
          state = state.copyWith(isLoading: false);
        }
      }
    } catch (e) {
      debugPrint('Error loading cart from Firestore: $e');
      state = state.copyWith(isLoading: false);
    }
  }
}

// Cart provider instances
final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});

final cartItemsProvider = Provider<List<CartItem>>((ref) {
  return ref.watch(cartProvider).items;
});

final cartItemCountProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).itemCount;
});

final cartTotalAmountProvider = Provider<double>((ref) {
  return ref.watch(cartProvider).totalAmount;
});

final cartIsEmptyProvider = Provider<bool>((ref) {
  return ref.watch(cartProvider).isEmpty;
});

// ==================== FAVORITES STATE ====================

// Favorites state data class
@immutable
class FavoritesState {
  final Set<String> favoriteIds;
  final bool isLoading;

  const FavoritesState({
    this.favoriteIds = const {},
    this.isLoading = false,
  });

  FavoritesState copyWith({
    Set<String>? favoriteIds,
    bool? isLoading,
  }) {
    return FavoritesState(
      favoriteIds: favoriteIds ?? this.favoriteIds,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  int get favoriteCount => favoriteIds.length;
  bool get isEmpty => favoriteIds.isEmpty;

  bool isFavorite(String itemId) => favoriteIds.contains(itemId);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FavoritesState &&
        setEquals(other.favoriteIds, favoriteIds) &&
        other.isLoading == isLoading;
  }

  @override
  int get hashCode => favoriteIds.hashCode ^ isLoading.hashCode;

  @override
  String toString() => 'FavoritesState(favoriteIds: ${favoriteIds.length}, isLoading: $isLoading)';
}

// Favorites notifier
class FavoritesNotifier extends StateNotifier<FavoritesState> {
  FavoritesNotifier() : super(const FavoritesState()) {
    _loadFromFirestore();
  }

  void toggleFavorite(String itemId) {
    final updatedFavorites = Set<String>.from(state.favoriteIds);
    
    if (updatedFavorites.contains(itemId)) {
      updatedFavorites.remove(itemId);
    } else {
      updatedFavorites.add(itemId);
    }
    
    state = state.copyWith(favoriteIds: updatedFavorites);
    _saveToFirestore();
  }

  void addToFavorites(String itemId) {
    if (!state.isFavorite(itemId)) {
      final updatedFavorites = Set<String>.from(state.favoriteIds)..add(itemId);
      state = state.copyWith(favoriteIds: updatedFavorites);
      _saveToFirestore();
    }
  }

  void removeFromFavorites(String itemId) {
    if (state.isFavorite(itemId)) {
      final updatedFavorites = Set<String>.from(state.favoriteIds)..remove(itemId);
      state = state.copyWith(favoriteIds: updatedFavorites);
      _saveToFirestore();
    }
  }

  void clearFavorites() {
    state = state.copyWith(favoriteIds: {});
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
              'favoriteIds': state.favoriteIds.toList(),
              'updatedAt': FieldValue.serverTimestamp(),
            });
      }
    } catch (e) {
      debugPrint('Error saving favorites to Firestore: $e');
    }
  }

  Future<void> _loadFromFirestore() async {
    try {
      state = state.copyWith(isLoading: true);
      
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
          
          state = state.copyWith(favoriteIds: favoriteList, isLoading: false);
        } else {
          state = state.copyWith(isLoading: false);
        }
      }
    } catch (e) {
      debugPrint('Error loading favorites from Firestore: $e');
      state = state.copyWith(isLoading: false);
    }
  }
}

// Favorites provider instances
final favoritesProvider = StateNotifierProvider<FavoritesNotifier, FavoritesState>((ref) {
  return FavoritesNotifier();
});

final favoriteIdsProvider = Provider<Set<String>>((ref) {
  return ref.watch(favoritesProvider).favoriteIds;
});

final favoriteCountProvider = Provider<int>((ref) {
  return ref.watch(favoritesProvider).favoriteCount;
});

final favoritesIsEmptyProvider = Provider<bool>((ref) {
  return ref.watch(favoritesProvider).isEmpty;
});

// Helper provider to check if specific item is favorite
final isFavoriteProvider = Provider.family<bool, String>((ref, itemId) {
  return ref.watch(favoritesProvider).isFavorite(itemId);
});

// ==================== APP SETTINGS STATE ====================

enum AppTheme { light, dark, system }

enum AppLanguage { english, spanish, french, german, chinese }

// Settings state data class
@immutable
class SettingsState {
  final AppTheme theme;
  final AppLanguage language;
  final bool notificationsEnabled;
  final bool darkModeEnabled;
  final bool biometricEnabled;
  final double fontSize;
  final bool autoBackupEnabled;

  const SettingsState({
    this.theme = AppTheme.system,
    this.language = AppLanguage.english,
    this.notificationsEnabled = true,
    this.darkModeEnabled = false,
    this.biometricEnabled = false,
    this.fontSize = 14.0,
    this.autoBackupEnabled = true,
  });

  SettingsState copyWith({
    AppTheme? theme,
    AppLanguage? language,
    bool? notificationsEnabled,
    bool? darkModeEnabled,
    bool? biometricEnabled,
    double? fontSize,
    bool? autoBackupEnabled,
  }) {
    return SettingsState(
      theme: theme ?? this.theme,
      language: language ?? this.language,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      fontSize: fontSize ?? this.fontSize,
      autoBackupEnabled: autoBackupEnabled ?? this.autoBackupEnabled,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SettingsState &&
        other.theme == theme &&
        other.language == language &&
        other.notificationsEnabled == notificationsEnabled &&
        other.darkModeEnabled == darkModeEnabled &&
        other.biometricEnabled == biometricEnabled &&
        other.fontSize == fontSize &&
        other.autoBackupEnabled == autoBackupEnabled;
  }

  @override
  int get hashCode {
    return theme.hashCode ^
        language.hashCode ^
        notificationsEnabled.hashCode ^
        darkModeEnabled.hashCode ^
        biometricEnabled.hashCode ^
        fontSize.hashCode ^
        autoBackupEnabled.hashCode;
  }

  @override
  String toString() => 'SettingsState(theme: $theme, language: $language)';
}

// Settings notifier
class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState()) {
    _loadFromFirestore();
  }

  void setTheme(AppTheme theme) {
    state = state.copyWith(theme: theme);
    _saveToFirestore();
  }

  void setLanguage(AppLanguage language) {
    state = state.copyWith(language: language);
    _saveToFirestore();
  }

  void toggleNotifications() {
    state = state.copyWith(notificationsEnabled: !state.notificationsEnabled);
    _saveToFirestore();
  }

  void toggleDarkMode() {
    state = state.copyWith(darkModeEnabled: !state.darkModeEnabled);
    _saveToFirestore();
  }

  void toggleBiometric() {
    state = state.copyWith(biometricEnabled: !state.biometricEnabled);
    _saveToFirestore();
  }

  void setFontSize(double fontSize) {
    state = state.copyWith(fontSize: fontSize.clamp(10.0, 24.0));
    _saveToFirestore();
  }

  void toggleAutoBackup() {
    state = state.copyWith(autoBackupEnabled: !state.autoBackupEnabled);
    _saveToFirestore();
  }

  void resetToDefaults() {
    state = const SettingsState();
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
              'theme': state.theme.name,
              'language': state.language.name,
              'notificationsEnabled': state.notificationsEnabled,
              'darkModeEnabled': state.darkModeEnabled,
              'biometricEnabled': state.biometricEnabled,
              'fontSize': state.fontSize,
              'autoBackupEnabled': state.autoBackupEnabled,
              'updatedAt': FieldValue.serverTimestamp(),
            });
      }
    } catch (e) {
      debugPrint('Error saving settings to Firestore: $e');
    }
  }

  Future<void> _loadFromFirestore() async {
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
          
          state = SettingsState(
            theme: AppTheme.values.firstWhere(
              (theme) => theme.name == data['theme'],
              orElse: () => AppTheme.system,
            ),
            language: AppLanguage.values.firstWhere(
              (lang) => lang.name == data['language'],
              orElse: () => AppLanguage.english,
            ),
            notificationsEnabled: data['notificationsEnabled'] ?? true,
            darkModeEnabled: data['darkModeEnabled'] ?? false,
            biometricEnabled: data['biometricEnabled'] ?? false,
            fontSize: (data['fontSize'] as num?)?.toDouble() ?? 14.0,
            autoBackupEnabled: data['autoBackupEnabled'] ?? true,
          );
        }
      }
    } catch (e) {
      debugPrint('Error loading settings from Firestore: $e');
    }
  }
}

// Settings provider instances
final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});

final themeProvider = Provider<AppTheme>((ref) {
  return ref.watch(settingsProvider).theme;
});

final languageProvider = Provider<AppLanguage>((ref) {
  return ref.watch(settingsProvider).language;
});

final notificationsEnabledProvider = Provider<bool>((ref) {
  return ref.watch(settingsProvider).notificationsEnabled;
});

final darkModeEnabledProvider = Provider<bool>((ref) {
  return ref.watch(settingsProvider).darkModeEnabled;
});

final fontSizeProvider = Provider<double>((ref) {
  return ref.watch(settingsProvider).fontSize;
});

// ==================== SEARCH STATE ====================

// Search state data class
@immutable
class SearchState {
  final String query;
  final List<String> searchHistory;
  final bool isLoading;
  final List<String> suggestions;

  const SearchState({
    this.query = '',
    this.searchHistory = const [],
    this.isLoading = false,
    this.suggestions = const [],
  });

  SearchState copyWith({
    String? query,
    List<String>? searchHistory,
    bool? isLoading,
    List<String>? suggestions,
  }) {
    return SearchState(
      query: query ?? this.query,
      searchHistory: searchHistory ?? this.searchHistory,
      isLoading: isLoading ?? this.isLoading,
      suggestions: suggestions ?? this.suggestions,
    );
  }

  bool get hasQuery => query.isNotEmpty;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SearchState &&
        other.query == query &&
        listEquals(other.searchHistory, searchHistory) &&
        other.isLoading == isLoading &&
        listEquals(other.suggestions, suggestions);
  }

  @override
  int get hashCode {
    return query.hashCode ^
        searchHistory.hashCode ^
        isLoading.hashCode ^
        suggestions.hashCode;
  }

  @override
  String toString() => 'SearchState(query: "$query", history: ${searchHistory.length})';
}

// Search notifier
class SearchNotifier extends StateNotifier<SearchState> {
  SearchNotifier() : super(const SearchState()) {
    _loadHistory();
  }

  void setQuery(String query) {
    final suggestions = query.isEmpty
        ? <String>[]
        : state.searchHistory
            .where((item) => item.toLowerCase().contains(query.toLowerCase()))
            .take(5)
            .toList();
    
    state = state.copyWith(query: query, suggestions: suggestions);
  }

  void clearQuery() {
    state = state.copyWith(query: '', suggestions: []);
  }

  void addToHistory(String query) {
    if (query.trim().isNotEmpty && !state.searchHistory.contains(query)) {
      final updatedHistory = [query, ...state.searchHistory].take(10).toList();
      state = state.copyWith(searchHistory: updatedHistory);
      _saveHistory();
    }
  }

  void removeFromHistory(String query) {
    final updatedHistory = state.searchHistory.where((item) => item != query).toList();
    state = state.copyWith(searchHistory: updatedHistory);
    _saveHistory();
  }

  void clearHistory() {
    state = state.copyWith(searchHistory: []);
    _saveHistory();
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
              'history': state.searchHistory,
              'updatedAt': FieldValue.serverTimestamp(),
            });
      }
    } catch (e) {
      debugPrint('Error saving search history: $e');
    }
  }

  Future<void> _loadHistory() async {
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
          final history = (data['history'] as List<dynamic>?)
              ?.map((item) => item.toString())
              .toList() ?? [];
          
          state = state.copyWith(searchHistory: history);
        }
      }
    } catch (e) {
      debugPrint('Error loading search history: $e');
    }
  }
}

// Search provider instances
final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier();
});

final searchQueryProvider = Provider<String>((ref) {
  return ref.watch(searchProvider).query;
});

final searchHistoryProvider = Provider<List<String>>((ref) {
  return ref.watch(searchProvider).searchHistory;
});

final searchSuggestionsProvider = Provider<List<String>>((ref) {
  return ref.watch(searchProvider).suggestions;
});

final hasSearchQueryProvider = Provider<bool>((ref) {
  return ref.watch(searchProvider).hasQuery;
});

// ==================== UTILITY PROVIDERS ====================

// Simple counter provider
final counterProvider = StateProvider<int>((ref) => 0);

// Theme provider
final isDarkModeProvider = StateProvider<bool>((ref) => false);

// Loading provider
final isLoadingProvider = StateProvider<bool>((ref) => false);
final loadingMessageProvider = StateProvider<String>((ref) => '');

// Combined loading provider
final loadingStateProvider = Provider<LoadingState>((ref) {
  return LoadingState(
    isLoading: ref.watch(isLoadingProvider),
    message: ref.watch(loadingMessageProvider),
  );
});

@immutable
class LoadingState {
  final bool isLoading;
  final String message;

  const LoadingState({
    required this.isLoading,
    required this.message,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LoadingState &&
        other.isLoading == isLoading &&
        other.message == message;
  }

  @override
  int get hashCode => isLoading.hashCode ^ message.hashCode;

  @override
  String toString() => 'LoadingState(isLoading: $isLoading, message: "$message")';
}

// Loading utility functions
class LoadingUtils {
  static void showLoading(WidgetRef ref, [String message = 'Loading...']) {
    ref.read(isLoadingProvider.notifier).state = true;
    ref.read(loadingMessageProvider.notifier).state = message;
  }

  static void hideLoading(WidgetRef ref) {
    ref.read(isLoadingProvider.notifier).state = false;
    ref.read(loadingMessageProvider.notifier).state = '';
  }
}

// ==================== COMBINED PROVIDERS ====================

// User data provider that combines auth and user-specific data
final userDataProvider = Provider<UserData>((ref) {
  final user = ref.watch(currentUserProvider);
  final cart = ref.watch(cartProvider);
  final favorites = ref.watch(favoritesProvider);
  final settings = ref.watch(settingsProvider);
  
  return UserData(
    user: user,
    cartItems: cart.items.length,
    favoriteCount: favorites.favoriteCount,
    theme: settings.theme,
    language: settings.language,
  );
});

@immutable
class UserData {
  final User? user;
  final int cartItems;
  final int favoriteCount;
  final AppTheme theme;
  final AppLanguage language;

  const UserData({
    required this.user,
    required this.cartItems,
    required this.favoriteCount,
    required this.theme,
    required this.language,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserData &&
        other.user == user &&
        other.cartItems == cartItems &&
        other.favoriteCount == favoriteCount &&
        other.theme == theme &&
        other.language == language;
  }

  @override
  int get hashCode {
    return user.hashCode ^
        cartItems.hashCode ^
        favoriteCount.hashCode ^
        theme.hashCode ^
        language.hashCode;
  }

  @override
  String toString() => 'UserData(user: ${user?.email}, cartItems: $cartItems, favorites: $favoriteCount)';
}

// ==================== ASYNC PROVIDERS ====================

// Example of async provider for fetching data
final productsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  // Simulate API call
  await Future.delayed(const Duration(seconds: 1));
  
  return [
    {'id': '1', 'name': 'Product 1', 'price': 29.99},
    {'id': '2', 'name': 'Product 2', 'price': 49.99},
    {'id': '3', 'name': 'Product 3', 'price': 19.99},
  ];
});

// Stream provider for real-time data
final realtimeDataProvider = StreamProvider<List<DocumentSnapshot>>((ref) {
  return FirebaseFirestore.instance
      .collection('realtime_data')
      .snapshots()
      .map((snapshot) => snapshot.docs);
});

// ==================== PROVIDER EXTENSIONS ====================

// Extension methods for common operations
extension RefExtensions on WidgetRef {
  void setLoading(bool loading, [String message = '']) {
    read(isLoadingProvider.notifier).state = loading;
    read(loadingMessageProvider.notifier).state = message;
  }

  void showLoading([String message = 'Loading...']) {
    setLoading(true, message);
  }

  void hideLoading() {
    setLoading(false);
  }

  void incrementCounter() {
    read(counterProvider.notifier).state++;
  }

  void decrementCounter() {
    final currentValue = read(counterProvider);
    if (currentValue > 0) {
      read(counterProvider.notifier).state--;
    }
  }

  void resetCounter() {
    read(counterProvider.notifier).state = 0;
  }

  void toggleTheme() {
    read(isDarkModeProvider.notifier).state = !read(isDarkModeProvider);
  }
}
