import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:to_do_app/main.dart';
import 'package:to_do_app/task.dart';
import 'package:to_do_app/task_store.dart';

class MemoryTaskStore implements TaskStore {
  List<Task> tasks = [];
  bool failLoad = false;
  bool failSave = false;
  Completer<void>? pendingSave;

  @override
  Future<List<Task>> load() async {
    if (failLoad) throw StateError('load failed');
    return [...tasks];
  }

  @override
  Future<void> save(List<Task> tasks) async {
    await pendingSave?.future;
    if (failSave) throw StateError('save failed');
    this.tasks = [...tasks];
  }
}

void main() {
  late MemoryTaskStore store;
  setUp(() => store = MemoryTaskStore());

  Future<void> start(WidgetTester tester) async {
    await tester.pumpWidget(MyWidget(store: store));
    await tester.pumpAndSettle();
  }

  Future<void> add(WidgetTester tester, String title) async {
    await tester.tap(find.text('Görev ekle'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), title);
    await tester.tap(find.text('Kaydet'));
    await tester.pumpAndSettle();
  }

  testWidgets('Rejects blank input and trims a saved task', (tester) async {
    await start(tester);
    await add(tester, '   ');
    expect(find.text('Lütfen bir görev yazın.'), findsOneWidget);
    expect(store.tasks, isEmpty);
    await tester.enterText(find.byType(TextFormField), '  Kitap oku  ');
    await tester.tap(find.text('Kaydet'));
    await tester.pumpAndSettle();
    expect(store.tasks.single.title, 'Kitap oku');
    expect(find.text('Kitap oku'), findsOneWidget);
  });

  testWidgets('Cancellation clears the next task form', (tester) async {
    await start(tester);
    await tester.tap(find.text('Görev ekle'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Vazgeçilen görev');
    await tester.tap(find.text('Vazgeç'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Görev ekle'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextFormField>(find.byType(TextFormField)).controller!.text,
      isEmpty,
    );
    expect(store.tasks, isEmpty);
  });

  testWidgets('Completion and filters use the correct task', (tester) async {
    store.tasks = [
      const Task(id: 'a', title: 'Biten görev', completed: true),
      const Task(id: 'b', title: 'Bekleyen görev'),
    ];
    await start(tester);
    await tester.tap(find.text('Bekleyen'));
    await tester.pumpAndSettle();
    expect(find.text('Biten görev'), findsNothing);
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    expect(store.tasks.every((task) => task.completed), isTrue);
    expect(find.text('Bu filtrede görev yok.'), findsOneWidget);
    await tester.tap(find.text('Tamamlanan'));
    await tester.pumpAndSettle();
    expect(find.byType(Checkbox), findsNWidgets(2));
  });

  testWidgets('Editing preserves identity and completion', (tester) async {
    store.tasks = [const Task(id: 'a', title: 'Eski görev', completed: true)];
    await start(tester);
    await tester.tap(find.byTooltip('Görev seçenekleri'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Düzenle'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Yeni görev');
    await tester.tap(find.text('Kaydet'));
    await tester.pumpAndSettle();
    expect(store.tasks.single.id, 'a');
    expect(store.tasks.single.completed, isTrue);
    expect(find.text('Yeni görev'), findsOneWidget);
  });

  testWidgets('Delete and undo preserve order and completion', (tester) async {
    store.tasks = [
      const Task(id: 'a', title: 'İlk görev', completed: true),
      const Task(id: 'b', title: 'İkinci görev'),
    ];
    await start(tester);
    await tester.tap(find.byTooltip('Görev seçenekleri').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sil'));
    await tester.pumpAndSettle();
    expect(store.tasks.single.id, 'b');
    await tester.tap(find.text('Geri al'));
    await tester.pumpAndSettle();
    expect(store.tasks.map((task) => task.id), ['a', 'b']);
    expect(store.tasks.first.completed, isTrue);
  });

  testWidgets('Undo waits for another write and preserves its changes', (
    tester,
  ) async {
    store.tasks = [
      const Task(id: 'a', title: 'Silinecek'),
      const Task(id: 'b', title: 'Tamamlanacak'),
    ];
    await start(tester);
    await tester.tap(find.byTooltip('Görev seçenekleri').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sil'));
    await tester.pumpAndSettle();
    store.pendingSave = Completer<void>();
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    await tester.tap(find.text('Geri al'));
    await tester.pump();
    store.pendingSave!.complete();
    await tester.pumpAndSettle();
    expect(store.tasks.map((task) => task.id), ['a', 'b']);
    expect(store.tasks.last.completed, isTrue);
  });

  testWidgets('Failed save preserves the existing state', (tester) async {
    store.tasks = [const Task(id: 'a', title: 'Korunan görev')];
    store.failSave = true;
    await start(tester);
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    expect(store.tasks.single.completed, isFalse);
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isFalse);
    expect(find.text('Kaydedilemedi. Lütfen tekrar deneyin.'), findsOneWidget);
  });

  testWidgets('Load failure blocks writes and supports retry', (tester) async {
    store.failLoad = true;
    await start(tester);
    expect(find.text('Görevler yüklenemedi.'), findsOneWidget);
    expect(
      tester
          .widget<FloatingActionButton>(find.byType(FloatingActionButton))
          .onPressed,
      isNull,
    );
    store.failLoad = false;
    await tester.tap(find.text('Tekrar dene'));
    await tester.pumpAndSettle();
    expect(find.text('Henüz görev yok. İlk görevini ekle!'), findsOneWidget);
  });

  testWidgets('Pending writes disable competing mutations', (tester) async {
    store.tasks = [const Task(id: 'a', title: 'Görev')];
    await start(tester);
    store.pendingSave = Completer<void>();
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).onChanged, isNull);
    expect(
      tester
          .widget<FloatingActionButton>(find.byType(FloatingActionButton))
          .onPressed,
      isNull,
    );
    store.pendingSave!.complete();
    await tester.pumpAndSettle();
    expect(store.tasks.single.completed, isTrue);
  });

  testWidgets('Long titles fit on a narrow display with large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    store.tasks = [
      Task(id: 'a', title: List.filled(20, 'Uzun görev').join(' ')),
    ];
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.5)),
          child: child!,
        ),
        home: MyWidget(store: store),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Görev ekle'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
