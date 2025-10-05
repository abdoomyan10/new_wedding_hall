
// core/error/failure.dart
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

// General failures
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure([String message = 'فشل في التخزين المؤقت']) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure() : super('فشل في الاتصال بالشبكة');
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([String message = 'العنصر غير موجود']) : super(message);
}

class InvalidInputFailure extends Failure {
  const InvalidInputFailure([String message = 'إدخال غير صالح']) : super(message);
}

class UnknownFailure extends Failure {
  const UnknownFailure([String message = 'فشل غير معروف']) : super(message);
}

class UnAuthenticatedFailure extends Failure {
  const UnAuthenticatedFailure(super.message);
}