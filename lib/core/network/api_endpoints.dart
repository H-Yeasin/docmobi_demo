class ApiEndpoints {
  // Use your local IP for physical devices or 10.0.2.2 for Android Emulator
  static const String baseUrl = "http://10.10.5.95:5000/api/v1"; 

  // Auth Endpoints
  static const String login = "$baseUrl/auth/login";
  static const String signup = "$baseUrl/auth/register";
  static const String verifyOtp = "$baseUrl/auth/verify-otp";
  
  // Feature Endpoints
  static const String appointments = "$baseUrl/appointment";
  static const String reels = "$baseUrl/reel";
}