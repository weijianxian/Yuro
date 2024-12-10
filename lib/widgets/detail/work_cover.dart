import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class WorkCover extends StatelessWidget {
  final String imageUrl;
  final String rjNumber;

  const WorkCover({
    super.key,
    required this.imageUrl,
    required this.rjNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'work-cover-$rjNumber',
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => const Center(
            child: CircularProgressIndicator(),
          ),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
      ),
    );
  }
}
