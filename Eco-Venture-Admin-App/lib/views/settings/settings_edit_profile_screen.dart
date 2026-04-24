import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:eco_venture_admin_portal/views/settings/widgets/edit_profile_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/utils.dart';
import '../../services/shared_preferences_helper.dart';
import '../../viewmodels/admin_profile/admin_provider.dart';

class SettingsEditProfileScreen extends ConsumerStatefulWidget {
  const SettingsEditProfileScreen({super.key});

  @override
  ConsumerState<SettingsEditProfileScreen> createState() =>
      _SettingsEditProfileScreenState();
}

class _SettingsEditProfileScreenState
    extends ConsumerState<SettingsEditProfileScreen> with TickerProviderStateMixin {
  File? _image;
  final picker = ImagePicker();

  String username = "Guest";
  String userEmail = "";
  String profileImg = "";

  late AnimationController _profilePulseController;
  late Animation<double> _profilePulse;

  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Logic: Profile Image Pulse Animation consistent with Settings
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
    _firstnameController.dispose();
    _lastnameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // Logic: Load cached values preserved
  Future<void> _loadSharedPreferences() async {
    final name = await SharedPreferencesHelper.instance.getAdminName();
    final email = await SharedPreferencesHelper.instance.getAdminEmail();
    final img = await SharedPreferencesHelper.instance.getAdminImgUrl();

    setState(() {
      username = name ?? "Guest";
      userEmail = email ?? "";
      profileImg = img ?? "";

      final parts = username.split(" ");
      _firstnameController.text = parts.isNotEmpty ? parts.first : "";
      _lastnameController.text =
      parts.length > 1 ? parts.sublist(1).join(" ") : "";
      _emailController.text = userEmail;
    });
  }

  // Logic: Firestore Image Sync preserved
  Future<void> _syncImageFromFirestore() async {
    final aid = await SharedPreferencesHelper.instance.getAdminId();
    if (aid == null) return;

    try {
      final doc =
      await FirebaseFirestore.instance.collection('Admins').doc(aid).get();

      if (doc.exists && doc.data() != null) {
        final imgUrl = doc.data()!['imageUrl'] ?? '';
        if (imgUrl.isNotEmpty) {
          await SharedPreferencesHelper.instance.saveAdminImgUrl(imgUrl);
          setState(() {
            profileImg = imgUrl;
          });
        }
      }
    } catch (e) {
      debugPrint("Error syncing image: $e");
    }
  }

  Future<void> _refreshProfile() async {
    await _syncImageFromFirestore();
    await _loadSharedPreferences();
    Utils.showDelightToast(
      context,
      "Profile refreshed successfully",
      icon: Icons.check_circle_rounded,
      autoDismiss: true,
      position: DelightSnackbarPosition.bottom,
      bgColor: Colors.amberAccent,
      textColor: Colors.black,
      duration: const Duration(seconds: 3),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile == null) return;

    setState(() => _image = File(pickedFile.path));

    final aid = await SharedPreferencesHelper.instance.getAdminId();
    if (aid != null && _image != null) {
      await ref
          .read(adminProfileProviderNew.notifier)
          .uploadAndSaveProfileImage(aid: aid, imageFile: _image!);

      await _syncImageFromFirestore();
      await _loadSharedPreferences();
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1B3D3A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(3.h),
          height: 25.h,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Upload Profile Photo",
                style: GoogleFonts.poppins(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 3.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildPickerIcon(
                    icon: Icons.image_rounded,
                    label: "Gallery",
                    color: Colors.blueAccent,
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                  _buildPickerIcon(
                    icon: Icons.camera_alt_rounded,
                    label: "Camera",
                    color: Colors.greenAccent,
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPickerIcon({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(2.h),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Icon(icon, color: color, size: 24.sp),
          ),
          SizedBox(height: 1.h),
          Text(label, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13.sp)),
        ],
      ),
    );
  }

  Future<void> _saveProfile() async {
    final firstName = _firstnameController.text.trim();
    final lastName = _lastnameController.text.trim();
    final fullName = "$firstName $lastName".trim();
    final aid = await SharedPreferencesHelper.instance.getAdminId();
    if (aid == null) return;

    if (_image != null) {
      await ref
          .read(adminProfileProviderNew.notifier)
          .uploadAndSaveProfileImage(aid: aid, imageFile: _image!);
    }

    if (fullName != username) {
      await ref
          .read(adminProfileProviderNew.notifier)
          .uploadAndSaveProfileName(aid: aid, name: fullName);
    }

    await _syncImageFromFirestore();
    await _loadSharedPreferences();

    Utils.showDelightToast(
      context,
      "Profile updated successfully",
      icon: Icons.verified_rounded,
      autoDismiss: true,
      position: DelightSnackbarPosition.top,
      bgColor: Colors.amberAccent,
      textColor: Colors.black,
      duration: const Duration(seconds: 3),
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProfileProviderNew);
    final admin = adminState.adminProfile;
    final effectiveImgUrl = admin?.imgUrl.isNotEmpty == true
        ? admin!.imgUrl
        : profileImg;

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
                      _buildImageSection(effectiveImgUrl),
                      SizedBox(height: 5.h),
                      _buildFormSection(),
                      SizedBox(height: 6.h),
                      _buildSaveButton(adminState.isLoading),
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
            onPressed: () => context.goNamed('adminProfile'),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22),
          ),
          Text(
            "Edit Profile",
            style: GoogleFonts.poppins(
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: _refreshProfile,
            icon: const Icon(Icons.refresh_rounded, color: Colors.amberAccent, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(String effectiveImgUrl) {
    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
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
                radius: 10.h,
                backgroundColor: Colors.white.withOpacity(0.1),
                backgroundImage: _image != null
                    ? FileImage(_image!)
                    : (effectiveImgUrl.isNotEmpty ? NetworkImage(effectiveImgUrl) : null),
                child: (_image == null && effectiveImgUrl.isEmpty)
                    ? Text(
                  username.isNotEmpty ? username[0].toUpperCase() : "?",
                  style: GoogleFonts.poppins(fontSize: 32.sp, color: Colors.white, fontWeight: FontWeight.w800),
                )
                    : null,
              ),
            ),
          ),
          GestureDetector(
            onTap: _showImagePickerOptions,
            child: Container(
              padding: EdgeInsets.all(1.5.h),
              decoration: const BoxDecoration(
                color: Colors.amberAccent,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
              ),
              child: const Icon(Icons.edit_rounded, color: Colors.black, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection() {
    return Container(
      padding: EdgeInsets.all(3.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel("First Name"),
          EditProfileTextField(
            controller: _firstnameController,
            icon: Icons.person_outline_rounded,
            hintText: "Enter first name",
          ),
          SizedBox(height: 2.h),
          _buildLabel("Last Name"),
          EditProfileTextField(
            controller: _lastnameController,
            icon: Icons.person_outline_rounded,
            hintText: "Enter last name",
          ),
          SizedBox(height: 2.h),
          _buildLabel("Email Address (Locked)"),
          EditProfileTextField(
            controller: _emailController,
            icon: Icons.email_outlined,
            hintText: "Email",
            readOnly: true,
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(left: 1.w, bottom: 1.h),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: Colors.white38,
        ),
      ),
    );
  }

  Widget _buildSaveButton(bool isLoading) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : () async {
          await _saveProfile();
        },
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          height: 7.5.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.amberAccent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(color: Colors.black, strokeWidth: 3),
            )
                : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_outline_rounded, color: Colors.black, size: 22),
                SizedBox(width: 3.w),
                Text(
                  "SAVE CHANGES",
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
