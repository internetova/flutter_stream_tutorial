import 'dart:async';

import 'package:flutter/material.dart';

/// Пример счётчика со стримом
class Example02 extends StatefulWidget {
  const Example02({super.key, required this.title});

  final String title;

  @override
  State<Example02> createState() => _Example02State();
}

class _Example02State extends State<Example02> {
  /// Контроллер для состояния счётчика
  /// С помощью контроллера мы можем:
  /// 1. Добавлять данные в поток
  /// 2. Добавить ошибку
  /// 3. Закрыть поток для освобождения ресурсов
  final _counterController = StreamController<int>();

  /// Поток с текущим значением счётчика
  Stream<int> get counterStream => _counterController.stream;

  int _counter = 0;

  void _incrementCounter() {
    _counter++;
    _counterController.add(_counter);
    // _counterController.sink.add(_counter);
    /// Оба этих подхода выполняют одну и ту же задачу. Существует разница в терминологии
    /// и структуре класса StreamController, но с точки зрения функциональности они идентичны.
    /// Термин "sink" используется для обозначения интерфейса, через который вы можете
    /// взаимодействовать с потоком для добавления данных. Однако, чтобы облегчить
    /// понимание и избежать путаницы, в большинстве случаев, разработчики предпочитают
    /// использовать _controller.add(data) вместо _controller.sink.add(data).
  }

  void _decrementCounter() {
    if (_counter != 0) _counter--;
    _counterController.add(_counter);
  }

  void _addError() {
    _counterController.addError('Ошибка!');
  }

  @override
  void initState() {
    super.initState();
    _counterController.add(_counter);
  }

  @override
  void dispose() {
    /// Закрыть поток и освободить ресурсы чтобы избежать утечки памяти.
    _counterController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🟡--------build Example02');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            /*
            Преимущества использования StreamBuilder:
            1. Автоматическая перерисовка: StreamBuilder обеспечивает автоматическую перерисовку
            пользовательского интерфейса (UI) каждый раз, когда поступают новые данные в поток.
            2. Удобство: Он упрощает работу с асинхронными данными и позволяет создавать
            реактивный пользовательский интерфейс без необходимости вручную управлять обновлением.
            3. Читаемость кода: StreamBuilder улучшает читаемость кода, так как позволяет
            легко понять, какие части интерфейса зависят от потока данных.
             */
            StreamBuilder<int>(
                /// Поток с данными
                stream: counterStream,
                /// Для обработки различные состояния данных из потока
                builder: (context, snapshot) {
                  /*
                  AsyncSnapshot - это объект, который предоставляет информацию о текущем состоянии
                  данных, переданных через поток, в определенный момент времени.

                  Он содержит следующие свойства:
                  1. connectionState: Это свойство показывает текущее состояние соединения потока.
                  Оно имеет значения, такие как:
                     ConnectionState.none: Состояние соединения не определено (например,
                         поток еще не начал генерировать данные).
                     ConnectionState.waiting: Поток ожидает получения данных.
                     ConnectionState.active: Поток активен и передает данные.
                     ConnectionState.done: Поток завершил свою работу (например, поток закрыт).
                  2. data: Это свойство содержит данные из потока. Оно будет содержать значение,
                     если поток генерирует данные успешно, или null, если данных еще нет или
                     поток завершился.
                  3. error: Это свойство содержит информацию об ошибке, если она произошла
                  во время работы с потоком. В противном случае, оно будет null.
                   */
                  if (snapshot.hasData) {
                    return Text(
                      '${snapshot.data}',
                      style: Theme.of(context).textTheme.headlineMedium,
                    );
                  } else if (snapshot.hasError) {
                    return Text(
                      '${snapshot.error}',
                      style: Theme.of(context).textTheme.headlineMedium,
                    );
                  }

                  return const SizedBox.shrink();
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
            const SizedBox(height: 20),
            IconButton.filledTonal(
              onPressed: _addError,
              icon: const Icon(Icons.error, color: Colors.red),
              alignment: Alignment.center,
              iconSize: 40,
            ),
          ],
        ),
      ),
    );
  }
}
