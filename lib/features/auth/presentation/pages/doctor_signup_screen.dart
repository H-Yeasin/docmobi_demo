import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/common_widgets/primary_button.dart';
import '../../data/repositories/auth_repository.dart';

class DoctorSignUpScreen extends StatefulWidget {
  const DoctorSignUpScreen({super.key});

  @override
  State<DoctorSignUpScreen> createState() => _DoctorSignUpScreenState();
}

class _DoctorSignUpScreenState extends State<DoctorSignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _licenseController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final AuthRepository _authRepo = AuthRepository();
  bool _isLoading = false;
  String? _selectedSpecialty;

  final List<String> _specialties = [
    "Podiatric Surgery",
    "Cardiology",
    "Dermatology",
    "Pediatrics",
    "Neurology",
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _licenseController.dispose();
    _experienceController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnackBar("Passwords do not match", isError: true);
      return;
    }
    if (_selectedSpecialty == null) {
      _showSnackBar("Please select a specialty", isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final Map<String, dynamic> doctorData = {
        "name": _nameController.text.trim(),
        "email": _emailController.text.trim(),
        "password": _passwordController.text.trim(),
        "medicalLicense": _licenseController.text.trim(),
        "specialty": _selectedSpecialty,
        "experience": _experienceController.text.trim(),
        "role": "doctor",
      };
      await _authRepo.register(doctorData);
      if (mounted) _showApprovalModal(context);
    } catch (e) {
      _showSnackBar(e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Determine if we are on a wide screen (Tablet/Desktop)
            bool isWide = constraints.maxWidth > 700;

            return Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isWide ? 40 : 24,
                  vertical: 20,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 800,
                  ), // Max width for the whole form
                  child: Column(
                    children: [
                      Image.asset('assets/logo.png', height: isWide ? 100 : 80),
                      const SizedBox(height: 16),
                      const Text(
                        "Create Account",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        "Please Signup to your Account",
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      const SizedBox(height: 32),

                      // Grid-like behavior: 2 columns if wide, 1 if narrow
                      Wrap(
                        spacing: 20,
                        runSpacing: 0,
                        children: [
                          _responsiveField(
                            isWide,
                            _buildTextField(
                              "Full Name",
                              "The king",
                              _nameController,
                            ),
                          ),
                          _responsiveField(
                            isWide,
                            _buildTextField(
                              "Email Address",
                              "you@gmail.com",
                              _emailController,
                            ),
                          ),
                          _responsiveField(
                            isWide,
                            _buildTextField(
                              "Medical License",
                              "1111 2222 3333",
                              _licenseController,
                            ),
                          ),
                          _responsiveField(
                            isWide,
                            _buildDropdownField(
                              "Medical Specialty*",
                              "Add your specialty",
                            ),
                          ),
                          _responsiveField(
                            isWide,
                            _buildTextField(
                              "Experience",
                              "05 Years",
                              _experienceController,
                            ),
                          ),
                          const SizedBox(
                            width: double.infinity,
                          ), // Force password to new line if desired or keep in grid
                          _responsiveField(
                            isWide,
                            _buildTextField(
                              "Password",
                              "••••••••",
                              _passwordController,
                              isPassword: true,
                            ),
                          ),
                          _responsiveField(
                            isWide,
                            _buildTextField(
                              "Confirm Password",
                              "••••••••",
                              _confirmPasswordController,
                              isPassword: true,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),
                      _isLoading
                          ? const CircularProgressIndicator()
                          : SizedBox(
                              width: isWide ? 300 : double.infinity,
                              child: PrimaryButton(
                                label: "Create Account",
                                onPressed: _handleSignup,
                              ),
                            ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Helper to wrap fields in a Sized box if the screen is wide
  Widget _responsiveField(bool isWide, Widget child) {
    return SizedBox(
      width: isWide
          ? 370
          : double.infinity, // roughly half of the 800 max width
      child: child,
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController controller, {
    bool isPassword = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            obscureText: isPassword,
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(String label, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedSpecialty,
                isExpanded: true,
                hint: Text(hint),
                items: _specialties
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedSpecialty = val),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showApprovalModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
                size: 60,
              ),
              const SizedBox(height: 16),
              const Text(
                "Waiting For Approval",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              const Text(
                "Please wait while we verify your submission.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: "Go to Login",
                onPressed: () => context.go('/login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
