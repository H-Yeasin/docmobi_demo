import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/common_widgets/auth_header.dart';
import '../../../../core/common_widgets/custom_text_field.dart';
import '../../../../core/common_widgets/primary_button.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/repositories/auth_repository.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // 1. Initialize Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final AuthRepository _authRepo = AuthRepository();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // 2. Registration Logic
  Future<void> _handleSignUp() async {
    // Debug Print: Check what is actually inside the controllers
    print("Name: '${_nameController.text}'");
    print("Email: '${_emailController.text}'");
    print("Pass: '${_passwordController.text}'");
    // Basic Validation
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      _showSnackBar("Please fill in all fields", isError: true);
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnackBar("Passwords do not match", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final Map<String, dynamic> patientData = {
        "fullName": _nameController.text.trim(),
        "email": _emailController.text.trim(),
        "password": _passwordController.text.trim(),
        "confirmPassword": _confirmPasswordController.text.trim(),
        "role": "patient", // Explicitly set role for patient flow
      };

      print("📤 Sending to Backend: $patientData");

      await _authRepo.register(patientData);

      _showSnackBar(
        "Account created successfully! Please login.",
        isError: false,
      );

      // Navigate to login after successful signup
      if (mounted) {
        context.go('/login', extra: 'patient');
      }
    } catch (e) {
      print("❌ SIGNUP ERROR: $e");
      _showSnackBar(e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const AuthHeader(
                title: "Create Account",
                subtitle: "Please Signup to your Account",
              ),
              const SizedBox(height: 32),

              CustomTextField(
                controller: _nameController,
                label: "Full Name",
                hint: "The king",
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _emailController,
                label: "Email Address",
                hint: "you@gmail.com",
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _passwordController,
                label: "Password",
                hint: "••••••••••••",
                isPassword: true,
                suffixIcon: const Icon(
                  Icons.visibility_off_outlined,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _confirmPasswordController,
                label: "Confirm Password",
                hint: "••••••••••••",
                isPassword: true,
                suffixIcon: const Icon(
                  Icons.visibility_off_outlined,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 32),

              _isLoading
                  ? const CircularProgressIndicator()
                  : PrimaryButton(
                      label: "Create Account",
                      icon: Icons.person_outline,
                      onPressed: _handleSignUp,
                    ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? "),
                  GestureDetector(
                    onTap: () => context.go('/login', extra: 'patient'),
                    child: const Text(
                      "Sign In",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
