import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/waste_type_chip.dart';
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
  String _selectedFilter = 'Всё';

  final List<Map<String, dynamic>> _filters = [
    {'label': 'Всё', 'icon': Icons.category},
    {'label': AppStrings.wastePlastic, 'icon': Icons.local_drink},
    {'label': AppStrings.wasteGlass, 'icon': Icons.wine_bar},
    {'label': AppStrings.wastePaper, 'icon': Icons.newspaper},
    {'label': AppStrings.wasteMetal, 'icon': Icons.hardware},
    {'label': AppStrings.wasteBatteries, 'icon': Icons.battery_full},
    {'label': AppStrings.wasteClothes, 'icon': Icons.checkroom},
    {'label': AppStrings.wasteElectronics, 'icon': Icons.devices_other}, 
  {'label': AppStrings.wasteHazardous, 'icon': Icons.warning_amber},
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget currentScreen;

    if (_selectedIndex == 0) {
      currentScreen = _buildMapScreen();
    } else if (_selectedIndex == 1) {
      currentScreen = FavoritesScreen(
       onOpenMap: () => _onItemTapped(0),
      );   
    } else if (_selectedIndex == 2) {
      currentScreen = const GuideScreen();
    } else if (_selectedIndex == 3) {
      currentScreen = ProfileScreen(
        isLoggedIn: _isLoggedIn,
        onLogin: () {
          setState(() {
            _isLoggedIn = true;
          });
        },
        onLogout: () {
          setState(() {
            _isLoggedIn = false;
          });
        },
      );
    } else {
      currentScreen = const Center(
        child: Text('Экран не найден'),
      );
    }

    return Scaffold(
      body: currentScreen,
      bottomNavigationBar: NavigationBar(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primaryGreen.withValues(alpha: 0.2),
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: AppStrings.tabMap,
          ),
          NavigationDestination(
            icon: Icon(Icons.star_outline),
            selectedIcon: Icon(Icons.star),
            label: AppStrings.tabFavorites,
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: AppStrings.tabGuide,
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: AppStrings.tabProfile,
          ),
        ],
      ),
    );
  }

  Widget _buildMapScreen() {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Container(
            color: AppColors.background,
            padding: const EdgeInsets.only(top: 8.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  child: Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.search, color: AppColors.textSecondary),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Найди зелёный адрес...',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Icon(Icons.tune, color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filters.length,
                    itemBuilder: (context, index) {
                      final filter = _filters[index];
                      final isSelected = _selectedFilter == filter['label'];

                      return Padding(
                        padding: EdgeInsets.only(
                          right: index == _filters.length - 1 ? 16 : 8,
                        ),
                        child: WasteTypeChip(
                          label: filter['label'],
                          icon: filter['icon'],
                          isSelected: isSelected,
                          onTap: () {
                            setState(() {
                              _selectedFilter = filter['label'];
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          const Expanded(
            child: YandexMapScreen(),
          ),
        ],
      ),
    );
  }
}