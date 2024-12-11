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

  String _getOrderText(String order, String sort) {
    switch (order) {
      case 'create_date':
        return sort == 'desc' ? '最新发布' : '最早发布';
      case 'dl_count':
        return sort == 'desc' ? '下载最多' : '下载最少';
      default:
        return '排序';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      body: Column(
        children: [
          Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 8,
              bottom: 8,
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: '搜索...',
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 20),
                              onPressed: () {
                                _searchController.clear();
                                context.read<SearchViewModel>().clear();
                              },
                            )
                          : null,
                      prefixIcon: const Icon(Icons.search, size: 20),
                      isDense: true,
                    ),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _onSearch(),
                    onChanged: (value) => setState(() {}),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      // 字幕选项
                      Consumer<SearchViewModel>(
                        builder: (context, viewModel, _) => FilterChip(
                          label: const Text('字幕'),
                          selected: viewModel.hasSubtitle,
                          onSelected: (_) => viewModel.toggleSubtitle(),
                          showCheckmark: true,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // 排序选项
                      Consumer<SearchViewModel>(
                        builder: (context, viewModel, _) => PopupMenuButton<(String, String)>(
                          child: Chip(
                            label: Text(_getOrderText(viewModel.order, viewModel.sort)),
                            deleteIcon: const Icon(Icons.arrow_drop_down, size: 18),
                            onDeleted: null,
                          ),
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: ('create_date', 'desc'),
                              child: Text('最新发布'),
                            ),
                            const PopupMenuItem(
                              value: ('create_date', 'asc'),
                              child: Text('最早发布'),
                            ),
                            const PopupMenuItem(
                              value: ('dl_count', 'desc'),
                              child: Text('下载最多'),
                            ),
                            const PopupMenuItem(
                              value: ('dl_count', 'asc'),
                              child: Text('下载最少'),
                            ),
                          ],
                          onSelected: (value) => viewModel.setOrder(value.$1, value.$2),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<SearchViewModel>(
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
          ),
        ],
      ),
    );
  }
} 