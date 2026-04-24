import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:eco_venture_admin_portal/services/shared_preferences_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../viewmodels/auth/auth_provider.dart';
import '../../core/utils/utils.dart';

class AdminSettings extends StatefulWidget {
  const AdminSettings({super.key});

  @override
  State<AdminSettings> createState() => _AdminSettingsState();
}

class _AdminSettingsState extends State<AdminSettings>
    with TickerProviderStateMixin {
  late AnimationController _profileImageController;
  late Animation<double> _profileImagePulse;
  String username = "Guest";
  String userImageUrl = "";

  Future<void> _loadUsername() async {
    final name = await SharedPreferencesHelper.instance.getAdminEmail();
    final image = await SharedPreferencesHelper.instance.getAdminImgUrl();
    setState(() {
      username = name ?? "Guest";
      userImageUrl = image ?? "";
    });
  }

  @override
  void initState() {
    super.initState();

    _profileImageController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _profileImagePulse = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _profileImageController, curve: Curves.easeInOut),
    );

    _profileImageController.repeat(reverse: true);
    _loadUsername();
  }

  @override
  void dispose() {
    _profileImageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2F5755), Color(0xFF0A3431)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 5.w),
                  child: Column(
                    children: [
                      _buildProfileCard(),
                      SizedBox(height: 4.h),
                      _buildSettingsSection(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Account Settings",
            style: GoogleFonts.poppins(
              fontSize: 21.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          Container(
            padding: EdgeInsets.all(1.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.settings_outlined, color: Colors.amberAccent),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          ScaleTransition(
            scale: _profileImagePulse,
            child: Container(
              padding: EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.amberAccent.withOpacity(0.5), width: 2),
              ),
              child: CircleAvatar(
                radius: 7.5.h,
                backgroundColor: Colors.white.withOpacity(0.1),
                backgroundImage: userImageUrl.isNotEmpty ? NetworkImage(userImageUrl) : null,
                child: userImageUrl.isEmpty
                    ? Icon(Icons.person_rounded, size: 10.w, color: Colors.amberAccent)
                    : null,
              ),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            username,
            style: GoogleFonts.poppins(
              fontSize: 17.sp,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            "System Administrator",
            style: GoogleFonts.poppins(
              fontSize: 13.sp,
              color: Colors.white38,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      children: [
        _buildThemedTile(
          title: "Profile Information",
          subtitle: "Manage your personal details",
          icon: Icons.person_outline_rounded,
          accentColor: Colors.blueAccent,
          onTap: () => context.goNamed('adminProfile'),
        ),
        _buildThemedTile(
          title: "App Theme",
          subtitle: "Switch to light mode",
          icon: Icons.dark_mode_outlined,
          accentColor: Colors.amberAccent,
          trailing: Switch(
            value: true,
            activeColor: Colors.amberAccent,
            onChanged: (val) {},
          ),
        ),
        _buildThemedTile(
          title: "About Company",
          subtitle: "Learn more about our mission",
          icon: Icons.business_outlined,
          accentColor: Colors.purpleAccent,
          onTap: () {},
        ),
        _buildThemedTile(
          title: "Support Center",
          subtitle: "Get help or report an issue",
          icon: Icons.support_agent_rounded,
          accentColor: Colors.orangeAccent,
          onTap: () {},
        ),
        Consumer(
          builder: (context, ref, child) {
            final authVM = ref.read(authViewModelProvider.notifier);
            return _buildThemedTile(
              title: "Logout",
              subtitle: "Sign out of your session",
              icon: Icons.logout_rounded,
              accentColor: Colors.redAccent,
              onTap: () async {
                final confirmed = await _showStyledConfirmDialog();
                if (confirmed == true) {
                  await authVM.signOut();
                  Utils.showDelightToast(
                    context,
                    "User successfully logged out",
                    duration: const Duration(seconds: 3),
                    textColor: Colors.black,
                    bgColor: Colors.amberAccent,
                    position: DelightSnackbarPosition.bottom,
                    icon: Icons.check_circle_rounded,
                    iconColor: Colors.black,
                  );
                  context.goNamed('login');
                }
              },
            );
          },
        ),
        SizedBox(height: 5.h),
      ],
    );
  }

  Widget _buildThemedTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Ink(
            padding: EdgeInsets.all(2.2.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(1.2.h),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(icon, color: accentColor, size: 22),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 15.5.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          color: Colors.white38,
                          fontSize: 12.5.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                trailing ?? Icon(Icons.arrow_forward_ios_rounded, color: Colors.white12, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _showStyledConfirmDialog() {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1B3D3A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          "Confirm Logout",
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        content: Text(
          "Are you sure you want to end your current session?",
          style: GoogleFonts.poppins(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text("CANCEL", style: GoogleFonts.poppins(color: Colors.white38, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amberAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              "LOGOUT",
              style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}
