import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

/// Пример где используется для отображения состояния загрузки ValueListenableBuilder,
/// а для результатов поиска StreamBuilder
class SearchScreen2 extends StatefulWidget {
  const SearchScreen2({super.key});

  @override
  State<SearchScreen2> createState() => _SearchScreen2State();
}

class _SearchScreen2State extends State<SearchScreen2> {
  final _searchController = TextEditingController();

  /// Стрим контроллер для поискового запроса
  /// С помощью seeded устанавливаем стартовое значение пустую строку
  final _searchSubject = BehaviorSubject<String>.seeded('');

  /// Состояние для состояния загрузки
  final _loadingState = ValueNotifier<bool>(false);

  /// Стрим контроллер для результатов поиска
  final _resultsSubject = BehaviorSubject<List<String>>.seeded(['']);

  late StreamSubscription _debounceSubscription;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      _searchSubject.add(_searchController.value.text);
    });

    _debounceSubscription = _searchSubject
        .debounceTime(const Duration(milliseconds: 500))
        .listen((query) => _performSearch(query));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceSubscription.cancel();
    _resultsSubject.close();
    _loadingState.dispose();
    super.dispose();
  }

  /// Выполнить поиск
  Future<void> _performSearch(String query) async {
    if (query.isEmpty) return;

    try {
      _loadingState.value = true;
      final results = _getFakeSearchResults(query);
      await Future.delayed(const Duration(seconds: 2));
      // throw Exception('Ошибка во время поиска');
      _resultsSubject.add(results);
    } on Exception catch (e) {
      _resultsSubject.addError(e.toString());
    } finally {
      _loadingState.value = false;
    }
  }

  /// Сгенерируем фейковый результат поиска
  List<String> _getFakeSearchResults(String query) {
    final random = Random();

    return random.nextInt(10) < 6 ? List.generate(10, (index) => '$query Result ${index + 1}') : [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Debounced Search Example')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Поиск',
                hintText: 'Введите текст...',
              ),
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<bool>(
                valueListenable: _loadingState,
                builder: (_, isLoading, __) {
                  return isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : StreamBuilder<List<String>>(
                          stream: _resultsSubject,
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Center(child: Text('Error: ${snapshot.error}'));
                            } else if (snapshot.hasData) {
                              final resultData = snapshot.data!;

                              if (resultData.isNotEmpty) {
                                return ListView.builder(
                                  itemCount: resultData.length,
                                  itemBuilder: (context, index) {
                                    return ListTile(title: Text(resultData[index]));
                                  },
                                );
                              } else {
                                return const Center(child: Text('Ничего не найдено'));
                              }
                            }

                            return const Center(child: CircularProgressIndicator());
                          },
                        );
                }),
          ),
        ],
      ),
    );
  }
}
