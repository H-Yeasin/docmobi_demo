import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/common_widgets/auth_header.dart';
import '../../../../core/common_widgets/custom_text_field.dart';
import '../../../../core/common_widgets/primary_button.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/auth_local_service.dart';
import '../../data/repositories/auth_repository.dart';

class LoginScreen extends StatefulWidget {
  final String userRole;
  const LoginScreen({super.key, required this.userRole});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 1. Initialize Controllers and Services
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthRepository _authRepo = AuthRepository();
  final AuthLocalService _localService = AuthLocalService();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // 2. Authentication Logic
  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError("Please fill in all fields");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _authRepo.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      print("✅ Login Success! Response data: $result");

      final String token = result['token'];
      final String roleFromBackend = result['user']['role'];

      await _localService.saveToken(token);
      await _localService.saveUserRole(roleFromBackend);

      if (roleFromBackend == 'doctor') {
        context.go('/home-doctor');
      } else {
        context.go('/home-patient');
      }
    } catch (e) {
      // e is now the String "User not found" thrown from the repo
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        margin: const EdgeInsets.all(16.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const AuthHeader(
                title: "Welcome back",
                subtitle: "Please Login to your Account",
              ),
              const SizedBox(height: 32),
              CustomTextField(
                controller: _emailController, // Added controller
                label: "Email Address",
                hint: "you@gmail.com",
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _passwordController, // Added controller
                label: "Password",
                hint: "••••••••••••",
                isPassword: true,
                suffixIcon: const Icon(Icons.visibility_off_outlined),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: true,
                        onChanged: (val) {},
                        activeColor: AppColors.primary,
                      ),
                      const Text("Remember me", style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  TextButton(
                    onPressed: () => context.push('/forgot-password'),
                    child: const Text(
                      "Forgot your password?",
                      style: TextStyle(fontSize: 12, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // 5. Submit Button with Loading State
              _isLoading
                  ? const CircularProgressIndicator()
                  : PrimaryButton(
                      label: "Sign in",
                      icon: Icons.login,
                      onPressed: _handleLogin,
                    ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? "),
                  GestureDetector(
                    onTap: () {
                      if (widget.userRole == 'doctor') {
                        context.push('/doctor-signup');
                      } else {
                        context.push('/signup');
                      }
                    },
                    child: const Text(
                      "Signup",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
