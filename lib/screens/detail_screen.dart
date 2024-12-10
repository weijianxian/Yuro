import 'package:flutter/material.dart';
import 'package:asmrapp/data/models/works/work.dart';
import 'package:asmrapp/widgets/detail/work_cover.dart';
import 'package:asmrapp/widgets/detail/work_info.dart';
import 'package:asmrapp/widgets/detail/work_actions.dart';

class DetailScreen extends StatelessWidget {
  final Work work;

  const DetailScreen({
    super.key, 
    required this.work,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RJ${work.id ?? 0}'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WorkCover(imageUrl: work.mainCoverUrl ?? ''),
            WorkInfo(work: work),
          ],
        ),
      ),
      bottomNavigationBar: WorkActions(
        onDownload: () {
          // TODO: 实现下载功能
        },
        onPlay: () {
          // TODO: 实现播放功能
        },
      ),
    );
  }
}
