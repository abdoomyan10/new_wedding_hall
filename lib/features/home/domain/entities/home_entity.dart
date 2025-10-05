// features/home/domain/entities/home_entity.dart
class HomeEntity {
  final int unreadNotificationsCount;
  final String userName;
  final String? userImageUrl;
  final DateTime lastUpdate;
  final int totalEvents;
  final int upcomingEvents;
  final double totalRevenue;
  final int pendingPayments;

  const HomeEntity({
    required this.unreadNotificationsCount,
    required this.userName,
    this.userImageUrl,
    required this.lastUpdate,
    required this.totalEvents,
    required this.upcomingEvents,
    required this.totalRevenue,
    required this.pendingPayments,
  });
}