import 'dart:async';
import 'package:flutter/foundation.dart';

class Debouncer {
  final int millisecond;
  Timer? _timer;

  Debouncer({required this.millisecond});

  run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: millisecond), action);
  }


  dispose(){
    _timer?.cancel();
  }
}
