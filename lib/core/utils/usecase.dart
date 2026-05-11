abstract class UseCase<Type, Params> {
  Future<Type> call(Params params);
}

/// Use when a UseCase needs no parameters
class NoParams {}
