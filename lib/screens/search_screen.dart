import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:asmrapp/presentation/viewmodels/search_viewmodel.dart';
import 'package:asmrapp/widgets/work_grid_view.dart';
import 'package:asmrapp/presentation/layouts/work_layout_strategy.dart';
import 'package:asmrapp/utils/logger.dart';
import 'package:asmrapp/widgets/pagination_controls.dart';

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
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearch() {
    final keyword = _searchController.text.trim();
    if (keyword.isEmpty) return;

    AppLogger.debug('执行搜索: $keyword');
    context.read<SearchViewModel>().search(keyword);
  }

  void _onPageChanged(int page) async {
    final viewModel = context.read<SearchViewModel>();
    await viewModel.loadPage(page);
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
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
          Widget? emptyWidget;
          if (viewModel.works.isEmpty && viewModel.keyword.isEmpty) {
            emptyWidget = const Center(
              child: Text('输入关键词开始搜索'),
            );
          } else if (viewModel.works.isEmpty) {
            emptyWidget = const Center(
              child: Text('没有找到相关结果'),
            );
          }

          return WorkGridView(
            works: viewModel.works,
            isLoading: viewModel.isLoading,
            error: viewModel.error,
            onRetry: _onSearch,
            customEmptyWidget: emptyWidget,
            layoutStrategy: _layoutStrategy,
            scrollController: _scrollController,
            bottomWidget: viewModel.works.isNotEmpty
                ? PaginationControls(
                    currentPage: viewModel.currentPage,
                    totalPages: viewModel.totalPages,
                    isLoading: viewModel.isLoading,
                    onPageChanged: _onPageChanged,
                  )
                : null,
          );
        },
      ),
    );
  }
} 