import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/eco_button.dart';
import 'auth_screen.dart';

class ProfileScreen extends StatefulWidget {
  final bool isLoggedIn;
  final VoidCallback onLogin;
  final VoidCallback onLogout;

  const ProfileScreen({
    super.key,
    required this.isLoggedIn,
    required this.onLogin,
    required this.onLogout,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          AppStrings.tabProfile,
          style: AppTextStyles.h2,
        ),
      ),
      body: widget.isLoggedIn ? _buildLoggedInProfile() : _buildLoggedOutProfile(),
    );
  }

  // Состояние: НЕ авторизован
  Widget _buildLoggedOutProfile() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                size: 50,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Добро пожаловать!',
              style: AppTextStyles.h2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Войдите, чтобы сохранять избранные пункты и отслеживать статистику',
              style: AppTextStyles.bodySecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            EcoButton(
              text: AppStrings.signIn,
              icon: Icons.login,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AuthScreen(
                      onLogin: widget.onLogin,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AuthScreen(
                      isRegistration: true,
                      onLogin: widget.onLogin,
                    ),
                  ),
                );
              },
              child: Text(
                'Нет аккаунта? ${AppStrings.signUp}',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Состояние: авторизован
  Widget _buildLoggedInProfile() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Карточка пользователя
        Container(
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
          child: Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    'А',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Анна',
                      style: AppTextStyles.h3.copyWith(fontSize: 20),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'anna@ecopoint.ru',
                      style: AppTextStyles.bodySecondary.copyWith(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Статистика
        Text(
          'Статистика',
          style: AppTextStyles.h3,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard('5', 'В избранном', Icons.star, AppColors.accentOrange),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard('3', 'Посещено', Icons.check_circle, AppColors.primaryGreen),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Настройки
        Text(
          'Настройки',
          style: AppTextStyles.h3,
        ),
        const SizedBox(height: 12),
        Container(
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
          child: Column(
            children: [
              _buildSettingsRow(
                icon: Icons.notifications,
                title: 'Уведомления',
                subtitle: 'Напоминания о пунктах рядом',
                trailing: Switch(
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                  activeColor: AppColors.primaryGreen,
                ),
              ),
              const Divider(height: 1, color: AppColors.divider),
              _buildSettingsRow(
                icon: Icons.straighten,
                title: 'Единицы расстояния',
                subtitle: 'Километры',
                trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
              ),
              const Divider(height: 1, color: AppColors.divider),
              _buildSettingsRow(
                icon: Icons.palette,
                title: 'Тема',
                subtitle: 'Светлая',
                trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // О приложении
        Text(
          'О приложении',
          style: AppTextStyles.h3,
        ),
        const SizedBox(height: 12),
        Container(
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
          child: Column(
            children: [
              _buildSettingsRow(
                icon: Icons.info,
                title: 'Версия',
                subtitle: '1.0.0',
                trailing: const SizedBox.shrink(),
              ),
              const Divider(height: 1, color: AppColors.divider),
              _buildSettingsRow(
                icon: Icons.privacy_tip,
                title: 'Политика конфиденциальности',
                trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
              ),
              const Divider(height: 1, color: AppColors.divider),
              _buildSettingsRow(
                icon: Icons.feedback,
                title: 'Обратная связь',
                trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Кнопка выхода
        EcoButton(
          text: 'Выйти',
          isSecondary: true,
          icon: Icons.logout,
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Выйти из аккаунта?', style: AppTextStyles.h3),
                content: Text('Вы сможете войти снова в любой момент', style: AppTextStyles.bodySecondary),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Отмена', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onLogout();
                    },
                    child: Text('Выйти', style: AppTextStyles.body.copyWith(color: AppColors.error, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color) {
    return Container(
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
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.h2.copyWith(fontSize: 24, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsRow({
    required IconData icon,
    required String title,
    String? subtitle,
    required Widget trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500)),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTextStyles.caption),
                ],
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}