import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:asmrapp/widgets/drawer_menu.dart';
import 'package:asmrapp/presentation/viewmodels/popular_viewmodel.dart';
import 'package:asmrapp/presentation/layouts/work_layout_strategy.dart';
import 'package:asmrapp/widgets/pagination_controls.dart';
import 'package:asmrapp/widgets/work_grid_view.dart';

class PopularScreen extends StatefulWidget {
  const PopularScreen({super.key});

  @override
  State<PopularScreen> createState() => _PopularScreenState();
}

class _PopularScreenState extends State<PopularScreen> {
  final _layoutStrategy = const WorkLayoutStrategy();
  final _scrollController = ScrollController();
  late PopularViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = PopularViewModel();
    _viewModel.loadPopular();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
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
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('热门作品'),
        ),
        drawer: const DrawerMenu(),
        body: Consumer<PopularViewModel>(
          builder: (context, viewModel, child) {
            return Column(
              children: [
                Expanded(
                  child: WorkGridView(
                    works: viewModel.works,
                    isLoading: viewModel.isLoading,
                    error: viewModel.error,
                    onRetry: () => viewModel.loadPopular(),
                    layoutStrategy: _layoutStrategy,
                    scrollController: _scrollController,
                    bottomWidget: viewModel.works.isNotEmpty
                        ? PaginationControls(
                            currentPage: viewModel.currentPage,
                            totalPages: viewModel.totalPages ?? 1,
                            onPageChanged: (page) {
                              viewModel.loadPage(page);
                              _scrollToTop();
                            },
                            isLoading: viewModel.isLoading,
                          )
                        : null,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
} 