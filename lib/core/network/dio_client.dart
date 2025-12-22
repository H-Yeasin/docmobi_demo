import 'package:dio/dio.dart';
import '../services/auth_local_service.dart';

class DioClient {
  final AuthLocalService _authLocal = AuthLocalService();
  late final Dio _dio;

  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: "http://10.10.5.95:5000/api/v1",
        connectTimeout: const Duration(seconds: 10),
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _authLocal.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          if (e.response?.statusCode == 401) {
            // Handle Token Expired (Redirect to login)
          }
          return handler.next(e);
        },
      ),
    );
  }

  Dio get instance => _dio;
}
