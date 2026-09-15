import 'dart:async';

import 'package:fpdart/fpdart.dart';

extension StreamExt on Stream {
  Stream<Either<L, R>> catchStreamError<L, R>(ErrorMapper<L> errorMapper) =>
      transform(StreamTransformer<R, Either<L, R>>.fromHandlers(
          handleData: (data, sink) => sink.add(Either.right(data)), handleError: (e, s, sink) => sink.add(Either.left(errorMapper(e)))));
}

typedef ErrorMapper<T> = T Function(Object error);