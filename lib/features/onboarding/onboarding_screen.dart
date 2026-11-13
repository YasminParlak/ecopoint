import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/eco_button.dart';
import '../map/map_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  final List<Map<String, String>> _pages = [
    {
      'title': AppStrings.onboardingTitle1,
      'subtitle': AppStrings.onboardingSubtitle1,
      'icon': '🗺️', // Заглушка для иллюстрации
    },
    {
      'title': AppStrings.onboardingTitle2,
      'subtitle': AppStrings.onboardingSubtitle2,
      'icon': '♻️',
    },
    {
      'title': AppStrings.onboardingTitle3,
      'subtitle': AppStrings.onboardingSubtitle3,
      'icon': '🌱',
    },
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
            // Если это последняя страница — переходим на Карту
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MapScreen()),
            );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Кнопка "Пропустить"
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const MapScreen()),
                    );
                  },
                  child: Text(
                    AppStrings.skip,
                    style: AppTextStyles.bodySecondary,
                  ),
                ),
              ),
            ),

            // Слайдер страниц
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Иллюстрация (заглушка эмодзи)
                        Text(
                          _pages[index]['icon']!,
                          style: const TextStyle(fontSize: 80),
                        ),
                        const SizedBox(height: 40),

                        // Заголовок
                        Text(
                          _pages[index]['title']!,
                          style: AppTextStyles.h1,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),

                        // Подзаголовок
                        Text(
                          _pages[index]['subtitle']!,
                          style: AppTextStyles.bodySecondary,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Пагинация (точки)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? AppColors.primaryGreen
                        : AppColors.divider,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            const SizedBox(height: 40),

            // Кнопки навигации
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: _currentPage == _pages.length - 1
                  ? EcoButton(
                      text: AppStrings.start,
                      onPressed: _nextPage,
                    )
                  : EcoButton(
                      text: AppStrings.next,
                      onPressed: _nextPage,
                    ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}