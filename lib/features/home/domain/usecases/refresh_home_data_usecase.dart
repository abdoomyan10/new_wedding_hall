// features/home/domain/usecases/refresh_home_data_usecase.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/home_entity.dart';
import '../repositories/home_repository.dart';

class RefreshHomeDataUseCase {
  final HomeRepository repository;

  RefreshHomeDataUseCase(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.refreshHomeData();
  }
}