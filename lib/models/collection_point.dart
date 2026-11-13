class CollectionPoint {
  final String id;
  final String name;
  final String address;
  final String distance;
  final List<String> wasteTypes;
  final bool isOpen; // Ручной флаг-страховка
  final double latitude;
  final double longitude;

  // Расписание по дням: индекс 0=пн ... 6=вс.
  // null в позиции = выходной; пара 0/0 = круглосуточно.
  final List<int?> openHours;
  final List<int?> closeHours;

  CollectionPoint({
    required this.id,
    required this.name,
    required this.address,
    required this.distance,
    required this.wasteTypes,
    required this.isOpen,
    required this.latitude,
    required this.longitude,
    this.openHours = const [],
    this.closeHours = const [],
  });

  /// Есть ли валидное расписание по 7 дням
  bool get _hasSchedule => openHours.length == 7 && closeHours.length == 7;

  /// 🟢 Открыт ли пункт ПРЯМО СЕЙЧАС
  bool get isOpenNow {
    // Если расписания нет -> используем ручной флаг
    if (!_hasSchedule) return isOpen;

    final now = DateTime.now();
    final idx = now.weekday - 1; // 1=пн -> 0 ... 7=вс -> 6
    
    // Защита от выхода за границы
    if (idx < 0 || idx >= 7) return false;

    final open = openHours[idx];
    final close = closeHours[idx];

    // Если хоть одно значение null -> выходной -> закрыто
    if (open == null || close == null) return false; 
    
    // Круглосуточно
    if (open == 0 && close == 0) return true; 

    // Обычный день
    if (close > open) return now.hour >= open && now.hour < close;
    
    // Ночная смена
    return now.hour >= open || now.hour < close;        
  }

    factory CollectionPoint.fromMap(Map<String, dynamic> map) {
    // Безопасно парсим массивы часов
    List<int?> safeOpenHours = const [];
    List<int?> safeCloseHours = const [];
    
    try {
      safeOpenHours = _parseDays(map['open_hours']);
      safeCloseHours = _parseDays(map['close_hours']);
    } catch (e) {
      // Если парсинг упал -> оставляем пустые списки
      // Тогда _hasSchedule будет false -> isOpenNow вернет флаг isOpen (true/false)
      print('PARSING ERROR for ${map['name']}: $e');
    }

    return CollectionPoint(
      id: map['id'] as String,
      name: map['name'] as String,
      address: map['address'] as String,
      distance: map['distance'] as String? ?? '',
      wasteTypes: List<String>.from(map['waste_types'] as List? ?? const []),
      isOpen: map['is_open'] as bool? ?? true,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      openHours: safeOpenHours,
      closeHours: safeCloseHours,
    );
  }

  /// Универсальный парсер массивов дней
  static List<int?> _parseDays(dynamic raw) {
    if (raw == null) return const [];
    
    // Случай 1: Пришёл готовый список [9, 9, ...]
    if (raw is List) {
      if (raw.length != 7) return const [];
      return raw.map((e) {
        if (e == null) return null;
        if (e is int) return e;
        if (e is String) return int.tryParse(e); // Пробуем превратить строку "9" в число
        return null;
      }).toList();
    }
    
    // Случай 2: Пришла строка "{9,9,...}" (редко, но бывает)
    if (raw is String) {
       try {
         final cleaned = raw.replaceAll('{', '').replaceAll('}', '');
         final parts = cleaned.split(',').map((s) => s.trim()).toList();
         if (parts.length != 7) return const [];
         
         return parts.map((p) {
           if (p.toLowerCase() == 'null') return null;
           return int.tryParse(p);
         }).toList();
       } catch (_) {
         return const [];
       }
    }

    return const [];
  }
}