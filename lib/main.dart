import 'package:flutter/material.dart';
import 'package:flutter_stream/examples/01_counter_set_state.dart';
import 'package:flutter_stream/examples/02_counter_stream_builder.dart';
import 'package:flutter_stream/examples/03_counter_stream_builder_void.dart';
import 'package:flutter_stream/examples/04_counter_two_stream_builder.dart';
import 'package:flutter_stream/examples/05_counter_behavior_subject.dart';
import 'package:flutter_stream/examples/06_button_behavior_subject.dart';
import 'package:flutter_stream/examples/07_2_search.dart';
import 'package:flutter_stream/examples/07_1_search.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Example01(title: 'Demo Counter'),
      // home: const Example02(title: 'Demo Counter Stream'),
      // home: const Example03(title: 'Demo Counter StreamBuilder void'),
      // home: const Example04(title: 'Demo Counter two StreamBuilder'),
      // home: const Example05(title: 'Demo Counter BehaviorSubject'),
      // home: const Example06(title: 'Demo Counter BehaviorSubject'),
      // home: const SearchScreen(),
      // home: const SearchScreen2(),
    );
  }
}


