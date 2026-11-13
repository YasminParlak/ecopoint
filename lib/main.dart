import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/constants/colors.dart';
import 'core/constants/text_styles.dart';
import 'features/onboarding/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

 await Supabase.initialize(
  url: 'https://lmfryzdqbrrxklvasjcy.supabase.co',
  publishableKey: 'sb_publishable_1Ggzfj5OicnvuHegyvNeSQ_czwQWKYS',
);

  runApp(const EcoPointApp());
}

class EcoPointApp extends StatelessWidget {
  const EcoPointApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoPoint',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primaryGreen,
        scaffoldBackgroundColor: AppColors.background,
        textTheme: GoogleFonts.manropeTextTheme(
          ThemeData.light().textTheme,
        ).copyWith(
          bodyLarge: AppTextStyles.body,
          bodyMedium: AppTextStyles.body,
          titleLarge: AppTextStyles.h1,
          titleMedium: AppTextStyles.h2,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: const OnboardingScreen(),
    );
  }
}