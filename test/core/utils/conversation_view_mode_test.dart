import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_app/core/utils/conversation_view_mode_preference.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final pref = ConversationViewModePreference.instance;

  setUp(() {
    pref.mode.value = ConversationViewMode.chat;
  });

  test('bind() with no stored value → chat (default)', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    pref.bind(prefs);
    expect(pref.mode.value, ConversationViewMode.chat);
  });

  test('bind() with stored "pager" → pager', () async {
    SharedPreferences.setMockInitialValues({
      'conversation_view_mode': 'pager',
    });
    final prefs = await SharedPreferences.getInstance();
    pref.bind(prefs);
    expect(pref.mode.value, ConversationViewMode.pager);
  });

  test('set(pager) then rebind on same prefs → pager (persisted)', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    pref.bind(prefs);
    pref.set(ConversationViewMode.pager);
    expect(pref.mode.value, ConversationViewMode.pager);

    // Simulate app restart.
    pref.mode.value = ConversationViewMode.chat;
    pref.bind(prefs);
    expect(pref.mode.value, ConversationViewMode.pager);
  });

  test('set(chat) after set(pager) → mode switches back', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    pref.bind(prefs);
    pref.set(ConversationViewMode.pager);
    pref.set(ConversationViewMode.chat);
    expect(pref.mode.value, ConversationViewMode.chat);
  });
}
