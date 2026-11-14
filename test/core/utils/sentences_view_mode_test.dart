import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_app/core/utils/sentences_view_mode_preference.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final pref = SentencesViewModePreference.instance;

  setUp(() {
    // Reset to default before each test.
    pref.mode.value = SentencesViewMode.list;
  });

  test('bind() with no stored value → mode is list (default)', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    pref.bind(prefs);
    expect(pref.mode.value, SentencesViewMode.list);
  });

  test('bind() with stored "pager" → mode is pager', () async {
    SharedPreferences.setMockInitialValues({
      'sentences_view_mode': 'pager',
    });
    final prefs = await SharedPreferences.getInstance();
    pref.bind(prefs);
    expect(pref.mode.value, SentencesViewMode.pager);
  });

  test('set(pager) then bind() on fresh prefs instance → pager (persisted)', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    pref.bind(prefs);
    pref.set(SentencesViewMode.pager);
    expect(pref.mode.value, SentencesViewMode.pager);

    // Simulate app restart: new prefs, new bind.
    pref.mode.value = SentencesViewMode.list; // reset in-memory
    pref.bind(prefs); // re-bind same prefs (which now has the saved value)
    expect(pref.mode.value, SentencesViewMode.pager);
  });

  test('set(list) after set(pager) → mode switches back to list', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    pref.bind(prefs);
    pref.set(SentencesViewMode.pager);
    pref.set(SentencesViewMode.list);
    expect(pref.mode.value, SentencesViewMode.list);
  });
}
