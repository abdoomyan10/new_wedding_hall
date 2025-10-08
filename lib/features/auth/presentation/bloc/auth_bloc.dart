// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:bloc/bloc.dart';

import 'package:injectable/injectable.dart';
import 'package:new_wedding_hall/core/usecase/usecase.dart';
import 'package:new_wedding_hall/core/utils/request_state.dart';
import 'package:new_wedding_hall/core/utils/toaster.dart';
import 'package:new_wedding_hall/features/auth/domain/usecase/login-user.dart';
import 'package:new_wedding_hall/features/auth/domain/usecase/logout_user.dart';
import 'package:new_wedding_hall/features/auth/domain/usecase/register_user.dart';
import 'package:new_wedding_hall/features/auth/presentation/bloc/auth_event.dart';
import 'package:new_wedding_hall/features/auth/presentation/bloc/auth_state.dart';

@lazySingleton
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUsecase loginUsecase;
  final RegisterUsecase registerUsecase;
  final LogoutUser logoutUser;
  AuthBloc(this.loginUsecase, this.registerUsecase, this.logoutUser)
    : super(AuthState()) {
    on<LoginEvent>((event, emit) async {
      emit(state.copyWith(status: RequestStatus.loading));
      final result = await loginUsecase(event.params);
      result.fold(
        (left) {
          emit(state.copyWith(status: RequestStatus.failed));
          Toaster.showToast(left.message);
        },
        (right) {
          emit(state.copyWith(status: RequestStatus.success, user: right));
        },
      );
    });
    on<RegisterEvent>((event, emit) async {
      emit(state.copyWith(status: RequestStatus.loading));
      final result = await registerUsecase(event.params);
      result.fold(
        (left) {
          emit(state.copyWith(status: RequestStatus.failed));
          Toaster.showToast(left.message);
        },
        (right) {
          emit(state.copyWith(status: RequestStatus.success, user: right));
        },
      );
    });
    on<LogoutEvent>((event, emit) async {
      emit(state.copyWith(status: RequestStatus.loading));
      final result = await logoutUser(NoParams());
      result.fold(
        (left) {
          emit(state.copyWith(status: RequestStatus.failed));
          Toaster.showToast(left.message);
        },
        (right) {
          emit(const AuthState(status: RequestStatus.success, user: null));
          Toaster.showToast('تم تسجيل الخروج بنجاح', isError: false);
        },
      );
    });
  }
}
