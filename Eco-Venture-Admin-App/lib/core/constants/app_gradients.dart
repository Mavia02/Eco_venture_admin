import 'package:flutter/material.dart';

class AppGradients {
  static LinearGradient backgroundGradient= LinearGradient( //backGround Color
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF003366).withValues(alpha: 0.8), Color(0xFF87CEEB)],
    stops: [0.1, 1.0],
  );

  static LinearGradient buttonGradient=LinearGradient(
    colors: [
      Color(0xFF1565C0), // Medium Blue
      Color(0xFF1DE9B6), // Aqua Green
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
