import 'package:eco_venture_admin_portal/core/constants/app_colors.dart';
import 'package:eco_venture_admin_portal/core/utils/validators.dart';
import 'package:eco_venture_admin_portal/viewmodels/auth/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class LoginScreens extends ConsumerStatefulWidget {
  const LoginScreens({super.key});

  @override
  ConsumerState<LoginScreens> createState() => _LoginScreensState();
}

class _LoginScreensState extends ConsumerState<LoginScreens> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formkey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Form(
          key: _formkey,
          child: Column(
            children: [
              ClipPath(
                clipper: ParabolaClipper(),
                child: Container(
                  height: 40.h,
                  width: 100.w,
                  color: AppColors.primary,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.school,
                        size: 15.w,
                        color: AppColors.background,
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        "EcoVenture",
                        style: GoogleFonts.poppins(
                          color: AppColors.background,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        "Admin Portal Login",
                        style: GoogleFonts.poppins(
                          color: AppColors.textLight,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 4.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                child: TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailController,
                  validator: Validators.email,
                  decoration: InputDecoration(
                    hintText: "username@gmail.com",
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
              SizedBox(height: 2.h),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                child: TextFormField(
                  keyboardType: TextInputType.visiblePassword,
                  controller: _passwordController,
                  obscureText: true,
                  validator: Validators.password,
                  decoration: InputDecoration(
                    hintText: "Password",
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: const Icon(Icons.visibility_off),
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

              SizedBox(height: 1.h),
              TextButton(
                onPressed: () {
                  context.goNamed('forgotPassword');
                },
                child: Text(
                  "Forgot password?",
                  style: GoogleFonts.poppins(
                    color: Colors.grey,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              SizedBox(height: 2.h),

              Consumer(
                builder: (context, ref, child) {
                  final signInState = ref.watch(authViewModelProvider);

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
                            elevation: 5,
                          ),
                          onPressed: signInState.isEmailLoading
                              ? null
                              : () async {
                            if (_formkey.currentState!.validate()) {
                              await ref.read(authViewModelProvider.notifier).signInUser(
                                _emailController.text.trim(),
                                _passwordController.text.trim(),
                                onSuccess: () {
                                  // Logic: Navigate directly to the Dashboard, skipping Landing
                                  context.goNamed("bottomNavChild");
                                },
                              );
                            }
                          },
                          child: Text(
                            signInState.isEmailLoading ? "Connecting..." : "Login here",
                            style: GoogleFonts.poppins(
                              fontSize: 15.sp,
                              color: AppColors.background,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      if (signInState.emailError != null)
                        Padding(
                          padding: EdgeInsets.only(top: 2.h),
                          child: Text(
                            signInState.emailError!,
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ParabolaClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 10.h);

    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 10.h,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
