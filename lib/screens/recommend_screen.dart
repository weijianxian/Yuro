import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:asmrapp/widgets/drawer_menu.dart';
import 'package:asmrapp/presentation/viewmodels/recommend_viewmodel.dart';
import 'package:asmrapp/presentation/layouts/work_layout_strategy.dart';
import 'package:asmrapp/widgets/work_grid/enhanced_work_grid_view.dart';
import 'package:asmrapp/presentation/viewmodels/auth_viewmodel.dart';

class RecommendScreen extends StatefulWidget {
  const RecommendScreen({super.key});

  @override
  State<RecommendScreen> createState() => _RecommendScreenState();
}

class _RecommendScreenState extends State<RecommendScreen> with AutomaticKeepAliveClientMixin {
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
      child: Scaffold(
        appBar: AppBar(
          title: const Text('为你推荐'),
        ),
        drawer: const DrawerMenu(),
        body: Consumer<RecommendViewModel>(
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
      ),
    );
  }
} 