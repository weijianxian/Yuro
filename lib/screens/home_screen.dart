import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:asmrapp/widgets/drawer_menu.dart';
import 'package:asmrapp/common/constants/strings.dart';
import 'package:asmrapp/presentation/viewmodels/home_viewmodel.dart';
import 'package:asmrapp/presentation/layouts/work_layout_strategy.dart';
import 'package:asmrapp/screens/search_screen.dart';
import 'package:asmrapp/widgets/work_grid/enhanced_work_grid_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin {
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
      child: Scaffold(
        appBar: AppBar(
          title: const Text(Strings.appName),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SearchScreen(),
                  ),
                );
              },
            ),
          ],
        ),
        drawer: const DrawerMenu(),
        body: Consumer<HomeViewModel>(
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
      ),
    );
  }
}
