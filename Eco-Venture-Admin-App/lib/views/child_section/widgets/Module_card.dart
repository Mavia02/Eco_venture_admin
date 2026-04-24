import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../core/constants/app_colors.dart';


class ModuleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Color> gradientColors;

  const ModuleCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 1.5.w, vertical: 1.h),
      child: Container(
        height: 20.h,
        width: 80.w,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.5, 1.0],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 2.w, top: 2.h),
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 19.sp,
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 2.w, top: 0.5.h),
              child: Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  color: AppColors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
