import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:asmrapp/presentation/viewmodels/recommend_viewmodel.dart';
import 'package:asmrapp/presentation/layouts/work_layout_strategy.dart';
import 'package:asmrapp/widgets/work_grid/enhanced_work_grid_view.dart';
import 'package:asmrapp/presentation/viewmodels/auth_viewmodel.dart';

class RecommendContent extends StatefulWidget {
  const RecommendContent({super.key});

  @override
  State<RecommendContent> createState() => _RecommendContentState();
}

class _RecommendContentState extends State<RecommendContent> with AutomaticKeepAliveClientMixin {
  final _layoutStrategy = const WorkLayoutStrategy();
  final _scrollController = ScrollController();
  late RecommendViewModel _viewModel;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    _viewModel = RecommendViewModel(authViewModel);
    _viewModel.loadRecommendations();
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
      child: Consumer<RecommendViewModel>(
        builder: (context, viewModel, child) {
          return EnhancedWorkGridView(
            works: viewModel.works,
            isLoading: viewModel.isLoading,
            error: viewModel.error,
            currentPage: viewModel.currentPage,
            totalPages: viewModel.totalPages,
            onPageChanged: (page) => viewModel.loadPage(page),
            onRefresh: () => viewModel.loadRecommendations(refresh: true),
            onRetry: () => viewModel.loadRecommendations(refresh: true),
            layoutStrategy: _layoutStrategy,
            scrollController: _scrollController,
          );
        },
      ),
    );
  }
} 