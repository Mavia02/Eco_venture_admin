import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:percent_indicator/percent_indicator.dart';

// Logic: Absolute imports synchronized with the project structure
import 'package:eco_venture_admin_portal/viewmodels/child_section/child_dashboard/child_dashboard_provider.dart';
import 'package:eco_venture_admin_portal/viewmodels/child_section/modules_uploaded/module_uploaded_provider.dart';
import 'package:eco_venture_admin_portal/viewmodels/child_section/active_challenges/active_challenge_provider.dart';
import 'package:eco_venture_admin_portal/viewmodels/child_section/avg_progress/avg_progress_provider.dart';

// Import the new Teacher Management Screen
import 'package:eco_venture_admin_portal/views/child_section/widgets/teacher_view.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class AdminChildHome extends ConsumerStatefulWidget {
  const AdminChildHome({super.key});

  @override
  ConsumerState<AdminChildHome> createState() => _AdminChildHomeState();
}

class _AdminChildHomeState extends ConsumerState<AdminChildHome> {
  // Logic: Unified color theme (Amber Accent) to support black text as established
  final List<Map<String, dynamic>> _modules = [
    {
      "title": "Interactive Quiz",
      "subtitle": "Engaging tests",
      "colors": [const Color(0xFFFFD740), const Color(0xFFFFC400)],
    },
    {
      "title": "Multimedia Learning",
      "subtitle": "Videos & stories",
      "colors": [const Color(0xFFFFD740), const Color(0xFFFFC400)],
    },
    {
      "title": "QR Treasure Hunt",
      "subtitle": "Interactive exploration",
      "colors": [const Color(0xFFFFD740), const Color(0xFFFFC400)],
    },
    {
      "title": "STEM Challenges",
      "subtitle": "Science projects",
      "colors": [const Color(0xFFFFD740), const Color(0xFFFFC400)],
    },
  ];

  @override
  void initState() {
    super.initState();
    // Logic: Initialize data fetching for all sections on load
    Future.microtask(() {
      ref.read(childDashboardProvider.notifier).fetchDashboardStats();
      ref.read(modulesUploadedProvider.notifier).fetchModuleStats();
      ref.read(activeChallengeProvider.notifier).fetchActiveStats();
      ref.read(avgProgressProvider.notifier).fetchGlobalProgress();
    });
  }

