// features/home/domain/usecases/get_home_data_usecase.dart
import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/home_entity.dart';
import '../entities/search_entity.dart';
import '../repositories/home_repository.dart';

class GetHomeDataUseCase {
  final HomeRepository repository;

  GetHomeDataUseCase(this.repository);

  Future<Either<Failure, HomeEntity>> call() async {
    return await repository.getHomeData();
  }
}

// features/home/domain/usecases/refresh_home_data_usecase.dart
class RefreshHomeDataUseCase {
  final HomeRepository repository;

  RefreshHomeDataUseCase(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.refreshHomeData();
  }
}

// features/home/domain/usecases/search_use_case.dart
class SearchUseCase {
  final HomeRepository repository;

  SearchUseCase(this.repository);

  Future<Either<Failure, SearchEntity>> call(String query) async {
    return await repository.search(query);
  }
}