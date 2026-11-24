import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/app_strings.dart';
import '../favorites/favorites_screen.dart';
import '../guide/guide_screen.dart';
import '../profile/profile_screen.dart';
import 'yandex_map_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  int _selectedIndex = 0;
  bool _isLoggedIn = false;
  
  // ✅ СОСТОЯНИЯ ДЛЯ ПОИСКА И ФИЛЬТРАЦИИ
  String _searchQuery = '';
  String? _selectedWasteType; // null = "Всё"
  bool _showOnlyOpen = false;

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  // ✅ МЕТОД СБРОСА ФИЛЬТРОВ
  void _resetFilters() {
    setState(() {
      _searchQuery = '';
      _selectedWasteType = null;
      _showOnlyOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget currentScreen;

    if (_selectedIndex == 0) {
      currentScreen = YandexMapScreen(
    searchQuery: _searchQuery,
    selectedWasteType: _selectedWasteType,
    showOnlyOpen: _showOnlyOpen,
    onSearchChanged: (query) => setState(() => _searchQuery = query),
    onFilterChanged: (type) => setState(() => _selectedWasteType = type),
    onToggleOpen: () => setState(() => _showOnlyOpen = !_showOnlyOpen),
    onReset: _resetFilters,
  );
    } else if (_selectedIndex == 1) {
      currentScreen = FavoritesScreen(onOpenMap: () => _onItemTapped(0));   
    } else if (_selectedIndex == 2) {
      currentScreen = const GuideScreen();
    } else if (_selectedIndex == 3) {
      currentScreen = ProfileScreen(
        isLoggedIn: _isLoggedIn,
        onLogin: () => setState(() => _isLoggedIn = true),
        onLogout: () => setState(() => _isLoggedIn = false),
      );
    } else {
      currentScreen = const Center(child: Text('Экран не найден'));
    }

    return Scaffold(
      body: currentScreen,
      bottomNavigationBar: NavigationBar(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primaryGreen.withValues(alpha: 0.2),
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map), label: AppStrings.tabMap),
          NavigationDestination(icon: Icon(Icons.star_outline), selectedIcon: Icon(Icons.star), label: AppStrings.tabFavorites),
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: AppStrings.tabGuide),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: AppStrings.tabProfile),
        ],
      ),
    );
  }
}