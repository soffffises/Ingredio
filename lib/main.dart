import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantry_chef/core/utils/constants.dart';
import 'package:pantry_chef/di/service_locator.dart';
import 'package:pantry_chef/data/local/hive_database.dart';
import 'package:pantry_chef/presentation/screens/splash_screen.dart';
import 'package:pantry_chef/presentation/screens/ingredients_screen.dart';
import 'package:pantry_chef/presentation/screens/recipes_list_screen.dart';
import 'package:pantry_chef/presentation/screens/favorites_screen.dart';
import 'package:pantry_chef/presentation/providers/hive_database_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator();
  runApp(
    ProviderScope(
      overrides: [
        hiveDatabaseProvider.overrideWithValue(getIt<HiveDatabase>()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Constants.appName,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0D47A1),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0D47A1),
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          ),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 16, color: Colors.black87),
          labelLarge: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        cardTheme: CardThemeData(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF0D47A1),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          LazyLoadWrapper(
            index: 0,
            selectedIndex: _selectedIndex,
            child: const IngredientsScreen(),
          ),
          LazyLoadWrapper(
            index: 1,
            selectedIndex: _selectedIndex,
            child: const RecipesListScreen(),
          ),
          LazyLoadWrapper(
            index: 2,
            selectedIndex: _selectedIndex,
            child: const FavoritesScreen(),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: Constants.ingredients,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: Constants.recipes,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: Constants.favorites,
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class LazyLoadWrapper extends StatefulWidget {
  final int index;
  final int selectedIndex;
  final Widget child;

  const LazyLoadWrapper({
    super.key,
    required this.index,
    required this.selectedIndex,
    required this.child,
  });

  @override
  State<LazyLoadWrapper> createState() => _LazyLoadWrapperState();
}

class _LazyLoadWrapperState extends State<LazyLoadWrapper> {
  bool _isLoaded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.selectedIndex == widget.index) {
      _isLoaded = true;
    }

    if (_isLoaded) {
      return widget.child;
    }

    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
