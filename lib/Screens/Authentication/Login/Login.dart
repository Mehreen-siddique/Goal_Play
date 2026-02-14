// screens/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:goal_play/Screens/Authentication/ForgotPassword/ForgotPassword.dart';
import 'package:goal_play/Screens/Authentication/Signup/Signup.dart';
import 'package:goal_play/Screens/Home/BottomBar/MainContainer.dart';
import 'package:goal_play/Screens/Utils/Constants/Constants.dart';
import 'package:goal_play/Services/AuthServices/AuthServices.dart';
import 'package:provider/provider.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  Timer? _errorTimer;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _errorTimer?.cancel();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authService = context.read<AuthService>();
      authService.clearError(); // Clear previous errors
      
      final success = await authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!success && mounted) {
        _clearErrorAfterDelay(); // Auto-clear error after 5 seconds
      }

      if (success && mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>MainContainerScreen()));
      }
    }
  }

  void _clearErrorAfterDelay() {
    _errorTimer?.cancel();
    _errorTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        context.read<AuthService>().clearError();
      }
    });
  }


  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusSM),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.whiteBackground,
          borderRadius: BorderRadius.circular(AppSizes.radiusSM),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.textDark),
            const SizedBox(width: 8),
            Text(label, style: AppTextStyles.bodyDark),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();

    // Auto-navigate if authenticated
    // if (authService.status == AuthStatus.authenticated)
    // {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     Navigator.push(context, MaterialPageRoute(builder: (context)=>MainContainerScreen()));
    //   });
    // }
    return
      Scaffold(
        backgroundColor: AppColors.lightBackground,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),

                  // Welcome Back Text
                  Center(
                    child: Text(
                      'Welcome Back!',
                      style: AppTextStyles.heading.copyWith(fontSize: 32),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Login to continue your journey',
                      style: AppTextStyles.body.copyWith(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 60),

                  Text(
                    'Email',
                    style: AppTextStyles.bodyDark.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Enter your email',
                      hintStyle: AppTextStyles.body,
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        color: AppColors.primaryPurple,
                      ),
                      filled: true,
                      fillColor: AppColors.whiteBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                        borderSide: BorderSide(
                          color: AppColors.borderLight,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                        borderSide: BorderSide(
                          color: AppColors.borderLight,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                        borderSide: BorderSide(
                          color: AppColors.primaryPurple,
                          width: 1.5,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      // Basic email validation regex
                      final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                      if (!emailRegex.hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Password Field
                  Text(
                    'Password',
                    style: AppTextStyles.bodyDark.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: 'Enter your password',
                      hintStyle: AppTextStyles.body,
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: AppColors.primaryPurple,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.textGray,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: AppColors.whiteBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                        borderSide: BorderSide(
                          color: AppColors.borderLight,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                        borderSide: BorderSide(
                          color: AppColors.borderLight,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                        borderSide: BorderSide(
                          color: AppColors.primaryPurple,
                          width: 1.5,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Error Display
                  if (authService.errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.errorRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                        border: Border.all(color: AppColors.errorRed.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: AppColors.errorRed, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              authService.errorMessage!,
                              style: AppTextStyles.caption.copyWith(color: AppColors.errorRed),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,MaterialPageRoute(builder: (context)=>ForgotPasswordScreen())
                        );
                      },
                      child: Text(
                        'Forgot Password?',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.primaryPurple,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    height: AppSizes.buttonHeight,
                    child: ElevatedButton(
                      onPressed: authService.status == AuthStatus.loading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                        ),
                        elevation: 4,
                        shadowColor: AppColors.shadowPurple,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.textWhite,
                          ),
                        ),
                      )
                          : Text(
                        'Login',
                        style: AppTextStyles.button,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Divider
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OR',
                          style: AppTextStyles.caption,
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Social Login Buttons
                  Row(
                    children: [
                      Expanded(
                        child: _buildSocialButton(
                          icon: Icons.g_mobiledata,
                          label: 'Google',
                          onTap: () async {
                            final authService = context.read<AuthService>();
                            final success = await authService.signInWithGoogle();
                            
                            if (success && mounted) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => MainContainerScreen()),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Sign Up Link
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Don\'t have an account? ',
                          style: AppTextStyles.body,
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,MaterialPageRoute(builder: (context)=>SignUpScreen())
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Sign Up',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.primaryPurple,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
  }
}


