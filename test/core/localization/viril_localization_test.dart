import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viril/core/localization/viril_localization.dart';

void main() {
  group('Viril localization', () {
    test('every offered language has core settings and goals translations', () {
      for (final code in virilLanguageNames.values) {
        final strings = VirilStrings(Locale(code));
        expect(strings.t('settings'), isNot('settings'), reason: code);
        expect(strings.t('goals'), isNot('goals'), reason: code);
      }
    });

    test('unknown keys fall back to the Russian source text when available', () {
      expect(VirilStrings(const Locale('en')).t('notYetTranslated'), 'notYetTranslated');
      expect(VirilStrings(const Locale('en')).t('cancel'), 'Cancel');
    });
  });
}
