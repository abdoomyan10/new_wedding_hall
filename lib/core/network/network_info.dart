
import 'package:connectivity_plus/connectivity_plus.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;

  NetworkInfoImpl({Connectivity? connectivity})
      : connectivity = connectivity ?? Connectivity();

  @override
  Future<bool> get isConnected async {
    try {
      final connectivityResult = await connectivity.checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      // في حالة حدوث خطأ، نفترض أن هناك اتصالاً لتجنب تعطيل التطبيق
      return true;
    }
  }
}