import 'dart:async';

import 'package:flutter/material.dart';
import 'package:to_do_app/alertbox.dart';
import 'package:to_do_app/task.dart';
import 'package:to_do_app/task_store.dart';
import 'package:to_do_app/todolist.dart';

enum TaskFilter { all, pending, completed }

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.store});
  final TaskStore? store;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final TaskStore _store;
  List<Task> _tasks = [];
  TaskFilter _filter = TaskFilter.all;
  bool _loading = true;
  bool _saving = false;
  bool _loadFailed = false;
  int _nextId = 0;
  Completer<void>? _writeCompleted;

  @override
  void initState() {
    super.initState();
    _store = widget.store ?? PreferencesTaskStore();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadFailed = false;
    });
    try {
      final tasks = await _store.load();
      if (!mounted) return;
      setState(() {
        _tasks = tasks;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadFailed = true;
      });
    }
  }

  Future<bool> _save(List<Task> tasks) async {
    if (_saving || _loading || _loadFailed) return false;
    setState(() => _saving = true);
    _writeCompleted = Completer<void>();
    try {
      await _store.save(tasks);
      if (!mounted) return false;
      setState(() => _tasks = tasks);
      return true;
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kaydedilemedi. Lütfen tekrar deneyin.'),
          ),
        );
      }
      return false;
    } finally {
      _writeCompleted!.complete();
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _editTask([Task? task]) async {
    final title = await showDialog<String>(
      context: context,
      builder: (_) => DialogBox(initialTitle: task?.title),
    );
    if (title == null || !mounted) return;
    final tasks = [..._tasks];
    if (task == null) {
      tasks.add(
        Task(
          id: '${DateTime.now().microsecondsSinceEpoch}-${_nextId++}',
          title: title,
        ),
      );
    } else {
      final index = tasks.indexWhere((item) => item.id == task.id);
      if (index == -1) return;
      tasks[index] = tasks[index].copyWith(title: title);
    }
    await _save(tasks);
  }

  Future<void> _deleteTask(Task task) async {
    final index = _tasks.indexWhere((item) => item.id == task.id);
    final saved = await _save(
      _tasks.where((item) => item.id != task.id).toList(),
    );
    if (!saved || !mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('Görev silindi.'),
          action: SnackBarAction(
            label: 'Geri al',
            onPressed: () async {
              await _writeCompleted?.future;
              if (!mounted) return;
              if (_tasks.any((item) => item.id == task.id)) return;
              final tasks = [..._tasks];
              tasks.insert(index.clamp(0, tasks.length), task);
              await _save(tasks);
            },
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final completed = _tasks.where((task) => task.completed).length;
    final visible = _tasks
        .where(
          (task) => switch (_filter) {
            TaskFilter.all => true,
            TaskFilter.pending => !task.completed,
            TaskFilter.completed => task.completed,
          },
        )
        .toList();
    final enabled = !_loading && !_saving && !_loadFailed;

    return Scaffold(
      appBar: AppBar(title: const Text('Görevlerim'), centerTitle: true),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: enabled ? () => _editTask() : null,
        icon: const Icon(Icons.add),
        label: const Text('Görev ekle'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _loadFailed
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Görevler yüklenemedi.'),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: _load,
                          child: const Text('Tekrar dene'),
                        ),
                      ],
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                        child: Text(
                          '${_tasks.length} görev • $completed tamamlandı • ${_tasks.length - completed} bekliyor',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final filter in TaskFilter.values)
                              ChoiceChip(
                                label: Text(switch (filter) {
                                  TaskFilter.all => 'Tümü',
                                  TaskFilter.pending => 'Bekleyen',
                                  TaskFilter.completed => 'Tamamlanan',
                                }),
                                selected: _filter == filter,
                                onSelected: (_) =>
                                    setState(() => _filter = filter),
                              ),
                          ],
                        ),
                      ),
                      if (_saving) const LinearProgressIndicator(),
                      Expanded(
                        child: visible.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Text(
                                    _tasks.isEmpty
                                        ? 'Henüz görev yok. İlk görevini ekle!'
                                        : 'Bu filtrede görev yok.',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  8,
                                  16,
                                  100,
                                ),
                                itemCount: visible.length,
                                itemBuilder: (_, index) {
                                  final task = visible[index];
                                  return ToDoList(
                                    key: ValueKey(task.id),
                                    taskName: task.title,
                                    taskCompleted: task.completed,
                                    onChanged: enabled
                                        ? (value) => _save([
                                            for (final item in _tasks)
                                              if (item.id == task.id)
                                                item.copyWith(
                                                  completed: value ?? false,
                                                )
                                              else
                                                item,
                                          ])
                                        : null,
                                    onEdit: enabled
                                        ? () => _editTask(task)
                                        : null,
                                    onDelete: enabled
                                        ? () => _deleteTask(task)
                                        : null,
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
