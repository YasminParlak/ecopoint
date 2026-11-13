import 'package:flutter/material.dart';

/// Цветовая палитра приложения EcoPoint
class AppColors {
  // Основные цвета бренда
  static const Color primaryGreen = Color(0xFF00C853); // Яркий эко-зелёный
  static const Color accentOrange = Color(0xFFFF9800); // Энергичный оранжевый

  // Фоны
  static const Color background = Color(0xFFFAFAFA);   // Очень светлый серый
  static const Color surface = Colors.white;           // Белый для карточек

  // Текст
  static const Color textPrimary = Color(0xFF212121);  // Тёмно-серый для заголовков
  static const Color textSecondary = Color(0xFF757575); // Серый для подписей

  // Статусы
  static const Color success = Color(0xFF4CAF50);      // "Открыто"
  static const Color error = Color(0xFFE53935);        // "Закрыто" или ошибка
  static const Color offlineBanner = Color(0xFFFFF3E0); // Оранжевый фон офлайн

  // Дополнительные
  static const Color divider = Color(0xFFE0E0E0);      // Разделители
  static const Color chipBackground = Color(0xFFF5F5F5); // Фон чипов/тегов
}