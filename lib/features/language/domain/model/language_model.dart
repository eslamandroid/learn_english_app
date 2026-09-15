import 'package:json_annotation/json_annotation.dart';

part 'language_model.g.dart';

@JsonSerializable()
class LanguageModel {
  final String code;
  final String name;
  final String nativeName;
  final bool isRtl;

  LanguageModel({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.isRtl,
  });

  factory LanguageModel.fromJson(Map<String, dynamic> json) =>
      _$LanguageModelFromJson(json);

  Map<String, dynamic> toJson() => _$LanguageModelToJson(this);

  LanguageModel copyWith({
    String? code,
    String? name,
    String? nativeName,
    bool? isRtl,
  }) =>
      LanguageModel(
        code: code ?? this.code,
        name: name ?? this.name,
        nativeName: nativeName ?? this.nativeName,
        isRtl: isRtl ?? this.isRtl,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LanguageModel && other.code == code;
  }

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => 'LanguageModel(code: $code, name: $name)';

  // Predefined supported languages
  static final List<LanguageModel> supportedLanguages = [
    LanguageModel(
      code: 'en',
      name: 'English',
      nativeName: 'English',
      isRtl: false,
    ),
    LanguageModel(
      code: 'ar',
      name: 'Arabic',
      nativeName: 'العربية',
      isRtl: true,
    ),
  ];

  static LanguageModel? getByCode(String code) {
    try {
      return supportedLanguages.firstWhere((lang) => lang.code == code);
    } catch (_) {
      return null;
    }
  }
}

