import 'dart:async';

import 'package:flutter/material.dart';

/// Пример счётчика со стримом void
/// Иногда нам необходимо обновить небольшую часть виджета, а не весь.
/// Для этого также можно использовать StreamBuilder
class Example03 extends StatefulWidget {
  const Example03({super.key, required this.title});

  final String title;

  @override
  State<Example03> createState() => _Example03State();
}

class _Example03State extends State<Example03> {
  final _counterController = StreamController<void>();

  Stream<void> get counterStream => _counterController.stream;

  int _counter = 0;

  void _incrementCounter() {
    _counter++;
    _counterController.add(null);
  }

  void _decrementCounter() {
    if (_counter != 0) _counter--;
    _counterController.add(null);
  }

  @override
  void dispose() {
    _counterController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🟡--------build Example03');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            StreamBuilder<void>(
                stream: counterStream,
                builder: (_, __) {
                  return Text(
                    '$_counter',
                    style: Theme.of(context).textTheme.headlineMedium,
                  );
                }),
            const SizedBox(height: 60),
            Row(
              children: [
                const SizedBox(width: 40),
                Expanded(
                  child: IconButton.filledTonal(
                    onPressed: _decrementCounter,
                    icon: const Icon(Icons.remove),
                    alignment: Alignment.center,
                    iconSize: 40,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: IconButton.filledTonal(
                    onPressed: _incrementCounter,
                    icon: const Icon(Icons.add),
                    alignment: Alignment.center,
                    iconSize: 40,
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
