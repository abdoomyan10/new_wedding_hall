// features/home/data/datasources/home_local_data_source.dart
import '../../domain/entities/search_result_entity.dart';
import '../models/home_model.dart';
import '../../domain/entities/search_entity.dart';

abstract class HomeDataSource {
  Future<HomeModel> getHomeData();
  Future<void> refreshHomeData();
  Future<SearchEntity> search(String query);
}

class HomeLocalDataSource implements HomeDataSource {
  @override
  Future<HomeModel> getHomeData() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return HomeModel(
      unreadNotificationsCount: 3,
      userName: "مدير الصالة",
      userImageUrl: null,
      lastUpdate: DateTime.now(),
      totalEvents: 15,
      upcomingEvents: 3,
      totalRevenue: 75000.0,
      pendingPayments: 2,
    );
  }

  @override
  Future<void> refreshHomeData() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<SearchEntity> search(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final results = [
      SearchResultEntity(
        id: "1",
        title: "أحمد محمد - زفاف",
        subtitle: "15 أكتوبر 2024 - 300 ضيف",
        type: "event",
      ),
      SearchResultEntity(
        id: "2",
        title: "فاتن سعيد",
        subtitle: "عميل - 2 حفلات سابقة",
        type: "client",
      ),
      SearchResultEntity(
        id: "3",
        title: "دفعة حفل ليلى",
        subtitle: "7000 ريال - مكتملة",
        type: "payment",
      ),
    ];

    return SearchEntity(query: query, results: results);
  }
}