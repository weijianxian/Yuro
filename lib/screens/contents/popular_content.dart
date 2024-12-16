import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:asmrapp/presentation/viewmodels/popular_viewmodel.dart';
import 'package:asmrapp/presentation/layouts/work_layout_strategy.dart';
import 'package:asmrapp/widgets/work_grid/enhanced_work_grid_view.dart';

class PopularContent extends StatefulWidget {
  const PopularContent({super.key});

  @override
  State<PopularContent> createState() => _PopularContentState();
}

class _PopularContentState extends State<PopularContent> with AutomaticKeepAliveClientMixin {
  final _layoutStrategy = const WorkLayoutStrategy();
  final _scrollController = ScrollController();
  late PopularViewModel _viewModel;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _viewModel = PopularViewModel();
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
      child: Consumer<PopularViewModel>(
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