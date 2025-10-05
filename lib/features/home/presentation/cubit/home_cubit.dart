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

  void loadHomeData() async {
    emit(HomeLoading());
    final result = await getHomeDataUseCase();
    result.fold(
          (failure) => emit(HomeError(failure.toString())),
          (homeData) => emit(HomeLoaded(homeData)),
    );
  }

  void refreshData() async {
    final result = await refreshHomeDataUseCase();
    result.fold(
          (failure) => emit(HomeError(failure.toString())),
          (_) => loadHomeData(),
    );
  }

  void search(String query) async {
    if (query.isEmpty) {
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

  void clearSearch() {
    loadHomeData();
  }
}