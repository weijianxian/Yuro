import 'package:asmrapp/core/platform/lyric_overlay_manager.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:asmrapp/presentation/viewmodels/player_viewmodel.dart';
import 'package:asmrapp/widgets/player/player_controls.dart';
import 'package:asmrapp/widgets/player/player_progress.dart';
import 'package:asmrapp/widgets/player/player_cover.dart';
import 'package:asmrapp/screens/detail_screen.dart';
import 'package:asmrapp/widgets/lyrics/components/player_lyric_view.dart';
import 'package:asmrapp/widgets/player/player_work_info.dart';
import 'package:asmrapp/core/platform/wakelock_controller.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> with TickerProviderStateMixin {
  bool _showLyrics = false;
  bool _canSwitchView = true;
  late final PlayerViewModel _viewModel;
  double _dragDistance = 0.0;
  static const double _dismissThreshold = 100.0;
  bool _isDragging = false;
  late AnimationController _dismissAnimationController;
  late Animation<double> _dismissAnimation;

  @override
  void initState() {
    super.initState();
    _viewModel = GetIt.I<PlayerViewModel>();
    
    _dismissAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _dismissAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _dismissAnimationController,
      curve: Curves.easeOut,
    ));
    
    _dismissAnimation.addListener(() {
      setState(() {});
    });
    
    _dismissAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _dismissAnimationController.dispose();
    super.dispose();
  }

  Widget _buildContent() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      switchInCurve: Curves.easeOutQuart,
      switchOutCurve: Curves.easeInQuart,
      transitionBuilder: (Widget child, Animation<double> animation) {
        final isLyrics = (child as dynamic).key == const ValueKey('lyrics');
        
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0, isLyrics ? 0.1 : -0.1),
              end: Offset.zero,
            ).animate(animation),
            child: ScaleTransition(
              scale: Tween<double>(
                begin: 0.95,
                end: 1.0,
              ).animate(animation),
              child: child,
            ),
          ),
        );
      },
      layoutBuilder: (currentChild, previousChildren) {
        return Stack(
          alignment: Alignment.center,
          children: <Widget>[
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
        );
      },
      child: _showLyrics
          ? LayoutBuilder(
              key: const ValueKey('lyrics'),
              builder: (context, constraints) {
                return PlayerLyricView(
                  onScrollStateChanged: (canSwitch) {
                    setState(() {
                      _canSwitchView = canSwitch;
                    });
                  },
                );
              },
            )
          : ListenableBuilder(
              listenable: _viewModel,
              builder: (context, _) {
                return Column(
                  key: const ValueKey('cover'),
                  children: [
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Hero(
                            tag: 'mini-player-cover',
                            child: PlayerCover(
                              coverUrl: _viewModel.currentTrackInfo?.coverUrl,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          PlayerWorkInfo(context: _viewModel.currentContext),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lyricManager = GetIt.I<LyricOverlayManager>();
    final wakeLockController = GetIt.I<WakeLockController>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.expand_more),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              final currentWork = _viewModel.currentContext?.work;
              if (currentWork != null) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => DetailScreen(
                      work: currentWork,
                      fromPlayer: true,
                    ),
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: Icon(
              lyricManager.isShowing ? Icons.lyrics : Icons.lyrics_outlined,
            ),
            onPressed: () => lyricManager.toggle(context),
          ),
          ListenableBuilder(
            listenable: wakeLockController,
            builder: (context, _) {
              return IconButton(
                icon: Icon(
                  wakeLockController.enabled 
                    ? Icons.lightbulb
                    : Icons.lightbulb_outline,
                ),
                tooltip: wakeLockController.enabled ? '关闭屏幕常亮' : '开启屏幕常亮',
                onPressed: () => wakeLockController.toggle(),
              );
            },
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: GestureDetector(
          onVerticalDragStart: (details) {
            _isDragging = true;
            _dragDistance = 0.0;
            _dismissAnimationController.value = 0.0;
          },
          onVerticalDragUpdate: (details) {
            _dragDistance += details.delta.dy;
            if (_dragDistance < 0) _dragDistance = 0;
            
            // 根据拖拽距离更新动画进度
            final progress = (_dragDistance / _dismissThreshold).clamp(0.0, 1.0);
            _dismissAnimationController.value = progress;
          },
          onVerticalDragEnd: (details) {
            _isDragging = false;
            if (_dragDistance > _dismissThreshold) {
              // 完成关闭动画
              _dismissAnimationController.forward();
            } else {
              // 回到原始位置
              _dismissAnimationController.reverse();
            }
          },
          onTap: () {
            if (!_isDragging && _canSwitchView) {
              setState(() {
                _showLyrics = !_showLyrics;
              });
            }
          },
          behavior: HitTestBehavior.opaque,
          child: Transform.translate(
            offset: Offset(0, _dismissAnimation.value * 100), // 跟随动画向上移动
            child: Opacity(
              opacity: 1.0 - _dismissAnimation.value * 0.5, // 逐渐透明
              child: Column(
                children: [
                  Expanded(
                    child: _buildContent(),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 32),
                    child: const Column(
                      children: [
                        PlayerProgress(),
                        SizedBox(height: 8),
                        SizedBox(height: 8),
                        PlayerControls(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
