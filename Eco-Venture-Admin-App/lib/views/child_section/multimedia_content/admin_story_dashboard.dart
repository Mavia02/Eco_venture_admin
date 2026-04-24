import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:go_router/go_router.dart';
import '../../../../models/story_model.dart';
import '../../../viewmodels/child_section/multimedia_content/admin_multimedia_provider.dart';


class AdminStoryDashboard extends ConsumerStatefulWidget {
  const AdminStoryDashboard({super.key});

  @override
  ConsumerState<AdminStoryDashboard> createState() => _AdminStoryDashboardState();
}

class _AdminStoryDashboardState extends ConsumerState<AdminStoryDashboard> {
  final Color _primary = const Color(0xFF8E2DE2); // Deep Purple
  final Color _textDark = const Color(0xFF1B2559);

  @override
  void initState() {
    super.initState();
    // Load Stories
    Future.microtask(() => ref.read(adminMultimediaViewModelProvider.notifier).loadStories());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminMultimediaViewModelProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.black), onPressed: () => context.pop()),
        title: Text("Global Stories", style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18.sp)),
        centerTitle: true,
      ),
      body: state.isLoading
          ? Center(child: CircularProgressIndicator(color: _primary))
          : state.stories.isEmpty
          ? Center(child: Text("No Stories Yet", style: TextStyle(fontSize: 16.sp, color: Colors.grey)))
          : ListView.separated(
        padding: EdgeInsets.all(5.w),
        itemCount: state.stories.length,
        separatorBuilder: (c, i) => SizedBox(height: 2.h),
        itemBuilder: (context, index) => _buildStoryCard(state.stories[index]),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed('adminAddStoryScreen'),
        backgroundColor: _primary,
        icon: const Icon(Icons.menu_book_rounded),
        label: Text("Create Story", style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildStoryCard(StoryModel story) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10)]),
      child: Row(
        children: [
          Container(
            height: 16.w, width: 16.w,
            decoration: BoxDecoration(
                color: _primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                image: (story.thumbnailUrl != null && story.thumbnailUrl!.startsWith('http'))
                    ? DecorationImage(image: NetworkImage(story.thumbnailUrl!), fit: BoxFit.cover)
                    : null
            ),
            child: story.thumbnailUrl == null ? Icon(Icons.auto_stories, color: _primary, size: 24.sp) : null,
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(story.title, style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w700, color: _textDark)),
                SizedBox(height: 0.5.h),
                Text("${story.pages.length} Pages", style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.grey)),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                icon: Icon(Icons.edit, color: Colors.blue, size: 18.sp),
                onPressed: () => context.pushNamed('adminEditStoryScreen', extra: story),
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red, size: 18.sp),
                onPressed: () {
                  if(story.id != null) ref.read(adminMultimediaViewModelProvider.notifier).deleteStory(story.id!);
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}