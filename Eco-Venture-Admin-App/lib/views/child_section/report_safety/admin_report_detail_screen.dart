import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:go_router/go_router.dart';
import '../../../models/report_model.dart';

// Logic: Preserving your existing mock provider
final safetyReportProvider = StateNotifierProvider<SafetyReportNotifier, List<ReportModel>>((ref) {
  return SafetyReportNotifier();
});

class SafetyReportNotifier extends StateNotifier<List<ReportModel>> {
  SafetyReportNotifier() : super([]);

  void resolveReport(String id) {
    debugPrint("Mock: Report $id resolved locally.");
  }
}

class AdminReportDetailScreen extends ConsumerWidget {
  final ReportModel report;

  const AdminReportDetailScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 5.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- REPORT SUMMARY PANEL ---
                      Container(
                        padding: EdgeInsets.all(2.5.h),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withOpacity(0.12)),
                        ),
                        child: Column(
                          children: [
                            _buildInfoRow("Reporter", report.reporterName, Icons.person_outline_rounded),
                            _buildDivider(),
                            _buildInfoRow("Source", report.source, Icons.category_outlined),
                            _buildDivider(),
                            _buildInfoRow("Issue Type", report.issueType, Icons.warning_amber_rounded),
                            _buildDivider(),
                            _buildInfoRow("Occurred At", report.timestamp.toString().substring(0, 16), Icons.access_time_rounded),
                          ],
                        ),
                      ),
                      SizedBox(height: 4.h),

                      // --- MESSAGE SECTION ---
                      Text(
                        "Incident Details",
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 1.5.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(2.5.h),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.08)),
                        ),
                        child: Text(
                          report.details,
                          style: GoogleFonts.poppins(
                            fontSize: 14.5.sp,
                            height: 1.6,
                            color: Colors.white.withOpacity(0.85),
                          ),
                        ),
                      ),
                      SizedBox(height: 6.h),

                      // --- ACTION BUTTONS ---
                      if (!report.isResolved) ...[
                        _buildActionButton(
                          label: "Suspend User Account",
                          icon: Icons.block_flipped,
                          color: Colors.redAccent,
                          onPressed: () => _showSuspendDialog(context, report.reporterName),
                        ),
                        SizedBox(height: 2.h),
                        _buildActionButton(
                          label: "Mark as Resolved",
                          icon: Icons.check_circle_rounded,
                          color: Colors.amberAccent,
                          isPrimary: true, // Uses Black text like Home Add button
                          onPressed: () {
                            ref.read(safetyReportProvider.notifier).resolveReport(report.id);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text("Report Resolved & Users Notified"),
                              backgroundColor: Colors.green,
                            ));
                            context.pop();
                          },
                        ),
                      ] else
                        _buildResolvedBadge(),

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
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          ),
          SizedBox(width: 2.w),
          Text(
            "Report Details",
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

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(1.2.h),
            decoration: BoxDecoration(
              color: Colors.amberAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.amberAccent, size: 20),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.white38, fontWeight: FontWeight.w500),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(fontSize: 15.sp, color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDivider() => Padding(
    padding: EdgeInsets.symmetric(vertical: 1.5.h),
    child: Divider(color: Colors.white.withOpacity(0.08), height: 1),
  );

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    bool isPrimary = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 7.h,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20, color: isPrimary ? Colors.black : Colors.white),
        label: Text(
          label,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w800,
            fontSize: 15.sp,
            color: isPrimary ? Colors.black : Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: isPrimary ? 4 : 0,
          shadowColor: Colors.black45,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
      ),
    );
  }

  Widget _buildResolvedBadge() {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
        decoration: BoxDecoration(
          color: Colors.greenAccent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.verified_rounded, color: Colors.greenAccent),
            SizedBox(width: 3.w),
            Text(
              "This incident is resolved",
              style: GoogleFonts.poppins(
                color: Colors.greenAccent,
                fontWeight: FontWeight.w700,
                fontSize: 14.5.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuspendDialog(BuildContext context, String userName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1B3D3A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Confirm Suspension",
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Are you sure you want to suspend $userName? Access will be revoked immediately.",
          style: GoogleFonts.poppins(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Cancel", style: GoogleFonts.poppins(color: Colors.white38)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("User account has been suspended"),
                backgroundColor: Colors.red,
              ));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              "Suspend",
              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }
}