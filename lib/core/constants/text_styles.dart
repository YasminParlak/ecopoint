import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

/// Текстовые стили с использованием шрифта Manrope
class AppTextStyles {

  // Заголовок 1 (H1) - для заголовков экранов
  static TextStyle get h1 => GoogleFonts.manrope(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  // Заголовок 2 (H2) - для подзаголовков
  static TextStyle get h2 => GoogleFonts.manrope(
    fontSize: 22,
    fontWeight: FontWeight.w600, // SemiBold
    color: AppColors.textPrimary,
    height: 1.3,
  );

  // Заголовок 3 (H3) - для секций
  static TextStyle get h3 => GoogleFonts.manrope(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  // Основной текст (Body)
  static TextStyle get body => GoogleFonts.manrope(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  // Вторичный текст (подписи, описания)
  static TextStyle get bodySecondary => GoogleFonts.manrope(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  // Маленький текст (Caption)
  static TextStyle get caption => GoogleFonts.manrope(
    fontSize: 12,
    fontWeight: FontWeight.w500, // Medium
    color: AppColors.textSecondary,
    height: 1.4,
  );

  // Кнопки
  static TextStyle get button => GoogleFonts.manrope(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  // Кнопки маленькие
  static TextStyle get buttonSmall => GoogleFonts.manrope(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );
}