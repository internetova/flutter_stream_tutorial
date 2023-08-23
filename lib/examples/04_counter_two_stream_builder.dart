import 'dart:async';

import 'package:flutter/material.dart';

/// Пример счётчика со стримом и двумя стримбилдерами
class Example04 extends StatefulWidget {
  const Example04({super.key, required this.title});

  final String title;

  @override
  State<Example04> createState() => _Example04State();
}

class _Example04State extends State<Example04> {
  /// Получим ошибку:
  /// Bad state: Stream has already been listened to.
  /// Потому что у нас на один стрим два слушателя (стримбилдера)
  // final _counterController = StreamController<int>();

  /// Если есть несколько слушателей, то необходимо создать широковещательный стрим. Его могут
  /// слушать разные потребители.
  /// Но тут может возникнуть следующая проблема. Т.к. у обычного стрима - для одного слушателя данные
  /// дожидаются появления слушателя, то в широковещательных стримах данные пропадают если
  /// у стрима нет слушателя. Слушатель получает данные только после того как подпишется на стрим и
  /// ему доступны только те данные, которые он получит после подписки.
  ///
  /// Поэтому необходимо использовать initialData для стримбилдера.
  final _counterController = StreamController<int>.broadcast();

  Stream<int> get counterStream => _counterController.stream;

  int _counter = 0;

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
                  child: Column(
                    children: [
                      const Text('StreamBuilder 2:'),
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
