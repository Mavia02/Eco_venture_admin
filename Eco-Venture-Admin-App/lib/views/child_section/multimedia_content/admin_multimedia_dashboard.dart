import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:go_router/go_router.dart';

class AdminMultimediaDashboard extends StatelessWidget {
  const AdminMultimediaDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final Color bg = const Color(0xFFF4F7FE);
    final Color textDark = const Color(0xFF1B2559);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textDark, size: 20.sp),
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        title: Text(
          "Multimedia Manager",
          style: GoogleFonts.poppins(color: textDark, fontWeight: FontWeight.w700, fontSize: 18.sp),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(5.w),
        child: Column(
          children: [
            SizedBox(height: 2.h),
            _buildMenuCard(
              context,
              "Manage Videos",
              "Upload global educational videos",
              Icons.video_library_rounded,
              const [Color(0xFFFF512F), Color(0xFFDD2476)], // Red/Pink
                  () => context.pushNamed('adminVideoDashboard'),
            ),
            SizedBox(height: 3.h),
            _buildMenuCard(
              context,
              "Manage Stories",
              "Create interactive storybooks",
              Icons.menu_book_rounded,
              const [Color(0xFF8E2DE2), Color(0xFF4A00E0)], // Purple
                  () => context.pushNamed('adminStoryDashboard'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, String subtitle, IconData icon, List<Color> gradient, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 25.h,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: gradient[0].withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8)),
          ],
        ),
        child: Stack(
          children: [
            Positioned(top: -30, right: -30, child: Container(width: 150, height: 150, decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle))),
            Padding(
              padding: EdgeInsets.all(6.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
                    child: Icon(icon, color: Colors.white, size: 28.sp),
                  ),
                  SizedBox(height: 2.h),
                  Text(title, style: GoogleFonts.poppins(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                  SizedBox(height: 0.5.h),
                  Text(subtitle, style: GoogleFonts.poppins(fontSize: 14.5.sp, color: Colors.white.withOpacity(0.9))),
                ],
              ),
            ),
            Positioned(
              right: 5.w, bottom: 5.w,
              child: Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 24.sp),
            )
          ],
        ),
      ),
    );
  }
}