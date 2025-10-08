import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import 'package:new_wedding_hall/features/auth/domain/repo/auth_repository.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';

@injectable
class RegisterUsecase implements UseCase<User, RegisterParams> {
  final AuthRepo repo;

  RegisterUsecase({required this.repo});
  @override
  Future<Either<Failure, User>> call(RegisterParams params) async {
    return await repo.register(params.email, params.password);
  }
}

class RegisterParams {
  final String email;
  final String password;

  RegisterParams({required this.email, required this.password});
}
