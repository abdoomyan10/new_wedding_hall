// features/home/domain/entities/search_entity.dart
import 'search_result_entity.dart';

class SearchEntity {
  final String query;
  final List<SearchResultEntity> results;

  SearchEntity({
    required this.query,
    required this.results,
  });
}