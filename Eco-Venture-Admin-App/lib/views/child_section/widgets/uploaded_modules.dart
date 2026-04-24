import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:go_router/go_router.dart';
import 'package:eco_venture_admin_portal/viewmodels/child_section/modules_uploaded/module_uploaded_provider.dart';
import 'package:eco_venture_admin_portal/models/modules_uploaded_model.dart';

class ModulesDetailsView extends ConsumerStatefulWidget {
  const ModulesDetailsView({super.key});

  @override
  ConsumerState<ModulesDetailsView> createState() => _ModulesDetailsViewState();
}

class _ModulesDetailsViewState extends ConsumerState<ModulesDetailsView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Refresh data on entry
    Future.microtask(() => ref.read(modulesUploadedProvider.notifier).fetchModuleStats());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(modulesUploadedProvider);

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
              _buildStatsBanner(state),
              _buildTabBar(),
              Expanded(
                child: state.isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.amberAccent))
                    : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildModuleList(state.stats.adminModules, "System Admin"),
                    _buildModuleList(state.stats.teacherModules, "Teacher Contributors"),
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
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          ),
          SizedBox(width: 2.w),
          Text(
            "Modules Library",
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

  Widget _buildStatsBanner(dynamic state) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(2.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem("Total Content", state.stats.totalCount.toString()),
          _buildVerticalDivider(),
          _buildStatItem("Admin Base", state.stats.adminCount.toString()),
          _buildVerticalDivider(),
          _buildStatItem("Teacher Files", state.stats.teacherCount.toString()),
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

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.all(4.w),
      height: 6.h,
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
        labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14.sp),
        tabs: const [
          Tab(text: "Admin Library"),
          Tab(text: "Teacher Uploads"),
        ],
      ),
    );
  }

  Widget _buildModuleList(List<ModuleContentModel> modules, String sourceLabel) {
    if (modules.isEmpty) {
      return Center(
        child: Text(
          "No modules found in this category",
          style: GoogleFonts.poppins(color: Colors.white38, fontSize: 15.sp),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      itemCount: modules.length,
      itemBuilder: (context, index) {
        final module = modules[index];
        return Container(
          margin: EdgeInsets.only(bottom: 1.5.h),
          padding: EdgeInsets.all(1.8.h),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              _buildCategoryIcon(module.category),
              SizedBox(width: 4.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      module.title,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16.sp,
                      ),
                    ),
                    Text(
                      "${module.category} • $sourceLabel",
                      style: GoogleFonts.poppins(
                        color: Colors.white38,
                        fontSize: 13.sp,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.white24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryIcon(String category) {
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
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}