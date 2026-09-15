import 'dart:ui';

abstract class CancellationToken {
  bool get isCancelled;
  /// Register a callback that fires once when cancelled.
  /// Returns a disposer to remove the listener.
  VoidCallback onCancel(void Function() listener);
}

abstract class CancellationTokenSource {
  CancellationToken get token;
  void cancel([String? reason]);
}

class SimpleCancellationTokenSource implements CancellationTokenSource {
  bool _isCancelled = false;
  final List<void Function()> _listeners = [];

  @override
  CancellationToken get token => _Token(
    isCancelledFn: () => _isCancelled,
    addListener: (fn) {
      if (_isCancelled) {
        // fire immediately if already cancelled
        fn();
        return () {};
      }
      _listeners.add(fn);
      return () {
        _listeners.remove(fn);
      };
    },
  );

  @override
  void cancel([String? reason]) {
    if (_isCancelled) return;
    _isCancelled = true;
    // fire once
    for (final l in List.of(_listeners)) {
      l();
    }
    _listeners.clear();
  }
}

class _Token implements CancellationToken {
  final bool Function() isCancelledFn;
  final VoidCallback Function(void Function()) addListener;
  _Token({required this.isCancelledFn, required this.addListener});

  @override
  bool get isCancelled => isCancelledFn();

  @override
  VoidCallback onCancel(void Function() listener) => addListener(listener);
}
