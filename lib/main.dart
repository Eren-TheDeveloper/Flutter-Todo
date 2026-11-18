import 'package:flutter/material.dart';
import 'package:to_do_app/homepage.dart';
import 'package:to_do_app/task_store.dart';

void main() => runApp(const MyWidget());

class MyWidget extends StatelessWidget {
  const MyWidget({super.key, this.store});
  final TaskStore? store;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Görevlerim',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF7F5FC),
    ),
    home: HomePage(store: store),
  );
}
