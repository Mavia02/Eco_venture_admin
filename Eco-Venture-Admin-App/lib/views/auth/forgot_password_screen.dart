import 'package:eco_venture_admin_portal/core/utils/validators.dart';
import 'package:eco_venture_admin_portal/viewmodels/auth/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../core/constants/app_colors.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formkey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  @override
  void dispose() {
    // TODO: implement dispose
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Form(
          key: _formkey,
          child: Column(
            children: [
              // Purple header
              ClipPath(
                clipper: ParabolaClipper(),
                child: Container(
                  height: 25.h,
                  width: 100.w,
                  color: AppColors.primary,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_reset, size: 13.w, color: Colors.white),
                      SizedBox(height: 1.h),
                      Text(
                        "EcoVenture",
                        style: GoogleFonts.poppins(
                          color: AppColors.background,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      SizedBox(height: 0.6.h),
                      Text(
                        "Forgot Password",
                        style: GoogleFonts.poppins(
                          color: AppColors.textLight,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 4.h),

              // Email input field
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailController,
                  validator: Validators.email,
                  decoration: InputDecoration(
                    hintText: "Enter your registered email",
                    prefixIcon: const Icon(Icons.email_outlined),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(vertical: 18),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 2.5.h),

              // Reset button
              Consumer(
                builder: (context, ref, child) {
                  final forgotState = ref.watch(authViewModelProvider);

                  return Column(
                    children: [
                      SizedBox(
                        width: 50.w,
                        height: 5.h,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 3,
                          ),
                          onPressed: forgotState.isEmailLoading
                              ? null
                              : () async {
                                  if (_formkey.currentState!.validate()) {
                                    await ref
                                        .read(authViewModelProvider.notifier)
                                        .forgotPassword(_emailController.text);
                                  }
                                },
                          child: Text(
                            "Reset Password",
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),

              SizedBox(height: 2.h),

              // Back to login
              TextButton(
                onPressed: () {
                  context.goNamed('login');
                },
                child: Text(
                  "Back to Login",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Same parabola clipper (reuse from login)
class ParabolaClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 8.h);

    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 8.h,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
