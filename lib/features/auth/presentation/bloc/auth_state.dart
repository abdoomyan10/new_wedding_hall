import 'package:firebase_auth/firebase_auth.dart';
import 'package:new_wedding_hall/core/utils/request_state.dart';

class AuthState {
  final RequestStatus status;
  final User? user;
  const AuthState({this.status = RequestStatus.init, this.user});

  AuthState copyWith({RequestStatus? status, User? user}) {
    return AuthState(status: status ?? this.status, user: user ?? this.user);
  }
}
