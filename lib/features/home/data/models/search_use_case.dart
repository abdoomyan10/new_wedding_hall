// features/home/domain/usecases/search_use_case.dart
import 'package:dartz/dartz.dart';
import 'package:wedding_hall/core/error/failure.dart';
import 'package:wedding_hall/core/usecase/usecase.dart';
import 'package:wedding_hall/features/home/domain/entities/search_entity.dart';
import 'package:wedding_hall/features/home/domain/repositories/home_repository.dart';

class SearchUseCase implements UseCase<SearchEntity, String> {
  final HomeRepository repository;

  const SearchUseCase(this.repository); // إضافة const

  @override
  Future<Either<Failure, SearchEntity>> call(String query) async {
    return await repository.search(query);
  }
}