import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_do_app/task.dart';
import 'package:to_do_app/task_store.dart';

class MemoryPreferences implements SharedPreferencesAsync {
  final data = <String, String>{};

  @override
  Future<String?> getString(String key) async => data[key];

  @override
  Future<void> setString(String key, String value) async {
    data[key] = value;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test(
    'New store starts empty and a new instance restores saved tasks',
    () async {
      final preferences = MemoryPreferences();
      final first = PreferencesTaskStore(preferences: preferences);
      expect(await first.load(), isEmpty);
      await first.save([
        const Task(id: 'a', title: 'Türkçe görev', completed: true),
      ]);
      final reopened = PreferencesTaskStore(preferences: preferences);
      final task = (await reopened.load()).single;
      expect(task.id, 'a');
      expect(task.title, 'Türkçe görev');
      expect(task.completed, isTrue);
      await reopened.save([]);
      expect(await first.load(), isEmpty);
    },
  );

  test('Invalid data is rejected without overwriting the original', () async {
    final preferences = MemoryPreferences();
    final store = PreferencesTaskStore(preferences: preferences);
    for (final raw in [
      'broken json',
      '{}',
      '[{"id":"a","title":" ","completed":false}]',
      '[{"id":"a","title":"Görev","completed":"false"}]',
      '[{"id":"a","title":"Bir","completed":false},{"id":"a","title":"İki","completed":true}]',
    ]) {
      preferences.data[PreferencesTaskStore.storageKey] = raw;
      await expectLater(store.load(), throwsFormatException);
      expect(preferences.data[PreferencesTaskStore.storageKey], raw);
    }
  });
}
