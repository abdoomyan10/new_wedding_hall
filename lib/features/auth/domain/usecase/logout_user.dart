import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:new_wedding_hall/core/error/failure.dart';
import 'package:new_wedding_hall/core/usecase/usecase.dart';
import 'package:new_wedding_hall/features/auth/domain/repo/auth_repository.dart';

@injectable
class LogoutUser implements UseCase<void, NoParams> {
  final AuthRepo repo;

  LogoutUser({required this.repo});

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repo.logout();
  }
}
