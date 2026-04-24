import 'dart:ui';
import 'package:eco_venture_admin_portal/views/child_section/admin_child_home.dart';
import 'package:eco_venture_admin_portal/views/child_section/report_safety/admin_safety_report_screen.dart';
import 'package:eco_venture_admin_portal/views/settings/admin_settings.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class BottomNavChild extends StatefulWidget {
  const BottomNavChild({super.key});

  @override
  State<BottomNavChild> createState() => _BottomNavChildState();
}

class _BottomNavChildState extends State<BottomNavChild>
    with TickerProviderStateMixin {
  int _currentIndex = 0;

  final _screens = [
    const AdminChildHome(),
    const AdminSafetyReportScreen(),
    const AdminSettings(),
  ];

  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Logic: Retained original navigation and animation logic
  void _onItemTapped(int index) {
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      // Logic: Background color remains consistent with the "DNA" of our gradient screens
      backgroundColor: const Color(0xFF0A3431),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _screens,
      ),
      bottomNavigationBar: _buildSophisticatedBottomBar(),
    );
  }

  Widget _buildSophisticatedBottomBar() {
    return Padding(
      padding: EdgeInsets.only(left: 5.w, right: 5.w, bottom: 3.h),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.2.h),
            decoration: BoxDecoration(
              // Logic: Darker Teal background with higher opacity for better visibility
              color: const Color(0xFF0A2523).withOpacity(0.85),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withOpacity(0.12),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.dashboard_rounded, "Home", 0),
                _buildNavItem(Icons.report_problem_rounded, "Report", 1),
                _buildNavItem(Icons.manage_accounts_rounded, "Settings", 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool isActive = _currentIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutQuint,
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 0.8.h),
        decoration: BoxDecoration(
          // Logic: Amber glow background for the active item pill
          color: isActive
              ? Colors.amberAccent.withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              duration: const Duration(milliseconds: 300),
              scale: isActive ? 1.2 : 1.0,
              child: Icon(
                icon,
                size: 20.sp,
                // Logic: Dominant Amber color for active icons
                color: isActive
                    ? Colors.amberAccent
                    : Colors.white.withOpacity(0.4),
              ),
            ),
            SizedBox(height: 0.5.h),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: GoogleFonts.poppins( // Switched to Poppins for DNA consistency
                color: isActive
                    ? Colors.amberAccent
                    : Colors.white.withOpacity(0.4),
                fontSize: 12.sp,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: 0.5,
              ),
              child: Text(label),
            ),
            // Logic: Tiny active indicator dot below the label
            AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: isActive ? 1.0 : 0.0,
              child: Container(
                margin: EdgeInsets.only(top: 0.5.h),
                height: 4,
                width: 4,
                decoration: const BoxDecoration(
                  color: Colors.amberAccent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
