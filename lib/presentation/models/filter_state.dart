class FilterState {
  final bool hasSubtitle;
  final String orderField;
  final bool isDescending;

  const FilterState({
    this.hasSubtitle = false,
    this.orderField = 'create_date',
    this.isDescending = true,
  });

  bool get showSortDirection => orderField != 'random';

  String get sortValue => orderField == 'random' ? 'desc' : (isDescending ? 'desc' : 'asc');

  FilterState copyWith({
    bool? hasSubtitle,
    String? orderField,
    bool? isDescending,
  }) {
    return FilterState(
      hasSubtitle: hasSubtitle ?? this.hasSubtitle,
      orderField: orderField ?? this.orderField,
      isDescending: isDescending ?? this.isDescending,
    );
  }

  // 用于持久化
  Map<String, dynamic> toJson() => {
    'hasSubtitle': hasSubtitle,
    'orderField': orderField,
    'isDescending': isDescending,
  };

  // 从持久化恢复
  factory FilterState.fromJson(Map<String, dynamic> json) => FilterState(
    hasSubtitle: json['hasSubtitle'] ?? false,
    orderField: json['orderField'] ?? 'create_date',
    isDescending: json['isDescending'] ?? true,
  );
} 