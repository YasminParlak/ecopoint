import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import '../../models/collection_point.dart'; 
import '../../services/supabase_service.dart';
import 'widgets/point_details_sheet.dart';

class YandexMapScreen extends StatefulWidget {
  const YandexMapScreen({super.key});

  @override
  State<YandexMapScreen> createState() => _YandexMapScreenState();
}

class _YandexMapScreenState extends State<YandexMapScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  
  // Храним данные здесь
  List<CollectionPoint> _points = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Метод загрузки данных
   Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final data = await _supabaseService.getCollectionPoints();
      
      setState(() {
        _points = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Крутилка при загрузке
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.orange, ));
    }

    // 2. Текст ошибки, если что-то пошло не так
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Ошибка загрузки:\n$_error', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadData, // Повторить попытку
                child: const Text('Повторить'),
              ),
            ],
          ),
        ),
      );
    }

    // 3. Создаём маркеры
    final mapObjects = <MapObject>[];
    
        for (var point in _points) {
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
                 onTap: (object, tapLocation) {
         showModalBottomSheet(
           context: context,
           isScrollControlled: true, // Разрешаем растягивание
           backgroundColor: Colors.transparent, // Прозрачный фон для скругления
           builder: (context) => PointDetailsSheet(point: point),
         );
       },
        ),
      );
    }
    // 4. Возвращаем карту
    return ClipRRect(
      borderRadius: BorderRadius.zero,
      child: YandexMap(
        mapType: MapType.vector,
        onMapCreated: (controller) {
          if (_points.isNotEmpty) {
            // Вычисляем центр между всеми точками (Миасс + Златоуст)
            double sumLat = 0;
            double sumLon = 0;
            for (var p in _points) {
              sumLat += p.latitude;
              sumLon += p.longitude;
            }
            
            controller.moveCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: Point(
                    latitude: sumLat / _points.length, 
                    longitude: sumLon / _points.length
                  ),
                  zoom: 9.0, // Масштаб, чтобы видеть оба города
                ),
              ),
              animation: const MapAnimation(type: MapAnimationType.smooth, duration: 1),
            );
          }
        },
        mapObjects: mapObjects,
      ),
    );
  }
}