import 'package:freezed_annotation/freezed_annotation.dart';

import 'i18n.dart';

part 'tag.freezed.dart';
part 'tag.g.dart';

@freezed
class Tag with _$Tag {
  factory Tag({
    int? id,
    I18n? i18n,
    String? name,
  }) = _Tag;

  factory Tag.fromJson(Map<String, dynamic> json) => _$TagFromJson(json);
}
