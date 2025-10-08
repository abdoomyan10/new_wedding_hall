import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import 'package:new_wedding_hall/core/error/failure.dart';
import 'package:new_wedding_hall/core/usecase/usecase.dart';
import 'package:new_wedding_hall/features/auth/domain/repo/auth_repository.dart';

@injectable
class LoginUsecase implements UseCase<User, LoginParams> {
  final AuthRepo repo;

  LoginUsecase({required this.repo});
  @override
  Future<Either<Failure, User>> call(LoginParams params) async {
    return await repo.login(params.email, params.password);
  }
}

class LoginParams {
  final String email;
  final String password;
  LoginParams({required this.email, required this.password});
}
