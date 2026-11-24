import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../core/constants/app_strings.dart';
import 'category_details_screen.dart';

class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  // Данные категорий
  final List<Map<String, dynamic>> _categories = const [
    {
      'icon': '🥤',
      'title': AppStrings.wastePlastic,
      'subtitle': 'Бутылки, пакеты, упаковка',
      'color': Color(0xFFFFEB3B), // Жёлтый
    },
    {
      'icon': '🍾',
      'title': AppStrings.wasteGlass,
      'subtitle': 'Бутылки, банки',
      'color': Color(0xFF4CAF50), // Зелёный
    },
    {
      'icon': '📰',
      'title': AppStrings.wastePaper,
      'subtitle': 'Картон, газеты, журналы',
      'color': Color(0xFF2196F3), // Синий
    },
    {
      'icon': '🥫',
      'title': AppStrings.wasteMetal,
      'subtitle': 'Банки, фольга',
      'color': Color(0xFF9E9E9E), // Серый
    },
    {
      'icon': '🔋',
      'title': AppStrings.wasteBatteries,
      'subtitle': 'Все типы батареек',
      'color': Color(0xFFFF5722), // Оранжевый
    },
    {
      'icon': '👕',
      'title': AppStrings.wasteClothes,
      'subtitle': 'Чистая, целая одежда',
      'color': Color(0xFF9C27B0), // Фиолетовый
    },
    {
      'icon': '📱',
      'title': AppStrings.wasteElectronics,
      'subtitle': 'Телефоны, провода',
      'color': Color(0xFF607D8B), // Голубой
    },
    {
      'icon': '💡',
      'title': AppStrings.wasteHazardous,
      'subtitle': 'Лампы, градусники, краски',
      'color': Color(0xFFF44336), // Красный
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          AppStrings.guideTitle,
          style: AppTextStyles.h2,
        ),
      ),
      body: Column(
        children: [
          // Список категорий
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                return _buildCategoryCard(context, category);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
      BuildContext context, Map<String, dynamic> category) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryDetailsScreen(
              icon: category['icon'],
              title: category['title'],
              color: category['color'],
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
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
        child: Row(
          children: [
            // Иконка категории
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: (category['color'] as Color).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  category['icon'],
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Информация
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category['title'],
                    style: AppTextStyles.h3.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category['subtitle'],
                    style: AppTextStyles.bodySecondary.copyWith(fontSize: 14),
                  ),
                ],
              ),
            ),

            // Стрелка вправо
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
