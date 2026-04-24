import 'package:animate_do/animate_do.dart';
import 'package:eco_venture_admin_portal/repositories/admin_firestore_repo.dart';
import 'package:eco_venture_admin_portal/services/shared_preferences_helper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final TextEditingController _nameController = TextEditingController();

  void _handleNavigation(BuildContext context, VoidCallback onNavigate)async {
    if (_nameController.text.trim().isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
              const SizedBox(width: 10),
              Text(
                "Missing Name",
                style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          content: Text(
            "Please enter your name before navigating to the next screen.",
            style: GoogleFonts.poppins(fontSize: 15),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFF2F5755),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: Text(
                "OK",
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    } else {
      await SharedPreferencesHelper.instance.saveAdminName(_nameController.text);
      final aid=await SharedPreferencesHelper.instance.getAdminId();
      if(aid==null)return ;
      await AdminFirestoreRepo.instance.updateAdminName(aid, _nameController.text);
      onNavigate();
    }
  }








  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          body: Column(
            children: [
              // ================== HEADER ==================
              Stack(
                children: [
                  Container(
                    height: 32.h,
                    width: 100.w,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF2F5755),
                          Color(0xFF1A2A6C),
                          Color(0xFF000428),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  ClipPath(
                    clipper: WaveClipper(),
                    child: Container(
                      height: 34.h,
                      width: 100.w,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF4F00BC),
                            Color(0xFF2D0C57),
                            Color(0xFF1A0A3A),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FadeInDown(
                          duration: const Duration(milliseconds: 700),
                          child: Container(
                            padding: EdgeInsets.all(2.5.h),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.public_rounded,
                              size: 7.h,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: 1.5.h),
                        FadeInUp(
                          duration: const Duration(milliseconds: 800),
                          child: Text(
                            "EcoVenture Admin Portal",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 21.sp,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        FadeInUp(
                          duration: const Duration(milliseconds: 900),
                          child: Text(
                            "Empowering your eco-learning experience 🌍",
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // ================== NAME FIELD ==================
              // ================== NAME FIELD ==================
              FadeInUp(
                duration: const Duration(milliseconds: 900),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2.h),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _nameController,
                      cursorColor: const Color(0xFF2F5755),
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF1E1E2F),
                      ),
                      decoration: InputDecoration(
                        hintText: "Enter your name",
                        hintStyle: GoogleFonts.poppins(
                          color: Colors.grey[500], fontSize: 16.sp,
                        ),
                        prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF2F5755)),
                        suffixIcon:
                        const Icon(Icons.check_circle_outline, color: Color(0xFF2F5755)),
                        contentPadding: EdgeInsets.symmetric(vertical: 2.h),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(2.h),
                          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(2.h),
                          borderSide: const BorderSide(
                            color: Color(0xFF2F5755),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: FadeInUp(
                  duration: const Duration(milliseconds: 900),
                  child: Padding(
                    padding:
                    EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        RoleCard(
                          icon: Icons.child_care_rounded,
                          title: "Child",
                          subtitle: "Manage child accounts",
                          onTap: () => _handleNavigation(
                              context, () => context.goNamed("bottomNavChild")),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFB24592), Color(0xFFF15F79)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        SizedBox(height: 2.5.h),
                        RoleCard(
                          icon: Icons.escalator_warning_rounded,
                          title: "Parent",
                          subtitle: "Manage parent accounts",
                          onTap: () => _handleNavigation(context, () {}),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF36D1DC), Color(0xFF5B86E5)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        SizedBox(height: 2.5.h),
                        RoleCard(
                          icon: Icons.school_rounded,
                          title: "Teacher",
                          subtitle: "Manage teacher accounts",
                          onTap: () => _handleNavigation(context, () {}),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ================== FOOTER ==================
              FadeIn(
                duration: const Duration(milliseconds: 700),
                child: Padding(
                  padding: EdgeInsets.only(bottom: 2.h),
                  child: Text(
                    "© 2025 EcoVenture | All rights reserved",
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class RoleCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Gradient gradient;

  const RoleCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    required this.gradient,
  });

  @override
  State<RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<RoleCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapCancel: () => setState(() => _isPressed = false),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap?.call();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..scale(_isPressed ? 0.97 : 1.0),
        padding: EdgeInsets.all(3.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2.h),
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.85),
              Colors.white.withOpacity(0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_isPressed ? 0.05 : 0.15),
              blurRadius: _isPressed ? 4 : 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(1.8.h),
              decoration: BoxDecoration(
                gradient: widget.gradient,
                borderRadius: BorderRadius.circular(1.8.h),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                widget.icon,
                size: 5.h,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 4.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: GoogleFonts.poppins(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E1E2F),
                  ),
                ),
                SizedBox(height: 0.6.h),
                Text(
                  widget.subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 60);

    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2, size.height - 60);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    var secondControlPoint = Offset(3 * size.width / 4, size.height - 120);
    var secondEndPoint = Offset(size.width, size.height - 60);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
