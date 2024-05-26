import 'package:aq_tools/aq_tools.dart';
import 'package:json_annotation/json_annotation.dart';

class LangModelJsonConverter extends JsonConverter<LangModel, dynamic> {
  @override
  LangModel fromJson(json) {
    return LangModel.fromMap(json);
  }

  @override
  Map<String, String?> toJson(LangModel object) {
    return object.languages;
  }
}
