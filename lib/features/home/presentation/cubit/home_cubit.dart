// features/home/presentation/cubit/home_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../domain/entities/home_entity.dart';
import '../../domain/entities/search_entity.dart';
import '../../domain/usecases/get_home_data_usecase.dart';



part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final GetHomeDataUseCase getHomeDataUseCase;
  final RefreshHomeDataUseCase refreshHomeDataUseCase;
  final SearchUseCase searchUseCase;

  HomeCubit({
    required this.getHomeDataUseCase,
    required this.refreshHomeDataUseCase,
    required this.searchUseCase,
  }) : super(HomeInitial());

  /// تحميل البيانات الأولية للصفحة الرئيسية
  void loadHomeData() async {
    emit(HomeLoading());
    final result = await getHomeDataUseCase();
    result.fold(
          (failure) => emit(HomeError(failure.toString())),
          (homeData) => emit(HomeLoaded(homeData)),
    );
  }

  /// تحديث البيانات (سحب للتحديث)
  void refreshData() async {
    // إذا كنا في حالة بحث، لا نقوم بالتحديث
    if (state is SearchResults || state is SearchLoading) {
      return;
    }

    emit(HomeRefreshing());
    final result = await refreshHomeDataUseCase();
    result.fold(
          (failure) {
        // في حالة فشل التحديث، نعود إلى البيانات القديمة مع رسالة خطأ
        if (state is HomeLoaded) {
          final currentState = state as HomeLoaded;
          emit(HomeRefreshError(currentState.homeData, failure.toString()));
        } else {
          emit(HomeError(failure.toString()));
        }
      },
          (refreshedData) {
        emit(HomeLoaded(refreshHomeDataUseCase as HomeEntity));
      },
    );
  }

  /// البحث في البيانات
  void search(String query) async {
    if (query.isEmpty) {
      // إذا كان البحث فارغاً، نعود للبيانات الرئيسية
      loadHomeData();
      return;
    }

    emit(SearchLoading());
    final result = await searchUseCase(query);
    result.fold(
          (failure) => emit(SearchError(failure.toString())),
          (results) => emit(SearchResults(results)),
    );
  }

  /// مسح نتائج البحث والعودة للبيانات الرئيسية
  void clearSearch() {
    loadHomeData();
  }

  /// العودة من خطأ التحديث إلى البيانات السليمة
  void recoverFromRefreshError() {
    if (state is HomeRefreshError) {
      final currentState = state as HomeRefreshError;
      emit(HomeLoaded(currentState.homeData));
    }
  }
}