import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/eco_button.dart';
import '../../models/collection_point.dart';
import '../../services/supabase_service.dart';
import '../../services/favorites_service.dart';
import '../map/widgets/point_details_sheet.dart'; // Для открытия карточки при тапе

class FavoritesScreen extends StatefulWidget {
  final VoidCallback onOpenMap;

  const FavoritesScreen({
    super.key,
    required this.onOpenMap,
  });

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  final FavoritesService _favoritesService = FavoritesService();

  List<CollectionPoint> _favoritePoints = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    try {
      // 1. Загружаем все пункты из базы
      final allPoints = await _supabaseService.getCollectionPoints();
      // 2. Загружаем ID избранных
      final favoriteIds = await _favoritesService.getFavoriteIds();
      // 3. Оставляем только те, что в избранном
      final favorites = allPoints.where((point) => favoriteIds.contains(point.id)).toList();

      setState(() {
        _favoritePoints = favorites;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _removeFromFavorites(String pointId) async {
    await _favoritesService.toggleFavorite(pointId);
    _loadFavorites(); // Перезагружаем список после удаления
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: Colors.orange)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          AppStrings.tabFavorites, // Убедись, что эта строка есть в app_strings.dart
          style: AppTextStyles.h2,
        ),
      ),
      body: _favoritePoints.isEmpty
          ? _buildEmptyState()
          : _buildFavoritesList(),
    );
  }

  // Пустое состояние (ТВОЙ КОД)
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('⭐', style: TextStyle(fontSize: 80)),
            const SizedBox(height: 24),
            Text(
              'Список пуст', // Или AppStrings.favoritesEmptyTitle, если есть
              style: AppTextStyles.h2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Нажмите на звездочку в карточке пункта, чтобы добавить его сюда',
              style: AppTextStyles.bodySecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            EcoButton(
              text: 'Открыть карту', // Или AppStrings.openMap
              icon: Icons.map,
              onPressed: widget.onOpenMap,
            ),
          ],
        ),
      ),
    );
  }

  // Список избранных пунктов (ТВОЙ КОД + onTap для открытия карточки)
  Widget _buildFavoritesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _favoritePoints.length,
      itemBuilder: (context, index) {
        final point = _favoritePoints[index];
        return GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => PointDetailsSheet(point: point),
            );
          },
          child: _buildFavoriteCard(point),
        );
      },
    );
  }

  // Карточка избранного пункта (ТВОЙ КОД)
  Widget _buildFavoriteCard(CollectionPoint point) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: point.isOpenNow // Исправлено на isOpenNow для актуальности
                    ? AppColors.success.withValues(alpha: 0.1)
                    : AppColors.textSecondary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                point.isOpenNow ? Icons.store : Icons.store_outlined,
                color: point.isOpenNow ? AppColors.success : AppColors.textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          point.name,
                          style: AppTextStyles.h3.copyWith(fontSize: 16),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Расстояние можно убрать, если оно не пересчитывается, или оставить
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    point.address,
                    style: AppTextStyles.bodySecondary.copyWith(fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: point.wasteTypes.take(3).map((type) { // Ограничим до 3, чтобы не ломать верстку
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.chipBackground,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          type,
                          style: AppTextStyles.caption.copyWith(fontSize: 11),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _removeFromFavorites(point.id),
              icon: const Icon(
                Icons.star,
                color: AppColors.accentOrange, // Твой кастомный цвет
              ),
            ),
          ],
        ),
      ),
    );
  }
}