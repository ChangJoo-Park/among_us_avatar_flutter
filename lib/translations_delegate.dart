import 'dart:async';

import 'package:among_us_profile_maker/translations.dart';
import 'package:flutter/material.dart';

class TranslationsDelegate extends LocalizationsDelegate<Translations> {
  const TranslationsDelegate();

  @override
  bool isSupported(Locale locale) => [
    'de',
    'en',
    'es',
    'fr',
    'id',
    'it',
    'pt',
    'ru',
    'vi',
  ].contains(locale.languageCode);

  @override
  Future<Translations> load(Locale locale) async {
    Translations localizations = new Translations(locale);
    await localizations.load();

    print("Load ${locale.languageCode}");

    return localizations;
  }

  @override
  bool shouldReload(TranslationsDelegate old) => false;
}
