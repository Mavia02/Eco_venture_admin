import 'package:eco_venture_admin_portal/core/utils/validators.dart';
import 'package:eco_venture_admin_portal/viewmodels/auth/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formkey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  // --- UI DNA COLORS ---
  final Color _accent = Colors.amberAccent;
  final Color _glassBG = Colors.white.withOpacity(0.06);
  final Color _glassBorder = Colors.white.withOpacity(0.12);

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: 100.h,
        width: 100.w,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2F5755), Color(0xFF0A3431)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Form(
              key: _formkey,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Column(
                  children: [
                    SizedBox(height: 8.h),

                    // --- BRANDING/ICON SECTION ---
                    Icon(
                      Icons.lock_reset_rounded,
                      size: 18.w,
                      color: _accent,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      "Account Recovery",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Text(
                      "ADMIN ACCESS ONLY",
                      style: GoogleFonts.poppins(
                        color: _accent,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 3,
                      ),
                    ),
                    SizedBox(height: 6.h),

                    // --- GLASS CARD ---
                    Container(
                      padding: EdgeInsets.all(3.h),
                      decoration: BoxDecoration(
                        color: _glassBG,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: _glassBorder),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Enter your registered email and we will send you instructions to reset your password.",
                            style: GoogleFonts.poppins(
                              color: Colors.white60,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                            ),
                            textAlign: TextAlign.start,
                          ),
                          SizedBox(height: 3.h),

                          _buildLabel("Registered Email"),
                          _buildThemedTextField(
                            controller: _emailController,
                            hint: "",
                            icon: Icons.alternate_email_rounded,
                            validator: Validators.email,
                          ),
                          SizedBox(height: 4.h),
                          _buildResetButton(),
                        ],
                      ),
                    ),

                    SizedBox(height: 4.h),

                    // --- BACK TO LOGIN ---
                    TextButton.icon(
                      onPressed: () => context.goNamed('login'),
                      icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white38, size: 14.sp),
                      label: Text(
                        "Return to Login",
                        style: GoogleFonts.poppins(
                          color: Colors.white38,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(left: 1.w, bottom: 1.h),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 13.5.sp,
          fontWeight: FontWeight.w600,
          color: Colors.white70,
        ),
      ),
    );
  }

  Widget _buildThemedTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      style: GoogleFonts.poppins(color: Colors.white, fontSize: 14.5.sp),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: Colors.white24, fontSize: 14.sp),
        prefixIcon: Icon(icon, color: _accent, size: 20),
        filled: true,
        fillColor: Colors.black26,
        contentPadding: EdgeInsets.symmetric(vertical: 2.h),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: _accent, width: 1.5),
        ),
        errorStyle: GoogleFonts.poppins(color: Colors.redAccent.shade100),
      ),
    );
  }

  Widget _buildResetButton() {
    return Consumer(
      builder: (context, ref, child) {
        final forgotState = ref.watch(authViewModelProvider);

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: forgotState.isEmailLoading
                ? null
                : () async {
              if (_formkey.currentState!.validate()) {
                await ref
                    .read(authViewModelProvider.notifier)
                    .forgotPassword(_emailController.text.trim());
              }
            },
            borderRadius: BorderRadius.circular(20),
            child: Ink(
              height: 7.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: _accent,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Center(
                child: forgotState.isEmailLoading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                )
                    : Text(
                  "SEND RESET LINK",
                  style: GoogleFonts.poppins(
                    fontSize: 15.sp,
                    color: Colors.black,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
