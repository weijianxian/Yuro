import 'package:flutter/material.dart';
import 'package:asmrapp/widgets/drawer_menu.dart';
import 'package:asmrapp/widgets/work_grid.dart';
import 'package:asmrapp/common/constants/strings.dart';
import 'package:asmrapp/presentation/viewmodels/home_viewmodel.dart';
import 'package:asmrapp/presentation/layouts/work_layout_strategy.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _viewModel = HomeViewModel();
  final _layoutStrategy = WorkLayoutStrategy();

  @override
  Widget build(BuildContext context) {
    final works = _viewModel.getWorks();

    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: Strings.search,
            onPressed: _viewModel.onSearch,
          ),
        ],
      ),
      drawer: const DrawerMenu(),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: _layoutStrategy.getPadding(context),
            sliver: WorkGrid(
              works: works,
              layoutStrategy: _layoutStrategy,
              onWorkTap: (work) {
                _viewModel.onWorkTap(work);
                Navigator.pushNamed(context, '/detail');
              },
            ),
          ),
        ],
      ),
    );
  }
} 