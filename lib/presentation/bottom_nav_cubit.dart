import 'package:flutter_bloc/flutter_bloc.dart';

enum BottomNavItem {
  home,
  halls,
  payments,
  bookings,
  settings,
}

class BottomNavCubit extends Cubit<int> {
  BottomNavCubit() : super(0);

  void changeTab(int index) {
    if (index >= 0 && index < BottomNavItem.values.length) {
      emit(index);
    }
  }

  BottomNavItem get currentItem => BottomNavItem.values[state];
}