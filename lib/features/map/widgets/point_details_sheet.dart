import 'package:flutter/material.dart';
import '../route_screen.dart';
import '../../../models/collection_point.dart';
import '../../../services/favorites_service.dart'; // 👈 Добавили сервис избранного

class PointDetailsSheet extends StatefulWidget {
  final CollectionPoint point;

  const PointDetailsSheet({super.key, required this.point});

  @override
  State<PointDetailsSheet> createState() => _PointDetailsSheetState();
}

class _PointDetailsSheetState extends State<PointDetailsSheet> {
  final FavoritesService _favoritesService = FavoritesService();
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  // Проверяем статус при открытии карточки
  Future<void> _checkFavoriteStatus() async {
    final isFav = await _favoritesService.isFavorite(widget.point.id);
    if (mounted) {
      setState(() => _isFavorite = isFav);
    }
  }

  // Переключаем статус и показываем уведомление
  Future<void> _toggleFavorite() async {
    final newState = await _favoritesService.toggleFavorite(widget.point.id);
    if (mounted) {
      setState(() => _isFavorite = newState);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isFavorite ? 'Добавлено в избранное ⭐' : 'Удалено из избранного'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Для удобства создаем локальную переменную, чтобы не писать widget.point везде
    final point = widget.point;

    // Определяем текст статуса для сегодняшнего дня
    String statusText;
    Color statusColor;
    
    if (point.isOpenNow) {
      statusText = "ОТКРЫТО СЕЙЧАС";
      statusColor = Colors.green;
    } else {
      statusText = "ЗАКРЫТО";
      statusColor = Colors.red;
    }

    // Формируем строку графика на сегодня
    final now = DateTime.now();
    final idx = now.weekday - 1;
    String todaySchedule = "Выходной";
    
    if (point.openHours.length == 7 && point.closeHours.length == 7) {
      final open = point.openHours[idx];
      final close = point.closeHours[idx];
      
      if (open != null && close != null) {
        if (open == 0 && close == 0) {
          todaySchedule = "Круглосуточно";
        } else {
          todaySchedule = "с ${open.toString().padLeft(2, '0')}:00 до ${close.toString().padLeft(2, '0')}:00";
        }
      }
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 60),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок (Название + Статус + ИЗБРАННОЕ)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  point.name,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              const SizedBox(width: 4),
              // 👇 КНОПКА ИЗБРАННОГО
              IconButton(
                icon: Icon(
                  _isFavorite ? Icons.star : Icons.star_border,
                  color: _isFavorite ? Colors.amber : Colors.grey,
                  size: 28,
                ),
                onPressed: _toggleFavorite,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Адрес
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(Icons.location_on_outlined, size: 18, color: Colors.grey[600]),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  point.address,
                  style: TextStyle(color: Colors.grey[700], fontSize: 14),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // График на сегодня
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time, color: Colors.grey[700]),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    "Сегодня: $todaySchedule",
                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Типы отходов
          const Text("Принимают:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: point.wasteTypes.map((type) => Chip(
              label: Text(type, style: const TextStyle(fontSize: 12)),
              backgroundColor: Colors.green.withOpacity(0.1),
              side: BorderSide.none,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            )).toList(),
          ),
          
          const SizedBox(height: 24),
          
          // Кнопка маршрута
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RouteScreen(point: point),
                  ),
                );
              },
              icon: const Icon(Icons.directions),
              label: const Text("Построить маршрут"),
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
    );
  }
}