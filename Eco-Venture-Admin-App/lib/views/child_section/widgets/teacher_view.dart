import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:eco_venture_admin_portal/viewmodels/child_section/teacher_view/teacher_view_view_model.dart';

class TeacherManagementScreen extends ConsumerWidget {
  const TeacherManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teachersAsync = ref.watch(teachersStreamProvider);

    return Scaffold(
      // Logic: Removed background color here to use the gradient container for full-screen coverage
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2F5755), Color(0xFF0A3431)], // Logic: Matches AdminChildHome DNA
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: teachersAsync.when(
                  data: (teachers) => teachers.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                    itemCount: teachers.length,
                    itemBuilder: (context, index) {
                      final teacher = teachers[index];
                      return _buildTeacherCard(context, ref, teacher);
                    },
                  ),
                  loading: () => const Center(child: CircularProgressIndicator(color: Colors.amberAccent)),
                  error: (e, _) => Center(child: Text("Error: $e", style: const TextStyle(color: Colors.white))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          SizedBox(width: 2.w),
          Text(
            "Teacher Directory",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 19.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text("No registered teachers found.",
          style: GoogleFonts.poppins(color: Colors.white54, fontSize: 16.sp)),
    );
  }

  Widget _buildTeacherCard(BuildContext context, WidgetRef ref, Map<String, dynamic> teacher) {
    // Logic: Now uses the robust isApproved check from the repository
    final isApproved = teacher['isApproved'] ?? false;
    final String id = teacher['id'];

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(2.2.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.amberAccent.withOpacity(0.1),
            child: Text(
              teacher['name'] != null && teacher['name'].isNotEmpty ? teacher['name'][0].toUpperCase() : '?',
              style: GoogleFonts.poppins(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 17.sp),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  teacher['name'] ?? 'Unknown Teacher',
                  style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.sp),
                ),
                Text(
                  teacher['email'] ?? 'No email provided',
                  style: GoogleFonts.poppins(color: Colors.white38, fontSize: 13.sp),
                ),
                SizedBox(height: 1.2.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.6.h),
                  decoration: BoxDecoration(
                    // Logic: Green for authorized, Orange for pending
                    color: isApproved ? Colors.greenAccent.withOpacity(0.1) : Colors.orangeAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    isApproved ? "AUTHORIZED TEACHER" : "PENDING APPROVAL",
                    style: GoogleFonts.poppins(
                      color: isApproved ? Colors.greenAccent : Colors.orangeAccent,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 26),
            onPressed: () => _showDeleteDialog(context, ref, id, teacher['name'] ?? 'this teacher'),
          )
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, String id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2F5755),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text("Revoke Access?", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text("This will permanently delete $name and all their data from Eco Venture.",
            style: GoogleFonts.poppins(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: GoogleFonts.poppins(color: Colors.white38)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              ref.read(teacherActionProvider.notifier).rejectAndRemove(id);
              Navigator.pop(context);
            },
            child: Text("Nuclear Wipe", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}