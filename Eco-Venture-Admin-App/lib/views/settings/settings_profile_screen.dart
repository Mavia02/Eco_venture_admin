import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:eco_venture_admin_portal/viewmodels/auth/auth_provider.dart';
import 'package:eco_venture_admin_portal/views/settings/widgets/profile_info_tile.dart';
import 'package:eco_venture_admin_portal/views/settings/widgets/settings_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../core/utils/utils.dart';
import '../../services/shared_preferences_helper.dart';

class SettingsProfileScreen extends ConsumerStatefulWidget {
  const SettingsProfileScreen({super.key});

  @override
  ConsumerState<SettingsProfileScreen> createState() => _SettingsProfileScreenState();
}

class _SettingsProfileScreenState extends ConsumerState<SettingsProfileScreen> with TickerProviderStateMixin {
  String username = "Guest";
  String userEmail = "";
  String userImageUrl = "";

  late AnimationController _profilePulseController;
  late Animation<double> _profilePulse;

  @override
  void initState() {
    super.initState();

    // Logic: Profile Image Pulse Animation consistent with Settings & Edit screens
    _profilePulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _profilePulse = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _profilePulseController, curve: Curves.easeInOut),
    );

    _loadSharedPreferences();
  }

  @override
  void dispose() {
    _profilePulseController.dispose();
    super.dispose();
  }

  Future<void> _loadSharedPreferences() async {
    final name = await SharedPreferencesHelper.instance.getAdminName();
    final email = await SharedPreferencesHelper.instance.getAdminEmail();
    final image = await SharedPreferencesHelper.instance.getAdminImgUrl();

    if (!mounted) return;
    setState(() {
      username = name ?? "Guest";
      userEmail = email ?? "";
      userImageUrl = image ?? "";
    });
  }

  Future<void> _handleDeleteAccount() async {
    final confirmed = await _showStyledDeleteConfirmDialog();

    if (confirmed != true) return;

    final uid = await SharedPreferencesHelper.instance.getAdminId();
    if (uid == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No user id found.")),
        );
      }
      return;
    }

    try {
      await ref.read(authViewModelProvider.notifier).deleteAdminAccount();

      if (!mounted) return;
      Utils.showDelightToast(
        context,
        "Account Deleted Successfully",
        duration: const Duration(seconds: 3),
        textColor: Colors.white,
        bgColor: Colors.redAccent,
        position: DelightSnackbarPosition.bottom,
        icon: Icons.delete_forever_rounded,
        iconColor: Colors.white,
      );

      await SharedPreferencesHelper.instance.clearAll();

      if (mounted) context.goNamed('login');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to delete account: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
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
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 5.w),
                  child: Column(
                    children: [
                      _buildProfileBanner(),
                      SizedBox(height: 3.h),
                      _buildPersonalInfoCard(),
                      SizedBox(height: 3.h),
                      _buildActionSection(),
                      SizedBox(height: 5.h),
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

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => context.goNamed('bottomNavChild'),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22),
          ),
          Text(
            "My Profile",
            style: GoogleFonts.poppins(
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: () async => await _loadSharedPreferences(),
            icon: const Icon(Icons.refresh_rounded, color: Colors.amberAccent, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileBanner() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 3.h),
      child: Column(
        children: [
          ScaleTransition(
            scale: _profilePulse,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.amberAccent.withOpacity(0.3), width: 2),
              ),
              child: CircleAvatar(
                radius: 8.h,
                backgroundColor: Colors.white.withOpacity(0.1),
                backgroundImage: userImageUrl.isNotEmpty ? NetworkImage(userImageUrl) : null,
                child: userImageUrl.isEmpty
                    ? Icon(Icons.person_rounded, size: 20.w, color: Colors.amberAccent)
                    : null,
              ),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            username,
            style: GoogleFonts.poppins(
              fontSize: 18.sp,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            userEmail,
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              color: Colors.white38,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoCard() {
    return Container(
      padding: EdgeInsets.all(2.5.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(1.2.h),
                decoration: BoxDecoration(
                  color: Colors.amberAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.badge_outlined, color: Colors.amberAccent, size: 20),
              ),
              SizedBox(width: 4.w),
              Text(
                'Personal Information',
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          ProfileInfoTile(
            icon: Icons.email_outlined,
            iconColor: Colors.blueAccent,
            title: "Registered Email",
            secondTitle: userEmail,
            // Styling logic within ProfileInfoTile should be updated
            // externally or handled here if needed.
          ),
        ],
      ),
    );
  }

  Widget _buildActionSection() {
    return Column(
      children: [
        _buildThemedActionTile(
          title: "Edit Profile",
          subtitle: "Update your personal details",
          icon: Icons.edit_rounded,
          accentColor: Colors.blueAccent,
          onTap: () => context.goNamed('editProfile'),
        ),
        _buildThemedActionTile(
          title: "Delete Account",
          subtitle: "Permanently remove all data",
          icon: Icons.delete_forever_rounded,
          accentColor: Colors.redAccent,
          isDanger: true,
          onTap: _handleDeleteAccount,
        ),
      ],
    );
  }

  Widget _buildThemedActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required VoidCallback onTap,
    bool isDanger = false,
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
              border: Border.all(color: isDanger ? Colors.redAccent.withOpacity(0.1) : Colors.white.withOpacity(0.08)),
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
                          color: isDanger ? Colors.redAccent : Colors.white,
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
                Icon(Icons.arrow_forward_ios_rounded, color: Colors.white12, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _showStyledDeleteConfirmDialog() {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1B3D3A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          "Delete Account",
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        content: Text(
          "This action is irreversible. All your data will be permanently removed. Proceed with caution.",
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
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              "DELETE",
              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}
