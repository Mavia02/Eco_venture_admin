import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:go_router/go_router.dart';
import 'package:eco_venture_admin_portal/viewmodels/child_section/child_dashboard/child_dashboard_provider.dart';
import 'package:eco_venture_admin_portal/viewmodels/child_section/child_dashboard/child_dashboard_state.dart';

class ChildrenDetailsView extends ConsumerStatefulWidget {
  const ChildrenDetailsView({super.key});

  @override
  ConsumerState<ChildrenDetailsView> createState() => _ChildrenDetailsViewState();
}

class _ChildrenDetailsViewState extends ConsumerState<ChildrenDetailsView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(childDashboardProvider.notifier).fetchDashboardStats();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(childDashboardProvider);

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
              _buildSummaryHeader(dashboardState),
              _buildTabBar(),
              Expanded(
                child: dashboardState.isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.amberAccent))
                    : dashboardState.error != null
                    ? _buildErrorState(dashboardState.error!)
                    : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildUserList(context, dashboardState.teacherStudents, "By Teacher"),
                    _buildUserList(context, dashboardState.directStudents, "Direct Registered"),
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
      padding: EdgeInsets.all(2.h),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          ),
          SizedBox(width: 2.w),
          Text(
            "Children Directory",
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

  Widget _buildSummaryHeader(ChildDashboardState state) {
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
          _buildStatItem("Total", state.summary.totalChildren.toString()),
          Container(width: 1, height: 4.h, color: Colors.white24),
          _buildStatItem("Teacher", state.summary.teacherRegistered.toString()),
          Container(width: 1, height: 4.h, color: Colors.white24),
          _buildStatItem("Direct", state.summary.directRegistered.toString()),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.amberAccent,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13.sp,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(15),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.amberAccent,
        ),
        labelColor: Colors.black,
        unselectedLabelColor: Colors.white70,
        indicatorSize: TabBarIndicatorSize.tab,
        tabs: const [
          Tab(text: "By Teacher"),
          Tab(text: "Direct/Admin"),
        ],
      ),
    );
  }

  Widget _buildUserList(BuildContext context, List<Map<String, dynamic>> students, String category) {
    if (students.isEmpty) {
      return Center(
        child: Text(
          "No students found in this category.",
          style: GoogleFonts.poppins(color: Colors.white54, fontSize: 15.sp),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];
        final name = student['displayName'] ?? student['name'] ?? "Unknown Student";
        final email = student['email'] ?? "No Email Provided";
        final imgUrl = student['imageUrl'] ?? student['imgUrl'];

        // Logic: Extract teacher name injected by the ViewModel
        final teacherName = student['teacher_name'];

        return Container(
          margin: EdgeInsets.only(bottom: 1.5.h),
          padding: EdgeInsets.all(1.5.h),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.white10,
                backgroundImage: (imgUrl != null && imgUrl.isNotEmpty)
                    ? NetworkImage(imgUrl)
                    : null,
                child: (imgUrl == null || imgUrl.isEmpty)
                    ? Icon(Icons.person, color: Colors.amberAccent.withOpacity(0.8))
                    : null,
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16.sp,
                      ),
                    ),
                    if (teacherName != null) ...[
                      Text(
                        "Teacher: $teacherName",
                        style: GoogleFonts.poppins(
                          color: Colors.amberAccent.withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                          fontSize: 13.sp,
                        ),
                      ),
                    ] else ...[
                      Text(
                        email,
                        style: GoogleFonts.poppins(
                          color: Colors.white54,
                          fontSize: 13.sp,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
            SizedBox(height: 2.h),
            Text(
              "Error loading data",
              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17.sp),
            ),
            SizedBox(height: 1.h),
            Text(
              error,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14.sp),
            ),
            SizedBox(height: 3.h),
            ElevatedButton(
              onPressed: () => ref.read(childDashboardProvider.notifier).fetchDashboardStats(),
              child: const Text("Retry"),
            )
          ],
        ),
      ),
    );
  }
}