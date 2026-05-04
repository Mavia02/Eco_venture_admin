import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:go_router/go_router.dart';
import 'package:eco_venture_admin_portal/models/report_model.dart';
import 'package:eco_venture_admin_portal/services/admin_report_service.dart';
import 'package:eco_venture_admin_portal/viewmodels/child_section/report_safety/teacher_verification_provider.dart';

// --- Logic: Provider definition for the Safety Reports ---
final safetyReportProvider = StateNotifierProvider<SafetyReportNotifier, List<ReportModel>>(
      (ref) => SafetyReportNotifier(),
);

// Logic: The updated Notifier that listens to Realtime Database via the Service
class SafetyReportNotifier extends StateNotifier<List<ReportModel>> {
  final AdminReportService _service = AdminReportService();

  SafetyReportNotifier() : super([]) {
    _service.getAllAdminReportsStream().listen((reports) {
      state = reports;
    });
  }

  // Logic: Resolution flow using the Service to update RTDB and notify backend
  Future<void> resolveReport(ReportModel report) async {
    try {
      await _service.resolveReportAction(
          report.id,
          report.source,
          reporterId: report.reporterId
      );
    } catch (e) {
      debugPrint("Error resolving report: $e");
    }
  }
}

class AdminSafetyReportScreen extends ConsumerStatefulWidget {
  const AdminSafetyReportScreen({super.key});
  @override
  ConsumerState<AdminSafetyReportScreen> createState() => _AdminSafetyReportScreenState();
}

class _AdminSafetyReportScreenState extends ConsumerState<AdminSafetyReportScreen> {
  final Color _bgStart = const Color(0xFF2F5755);
  final Color _bgEnd = const Color(0xFF0A3431);

  @override
  Widget build(BuildContext context) {
    final reports = ref.watch(safetyReportProvider);
    final pendingReportsCount = reports.where((r) => !r.isResolved).length;
    final teacherState = ref.watch(teacherVerificationViewModelProvider);
    final pendingTeacherCount = teacherState.pendingTeachers.length;
    final approvedTeacherCount = ref.watch(approvedTeacherCountProvider).valueOrNull ?? 0;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_bgStart, _bgEnd],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader("Safety Overview"),
                      SizedBox(height: 2.h),
                      Row(
                        children: [
                          Expanded(
                            child: _buildActionCard(
                              title: "Safety Reports",
                              count: "$pendingReportsCount",
                              icon: Icons.gpp_maybe_rounded,
                              color: Colors.orangeAccent,
                              onTap: () {},
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: _buildTeacherQueueCard(
                              pendingCount: pendingTeacherCount,
                              approvedCount: approvedTeacherCount,
                              onTap: () => context.pushNamed('adminTeacherVerificationScreen'),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      _buildReportsSection(reports),
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

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          ),
          Text(
            "Reports Command Center",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 19.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(fontSize: 17.sp, fontWeight: FontWeight.w700, color: Colors.white),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String count,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: EdgeInsets.all(2.2.h),
      height: 18.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white.withOpacity(0.06),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: EdgeInsets.all(0.8.h),
            decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 20.sp),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(count, style: GoogleFonts.poppins(fontSize: 22.sp, fontWeight: FontWeight.w800, color: Colors.white)),
              Text(title, style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.white70, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTeacherQueueCard({required int pendingCount, required int approvedCount, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(2.2.h),
        height: 18.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.white.withOpacity(0.06),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.all(0.8.h),
              decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.verified_user_rounded, color: Colors.blueAccent, size: 20),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text("$pendingCount", style: GoogleFonts.poppins(fontSize: 22.sp, fontWeight: FontWeight.w800, color: Colors.white)),
                    SizedBox(width: 2.w),
                    Text("Pending", style: GoogleFonts.poppins(fontSize: 11.sp, color: Colors.amberAccent, fontWeight: FontWeight.bold)),
                  ],
                ),
                Text("$approvedCount Active Teachers", style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.white60, fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportsSection(List<ReportModel> reports) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 4.w),
          decoration: const BoxDecoration(color: Colors.amberAccent, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: Row(
            children: [
              const Icon(Icons.history_toggle_off_rounded, color: Colors.black),
              SizedBox(width: 3.w),
              Text("Recent Safety Reports", style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.w800, color: Colors.black)),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: reports.length,
            separatorBuilder: (context, index) => Divider(color: Colors.white.withOpacity(0.05), height: 1),
            itemBuilder: (context, index) {
              final report = reports[index];
              return ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                leading: CircleAvatar(
                  backgroundColor: report.severity == "High" ? Colors.redAccent.withOpacity(0.2) : Colors.orangeAccent.withOpacity(0.2),
                  child: Icon(Icons.warning_amber_rounded, color: report.severity == "High" ? Colors.redAccent : Colors.orangeAccent, size: 20),
                ),
                title: Text(report.reporterName, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15.sp)),
                subtitle: Text("${report.issueType} • Source: ${report.source}", style: GoogleFonts.poppins(color: Colors.white54, fontSize: 13.sp)),
                trailing: report.isResolved
                    ? const Icon(Icons.check_circle, color: Colors.greenAccent, size: 20)
                    : const Icon(Icons.chevron_right_rounded, color: Colors.white24),
                onTap: () => context.pushNamed('adminReportDetailScreen', extra: report),
              );
            },
          ),
        ),
      ],
    );
  }
}
