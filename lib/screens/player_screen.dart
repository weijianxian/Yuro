import 'package:flutter/material.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('正在播放'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('播放器控件将在这里显示'),
            // TODO: 添加播放控制器、进度条等
          ],
        ),
      ),
    );
  }
}
