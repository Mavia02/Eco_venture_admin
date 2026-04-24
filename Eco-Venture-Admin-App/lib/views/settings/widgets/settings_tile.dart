import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
class SettingsTile extends StatelessWidget {
  final String title;
  final Color? titleColor;
  final String subtitle;
  final Color? subtitleColor;
  final Color circleColor;
  final IconData leadingIcon;
  final Color leadingIconColor;
  final Widget? trailing;
  final VoidCallback? onPressed; // 👈 added

  const SettingsTile({
    super.key,
    required this.circleColor,
    required this.title,
    required this.subtitle,
    required this.leadingIcon,
    this.titleColor,
    this.subtitleColor,
    this.leadingIconColor = Colors.blue,
    this.trailing,
    this.onPressed, // 👈 added
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 2.w, right: 2.w),
      child: Material(
        elevation: 10,
        borderRadius: BorderRadius.all(Radius.circular(20.sp)),
        child: InkWell( // 👈 makes it tappable
          borderRadius: BorderRadius.all(Radius.circular(20.sp)),
          onTap: onPressed, // 👈 trigger callback
          child: Container(
            height: 12.h,
            width: 100.w,
            decoration: BoxDecoration(
              color: Colors.white70,
              borderRadius: BorderRadius.all(Radius.circular(20.sp)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Leading circle
                Padding(
                  padding: EdgeInsets.only(top: 2.5.h, left: 6.w),
                  child: Container(
                    height: 7.h,
                    width: 16.w,
                    decoration: BoxDecoration(
                      color: circleColor,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Center(
                      child: Icon(
                        leadingIcon,
                        color: Colors.white,
                        size: 8.w,
                      ),
                    ),
                  ),
                ),

                // Title + Subtitle
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 2.5.h,
                      left: 6.w,
                      right: 3.w,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.poppins(
                            fontSize: 18.sp,
                            color: titleColor ?? Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          subtitle,
                          style: GoogleFonts.poppins(
                            fontSize: 15.sp,
                            color: subtitleColor ?? Colors.black.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w400,
                          ),
                          softWrap: true,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),

                // Trailing
                if (trailing != null)
                  Padding(
                    padding: EdgeInsets.only(right: 5.w, top: 3.5.h),
                    child: trailing!,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
