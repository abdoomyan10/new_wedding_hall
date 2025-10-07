// features/home/domain/repositories/home_repository.dart
import 'package:dartz/dartz.dart';
import 'package:new_wedding_hall/core/error/failure.dart';
import 'package:new_wedding_hall/features/home/domain/entities/home_entity.dart';
import 'package:new_wedding_hall/features/home/domain/entities/search_entity.dart';

abstract class HomeRepository {
  Future<Either<Failure, HomeEntity>> getHomeData();
  Future<Either<Failure, void>> refreshHomeData();

  Future<Either<Failure, SearchEntity>> search(String query);
}
