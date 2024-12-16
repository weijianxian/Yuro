import 'package:flutter/material.dart';

class PaginationControls extends StatelessWidget {
  final int currentPage;
  final int? totalPages;
  final bool isLoading;
  final Function(int) onPageChanged;

  const PaginationControls({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.isLoading,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(width: 32),
          IconButton(
            onPressed: currentPage > 1 && !isLoading
                ? () => onPageChanged(currentPage - 1)
                : null,
            icon: const Icon(Icons.chevron_left),
          ),
          const SizedBox(width: 16),
          Text('$currentPage/${totalPages ?? "?"}'),
          const SizedBox(width: 16),
          IconButton(
            onPressed:
                totalPages != null && currentPage < totalPages! && !isLoading
                    ? () => onPageChanged(currentPage + 1)
                    : null,
            icon: const Icon(Icons.chevron_right),
          ),
          SizedBox(
            width: 32,
            child: isLoading
                ? const Padding(
                    padding: EdgeInsets.only(left: 16),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                  )
                : null,
          ),
        ],
      ),
    );
  }
}
