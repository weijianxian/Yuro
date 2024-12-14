import 'package:flutter/material.dart';
import 'package:asmrapp/screens/home_screen.dart';
import 'package:asmrapp/screens/recommend_screen.dart';
import 'package:asmrapp/screens/popular_screen.dart';
import 'package:asmrapp/widgets/mini_player/mini_player.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _pageController = PageController();
  int _currentIndex = 0;

  final _pages = const [
    HomeScreen(),
    RecommendScreen(),
    PopularScreen(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onTabTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const ClampingScrollPhysics(),
        onPageChanged: _onPageChanged,
        children: _pages,
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniPlayer(),
          NavigationBar(
            height: 60,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
            backgroundColor: Theme.of(context).colorScheme.surface,
            elevation: 0,
            selectedIndex: _currentIndex,
            onDestinationSelected: _onTabTapped,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: '主页',
              ),
              NavigationDestination(
                icon: Icon(Icons.recommend_outlined),
                selectedIcon: Icon(Icons.recommend),
                label: '推荐',
              ),
              NavigationDestination(
                icon: Icon(Icons.trending_up_outlined),
                selectedIcon: Icon(Icons.trending_up),
                label: '热门',
              ),
            ],
          ),
        ],
      ),
    );
  }
} 