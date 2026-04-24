import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:go_router/go_router.dart';
import 'package:eco_venture_admin_portal/viewmodels/child_section/active_challenges/active_challenge_provider.dart';
import 'package:eco_venture_admin_portal/models/active_challenge_model.dart';

class ActiveChallengesDetailsView extends ConsumerStatefulWidget {
  const ActiveChallengesDetailsView({super.key});

  @override
  ConsumerState<ActiveChallengesDetailsView> createState() => _ActiveChallengesDetailsViewState();
}

class _ActiveChallengesDetailsViewState extends ConsumerState<ActiveChallengesDetailsView> {

  @override
  void initState() {
    super.initState();
    // Refresh the active challenges data when entering the view
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(activeChallengeProvider.notifier).fetchActiveStats();
    });
  }

  /// Logic: Helper to format time without requiring the 'intl' package dependency.
  /// Formats DateTime to a readable 12-hour format (e.g., 4:41 PM).
  String _formatTime(DateTime dateTime) {
    int hour = dateTime.hour;
    String period = hour >= 12 ? 'PM' : 'AM';

    // Convert to 12-hour format
    if (hour > 12) hour -= 12;
    if (hour == 0) hour = 12;

    String minute = dateTime.minute.toString().padLeft(2, '0');
    return "$hour:$minute $period";
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(activeChallengeProvider);

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
              _buildSummaryBanner(state),
              Expanded(
                child: state.isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.amberAccent))
                    : state.error != null
                    ? _buildErrorState(state.error!)
                    : _buildChallengesList(state.activeChallenges),
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
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          ),
          SizedBox(width: 2.w),
          Text(
            "Active Challenges",
            style: GoogleFonts.poppins(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBanner(dynamic state) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(2.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem("Total Active", state.totalActiveCount.toString()),
          _buildVerticalDivider(),
          _buildStatItem("In Progress", state.activeChallenges.length.toString()),
          _buildVerticalDivider(),
          _buildStatItem("Categories", "4"), // Quizzes, QR, Multimedia, STEM
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String val) {
    return Column(
      children: [
        Text(
          val,
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.amberAccent,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.white60),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() => Container(width: 1, height: 4.h, color: Colors.white10);

  Widget _buildChallengesList(List<ActiveChallengeModel> challenges) {
    if (challenges.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_turned_in_outlined, color: Colors.white24, size: 40.sp),
            SizedBox(height: 2.h),
            Text(
              "No active challenges right now",
              style: GoogleFonts.poppins(color: Colors.white38, fontSize: 16.sp),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      itemCount: challenges.length,
      itemBuilder: (context, index) {
        final challenge = challenges[index];
        return Container(
          margin: EdgeInsets.only(bottom: 2.h),
          padding: EdgeInsets.all(2.h),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  _buildStatusIcon(challenge.category),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          challenge.userName,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                          ),
                        ),
                        Text(
                          "${challenge.challengeTitle} • ${challenge.category}",
                          style: GoogleFonts.poppins(
                            color: Colors.amberAccent,
                            fontWeight: FontWeight.w500,
                            fontSize: 13.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: Colors.amberAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      challenge.status,
                      style: GoogleFonts.poppins(
                        color: Colors.amberAccent,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.access_time_filled, color: Colors.white38, size: 14),
                      SizedBox(width: 1.5.w),
                      Text(
                        "Last: ${_formatTime(challenge.lastActivity)}",
                        style: GoogleFonts.poppins(color: Colors.white38, fontSize: 12.sp),
                      ),
                    ],
                  ),
                  Text(
                    "${challenge.progressPercent.toInt()}%",
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: challenge.progressPercent / 100,
                  backgroundColor: Colors.white10,
                  color: Colors.amberAccent,
                  minHeight: 6,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusIcon(String category) {
    IconData icon;
    Color color;

    if (category.contains("Quiz")) {
      icon = Icons.quiz_rounded;
      color = Colors.greenAccent;
    } else if (category.contains("STEM")) {
      icon = Icons.science_rounded;
      color = Colors.pinkAccent;
    } else if (category.contains("QR")) {
      icon = Icons.qr_code_2_rounded;
      color = Colors.orangeAccent;
    } else {
      icon = Icons.play_circle_fill_rounded;
      color = Colors.blueAccent;
    }

    return Container(
      padding: EdgeInsets.all(1.2.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
          SizedBox(height: 2.h),
          Text(
            "Error loading activity",
            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 1.h),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: Colors.white54, fontSize: 13.sp),
            ),
          ),
          TextButton(
            onPressed: () => ref.read(activeChallengeProvider.notifier).fetchActiveStats(),
            child: const Text("Retry", style: TextStyle(color: Colors.amberAccent)),
          )
        ],
      ),
    );
  }
}