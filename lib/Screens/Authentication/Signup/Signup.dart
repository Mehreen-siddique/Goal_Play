// screens/auth/SignUp_screen.dart



import 'package:flutter/material.dart';

import 'dart:async';

import 'package:goal_play/Screens/Authentication/Login/Login.dart';

import 'package:goal_play/Screens/Home/BottomBar/MainContainer.dart';

import 'package:goal_play/Screens/Utils/Constants/Constants.dart';

import 'package:goal_play/Services/AuthServices/AuthServices.dart';

import 'package:provider/provider.dart';





class SignUpScreen extends StatefulWidget {

  const SignUpScreen({super.key});



  @override

  State<SignUpScreen> createState() => _SignUpScreenState();

}



class _SignUpScreenState extends State<SignUpScreen> {

  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();

  final _passwordController = TextEditingController();

  final _confirmPasswordController = TextEditingController();

  final _nameController = TextEditingController();

  bool _obscurePassword = true;

  bool _isLoading = false;

  Timer? _errorTimer;



  @override

  void dispose() {

    _emailController.dispose();

    _passwordController.dispose();

    _confirmPasswordController.dispose();

    _nameController.dispose();

    _errorTimer?.cancel();

    super.dispose();

  }



  void _handleSignup() async {

    if (_formKey.currentState!.validate()) {

      final authService = context.read<AuthService>();

      authService.clearError(); // Clear previous errors

      

      final success = await authService.signUp(

        email: _emailController.text.trim(),

        password: _passwordController.text,

        name: _nameController.text.trim(),

      );



      if (!success && mounted) {

        _clearErrorAfterDelay(); // Auto-clear error after 5 seconds

      }



      if (success && mounted) {

        // Navigate to home screen

        Navigator.pushReplacement(context,

            MaterialPageRoute(builder: (context) => MainContainerScreen()));

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





  @override

  Widget build(BuildContext context) {

    final authService = context.watch<AuthService>();

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

                      'Create Account',

                      style: AppTextStyles.heading.copyWith(fontSize: 32),

                    ),

                  ),



                  const SizedBox(height: 60),



                  // Email Field

                  Text(

                    'userName',

                    style: AppTextStyles.bodyDark.copyWith(

                      fontWeight: FontWeight.w600,

                      fontSize: 15,

                    ),

                  ),

                  const SizedBox(height: 8),

                  TextFormField(

                    controller: _nameController,

                    keyboardType: TextInputType.emailAddress,

                    decoration: InputDecoration(

                      hintText: 'Enter your username',

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

                        return 'Please enter your username';

                      }

                      // if (!value.contains('@')) {

                      //   return 'Please enter a valid email';

                      // }

                      return null;

                    },

                  ),

                  const SizedBox(height: 20),



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



                  // Error Display

                  if (authService.errorMessage != null)

                    Container(

                      padding: const EdgeInsets.all(12),

                      decoration: BoxDecoration(

                        color: AppColors.errorRed.withOpacity(0.1),

                        borderRadius: BorderRadius.circular(AppSizes.radiusSM),

                        border: Border.all(color: AppColors.errorRed.withOpacity(0.3)),

                      ),

                      child: Column(

                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [

                          Row(

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

                          if (authService.errorMessage!.contains('already registered'))

                            Padding(

                              padding: const EdgeInsets.only(top: 8),

                              child: Row(

                                children: [

                                  Icon(Icons.info_outline, color: AppColors.primaryPurple, size: 16),

                                  const SizedBox(width: 4),

                                  Expanded(

                                    child: Text(

                                      'Try logging in instead or use a different email',

                                      style: AppTextStyles.caption.copyWith(color: AppColors.primaryPurple),

                                    ),

                                  ),

                                ],

                              ),

                            ),

                        ],

                      ),

                    ),



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

                  Text(

                    'Confirm Password',

                    style: AppTextStyles.bodyDark.copyWith(

                      fontWeight: FontWeight.w600,

                      fontSize: 15,

                    ),

                  ),

                  const SizedBox(height: 8),

                  TextFormField(

                    controller: _confirmPasswordController,

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

                      if (value != _passwordController.text) {

                        return 'Passwords do not match';

                      }

                      return null;

                    },

                  ),



                  const SizedBox(height: 30),



                  // Login Button

                  SizedBox(

                    width: double.infinity,

                    height: AppSizes.buttonHeight,

                    child: ElevatedButton(

                      onPressed: authService.status == AuthStatus.loading ? null : _handleSignup,

                      style: ElevatedButton.styleFrom(

                        backgroundColor: AppColors.primaryPurple,

                        shape: RoundedRectangleBorder(

                          borderRadius: BorderRadius.circular(AppSizes.radiusSM),

                        ),

                        elevation: 4,

                        shadowColor: AppColors.shadowPurple,

                      ),

                      child: authService.status == AuthStatus.loading

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

                        'SignUp',

                        style: AppTextStyles.button,

                      ),

                    ),

                  ),

                  const SizedBox(height: 30),





                  // Sign Up Link

                  Center(

                    child: Row(

                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [

                        Text(

                          'Already have an account? ',

                          style: AppTextStyles.body,

                        ),

                        TextButton(

                          onPressed: () {

                            Navigator.push(

                              context,

                              MaterialPageRoute(

                                builder: (_) => LoginScreen(),

                              ),

                            );

                          },

                          style: TextButton.styleFrom(

                            padding: EdgeInsets.zero,

                            minimumSize: const Size(0, 0),

                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,

                          ),

                          child: Text(

                            'LogIn',

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







