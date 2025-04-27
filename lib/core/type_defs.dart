import 'package:fpdart/fpdart.dart';
import 'failure.dart';

typedef FutureVoid = Future<Either<Failure, void>>;
typedef FutureEither<T> = Future<Either<Failure, T>>;
