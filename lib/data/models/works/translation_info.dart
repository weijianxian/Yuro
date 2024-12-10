import 'package:freezed_annotation/freezed_annotation.dart';

part 'translation_info.freezed.dart';
part 'translation_info.g.dart';

@freezed
class TranslationInfo with _$TranslationInfo {
  factory TranslationInfo({
    String? lang,
    @JsonKey(name: 'is_child') bool? isChild,
    @JsonKey(name: 'is_parent') bool? isParent,
    @JsonKey(name: 'is_original') bool? isOriginal,
    @JsonKey(name: 'is_volunteer') bool? isVolunteer,
    @JsonKey(name: 'child_worknos') List<dynamic>? childWorknos,
    @JsonKey(name: 'parent_workno') String? parentWorkno,
    @JsonKey(name: 'original_workno') String? originalWorkno,
    @JsonKey(name: 'is_translation_agree') bool? isTranslationAgree,
    @JsonKey(name: 'translation_bonus_langs')
    List<dynamic>? translationBonusLangs,
    @JsonKey(name: 'is_translation_bonus_child') bool? isTranslationBonusChild,
    @JsonKey(name: 'production_trade_price_rate') int? productionTradePriceRate,
  }) = _TranslationInfo;

  factory TranslationInfo.fromJson(Map<String, dynamic> json) =>
      _$TranslationInfoFromJson(json);
}
