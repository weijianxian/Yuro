import 'package:flutter/material.dart';
import 'package:asmrapp/screens/home_screen.dart';
import 'package:asmrapp/screens/player_screen.dart';
import 'package:asmrapp/common/constants/strings.dart';
import 'package:asmrapp/presentation/viewmodels/auth_viewmodel.dart';
import 'core/di/service_locator.dart';
import 'package:provider/provider.dart';
import 'screens/main_screen.dart';

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => getIt<AuthViewModel>(),
        ),
        // ... 其他 providers
      ],
      child: MaterialApp(
        title: Strings.appName,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const MainScreen(),
        routes: {
          '/player': (context) => const PlayerScreen(),
        },
      ),
    );
  }
}
