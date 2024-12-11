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

  void _showPageJumpDialog(BuildContext context, HomeViewModel viewModel) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('跳转到指定页面'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: '页码 (1-${viewModel.totalPages})',
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              final page = int.tryParse(controller.text);
              if (page != null) {
                viewModel.jumpToPage(page);
              }
              Navigator.pop(context);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
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
                const SizedBox(width: 12),
                if (viewModel.totalPages != null)
                  InkWell(
                    onTap: () => _showPageJumpDialog(context, viewModel),
                    child: Text(
                      '(${viewModel.currentPage}/${viewModel.totalPages})',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
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
                  if (viewModel.isLoading)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: CircularProgressIndicator()),
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
