T? firstWhereSafe<T>(List<T> list, bool Function(T) test) {
  int index = list.indexWhere(test);
  if (index >= 0) {
    return list[index];
  }
  return null;
}

extension ListExtension<T> on List<T> {
  void addUnique(T object) {
    if (!contains(object)) {
      add(object);
    }
  }
}
