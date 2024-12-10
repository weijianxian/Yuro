class Work {
  final int id;
  final String title;
  final String circleName;
  final bool nsfw;
  final String release;
  final int dlCount;
  final int price;
  final int reviewCount;
  final int rateCount;
  final double rateAverage;
  final bool hasSubtitle;
  final String createDate;
  final List<Tag> tags;
  final String mainCoverUrl;
  final String thumbnailCoverUrl;
  final String samCoverUrl;

  const Work({
    required this.id,
    required this.title,
    required this.circleName,
    required this.nsfw,
    required this.release,
    required this.dlCount,
    required this.price,
    required this.reviewCount,
    required this.rateCount,
    required this.rateAverage,
    required this.hasSubtitle,
    required this.createDate,
    required this.tags,
    required this.mainCoverUrl,
    required this.thumbnailCoverUrl,
    required this.samCoverUrl,
  });

  factory Work.fromJson(Map<String, dynamic> json) {
    return Work(
      id: json['id'] as int,
      title: json['title'] as String,
      circleName: json['name'] as String,
      nsfw: json['nsfw'] as bool,
      release: json['release'] as String,
      dlCount: json['dl_count'] as int,
      price: json['price'] as int,
      reviewCount: json['review_count'] as int,
      rateCount: json['rate_count'] as int,
      rateAverage: (json['rate_average_2dp'] as num).toDouble(),
      hasSubtitle: json['has_subtitle'] as bool,
      createDate: json['create_date'] as String,
      tags: (json['tags'] as List<dynamic>)
          .map((tag) => Tag.fromJson(tag as Map<String, dynamic>))
          .toList(),
      mainCoverUrl: json['mainCoverUrl'] as String,
      thumbnailCoverUrl: json['thumbnailCoverUrl'] as String,
      samCoverUrl: json['samCoverUrl'] as String,
    );
  }
}

class Tag {
  final int id;
  final String name;
  final Map<String, I18n> i18n;

  const Tag({
    required this.id,
    required this.name,
    required this.i18n,
  });

  factory Tag.fromJson(Map<String, dynamic> json) {
    final i18nMap = <String, I18n>{};
    final i18nJson = json['i18n'] as Map<String, dynamic>;
    
    i18nJson.forEach((key, value) {
      if (value != null) {
        i18nMap[key] = I18n.fromJson(value as Map<String, dynamic>);
      }
    });

    return Tag(
      id: json['id'] as int,
      name: json['name'] as String,
      i18n: i18nMap,
    );
  }
}

class I18n {
  final String? name;
  final List<String>? history;

  const I18n({
    this.name,
    this.history,
  });

  factory I18n.fromJson(Map<String, dynamic> json) {
    return I18n(
      name: json['name'] as String?,
      history: json['history'] == null
          ? null
          : (json['history'] as List<dynamic>).cast<String>(),
    );
  }
} 