  @override
  Widget build(BuildContext context) {
    final childState = ref.watch(childDashboardProvider);
    final moduleState = ref.watch(modulesUploadedProvider);
    final activeChallengeState = ref.watch(activeChallengeProvider);
    final progressState = ref.watch(avgProgressProvider);

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
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(vertical: 2.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderSection(),
                SizedBox(height: 3.h),

                // Dashboard Summary Cards
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Wrap(
                    spacing: 3.w,
                    runSpacing: 2.h,
                    children: [
                      _buildTappableDashboardCard(
                        onTap: () => context.pushNamed('childrenDetails'),
                        title: "Total Children",
                        value: childState.isLoading ? "..." : childState.summary.totalChildren.toString(),
                        icon: Icons.people_alt_rounded,
                      ),
                      _buildTappableDashboardCard(
                        onTap: () => context.pushNamed('modulesDetails'),
                        title: "Modules Uploaded",
                        value: moduleState.isLoading ? "..." : moduleState.stats.totalCount.toString(),
                        icon: Icons.folder_copy_rounded,
                      ),
                      _buildTappableDashboardCard(
                        onTap: () => context.pushNamed('activeChallengesDetails'),
                        title: "Active Challenges",
                        value: activeChallengeState.isLoading ? "..." : activeChallengeState.totalActiveCount.toString(),
                        icon: Icons.flag_rounded,
                      ),
                      _buildTappableDashboardCard(
                        onTap: () => context.pushNamed('avgProgressDetails'),
                        title: "Avg. Progress",
                        valueWidget: CircularPercentIndicator(
                          radius: 3.5.h,
                          lineWidth: 1.5.w,
                          percent: (progressState.stats.globalAverage / 100).clamp(0.0, 1.0),
                          center: Text(
                            "${progressState.stats.globalAverage.toInt()}%",
                            style: GoogleFonts.poppins(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          progressColor: Colors.amberAccent,
                          backgroundColor: Colors.white10,
                          circularStrokeCap: CircularStrokeCap.round,
                          animation: true,
                        ),
                        icon: Icons.show_chart_rounded,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 4.h),

                // Learning Modules Section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.5.h),
                  child: Text(
                    "Learning Modules",
                    style: GoogleFonts.poppins(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 2.h,
                      crossAxisSpacing: 3.w,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: _modules.length,
                    itemBuilder: (context, index) {
                      final module = _modules[index];
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          switch (module['title']) {
                            case "Interactive Quiz": context.goNamed("interactiveQuiz"); break;
                            case "Multimedia Learning": context.goNamed('adminMultimediaDashboard'); break;
                            case "QR Treasure Hunt": context.goNamed('adminTreasureHuntDashboard'); break;
                            case "STEM Challenges": context.goNamed("stemChallengesScreen"); break;
                          }
                        },
                        child: _buildThemedModuleCard(module),
                      );
                    },
                  ),
                ),

                SizedBox(height: 4.h),

                // Progress Overview Section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.w),
                  child: Text(
                    "Progress Overview",
                    style: GoogleFonts.poppins(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                _buildProgressCard(),

                // Enhanced Teacher Management Section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.5.h),
                  child: Text(
                    "Teacher Management",
                    style: GoogleFonts.poppins(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                _buildTeacherManagementCard(context),

                SizedBox(height: 5.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Logic: Header section
  Widget _buildHeaderSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Admin Panel",
            style: GoogleFonts.poppins(
              fontSize: 21.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTappableDashboardCard({
    required String title,
    String? value,
    Widget? valueWidget,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          width: 44.w,
          padding: EdgeInsets.all(2.2.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Colors.white.withOpacity(0.06),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(0.8.h),
                    decoration: BoxDecoration(
                      color: Colors.amberAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: Colors.amberAccent, size: 18),
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              valueWidget ??
                  Text(
                    value ?? "--",
                    style: GoogleFonts.poppins(
                      fontSize: 22.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemedModuleCard(Map<String, dynamic> module) {
    return Container(
      padding: EdgeInsets.all(2.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: module['colors'],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            module['title'],
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontWeight: FontWeight.w800,
              fontSize: 16.sp,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            module['subtitle'],
            style: GoogleFonts.poppins(
              color: Colors.black87,
              fontWeight: FontWeight.w500,
              fontSize: 13.sp,
            ),
          ),
          const Spacer(),
          const Align(
            alignment: Alignment.bottomRight,
            child: Icon(Icons.arrow_circle_right_rounded, color: Colors.black, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 0,
      color: Colors.transparent,
      margin: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(2.h, 3.h, 2.h, 1.h),
              child: SizedBox(
                height: 22.h,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 10,
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const titles = ['Quiz', 'Media', 'Hunt', 'STEM', 'Other'];
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                titles[value.toInt()],
                                style: GoogleFonts.poppins(
                                  color: Colors.white54,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11.sp,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    barGroups: [
                      _buildBarGroup(0, 5, Colors.greenAccent),
                      _buildBarGroup(1, 7, Colors.blueAccent),
                      _buildBarGroup(2, 4, Colors.orangeAccent),
                      _buildBarGroup(3, 8, Colors.pinkAccent),
                      _buildBarGroup(4, 6, Colors.amberAccent),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 1.5.h),
              decoration: const BoxDecoration(
                color: Colors.amberAccent,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              child: Center(
                child: Text(
                  "Completion Rates by Category",
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 20,
          borderRadius: BorderRadius.circular(6),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 10,
            color: Colors.white10,
          ),
        ),
      ],
    );
  }

  /// Logic: Enhanced Teacher Management card with premium UI
  Widget _buildTeacherManagementCard(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      child: GestureDetector(
        onTap: () => context.pushNamed('teacherManagement'),
        child: Container(
          padding: EdgeInsets.all(2.5.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            // Logic: Deep gradient to make it pop against the background
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF3C6A67).withOpacity(0.8),
                const Color(0xFF1B403D).withOpacity(0.9),
              ],
            ),
            border: Border.all(color: Colors.amberAccent.withOpacity(0.2), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              // Logic: Prominent Icon container with highlight effect
              Container(
                padding: EdgeInsets.all(1.5.h),
                decoration: BoxDecoration(
                  color: Colors.amberAccent,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amberAccent.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: const Icon(
                  Icons.supervised_user_circle_rounded,
                  color: Colors.black,
                  size: 32,
                ),
              ),
              SizedBox(width: 5.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Registered Teachers",
                      style: GoogleFonts.poppins(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      "Manage access & view directory",
                      style: GoogleFonts.poppins(
                        fontSize: 13.5.sp,
                        color: Colors.white54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Logic: Distinct action arrow
              Container(
                padding: EdgeInsets.all(1.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.amberAccent,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}