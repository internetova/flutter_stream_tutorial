import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';

/// Пример использования BehaviorSubject
class Example06 extends StatefulWidget {
  const Example06({super.key, required this.title});

  final String title;

  @override
  State<Example06> createState() => _Example06State();
}

class _Example06State extends State<Example06> {
  final loadingController = BehaviorSubject.seeded(true);
  Stream<bool> get loadingStream => loadingController.stream;

  void _onPressed() {
    debugPrint('🟡--------_onPressed');
    loadingController.add(true);
    _stopLoading();
  }

  Future<void> _stopLoading() async {
    Future.delayed(
      const Duration(seconds: 3),
      () => loadingController.add(false),
    );
  }

  @override
  void initState() {
    super.initState();
    _stopLoading();
  }

  @override
  void dispose() {
    loadingController.close();
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
            StreamBuilder<bool>(
                stream: loadingStream,
                builder: (_, snapshot) {
                  if (snapshot.data == true) {
                    return const SizedBox(
                      height: 40,
                      child: CircularProgressIndicator(),
                    );
                  }

                  return const SizedBox(
                    height: 40,
                    child: Text('Данные загружены'),
                  );
                }),
            const SizedBox(height: 60),
            StreamBuilder<bool>(
                stream: loadingStream,
                builder: (_, snapshot) {
                  return AbsorbPointer(
                    absorbing: snapshot.data == true,
                    child: FilledButton(
                      onPressed: _onPressed,
                      child: const Text('Обновить'),
                    ),
                  );
                }),
          ],
        ),
      ),
    );
  }
}
