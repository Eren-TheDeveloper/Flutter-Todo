import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_do_app/task.dart';

abstract class TaskStore {
  Future<List<Task>> load();
  Future<void> save(List<Task> tasks);
}

class PreferencesTaskStore implements TaskStore {
  PreferencesTaskStore({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const storageKey = 'tasks.v1';
  final SharedPreferencesAsync _preferences;

  @override
  Future<List<Task>> load() async {
    final raw = await _preferences.getString(storageKey);
    if (raw == null) return [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      throw const FormatException('Geçersiz görev listesi.');
    }
    final tasks = decoded.map(Task.fromJson).toList();
    if (tasks.map((task) => task.id).toSet().length != tasks.length) {
      throw const FormatException('Tekrarlanan görev kimliği.');
    }
    return tasks;
  }

  @override
  Future<void> save(List<Task> tasks) => _preferences.setString(
    storageKey,
    jsonEncode(tasks.map((task) => task.toJson()).toList()),
  );
}
