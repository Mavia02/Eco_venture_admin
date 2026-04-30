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

  // --- THE ADMINISTRATIVE WALL (Logic Preserved) ---
  static const String _authorizedAdminEmail = "mehranbangash46@gmail.com";
  String? _unauthorizedError;

  // --- UI DNA COLORS ---
  final Color _accent = Colors.amberAccent;
  final Color _glassBG = Colors.white.withOpacity(0.06);
  final Color _glassBorder = Colors.white.withOpacity(0.12);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
                    // --- BRANDING SECTION ---
                    Icon(
                      Icons.admin_panel_settings_rounded,
                      size: 18.w,
                      color: _accent,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      "EcoVenture",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                      ),
                    ),
                    Text(
                      "ADMINISTRATOR PORTAL",
                      style: GoogleFonts.poppins(
                        color: _accent,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 4,
                      ),
                    ),
                    SizedBox(height: 6.h),

                    // --- LOGIN GLASS CARD ---
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
                          _buildLabel("Admin Email"),
                          _buildThemedTextField(
                            controller: _emailController,
                            hint: "", // REMOVED PRE-DEFINED SHADE/HINT
                            icon: Icons.alternate_email_rounded,
                            validator: Validators.email,
                            onChanged: (_) => setState(() => _unauthorizedError = null),
                          ),
                          SizedBox(height: 2.5.h),
                          _buildLabel("Secure Password"),
                          _buildThemedTextField(
                            controller: _passwordController,
                            hint: "", // REMOVED HINT
                            icon: Icons.lock_outline_rounded,
                            isPassword: true,
                            validator: Validators.password,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => context.goNamed('forgotPassword'),
                              child: Text(
                                "Recovery access?",
                                style: GoogleFonts.poppins(
                                  color: Colors.white38,
                                  fontSize: 13.sp,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 2.h),
                          _buildLoginButton(),
                        ],
                      ),
                    ),

                    _buildErrorDisplay(),

                    SizedBox(height: 5.h),
                    Text(
                      "Authorized Personnel Only",
                      style: GoogleFonts.poppins(
                        color: Colors.white24,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
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
    bool isPassword = false,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      validator: validator,
      onChanged: onChanged,
      style: GoogleFonts.poppins(color: Colors.white, fontSize: 14.5.sp),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: Colors.white10),
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

  Widget _buildLoginButton() {
    return Consumer(
      builder: (context, ref, child) {
        final signInState = ref.watch(authViewModelProvider);

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: signInState.isEmailLoading
                ? null
                : () async {
              if (_formkey.currentState!.validate()) {
                final inputEmail = _emailController.text.trim();

                // --- LOGIC PRESERVED: THE WALL CHECK ---
                if (inputEmail != _authorizedAdminEmail) {
                  setState(() {
                    _unauthorizedError = "ACCESS DENIED: Account not authorized for Admin Panel.";
                  });
                  return;
                }

                await ref.read(authViewModelProvider.notifier).signInUser(
                  inputEmail,
                  _passwordController.text.trim(),
                  onSuccess: () {
                    context.goNamed("bottomNavChild");
                  },
                );
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
                child: signInState.isEmailLoading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                )
                    : Text(
                  "LOGIN TO PORTAL",
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

  Widget _buildErrorDisplay() {
    return Consumer(
      builder: (context, ref, child) {
        final signInState = ref.watch(authViewModelProvider);
        final error = _unauthorizedError ?? signInState.emailError;

        if (error == null) return const SizedBox.shrink();

        return Padding(
          padding: EdgeInsets.only(top: 3.h),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.gpp_bad_rounded, color: Colors.redAccent, size: 20),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    error,
                    style: GoogleFonts.poppins(
                      color: Colors.redAccent,
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
