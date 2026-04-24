import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class Utils {
  /// Show DelightToastBar anywhere in the app
  static void showDelightToast(
      BuildContext context,
      String message, {
        IconData icon = Icons.info,
        Color textColor=Colors.black,
        Color iconColor = Colors.white,
        Color bgColor = Colors.black87,
        DelightSnackbarPosition position = DelightSnackbarPosition.top,
        bool autoDismiss = true,
        Duration duration = Durations.extralong4,
      }) {
    DelightToastBar(
      builder: (ctx) => ToastCard(
        color: bgColor,
        leading: Icon(icon, color: iconColor),
        title: Text(
          message,
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
      position: position,
      autoDismiss: autoDismiss,
      snackbarDuration: duration,
    ).show(context);
  }
}
