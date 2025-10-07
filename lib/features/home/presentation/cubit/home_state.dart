// features/home/presentation/cubit/home_state.dart
part of 'home_cubit.dart';

@immutable
abstract class HomeState {
  const HomeState();
}

/// الحالة الأولية
class HomeInitial extends HomeState {
  const HomeInitial();
}

/// جاري تحميل البيانات
class HomeLoading extends HomeState {
  const HomeLoading();
}

/// جاري تحديث البيانات (سحب للتحديث)
class HomeRefreshing extends HomeState {
  const HomeRefreshing();
}

/// البيانات محملة بنجاح
class HomeLoaded extends HomeState {
  final HomeEntity homeData;

  const HomeLoaded(this.homeData);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HomeLoaded && other.homeData == homeData;
  }

  @override
  int get hashCode => homeData.hashCode;
}

/// خطأ في تحميل البيانات
class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HomeError && other.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}

/// خطأ أثناء التحديث (مع الاحتفاظ بالبيانات القديمة)
class HomeRefreshError extends HomeState {
  final HomeEntity homeData;
  final String errorMessage;

  const HomeRefreshError(this.homeData, this.errorMessage);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HomeRefreshError &&
        other.homeData == homeData &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode => homeData.hashCode ^ errorMessage.hashCode;
}

/// جاري البحث
class SearchLoading extends HomeState {
  const SearchLoading();
}

/// نتائج البحث
class SearchResults extends HomeState {
  final SearchEntity results;

  const SearchResults(this.results);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SearchResults && other.results == results;
  }

  @override
  int get hashCode => results.hashCode;
}

/// خطأ في البحث
class SearchError extends HomeState {
  final String message;

  const SearchError(this.message);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SearchError && other.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}