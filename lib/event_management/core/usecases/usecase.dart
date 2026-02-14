import 'package:dartz/dartz.dart';

import '../errors/failures.dart';

/// Generic contract.  T = success return type.  P = params (use [NoParams] for zero-arg).
abstract class UseCase<T, P> {
  Future<Either<Failure, T>> call(P params);
}

/// Sentinel used when a use-case takes no parameters.
class NoParams {
  const NoParams();
}