import 'package:flutter/material.dart';
import 'package:asmrapp/screens/home_screen.dart';
import 'package:asmrapp/screens/player_screen.dart';
import 'package:asmrapp/screens/detail_screen.dart';
import 'package:asmrapp/widgets/drawer_menu.dart';
import 'package:asmrapp/common/constants/strings.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Strings.appName,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      routes: {
        '/player': (context) => const PlayerScreen(),
      },
    );
  }
}
