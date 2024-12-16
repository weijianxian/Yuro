import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:asmrapp/presentation/viewmodels/home_viewmodel.dart';
import 'package:asmrapp/presentation/layouts/work_layout_strategy.dart';
import 'package:asmrapp/widgets/work_grid/enhanced_work_grid_view.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> with AutomaticKeepAliveClientMixin {
  final _layoutStrategy = const WorkLayoutStrategy();
  final _scrollController = ScrollController();
  late HomeViewModel _viewModel;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _viewModel = HomeViewModel();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<HomeViewModel>(
        builder: (context, viewModel, child) {
          return EnhancedWorkGridView(
            works: viewModel.works,
            isLoading: viewModel.isLoading,
            error: viewModel.error,
            currentPage: viewModel.currentPage,
            totalPages: viewModel.totalPages,
            onPageChanged: (page) => viewModel.loadPage(page),
            onRefresh: () => viewModel.refresh(),
            onRetry: () => viewModel.refresh(),
            layoutStrategy: _layoutStrategy,
            scrollController: _scrollController,
          );
        },
      ),
    );
  }
} 