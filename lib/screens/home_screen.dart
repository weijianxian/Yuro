import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:asmrapp/widgets/drawer_menu.dart';
import 'package:asmrapp/widgets/work_grid.dart';
import 'package:asmrapp/common/constants/strings.dart';
import 'package:asmrapp/presentation/viewmodels/home_viewmodel.dart';
import 'package:asmrapp/presentation/layouts/work_layout_strategy.dart';
import 'package:asmrapp/screens/detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _layoutStrategy = const WorkLayoutStrategy();
  late HomeViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = HomeViewModel();
    _viewModel.loadWorks();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        appBar: AppBar(
          title: Consumer<HomeViewModel>(
            builder: (context, viewModel, child) => Row(
              children: [
                const Text(Strings.appName),
              ],
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              tooltip: Strings.search,
              onPressed: _viewModel.onSearch,
            ),
          ],
        ),
        drawer: const DrawerMenu(),
        body: Consumer<HomeViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.works.isEmpty && viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.works.isEmpty && viewModel.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(viewModel.error!),
                    ElevatedButton(
                      onPressed: () => viewModel.loadWorks(refresh: true),
                      child: const Text('重试'),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => viewModel.loadWorks(refresh: true),
              child: CustomScrollView(
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
              ),
            );
          },
        ),
      ),
    );
  }
}
