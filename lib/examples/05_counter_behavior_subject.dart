import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';

/// Пример использования BehaviorSubject
/// BehaviorSubject - это еще один вид потока (stream) из библиотеки RxDart в языке Dart,
/// который предоставляет доступ к последнему событию потока и продолжает его предоставлять
/// каждому новому подписчику. Это полезно, когда вы хотите, чтобы новые подписчики получали
/// последнее актуальное состояние потока, а также будут уведомляться о всех последующих изменениях.
///
/// RxDart расширяет возможности потоков Dart и StreamControllers.
class Example05 extends StatefulWidget {
  const Example05({super.key, required this.title});

  final String title;

  @override
  State<Example05> createState() => _Example05State();
}

class _Example05State extends State<Example05> {
  /// Можно инициализировать стартовым значением
  final _counterController = BehaviorSubject<int>.seeded(0);
  // final _counterController = StreamController<int>.broadcast();


  Stream<int> get counterStream => _counterController.stream;

  int _counter = 0;

  final Future<String> delayedData = Future.delayed(
    const Duration(seconds: 5),
    () => 'Старт StreamBuilder 2',
  );

  void _incrementCounter() {
    _counter++;
    _counterController.add(_counter);
  }

  void _decrementCounter() {
    if (_counter != 0) _counter--;
    _counterController.add(_counter);
  }

  @override
  void dispose() {
    _counterController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text('StreamBuilder 1:'),
                      StreamBuilder<int>(
                          stream: counterStream,
                          initialData: _counter,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Text(
                                '${snapshot.data}',
                                style: Theme.of(context).textTheme.headlineMedium,
                              );
                            }

                            return const SizedBox.shrink();
                          }),
                    ],
                  ),
                ),
                const SizedBox(width: 40),
                Expanded(
                  child: FutureBuilder<String>(
                    future: delayedData,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Column(
                          children: [
                            const Text('StreamBuilder 2:'),
                            StreamBuilder<int>(
                                stream: counterStream,
                                /// Уберём initialData - здесь будет последнее значение из потока
                                initialData: _counter,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return Text(
                                      '${snapshot.data}',
                                      style: Theme.of(context).textTheme.headlineMedium,
                                    );
                                  }

                                  return const SizedBox.shrink();
                                }),
                          ],
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
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
