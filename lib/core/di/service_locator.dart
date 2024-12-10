import 'package:get_it/get_it.dart';
import '../audio/i_audio_player_service.dart';
import '../audio/audio_player_service.dart';
import '../../data/services/api_service.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // 核心服务
  getIt.registerLazySingleton<IAudioPlayerService>(
    () => AudioPlayerService(),
  );
  
  // API 服务
  getIt.registerLazySingleton<ApiService>(
    () => ApiService(),
  );
} 