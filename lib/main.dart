import 'package:flutter/material.dart';
import 'package:asmrapp/screens/home_screen.dart';
import 'package:asmrapp/screens/player_screen.dart';
import 'package:asmrapp/common/constants/strings.dart';
import 'core/di/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化服务定位器
  await setupServiceLocator();

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
