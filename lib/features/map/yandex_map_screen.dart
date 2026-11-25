import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/waste_type_chip.dart';
import '../../models/collection_point.dart';
import '../../services/supabase_service.dart';
import 'widgets/point_details_sheet.dart';

class YandexMapScreen extends StatefulWidget {
  final String searchQuery;
  final String? selectedWasteType;
  final bool showOnlyOpen;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String?> onFilterChanged;
  final VoidCallback onToggleOpen;
  final VoidCallback onReset;

  const YandexMapScreen({
    super.key,
    required this.searchQuery,
    required this.selectedWasteType,
    required this.showOnlyOpen,
    required this.onSearchChanged,
    required this.onFilterChanged,
    required this.onToggleOpen,
    required this.onReset,
  });

  @override
  State<YandexMapScreen> createState() => _YandexMapScreenState();
}

class _YandexMapScreenState extends State<YandexMapScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  YandexMapController? _mapController;
  late final TextEditingController _searchController;
  List<CollectionPoint> _allPoints = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
    _loadData();
  }

  @override
  void didUpdateWidget(covariant YandexMapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchQuery != _searchController.text) {
      _searchController.text = widget.searchQuery;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    print('🔄 Начало загрузки данных из Supabase...');
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await _supabaseService.getCollectionPoints();
      print('✅ Данные получены! Количество: ${data.length}');
      setState(() {
        _allPoints = data;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ ОШИБКА ЗАГРУЗКИ: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Логика фильтрации
  List<CollectionPoint> get _filteredPoints {
    return _allPoints.where((point) {
      // Поиск по названию, адресу или типу отходов
      if (widget.searchQuery.isNotEmpty) {
        final q = widget.searchQuery.toLowerCase();
        if (!point.name.toLowerCase().contains(q) &&
            !point.address.toLowerCase().contains(q) &&
            !point.wasteTypes.any((t) => t.toLowerCase().contains(q))) {
          return false;
        }
      }
      // Фильтр по типу отходов
      if (widget.selectedWasteType != null &&
          widget.selectedWasteType != 'Всё') {
        if (!point.wasteTypes.contains(widget.selectedWasteType)) return false;
      }
      // Фильтр "Только открытые"
      if (widget.showOnlyOpen && !point.isOpenNow) return false;

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.orange));
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Ошибка:\n$_error', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                  onPressed: _loadData, child: const Text('Повторить')),
            ],
          ),
        ),
      );
    }

    final filteredPoints = _filteredPoints;

    // Создаем маркеры только для отфильтрованных точек
    final mapObjects = <MapObject>[];
    for (var point in filteredPoints) {
      mapObjects.add(
        PlacemarkMapObject(
          mapId: MapObjectId('point_${point.id}'),
          point: Point(latitude: point.latitude, longitude: point.longitude),
          icon: PlacemarkIcon.single(
            PlacemarkIconStyle(
              image: BitmapDescriptor.fromAssetImage(
                point.isOpenNow
                    ? 'assets/icons/marker_green.png'
                    : 'assets/icons/marker_red.png',
              ),
              scale: 0.3,
            ),
          ),
          onTap: (_, __) => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => PointDetailsSheet(point: point),
          ),
        ),
      );
    }

    // Список фильтров
    final List<Map<String, dynamic>> filters = [
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

    return Stack(
      children: [
        // 🗺️ КАРТА (растянута на весь экран через Positioned.fill)
        Positioned.fill(
          child: YandexMap(
            mapType: MapType.map,
            onMapCreated: (controller) {
              print(
                  '✅✅✅ КАРТА СОЗДАНА! Размер: ${MediaQuery.of(context).size}');
              _mapController = controller;
              if (_allPoints.isNotEmpty) {
                double sumLat = 0, sumLon = 0;
                for (var p in _allPoints) {
                  sumLat += p.latitude;
                  sumLon += p.longitude;
                }
                controller.moveCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                      target: Point(
                        latitude: sumLat / _allPoints.length,
                        longitude: sumLon / _allPoints.length,
                      ),
                      zoom: 9.0,
                    ),
                  ),
                  animation: const MapAnimation(
                    type: MapAnimationType.smooth,
                    duration: 1,
                  ),
                );
              }
            },
            mapObjects: mapObjects,
          ),
        ),

        // 🎛️ ИНТЕРФЕЙС УПРАВЛЕНИЯ (опущен под статус-бар)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            color: AppColors.background,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 8.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🔍 ПОЛЕ ПОИСКА
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
                    child: Row(
                      children: [
                        const Icon(Icons.search,
                            color: AppColors.textSecondary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              hintText: 'Найди зелёный адрес...',
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 16,
                              ),
                            ),
                            onChanged: widget.onSearchChanged,
                            controller: _searchController,
                          ),
                        ),
                        if (widget.searchQuery.isNotEmpty ||
                            widget.selectedWasteType != null ||
                            widget.showOnlyOpen)
                          IconButton(
                            icon: const Icon(
                              Icons.clear,
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                            onPressed: widget.onReset,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          )
                        else
                          const Icon(Icons.tune,
                              color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                ),

                // 🏷️ ЧИПСЫ ФИЛЬТРОВ
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filters.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: WasteTypeChip(
                            label: 'Открыто', // 
                            icon: Icons.access_time, 
                            customIcon: const Stack(
                              alignment: Alignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 11,
                                  backgroundColor: Color(0xFF4CAF50),
                                ),
                                Icon(Icons.access_time,
                                    size: 13, color: Colors.white),
                              ],
                            ),
                            isSelected: widget.showOnlyOpen,
                            onTap: widget.onToggleOpen,
                          ),
                        );
                      }

                      final filterIndex = index - 1;
                      final filter = filters[filterIndex];
                      final String label = filter['label'] as String;
                      final IconData icon = filter['icon'] as IconData;

                      final isSelected = widget.selectedWasteType == label ||
                          (label == 'Всё' && widget.selectedWasteType == null);

                      return Padding(
                        padding: EdgeInsets.only(
                          right: filterIndex == filters.length - 1 ? 16 : 8,
                        ),
                        child: WasteTypeChip(
                          label: label,
                          icon: icon,
                          isSelected: isSelected,
                          onTap: () => widget.onFilterChanged(
                            label == 'Всё' ? null : label,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),

        // 📊 ИНДИКАТОР РЕЗУЛЬТАТОВ
        if (filteredPoints.length != _allPoints.length)
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Найдено: ${filteredPoints.length} из ${_allPoints.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
