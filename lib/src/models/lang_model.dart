import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' show BuildContext;
import 'package:quiver/strings.dart';

/// We use this Lang image model to match our APIs.
/// Specially Laravel APIs using Spatie's Translatable.
/// https://spatie.be/docs/laravel-translatable.
///
/// as api response will be either
///
/// ```json
/// name: {
///       en: "Sham El-zein",
///       ar: "شام الزين"
///     },
/// ```

class LangModel {
  late Map<String, String?> languages;
  String defaultLanguage = 'en';
  static int LANGUAGE_KEY_MAX_LENGTH = 3;
  static List<String> LANGUAGE_FALLBACK_KEYS = ['ar', 'en'];

  factory LangModel.fromJson(dynamic json) {
    if (json is String) {
      return LangModel.fromMap({
        'en': json,
        'ar': json,
      });
    } else
      return LangModel.fromMap(json);
  }

  Map<String, dynamic> toJson() => this.languages;

  LangModel.fromMap(dynamic m, {this.defaultLanguage = 'en'}) {
    if (m is String) {
      try {
        final decoded = jsonDecode(m);
        if (decoded is Map) m = decoded;
      } catch (e) {
        // not json object.
      }
    }

    if (m is! Map) {
      Map<String, String?> l = <String, String?>{};
      for (var element in LANGUAGE_FALLBACK_KEYS) {
        l[element] = m?.toString();
      }
      m = l;
    }

    languages = parseJsonMap(m);
  }

  Map<String, String?> parseJsonMap(Map<dynamic, dynamic> m) {
    Map<String, String?> l = <String, String?>{};

    for (var key in m.keys) {
      final value = m[key];

      if (value == null) {
        // if null value just continue.
        continue;
      }

      if (key is! String || key.length > LANGUAGE_KEY_MAX_LENGTH) {
        // if key is not string, this is not a language
        // if key.length is more than max length, it's not a language
        continue;
      }

      if (value is Map) {
        // this might be happened because of bug in casting on server.
        // so this is just work around to stay safe.
        l.addAll(parseJsonMap(value));
        continue;
      }

      if (value is String && isBlank(value)) {
        // if value is string and value is empty then ignore.
        continue;
      }

      // finally add value.toString to the value.
      l[key] = value.toString();
    }

    return l;
  }

  String? getLang(String language) {
    if (languages.containsKey(language) && isNotBlank(languages[language])) {
      return languages[language];
    }

    return null;
  }

  String? setLang(String language, String? value) {
    if (isNotBlank(value)) {
      return languages.update(language, (_) => value, ifAbsent: () => value);
    }

    return languages.remove(language);
  }

  String? getDefaultLang() {
    if (languages.containsKey(defaultLanguage) &&
        isNotBlank(languages[defaultLanguage])) {
      return languages[defaultLanguage];
    }

    return null;
  }

  String? getFirstLang() {
    return languages.values.isNotEmpty ? languages.values.first : null;
  }

  String? get(BuildContext context) {
    return getLang(context.locale.languageCode) ??
        getDefaultLang() ??
        getFirstLang();
  }

  String? getWithReplace(BuildContext context, Map<String, String> replace) {
    String? output = get(context);

    replace.forEach((key, value) {
      output = output?.replaceAll(key, value);
    });

    return output;
  }
}
