// features/home/data/models/home_model.dart
import '../../domain/entities/home_entity.dart';

class HomeModel extends HomeEntity {
  HomeModel({
    required int unreadNotificationsCount,
    required String userName,
    String? userImageUrl,
    required DateTime lastUpdate,
    required int totalEvents,
    required int upcomingEvents,
    required double totalRevenue,
    required int pendingPayments,
  }) : super(
    unreadNotificationsCount: unreadNotificationsCount,
    userName: userName,
    userImageUrl: userImageUrl,
    lastUpdate: lastUpdate,
    totalEvents: totalEvents,
    upcomingEvents: upcomingEvents,
    totalRevenue: totalRevenue,
    pendingPayments: pendingPayments,
  );

  factory HomeModel.fromJson(Map<String, dynamic> json) {
    return HomeModel(
      unreadNotificationsCount: json['unreadNotificationsCount'] ?? 0,
      userName: json['userName'] ?? '',
      userImageUrl: json['userImageUrl'],
      lastUpdate: DateTime.parse(json['lastUpdate']),
      totalEvents: json['totalEvents'] ?? 0,
      upcomingEvents: json['upcomingEvents'] ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      pendingPayments: json['pendingPayments'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'unreadNotificationsCount': unreadNotificationsCount,
      'userName': userName,
      'userImageUrl': userImageUrl,
      'lastUpdate': lastUpdate.toIso8601String(),
      'totalEvents': totalEvents,
      'upcomingEvents': upcomingEvents,
      'totalRevenue': totalRevenue,
      'pendingPayments': pendingPayments,
    };
  }
}