import 'package:equatable/equatable.dart';
import 'package:new_wedding_hall/features/auth/domain/usecase/login-user.dart';
import 'package:new_wedding_hall/features/auth/domain/usecase/register_user.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class LoginEvent extends AuthEvent {
  final LoginParams params;

  const LoginEvent({required this.params});
}

class RegisterEvent extends AuthEvent {
  final RegisterParams params;

  const RegisterEvent({required this.params});
}

class LogoutEvent extends AuthEvent {}
