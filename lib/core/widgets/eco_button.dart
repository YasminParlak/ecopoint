import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';

/// Основная зелёная кнопка EcoPoint
class EcoButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isSecondary; // Вторичный стиль (прозрачная с обводкой)
  final IconData? icon;

  const EcoButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: isSecondary
            ? null
            : const LinearGradient(
                colors: [
                  AppColors.primaryGreen,
                  Color(0xFF00B248),
                ],
              ),
        color: isSecondary ? Colors.transparent : null,
        border: isSecondary
            ? Border.all(color: AppColors.primaryGreen, width: 2)
            : null,
        boxShadow: isSecondary
            ? null
            : [
                BoxShadow(
                  color: AppColors.primaryGreen.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        Icon(
                          icon,
                          color: isSecondary
                              ? AppColors.primaryGreen
                              : Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        text,
                        style: AppTextStyles.button.copyWith(
                          color: isSecondary
                              ? AppColors.primaryGreen
                              : Colors.white,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}