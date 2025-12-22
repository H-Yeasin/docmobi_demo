import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/api_endpoints.dart';

class AuthRepository {
  final Dio _dio = DioClient().instance;

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.login,
        data: {"email": email, "password": password},
      );
      return response.data;
    } on DioException catch (e) {
      // Extract the specific message from your backend response
      final errorMessage =
          e.response?.data['message'] ?? "An unexpected error occurred";
      print("🌐 Backend says: $errorMessage");
      throw errorMessage; // Throwing the string message directly
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      // Determine which endpoint to use based on the presence of a license or role
      final String endpoint = userData.containsKey('medicalLicense')
          ? ApiEndpoints
                .signup // or your specific doctor register endpoint
          : ApiEndpoints.signup;

      final response = await _dio.post(endpoint, data: userData);
      return response.data;
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? "Registration failed";
      print("🌐 Registration Error: $errorMessage");
      throw errorMessage;
    }
  }
}
