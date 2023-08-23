import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

/// Пример где используется Rx.combineLatest2
/// Объединяем состояние загрузки и данные
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();

  /// Стрим контроллер для поискового запроса
  /// Будем отправлять сюда данные из текстового поля
  /// seeded - задаём стартовое значение для стрима
  final _searchSubject = BehaviorSubject<String>.seeded('');

  /// Стрим контроллер для состояния загрузки
  final _loadingSubject = BehaviorSubject<bool>.seeded(false);

  /// Стрим контроллер для результатов поиска
  /// Сюда будем отправлять результат, который нам будет возвращать метод поиска
  final _resultsSubject = BehaviorSubject<List<String>>.seeded(['']);

  /// Объединяет заданные потоки в единую последовательность потоков, используя функцию
  /// объединения всякий раз, когда любая из последовательностей потоков создает элемент
  /// Тут объединим два стрима - состояние загрузки и результат поиска
  /// Стрим будет отдавать новое значение всякий раз как произойдет изменение в любом из стримов
  /// * Как работает Rx.combineLatest2 можно посмотреть в проекте dart или на видео уроке
  late final Stream<Map<String, Object>> _combinedSubject;

  /// Нам нужна подписка на стрим с данными для поискового запроса
  /// Это надо для того, чтобы преобразовать данные из этого стрима.
  /// Что будем делать смотрите в строке инициализации подписки
  late StreamSubscription _debounceSubscription;

  @override
  void initState() {
    super.initState();
    /// Добавили слушатель на текст контроллер чтобы отправлять данные в стрим с поисковым запросом
    _searchController.addListener(() {
      /// Когда текстовое поле изменяется отправляем новые данные в стрим
      _searchSubject.add(_searchController.value.text);
    });

    /*
    Rx.combineLatest2 - это функция из библиотеки rxdart в языке Dart, предназначенная для
    комбинирования значений из двух потоков и создания нового потока, который будет испускать
    обновления, когда оба входных потока испускают новые значения.
     */

    /// Объединим стрим с результатами поиска и стрим с состоянием загрузки данных.
    /// На выходе мы будем получать карту с обновлёнными данными.
    _combinedSubject =
        Rx.combineLatest2(_resultsSubject, _loadingSubject, (List<String> data, bool isLoading) {
      return {'data': data, 'isLoading': isLoading};
    });

    /// Инициируем подписку на стрим с данными для поискового запроса
    /// Мы подпишемся на стрим для формирования поискового запроса, трансформируем данные и
    /// только потом их будем обрабатывать - выполнять поиск.
    ///
    /// Для этого используем расширение debounceTime из rxdart
    ///
    /// Это делается для того, чтобы не отправлять запросы при каждом
    /// изменении значения в поисковой строке, т.к. в этом нет смысла и это лишняя нагрузка
    ///
    /* Пример как работает debounceTime:
        Stream.fromIterable(<code>1, 2, 3, 4</code>)
              .debounceTime(Duration(seconds: 1))
              .listen(print); // prints 4
     */
    _debounceSubscription = _searchSubject
        .debounceTime(const Duration(milliseconds: 500))
    /// Обрабатываем преобразованный результат - выполняем поиск
        .listen((query) => _performSearch(query));
  }

  @override
  void dispose() {
    /// Для освобождения ресурсов надо отписаться от подписок и закрыть все контроллеры
    _searchController.dispose();
    _debounceSubscription.cancel();
    _resultsSubject.close();
    super.dispose();
  }

  /// Выполнить поиск
  Future<void> _performSearch(String query) async {
    /// Если строка пустая ничего не делаем
    if (query.isEmpty) return;

    try {
      /// Отправляем состояние загрузки
      _loadingSubject.add(true);
      /// Выполняем поиск
      final results = _getFakeSearchResults(query);
      await Future.delayed(const Duration(seconds: 2));
      /// Раскомментируйте строку если хотите увидеть ошибку
      // throw Exception('Ошибка во время поиска');
      /// Когда получили результат добавляем его в стрим с результатами
      _resultsSubject.add(results);
      /// А также в стрим состоянием загрузки сообщаем что данные уже получены
      _loadingSubject.add(false);
    } on Exception catch (e) {
      /// Если произошла ошибка то добавим в стрим с результатами ошибку
      _resultsSubject.addError(e.toString());
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
            child: StreamBuilder<Map<String, Object>>(
              /// Используем комбинированный стрим где будут результаты поиска
              /// и состояние загрузки данных
              stream: _combinedSubject,
              builder: (context, snapshot) {
                /// Если есть ошибка покажем пользователю
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                /// Если у нас есть данные в стриме
                } else if (snapshot.hasData) {
                  /// Для упрощения дальнейшего использования сделаем декомпозицию из карты
                  final isLoading = snapshot.data?['isLoading'];
                  final data = snapshot.data?['data'];

                  /// Если мы в состоянии загрузки - покажем лоадер
                  if (isLoading == true) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    /// Если нет, то покажем данные
                    if (data != null && data is List<String> && data.isNotEmpty) {
                      return ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          return ListTile(title: Text(data[index]));
                        },
                      );
                    } else {
                      return const Center(child: Text('Ничего не найдено'));
                    }
                  }
                }

                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }
}
