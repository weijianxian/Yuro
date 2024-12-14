import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:asmrapp/data/models/works/work.dart';
import 'package:asmrapp/presentation/viewmodels/similar_works_viewmodel.dart';
import 'package:asmrapp/widgets/work_grid_view.dart';
import 'package:asmrapp/presentation/layouts/work_layout_strategy.dart';
import 'package:asmrapp/widgets/pagination_controls.dart';

class SimilarWorksScreen extends StatefulWidget {
  final Work work;

  const SimilarWorksScreen({
    super.key,
    required this.work,
  });

  @override
  State<SimilarWorksScreen> createState() => _SimilarWorksScreenState();
}

class _SimilarWorksScreenState extends State<SimilarWorksScreen> {
  final _layoutStrategy = const WorkLayoutStrategy();
  final _scrollController = ScrollController();
  late SimilarWorksViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = SimilarWorksViewModel(widget.work);
    _viewModel.loadSimilarWorks();
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
          title: const Text('相关推荐'),
        ),
        body: Consumer<SimilarWorksViewModel>(
          builder: (context, viewModel, child) {
            return Column(
              children: [
                Expanded(
                  child: WorkGridView(
                    works: viewModel.works,
                    isLoading: viewModel.isLoading,
                    error: viewModel.error,
                    onRetry: () => viewModel.loadSimilarWorks(),
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