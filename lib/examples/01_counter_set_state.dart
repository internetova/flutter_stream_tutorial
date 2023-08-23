import 'package:flutter/material.dart';

/// Классический счетчик
class Example01 extends StatefulWidget {
  const Example01({super.key, required this.title});

  final String title;

  @override
  State<Example01> createState() => _Example01State();
}

class _Example01State extends State<Example01> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _decrementCounter() {
    setState(() {
      if (_counter != 0) _counter--;
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🟡--------build Example01');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
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
