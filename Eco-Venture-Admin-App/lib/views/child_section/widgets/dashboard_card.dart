import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../core/constants/app_colors.dart';

class DashboardCard extends StatelessWidget {
  final String title;
  final Widget content; // flexible (text, circle, chart, etc.)
  final Color? bgColor;

  const DashboardCard({
    super.key,
    required this.title,
    required this.content,
    this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
        child: Container(
          height: 18.h,
          decoration: BoxDecoration(
            color: bgColor ?? AppColors.background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.all(2.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2E2E2E),
                  ),
                ),
                SizedBox(height: 1.h),
                content, // <-- flexible widget passed from outside
              ],
            ),
          ),
        ),
      ),
    );
  }
}
