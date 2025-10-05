
// features/home/data/repositories/home_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/home_entity.dart';
import '../../domain/entities/search_entity.dart';
import '../../domain/repositories/home_repository.dart';

import '../datasources/home_local_data_source.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeDataSource dataSource;
  final NetworkInfo networkInfo;

  HomeRepositoryImpl({
    required this.dataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, HomeEntity>> getHomeData() async {
    try {
      final homeData = await dataSource.getHomeData();
      return Right(homeData);
    } on Exception {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> refreshHomeData() async {
    try {
      await dataSource.refreshHomeData();
      return const Right(null);
    } on Exception {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, SearchEntity>> search(String query) async {
    try {
      final results = await dataSource.search(query);
      return Right(results);
    } on Exception {
      return Left(CacheFailure());
    }
  }
}