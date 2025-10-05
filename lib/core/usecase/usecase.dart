import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:new_wedding_hall/core/error/failure.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams extends Equatable {
  const NoParams();
  Map<String, dynamic> getBody() => {};

  Map<String, String> getParams() => {};

  @override
  List<Object> get props => [];
}
