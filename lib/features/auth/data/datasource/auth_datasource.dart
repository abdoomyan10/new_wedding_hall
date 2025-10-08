import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import 'package:new_wedding_hall/core/error/exceptions.dart';
import 'package:new_wedding_hall/core/utils/toaster.dart';

abstract class AuthDatasource {
  Future<User> login(String email, String password);
  Future<User> register(String email, String password);
  Future<void> logout();
}

@Injectable(as: AuthDatasource)
class AuthDatasourceImpl implements AuthDatasource {
  @override
  Future<User> login(String email, String password) async {
    try {
      final user = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (user.user == null) {
        throw ServerException('User Not Found');
      } else {
        return user.user!;
      }
    } on FirebaseAuthException catch (e) {
      if (e.message != null) {
        Toaster.showToast(e.message!, isError: true);
      }
      throw ServerException(e.message ?? 'User Not Found');
    }
  }

  @override
  Future<User> register(String email, String password) async {
    try {
      final user = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (user.user == null) {
        throw ServerException('User Not Found');
      } else {
        return user.user!;
      }
    } on FirebaseAuthException catch (e) {
      if (e.message != null) {
        Toaster.showToast(e.message!, isError: true);
      }
      throw ServerException(e.message ?? 'User Not Found');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
    } on FirebaseAuthException catch (e) {
      if (e.message != null) {
        Toaster.showToast(e.message!, isError: true);
      }
      throw ServerException(e.message ?? 'Logout failed');
    }
  }
}
