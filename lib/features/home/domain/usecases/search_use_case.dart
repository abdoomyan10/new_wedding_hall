import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/search_entity.dart';
import '../repositories/home_repository.dart';

class SearchUseCase {
  final HomeRepository repository;

  SearchUseCase(this.repository);

  Future<Either<Failure, SearchEntity>> call(String query) async {
    return await repository.search(query);
  }
}