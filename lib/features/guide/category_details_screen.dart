import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';

class CategoryDetailsScreen extends StatelessWidget {
  final String icon;
  final String title;
  final Color color;

  const CategoryDetailsScreen({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
  });

  // Данные для каждой категории
  Map<String, dynamic> _getCategoryData(String title) {
    switch (title) {
      case 'Пластик':
        return {
          'accepts': [
            'ПЭТ-бутылки (вода, газировка)',
            'Пластиковые канистры',
            'Флаконы от шампуня, геля',
            'Пластиковые пакеты',
            'Пищевые контейнеры (ПП, ПНД)',
            'Пластиковые крышки',
          ],
          'notAccepts': [
            'Загрязнённая упаковка',
            'Одноразовая посуда',
            'Зубные щётки',
            'Игрушки',
            'Пластиковые пакеты с металлизацией',
          ],
          'howToPrepare': [
            'Сполосните ёмкость',
            'Снимите этикетку (если легко снимается)',
            'Снимите крышку (сдаётся отдельно)',
            'Сожмите бутылку для экономии места',
          ],
        };

      case 'Стекло':
        return {
          'accepts': [
            'Стеклянные бутылки (вино, пиво)',
            'Стеклянные банки',
            'Стеклянная тара от косметики',
            'Листовое стекло',
          ],
          'notAccepts': [
            'Зеркала',
            'Оконное стекло',
            'Хрусталь',
            'Керамика и фаянс',
            'Лампочки',
            'Посуда Pyrex',
          ],
          'howToPrepare': [
            'Сполосните тару',
            'Снимите металлические крышки',
            'Удалите пластиковые элементы',
            'Не разбивайте стекло!',
          ],
        };

      case 'Бумага':
        return {
          'accepts': [
            'Газеты и журналы',
            'Картонные коробки',
            'Офисная бумага',
            'Бумажные пакеты',
            'Книги (без переплёта)',
            'Бумажные конверты',
          ],
          'notAccepts': [
            'Загрязнённая бумага',
            'Чеки (термобумага)',
            'Одноразовая посуда',
            'Бумажные стаканчики',
            'Влажные салфетки',
            'Обои',
          ],
          'howToPrepare': [
            'Удалите скрепки, скобы',
            'Сложите коробки плоско',
            'Не мочите бумагу',
            'Удалите пластиковые окна из конвертов',
          ],
        };

      case 'Металл':
        return {
          'accepts': [
            'Алюминиевые банки',
            'Жестяные банки (консервы)',
            'Алюминиевая фольга',
            'Металлические крышки',
            'Консервные банки',
          ],
          'notAccepts': [
            'Аэрозольные баллончики',
            'Электрические приборы',
            'Батарейки',
            'Опасные отходы',
          ],
          'howToPrepare': [
            'Сполосните банки',
            'Сожмите для экономии места',
            'Удалите пластиковые элементы',
          ],
        };

      case 'Батарейки':
        return {
          'accepts': [
            'Пальчиковые (AA)',
            'Мизинчиковые (AAA)',
            'Батарейки-таблетки',
            'Аккумуляторы',
            'Батарейки из часов',
            'Батарейки из игрушек',
          ],
          'notAccepts': [
            'Автомобильные аккумуляторы',
            'Промышленные батареи',
          ],
          'howToPrepare': [
            'Заклейте контакты скотчем',
            'Не повреждайте корпус',
            'Храните в сухом месте',
          ],
        };

      case 'Одежда':
        return {
          'accepts': [
            'Чистая одежда',
            'Обувь (парная)',
            'Сумки и рюкзаки',
            'Постельное бельё',
            'Шторы и текстиль',
            'Детская одежда',
          ],
          'notAccepts': [
            'Грязная одежда',
            'Повреждённая одежда',
            'Нижнее бельё',
            'Носки',
          ],
          'howToPrepare': [
            'Постирайте и высушите',
            'Сложите аккуратно',
            'Обувь свяжите вместе',
          ],
        };

      case 'Электроника':
        return {
          'accepts': [
            'Мобильные телефоны',
            'Провода и кабели',
            'Зарядные устройства',
            'Наушники',
            'Клавиатуры и мыши',
            'Флешки',
          ],
          'notAccepts': [
            'Крупная бытовая техника',
            'Мониторы и телевизоры',
          ],
          'howToPrepare': [
            'Удалите батарейки',
            'Сотрите личные данные',
            'Сложите провода вместе',
          ],
        };

      case 'Опасные':
        return {
          'accepts': [
            'Ртутные градусники',
            'Энергосберегающие лампы',
            'Люминесцентные лампы',
            'Аэрозоли (дезодоранты)',
            'Краски и лаки',
            'Растворители',
            'Удобрения',
          ],
          'notAccepts': [
            'Обычные лампы накаливания',
            'Светодиодные лампы',
          ],
          'howToPrepare': [
            'Не повреждайте упаковку',
            'Храните в оригинальной таре',
            'Плотно закройте крышки',
          ],
        };

      default:
        return {
          'accepts': [],
          'notAccepts': [],
          'howToPrepare': [],
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = _getCategoryData(title);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.h2,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            title: '✅ Что можно сдать',
            items: data['accepts'] as List<String>,
            iconColor: AppColors.success,
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: '❌ Что нельзя сдавать',
            items: data['notAccepts'] as List<String>,
            iconColor: AppColors.error,
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: '📋 Как подготовить',
            items: data['howToPrepare'] as List<String>,
            iconColor: AppColors.primaryGreen,
            isPreparation: true,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<String> items,
    required Color iconColor,
    bool isPreparation = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.h3.copyWith(
              color: iconColor,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      isPreparation
                          ? Icons.check_circle_outline
                          : Icons.circle,
                      size: 16,
                      color: iconColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item,
                        style: AppTextStyles.body,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}