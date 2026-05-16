import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/theme_provider.dart';
import 'providers/workout_provider.dart';
import 'screens/home_screen.dart';
import 'screens/detail_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/about_screen.dart';

void main() async {
  // Обязательная инициализация для работы плагинов (SharedPreferences и др.)
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => WorkoutProvider()),
      ],
      child: const FitLifeApp(),
    ),
  );
}

class FitLifeApp extends StatelessWidget {
  const FitLifeApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Используем Consumer, чтобы приложение корректно реагировало на смену темы
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'FitLife',
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.themeMode,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF2ECC71),
              brightness: Brightness.light,
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF2ECC71),
              brightness: Brightness.dark,
            ),
          ),
          initialRoute: '/',
          routes: {
            '/': (context) => const HomeScreen(),
            '/detail': (context) => const DetailScreen(),
            '/settings': (context) => const SettingsScreen(),
            '/about': (context) => const AboutScreen(),
          },
        );
      },
    );
  }
}
