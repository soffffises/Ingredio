import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pantry_chef/core/utils/app_theme.dart';
import 'package:pantry_chef/core/utils/constants.dart';
import 'package:pantry_chef/di/service_locator.dart';
import 'package:pantry_chef/data/local/hive_database.dart';
import 'package:pantry_chef/presentation/screens/splash_screen.dart';
import 'package:pantry_chef/presentation/screens/ingredients_screen.dart';
import 'package:pantry_chef/presentation/screens/recipes_list_screen.dart';
import 'package:pantry_chef/presentation/screens/favorites_screen.dart';
import 'package:pantry_chef/presentation/screens/profile_screen.dart';
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
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
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
  int _selectedIndex = 1;

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
            child: const RecipesListScreen(),
          ),
          LazyLoadWrapper(
            index: 1,
            selectedIndex: _selectedIndex,
            child: const IngredientsScreen(),
          ),
          LazyLoadWrapper(
            index: 2,
            selectedIndex: _selectedIndex,
            child: const FavoritesScreen(),
          ),
          LazyLoadWrapper(
            index: 3,
            selectedIndex: _selectedIndex,
            child: const ProfileScreen(),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return _IosBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      );
    }

    return NavigationBar(
      height: 80,
      selectedIndex: _selectedIndex,
      onDestinationSelected: _onItemTapped,
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.primaryContainer.withValues(alpha: 0.12),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      destinations: const [
        NavigationDestination(
          icon: FaIcon(FontAwesomeIcons.compass, size: 20),
          selectedIcon: FaIcon(FontAwesomeIcons.solidCompass, size: 20),
          label: 'Discover',
        ),
        NavigationDestination(
          icon: FaIcon(FontAwesomeIcons.boxOpen, size: 20),
          selectedIcon: FaIcon(FontAwesomeIcons.box, size: 20),
          label: 'Pantry',
        ),
        NavigationDestination(
          icon: FaIcon(FontAwesomeIcons.heart, size: 20),
          selectedIcon: FaIcon(FontAwesomeIcons.solidHeart, size: 20),
          label: Constants.favorites,
        ),
        NavigationDestination(
          icon: FaIcon(FontAwesomeIcons.user, size: 20),
          selectedIcon: FaIcon(FontAwesomeIcons.solidUser, size: 20),
          label: 'Profile',
        ),
      ],
    );
  }
}

class _IosBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _IosBottomNavigationBar({
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = [
    _TabItem(
      label: 'Discover',
      icon: FontAwesomeIcons.compass,
      selectedIcon: FontAwesomeIcons.solidCompass,
    ),
    _TabItem(
      label: 'Pantry',
      icon: FontAwesomeIcons.boxOpen,
      selectedIcon: FontAwesomeIcons.box,
    ),
    _TabItem(
      label: Constants.favorites,
      icon: FontAwesomeIcons.heart,
      selectedIcon: FontAwesomeIcons.solidHeart,
    ),
    _TabItem(
      label: 'Profile',
      icon: FontAwesomeIcons.user,
      selectedIcon: FontAwesomeIcons.solidUser,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.outlineVariant, width: 0.5),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: SizedBox(
          height: 58,
          child: Row(
            children: [
              for (var i = 0; i < _items.length; i++)
                Expanded(
                  child: _IosTabButton(
                    item: _items[i],
                    selected: currentIndex == i,
                    onTap: () => onTap(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IosTabButton extends StatelessWidget {
  final _TabItem item;
  final bool selected;
  final VoidCallback onTap;

  const _IosTabButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.onSurfaceVariant;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: const Size(0, 58),
      onPressed: onTap,
      child: Center(
        child: SizedBox(
          width: 68,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: 34,
                height: 26,
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primaryContainer.withValues(alpha: 0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Center(
                  child: FaIcon(
                    selected ? item.selectedIcon : item.icon,
                    size: 17,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                item.label,
                maxLines: 1,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 10.5,
                  height: 1.1,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabItem {
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  const _TabItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });
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
