import 'dart:async';
import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/collection_point.dart';

class RouteScreen extends StatefulWidget {
  final CollectionPoint point;

  const RouteScreen({super.key, required this.point});

  @override
  State<RouteScreen> createState() => _RouteScreenState();
}

class _RouteScreenState extends State<RouteScreen> {
  Position? _userPosition;
  bool _isLoading = true;
  String? _error;

  List<MapObject> _mapObjects = [];
  YandexMapController? _mapController;

  // Подписка на поток геолокации
  StreamSubscription<Position>? _positionStream;

  // Порог перерисовки маршрута (в метрах)
  static const double _routeUpdateThreshold = 50.0;

  @override
  void initState() {
    super.initState();
    _buildSmartRoute();
  }

  Future<bool> _ensureLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        setState(() {
          _error = 'Включите геолокацию (GPS) в настройках телефона';
          _isLoading = false;
        });
      }
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (mounted) {
        setState(() {
          _error =
              'Нет доступа к геолокации. Разрешите его в настройках приложения';
          _isLoading = false;
        });
      }
      return false;
    }
    return true;
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  /// Запускает отслеживание позиции пользователя
  void _startPositionTracking() {
    // Отменяем предыдущую подписку, если была
    _positionStream?.cancel();

    // Слушаем обновления позиции каждые 5 метров или 5 секунд
    _positionStream = Geolocator.getPositionStream(
      locationSettings: AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
        intervalDuration: const Duration(seconds: 5),
      ),
    ).listen((Position position) {
      _onUserPositionChanged(position);
    });
  }

  /// Реагирует на изменение позиции пользователя
  Future<void> _onUserPositionChanged(Position newPosition) async {
    if (!mounted) return;

    final oldPosition = _userPosition;
    _userPosition = newPosition;

    // 1. Обновляем маркер пользователя на карте
    _updateUserMarker();

    // 2. Если пользователь ушёл далеко от маршрута — перерисовываем его
    if (oldPosition != null) {
      final distance = Geolocator.distanceBetween(
        oldPosition.latitude,
        oldPosition.longitude,
        newPosition.latitude,
        newPosition.longitude,
      );

      if (distance > _routeUpdateThreshold) {
        await _rebuildRoute();
      }
    }

    // 3. Двигаем камеру за пользователем (плавно)
    _followUser();
  }

  /// Обновляет только маркер пользователя (быстро, без перерисовки маршрута)
  void _updateUserMarker() {
    if (_userPosition == null) return;

    setState(() {
      // Удаляем старый маркер пользователя
      _mapObjects.removeWhere((obj) => obj.mapId.value == 'user_marker');

      // Добавляем новый
      _mapObjects.add(
        PlacemarkMapObject(
          mapId: const MapObjectId('user_marker'),
          point: Point(
            latitude: _userPosition!.latitude,
            longitude: _userPosition!.longitude,
          ),
          icon: PlacemarkIcon.single(
            PlacemarkIconStyle(
              image: BitmapDescriptor.fromAssetImage(
                  'assets/icons/user_marker.png'),
              scale: 0.4,
            ),
          ),
        ),
      );
    });
  }

  /// Плавно двигает камеру к пользователю
  void _followUser() {
    if (_userPosition == null || _mapController == null) return;

    _mapController!.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: Point(
            latitude: _userPosition!.latitude,
            longitude: _userPosition!.longitude,
          ),
          zoom: 15, // Приближаем при движении
        ),
      ),
      animation: const MapAnimation(type: MapAnimationType.smooth, duration: 1),
    );
  }

  /// Пересоздаёт маршрут от текущей позиции пользователя
  Future<void> _rebuildRoute() async {
    if (_userPosition == null) return;

    final start = '${_userPosition!.longitude},${_userPosition!.latitude}';
    final end = '${widget.point.longitude},${widget.point.latitude}';

    final url = Uri.parse(
      'http://router.project-osrm.org/route/v1/driving/$start;$end?overview=full&geometries=geojson',
    );

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['code'] == 'Ok' && data['routes'].isNotEmpty) {
          final coordinates =
              data['routes'][0]['geometry']['coordinates'] as List;

          final routePoints = coordinates.map<Point>((coord) {
            final list = coord as List;
            return Point(
              latitude: (list[1] as num).toDouble(),
              longitude: (list[0] as num).toDouble(),
            );
          }).toList();

          setState(() {
            // Удаляем старую линию маршрута
            _mapObjects.removeWhere((obj) => obj.mapId.value == 'route_line');

            // Добавляем новую
            _mapObjects.add(
              PolylineMapObject(
                mapId: const MapObjectId('route_line'),
                polyline: Polyline(points: routePoints),
                strokeColor: Colors.green,
                strokeWidth: 6.0,
              ),
            );
          });
          return;
        }
      }
    } catch (e) {
      debugPrint('OSRM rebuild failed: $e');
    }

    // Fallback: прямая линия, если OSRM не ответил
    setState(() {
      _mapObjects.removeWhere((obj) => obj.mapId.value == 'route_line');
      _mapObjects.add(
        PolylineMapObject(
          mapId: const MapObjectId('route_line'),
          polyline: Polyline(points: [
            Point(
                latitude: _userPosition!.latitude,
                longitude: _userPosition!.longitude),
            Point(
                latitude: widget.point.latitude,
                longitude: widget.point.longitude),
          ]),
          strokeColor: Colors.green,
          strokeWidth: 6.0,
        ),
      );
    });
  }

  /// Первоначальная загрузка маршрута
  Future<void> _buildSmartRoute() async {
    try {
      final hasPermission = await _ensureLocationPermission();
      if (!hasPermission) return;
      _userPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final start = '${_userPosition!.longitude},${_userPosition!.latitude}';
      final end = '${widget.point.longitude},${widget.point.latitude}';

      final url = Uri.parse(
        'http://router.project-osrm.org/route/v1/driving/$start;$end?overview=full&geometries=geojson',
      );

      List<Point> routePoints = [];
      bool osrmWorked = false;

      try {
        final response =
            await http.get(url).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          if (data['code'] == 'Ok' && data['routes'].isNotEmpty) {
            final coordinates =
                data['routes'][0]['geometry']['coordinates'] as List;

            routePoints = coordinates.map<Point>((coord) {
              final list = coord as List;
              return Point(
                latitude: (list[1] as num).toDouble(),
                longitude: (list[0] as num).toDouble(),
              );
            }).toList();

            osrmWorked = true;
          }
        }
      } catch (e) {
        debugPrint('OSRM failed, using straight line: $e');
      }

      if (!osrmWorked || routePoints.isEmpty) {
        routePoints = [
          Point(
              latitude: _userPosition!.latitude,
              longitude: _userPosition!.longitude),
          Point(
              latitude: widget.point.latitude,
              longitude: widget.point.longitude),
        ];
      }

      setState(() {
        _mapObjects = [
          // Линия маршрута
          PolylineMapObject(
            mapId: const MapObjectId('route_line'),
            polyline: Polyline(points: routePoints),
            strokeColor: Colors.green,
            strokeWidth: 6.0,
          ),

          // Маркер назначения (цвет зависит от статуса)
          PlacemarkMapObject(
            mapId: const MapObjectId('destination_marker'),
            point: Point(
                latitude: widget.point.latitude,
                longitude: widget.point.longitude),
            icon: PlacemarkIcon.single(
              PlacemarkIconStyle(
                image: BitmapDescriptor.fromAssetImage(
                  widget.point.isOpenNow
                      ? 'assets/icons/marker_green.png'
                      : 'assets/icons/marker_red.png',
                ),
                scale: 0.4,
              ),
            ),
          ),

          // Маркер пользователя
          PlacemarkMapObject(
            mapId: const MapObjectId('user_marker'),
            point: Point(
              latitude: _userPosition!.latitude,
              longitude: _userPosition!.longitude,
            ),
            icon: PlacemarkIcon.single(
              PlacemarkIconStyle(
                image: BitmapDescriptor.fromAssetImage(
                    'assets/icons/user_marker.png'),
                scale: 0.4,
              ),
            ),
          ),
        ];
        _isLoading = false;
      });

      Future.delayed(const Duration(milliseconds: 500), () {
        if (_mapController != null && mounted) {
          _fitCameraToRoute(routePoints);
        }
      });
      // ✅ Запускаем отслеживание позиции после загрузки

      _startPositionTracking();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Подбирает зум под весь маршрут
  void _fitCameraToRoute(List<Point> points) {
    if (points.isEmpty || _mapController == null) return;

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLon = points.first.longitude;
    double maxLon = points.first.longitude;

    for (var p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLon) minLon = p.longitude;
      if (p.longitude > maxLon) maxLon = p.longitude;
    }

    final centerLat = (minLat + maxLat) / 2;
    final centerLon = (minLon + maxLon) / 2;

    final latDiff = maxLat - minLat;
    final lonDiff = maxLon - minLon;
    final maxDiff = latDiff > lonDiff ? latDiff : lonDiff;

    // минимальный зум до 10 (чтобы не показывать весь мир)
    double zoom;
    if (maxDiff < 0.01) {
      zoom = 15;
    } else if (maxDiff < 0.03) {
      zoom = 13;
    } else if (maxDiff < 0.08) {
      zoom = 12;
    } else if (maxDiff < 0.2) {
      zoom = 11;
    } else if (maxDiff < 0.5) {
      zoom = 10;
    } else {
      zoom = 10;
    }

    _mapController!.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: Point(latitude: centerLat, longitude: centerLon),
          zoom: zoom,
        ),
      ),
      animation: const MapAnimation(type: MapAnimationType.smooth, duration: 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Маршрут до "${widget.point.name}"'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            )
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _buildSmartRoute,
                          child: const Text('Повторить'),
                        ),
                      ],
                    ),
                  ),
                )
              : Stack(
                  children: [
                    YandexMap(
                      onMapCreated: (controller) {
                        _mapController = controller;
                        // ✅ Если данные уже загружены — центрируем сразу
                        if (_userPosition != null && _mapObjects.isNotEmpty) {
                          final routeLine = _mapObjects
                              .whereType<PolylineMapObject>()
                              .firstOrNull;
                          if (routeLine != null &&
                              routeLine.polyline.points.isNotEmpty) {
                            _fitCameraToRoute(routeLine.polyline.points);
                          }
                        }
                      },
                      mapObjects: _mapObjects,
                    ),
                    // Кнопка "Центрировать на мне"
                    Positioned(
                      right: 16,
                      bottom: 220,
                      child: FloatingActionButton(
                        mini: true,
                        backgroundColor: Colors.white,
                        onPressed: () {
                          if (_userPosition != null) {
                            _mapController?.moveCamera(
                              CameraUpdate.newCameraPosition(
                                CameraPosition(
                                  target: Point(
                                    latitude: _userPosition!.latitude,
                                    longitude: _userPosition!.longitude,
                                  ),
                                  zoom: 16,
                                ),
                              ),
                              animation: const MapAnimation(
                                  type: MapAnimationType.smooth, duration: 0.5),
                            );
                          }
                        },
                        child:
                            const Icon(Icons.my_location, color: Colors.green),
                      ),
                    ),

                    // Информационная панель снизу
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 60),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(24)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, -2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.point.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: (widget.point.isOpenNow
                                            ? Colors.green
                                            : Colors.red)
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    widget.point.isOpenNow
                                        ? "ОТКРЫТО"
                                        : "ЗАКРЫТО",
                                    style: TextStyle(
                                      color: widget.point.isOpenNow
                                          ? Colors.green
                                          : Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.point.address,
                              style: TextStyle(
                                  color: Colors.grey[700], fontSize: 14),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton.icon(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                ),
                                label: const Text('Вернуться к карте'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
