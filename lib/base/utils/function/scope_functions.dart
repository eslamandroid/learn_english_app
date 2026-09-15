T run<T>(T Function() block) {
  return block();
}

extension ScopeFunctionsForObject<T> on T {
  R let<R>(R Function(T it) block) => block(this);

  T also(void Function(T it) block) {
    block(this);
    return this;
  }

  void apply(Function(T that) action) {
    if (this != null) {
      action(this!);
    }
  }
}
