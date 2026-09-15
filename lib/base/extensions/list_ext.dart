import 'package:collection/collection.dart';

extension ListExtension on List {
  T? getDataOrNull<T>(index) => (length - 1 >= index && index > 0) ? this[index] : null;

  (T, int)? getRecordDataOrNull<T>(index) => (length - 1 >= index && index > 0) ? (this[index], index) : null;

  bool haveSame(List<String> list) {
    final current = this as List<String>;
    final yesHave = <bool>{};
    for (var element in current) {
      yesHave.add(list.contains(element));
    }
    return yesHave.firstWhereOrNull((element) => element == false) == null;
  }

  List<T> addWhere<T>(T t, bool Function(T element) where, [bool toggle = false]) {
    final items = (this as List<T>).toList();
    final hasSameData = items.firstWhereOrNull(where) != null;
    if (!hasSameData) {
      items.add(t);
    } else {
      if (toggle) {
        items.remove(t);
      }
    }
    return items;
  }

  List<T> deleteWhere<T>(bool Function(T element) where) {
    final items = (this as List<T>).toList();
    items.removeWhere(where);
    return items;
  }

  List<T> updateWhere<T>(T t, bool Function(T element) where) {
    final items = (this as List<T>).toList();
    final index = items.indexWhere(where);
    if (index > -1) {
      items[index] = t;
      return items;
    } else {
      for (int index = 0; index <= items.length - 1; index++) {
        final item = items[index];
        if (where(item)) {
          items[index] = t;
          return items;
        }
      }
    }
    return items;
  }

  int sumList<T>(int Function(T element) mapWhere) {
    int sum = 0;
    for (var element in map((e) => mapWhere(e)).toList()) {
      sum = sum + element;
    }
    return sum;
  }

  List<R> filterListByList<T, R>(List<T> t, bool Function(T element, T element2) where, [R Function(T element)? onMap]) {
    final List<R> filterList = [];
    forEach((element) {
      final exists = t.firstWhereOrNull(((element2) => where(element2, element))) != null;
      if (!exists) {
        filterList.add(onMap != null ? onMap(element) : element);
      }
    });
    return filterList;
  }

  Map<String, R> toHashMap<T,R>(Map<String, R> Function(T element) onMap) {
    final map = <String, R>{};
    forEach((element) {
      map.addAll(onMap(element));
    });
    return map;
  }
}

extension MapExtension on Map {
  T? getOrNull<T>(key) => isNotEmpty && containsKey(key) ? this[key] : null;

  List<(dynamic, dynamic)> toRecordList() {
    final list = <(dynamic, dynamic)>[];
    forEach((key, value) {
      list.add((key, value));
    });
    return list;
  }
}

extension ListStringExtension on List<String> {
  String toText() {
    StringBuffer br = StringBuffer();
    forEach((element) {
      br.write("$element -");
    });
    return br.toString();
  }
}
