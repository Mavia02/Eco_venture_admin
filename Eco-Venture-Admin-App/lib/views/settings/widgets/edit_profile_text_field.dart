import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
class EditProfileTextField extends StatelessWidget {
  final IconData icon;
  final String hintText;
  final Color fillColor;
  final Color iconBgColor;
  final Color iconColor;
  final Widget? trailing;
  final VoidCallback? onTap;
  final TextEditingController controller;
  final bool readOnly; // <--- NEW

  const EditProfileTextField({
    super.key,
    required this.icon,
    required this.controller,
    required this.hintText,
    this.fillColor = Colors.white70,
    this.iconBgColor = const Color(0xFFE0E0E0),
    this.iconColor = Colors.blue,
    this.trailing,
    this.onTap,
    this.readOnly = false, // <--- default false
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 2.4.w, right: 2.h),
      child: Material(
        elevation: 10,
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        child: TextField(
          controller: controller,
          onTap: onTap,
          cursorColor: Colors.blue,
          readOnly: readOnly || onTap != null, // <--- use both cases
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            hintText: hintText,
            hintStyle: GoogleFonts.poppins(
              fontSize: 16.sp,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor),
            ),
            suffixIcon: trailing,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Colors.white70, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
            filled: true,
            fillColor: fillColor,
          ),
        ),
      ),
    );
  }
}