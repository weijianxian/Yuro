import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:asmrapp/presentation/viewmodels/search_viewmodel.dart';
import 'package:asmrapp/widgets/work_grid.dart';
import 'package:asmrapp/presentation/layouts/work_layout_strategy.dart';
import 'package:asmrapp/screens/detail_screen.dart';
import 'package:asmrapp/utils/logger.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SearchViewModel(),
      child: const SearchScreenContent(),
    );
  }
}

class SearchScreenContent extends StatefulWidget {
  const SearchScreenContent({super.key});

  @override
  State<SearchScreenContent> createState() => _SearchScreenContentState();
}

class _SearchScreenContentState extends State<SearchScreenContent> {
  final _searchController = TextEditingController();
  final _layoutStrategy = const WorkLayoutStrategy();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    final keyword = _searchController.text.trim();
    if (keyword.isEmpty) return;

    AppLogger.debug('执行搜索: $keyword');
    context.read<SearchViewModel>().search(keyword);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: '搜索...',
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                context.read<SearchViewModel>().clear();
              },
            ),
          ),
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _onSearch(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _onSearch,
          ),
        ],
      ),
      body: Consumer<SearchViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (viewModel.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(viewModel.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _onSearch,
                    child: const Text('重试'),
                  ),
                ],
              ),
            );
          }

          if (viewModel.works.isEmpty) {
            if (viewModel.keyword.isEmpty) {
              return Center(
                child: Text(
                  '输入关键词开始搜索',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              );
            }
            return Center(
              child: Text(
                '没有找到相关结果',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: _layoutStrategy.getPadding(context),
                sliver: WorkGrid(
                  works: viewModel.works,
                  layoutStrategy: _layoutStrategy,
                  onWorkTap: (work) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailScreen(work: work),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
} 