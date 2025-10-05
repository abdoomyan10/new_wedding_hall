

// features/home/presentation/cubit/home_state.dart
part of 'home_cubit.dart';

@immutable
abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final HomeEntity homeData;

  HomeLoaded(this.homeData);
}

class HomeError extends HomeState {
  final String message;

  HomeError(this.message);
}

class SearchLoading extends HomeState {}

class SearchResults extends HomeState {
  final SearchEntity results;

  SearchResults(this.results);
}

class SearchError extends HomeState {
  final String message;

  SearchError(this.message);
}