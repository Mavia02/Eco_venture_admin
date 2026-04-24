import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:go_router/go_router.dart';
import '../../../viewmodels/child_section/report_safety/teacher_verification_provider.dart';

class AdminTeacherVerificationScreen extends ConsumerWidget {
  const AdminTeacherVerificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Logic: Watch the state and read the viewmodel for actions
    final state = ref.watch(teacherVerificationViewModelProvider);
    final viewModel = ref.read(teacherVerificationViewModelProvider.notifier);

    // Logic: Listen for errors to show snackbars
    ref.listen(teacherVerificationViewModelProvider, (prev, next) {
      if (next.errorMessage != null && next.errorMessage != prev?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!), backgroundColor: Colors.red),
        );
      }
    });

    return Scaffold(
      body: Container(
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
                child: Stack(
                  children: [
                    // --- MAIN CONTENT ---
                    if (state.pendingTeachers.isEmpty && !state.isLoading)
                      _buildEmptyState()
                    else
                      ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                        itemCount: state.pendingTeachers.length,
                        itemBuilder: (context, index) {
                          final teacher = state.pendingTeachers[index];
                          return _buildTeacherCard(context, teacher, viewModel, state.isLoading);
                        },
                      ),

                    // --- LOADING OVERLAY ---
                    if (state.isLoading)
                      Container(
                        color: Colors.black.withOpacity(0.4),
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.amberAccent),
                        ),
                      ),
                  ],
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
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          ),
          SizedBox(width: 2.w),
          Text(
            "Teacher Verification",
            style: GoogleFonts.poppins(
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeacherCard(BuildContext context, dynamic teacher, dynamic viewModel, bool isLoading) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.5.h),
      padding: EdgeInsets.all(2.5.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.amberAccent.withOpacity(0.1),
                child: Text(
                  teacher.name.isNotEmpty ? teacher.name[0].toUpperCase() : '?',
                  style: GoogleFonts.poppins(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.amberAccent,
                  ),
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      teacher.name,
                      style: GoogleFonts.poppins(
                        fontSize: 16.5.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      teacher.email,
                      style: GoogleFonts.poppins(
                        fontSize: 13.5.sp,
                        color: Colors.white38,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: Colors.orangeAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "PENDING APPROVAL",
                        style: GoogleFonts.poppins(
                          fontSize: 11.sp,
                          color: Colors.orangeAccent,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  label: "Reject",
                  color: Colors.redAccent.withOpacity(0.8),
                  onPressed: isLoading ? null : () => viewModel.rejectTeacher(teacher.id),
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: _buildActionButton(
                  label: "Approve Access",
                  color: Colors.amberAccent,
                  isPrimary: true,
                  onPressed: isLoading ? null : () => viewModel.approveTeacher(teacher.id),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color color,
    VoidCallback? onPressed,
    bool isPrimary = false,
  }) {
    return SizedBox(
      height: 6.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: isPrimary ? Colors.black : Colors.white,
          elevation: isPrimary ? 4 : 0,
          shadowColor: Colors.black45,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w800,
            fontSize: 14.sp,
            color: isPrimary ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(3.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.verified_user_rounded, size: 40.sp, color: Colors.amberAccent.withOpacity(0.5)),
          ),
          SizedBox(height: 2.h),
          Text(
            "All caught up!",
            style: GoogleFonts.poppins(fontSize: 17.sp, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          Text(
            "No pending teacher requests found.",
            style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.white38),
          ),
        ],
      ),
    );
  }
}