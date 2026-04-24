import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
class ProfileInfoTile extends StatelessWidget {
  final String? title;
  final String? secondTitle;
  final Color? rectangleColor;
  final IconData icon;
  final Color iconColor;

  const ProfileInfoTile({
    super.key, this.title,required this.iconColor, this.secondTitle, this.rectangleColor, required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 6.h,
          width: 14.w,
          decoration: BoxDecoration(
            color: rectangleColor ??Colors.blueGrey.shade100,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Icon(icon, color: iconColor, size: 8.w),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 2.w),
                child: Text(
                  title??"",
                  style: GoogleFonts.poppins(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),),
              ),
              Padding(
                padding: EdgeInsets.only(left: 2.w),
                child: Text(
                  secondTitle?? "",
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}