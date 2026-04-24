import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:eco_venture_admin_portal/viewmodels/child_section/avg_progress/avg_progress_provider.dart';
import 'package:eco_venture_admin_portal/viewmodels/child_section/avg_progress/avg_progress_state.dart';

class AvgProgressDetailsView extends ConsumerStatefulWidget {
  const AvgProgressDetailsView({super.key});

  @override
  ConsumerState<AvgProgressDetailsView> createState() => _AvgProgressDetailsViewState();
}

class _AvgProgressDetailsViewState extends ConsumerState<AvgProgressDetailsView> {
  @override
  void initState() {
    super.initState();
    // Logic: Ensure stats are refreshed when entering the detail view
    Future.microtask(() {
      ref.read(avgProgressProvider.notifier).fetchGlobalProgress();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(avgProgressProvider);

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
                child: state.isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.amberAccent))
                    : state.error != null
                    ? _buildErrorState(state.error!)
                    : _buildMainContent(state),
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
            "Overall Engagement",
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

  Widget _buildMainContent(AvgProgressState state) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        children: [
          _buildGlobalScoreCard(state.stats.globalAverage),
          SizedBox(height: 3.h),
          _buildSectionTitle("Module Breakdown"),
          SizedBox(height: 2.h),
          _buildModuleGrid(state),
          SizedBox(height: 4.h),
          _buildInsightsCard(state),
          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  Widget _buildGlobalScoreCard(double globalAvg) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          CircularPercentIndicator(
            radius: 10.h,
            lineWidth: 12.0,
            percent: globalAvg / 100,
            animation: true,
            animateFromLastPercent: true,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${globalAvg.toInt()}%",
                  style: GoogleFonts.poppins(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "Global Avg",
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
            progressColor: Colors.amberAccent,
            backgroundColor: Colors.white10,
            circularStrokeCap: CircularStrokeCap.round,
          ),
          SizedBox(height: 3.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: Text(
              "This score represents equal participation across all 4 learning modules.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.white38,
                fontSize: 13.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleGrid(AvgProgressState state) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 2.h,
      crossAxisSpacing: 4.w,
      childAspectRatio: 0.85,
      children: [
        _buildModuleStatCard(
          "Interactive Quizzes",
          state.stats.quizAverage,
          Icons.quiz_rounded,
          Colors.greenAccent,
        ),
        _buildModuleStatCard(
          "STEM Challenges",
          state.stats.stemAverage,
          Icons.science_rounded,
          Colors.pinkAccent,
        ),
        _buildModuleStatCard(
          "QR Hunt Search",
          state.stats.qrAverage,
          Icons.qr_code_2_rounded,
          Colors.orangeAccent,
        ),
        _buildModuleStatCard(
          "Media Engagement",
          state.stats.multimediaEngagement,
          Icons.play_circle_fill_rounded,
          Colors.blueAccent,
        ),
      ],
    );
  }

  Widget _buildModuleStatCard(String title, double value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(2.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 1.5.h),
          CircularPercentIndicator(
            radius: 4.h,
            lineWidth: 6.0,
            percent: value / 100,
            animation: true,
            center: Text(
              "${value.toInt()}%",
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            progressColor: color,
            backgroundColor: Colors.white10,
            circularStrokeCap: CircularStrokeCap.round,
          ),
          SizedBox(height: 1.5.h),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsCard(AvgProgressState state) {
    return Container(
      padding: EdgeInsets.all(2.5.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amberAccent.withOpacity(0.1), Colors.transparent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amberAccent.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline_rounded, color: Colors.amberAccent),
              SizedBox(width: 2.w),
              Text(
                "Admin Insights",
                style: GoogleFonts.poppins(
                  color: Colors.amberAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 15.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          _buildInsightRow(
            "Tracking ${state.stats.totalStudentsTracked} active children.",
          ),
          _buildInsightRow(
            state.stats.quizAverage > 70
                ? "Children are excelling at Quizzes."
                : "Quizzes may need difficulty adjustment.",
          ),
          _buildInsightRow(
            "Equal 25% weightage applied per category.",
          ),
        ],
      ),
    );
  }

  Widget _buildInsightRow(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(color: Colors.amberAccent, fontSize: 18)),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 17.sp,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
          SizedBox(height: 2.h),
          Text(error, style: const TextStyle(color: Colors.white70)),
          TextButton(
            onPressed: () => ref.read(avgProgressProvider.notifier).fetchGlobalProgress(),
            child: const Text("Retry", style: TextStyle(color: Colors.amberAccent)),
          )
        ],
      ),
    );
  }
}