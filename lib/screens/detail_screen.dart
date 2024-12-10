import 'package:flutter/material.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('音乐详情'),
      ),
      body: const Center(
        child: Text('音乐详细信息将在这里显示'),
      ),
    );
  }
} 