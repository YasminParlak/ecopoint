import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/eco_button.dart';


class AuthScreen extends StatefulWidget {
  final bool isRegistration;
  final VoidCallback onLogin;

  const AuthScreen({
    super.key,
    this.isRegistration = false,
    required this.onLogin,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      // Имитация успешного входа
      widget.onLogin();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Text(
                widget.isRegistration ? 'Регистрация' : 'Вход в EcoPoint',
                style: AppTextStyles.h1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                widget.isRegistration
                    ? 'Создайте аккаунт для сохранения избранного'
                    : 'Войдите, чтобы продолжить',
                style: AppTextStyles.bodySecondary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Поле имени (только для регистрации)
              if (widget.isRegistration) ...[
                _buildTextField(
                  controller: _nameController,
                  label: 'Имя',
                  icon: Icons.person,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Введите имя';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],

              // Поле email
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Введите email';
                  if (!value.contains('@')) return 'Некорректный email';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Поле пароля
              _buildTextField(
                controller: _passwordController,
                label: 'Пароль',
                icon: Icons.lock,
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Введите пароль';
                  if (value.length < 6) return 'Минимум 6 символов';
                  return null;
                },
              ),

              if (!widget.isRegistration)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // Заглушка для "Забыли пароль"
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Функция в разработке')),
                      );
                    },
                    child: Text(
                      'Забыли пароль?',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.primaryGreen,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // Кнопка входа/регистрации
              EcoButton(
                text: widget.isRegistration ? AppStrings.signUp : AppStrings.signIn,
                onPressed: _submit,
              ),

              const SizedBox(height: 24),

              // Разделитель
              Row(
                children: [
                  const Expanded(child: Divider(color: AppColors.divider)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('или', style: AppTextStyles.caption),
                  ),
                  const Expanded(child: Divider(color: AppColors.divider)),
                ],
              ),

              const SizedBox(height: 24),

              // Кнопка Google
              _buildSocialButton(
                icon: Icons.g_mobiledata,
                label: 'Войти через Google',
                onPressed: () {
                  widget.onLogin();
                  Navigator.pop(context);
                },
              ),

              const SizedBox(height: 12),

              // Кнопка Apple
              _buildSocialButton(
                icon: Icons.apple,
                label: 'Войти через Apple',
                onPressed: () {
                  widget.onLogin();
                  Navigator.pop(context);
                },
              ),

              const SizedBox(height: 24),

              // Переключение между входом и регистрацией
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AuthScreen(
                          isRegistration: !widget.isRegistration,
                          onLogin: widget.onLogin,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    widget.isRegistration
                        ? 'Уже есть аккаунт? Войти'
                        : 'Нет аккаунта? Зарегистрироваться',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.bodySecondary,
        prefixIcon: Icon(icon, color: AppColors.textSecondary),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 24, color: AppColors.textPrimary),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: AppTextStyles.button.copyWith(color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}