// features/home/domain/entities/search_result_entity.dart
class SearchResultEntity {
  final String id;
  final String type; // 'event', 'client', 'payment'
  final String title;
  final String subtitle;

  SearchResultEntity({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
  });
}