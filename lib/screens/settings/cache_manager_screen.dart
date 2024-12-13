import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:asmrapp/presentation/viewmodels/settings/cache_manager_viewmodel.dart';

class CacheManagerScreen extends StatelessWidget {
  const CacheManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CacheManagerViewModel()..loadCacheSize(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('缓存管理'),
        ),
        body: Consumer<CacheManagerViewModel>(
          builder: (context, viewModel, _) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.error != null) {
              return Center(
                child: Text(
                  viewModel.error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              );
            }

            return ListView(
              children: [
                ListTile(
                  title: const Text('当前缓存大小'),
                  subtitle: Text(viewModel.cacheSizeFormatted),
                  trailing: TextButton(
                    onPressed: viewModel.isLoading 
                      ? null 
                      : () => viewModel.clearCache(),
                    child: const Text('清理缓存'),
                  ),
                ),
                const Divider(),
                const ListTile(
                  title: Text('缓存说明'),
                  subtitle: Text('缓存用于存储最近播放的音频文件，以提高再次播放时的加载速度。系统会自动清理过期和超量的缓存。'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
} 