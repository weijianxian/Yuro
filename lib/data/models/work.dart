class Work {
  final String id;          // RJ号
  final String title;       // 标题
  final String circle;      // 社团/创作者
  final List<String> tags;  // 标签列表
  final String releaseDate; // 发布日期
  final String duration;    // 时长
  final String coverUrl;    // 封面URL

  const Work({
    required this.id,
    required this.title,
    required this.circle,
    required this.tags,
    required this.releaseDate,
    required this.duration,
    required this.coverUrl,
  });

  // 用于测试的模拟数据
  static List<Work> get mockData => List.generate(
    10,
    (index) => Work(
      id: 'RJ01281359',
      title: 'わたしとめおとになってください。',
      circle: '縁側こより',
      tags: ['癒し/背德', '純爱', '治愈', '少女', 'ASMR', '舔耳', '低语'],
      releaseDate: '2024-11-01',
      duration: '3时26分',
      coverUrl: 'https://api.asmr.one/api/cover/1274961.jpg?type=main',
    ),
  );
} 