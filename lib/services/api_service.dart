import 'package:dio/dio.dart';
import 'package:totheblessing/core/Constants.dart';

class ApiService {
  final Dio dio;

  ApiService(String? token)
      : dio = Dio(BaseOptions(
          baseUrl: Constants.baseUrl, // Mude para sua URL
          headers: {
            'Content-Type': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ));

  void updateToken(String? token) {
    if (token != null) {
      dio.options.headers['Authorization'] = 'Bearer $token';
    } else {
      dio.options.headers.remove('Authorization');
    }
  }
}
