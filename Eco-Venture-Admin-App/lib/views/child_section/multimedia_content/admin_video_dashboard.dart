import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

// Import your model and provider
import '../../../../models/video_model.dart';
import '../../../viewmodels/child_section/multimedia_content/admin_multimedia_provider.dart';



class AdminVideoDashboard extends ConsumerStatefulWidget {
  const AdminVideoDashboard({super.key});

  @override
  ConsumerState<AdminVideoDashboard> createState() => _AdminVideoDashboardState();
}

class _AdminVideoDashboardState extends ConsumerState<AdminVideoDashboard> {
  final Color _primary = const Color(0xFFE53935);
  final Color _bg = const Color(0xFFF4F7FE);
  final Color _textDark = const Color(0xFF1B2559);

  @override
  void initState() {
    super.initState();
    // FIX: Changed fetchVideos() to loadVideos() to match your ViewModel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminVideoViewModelProvider.notifier).loadVideos();
    });
  }

  Future<void> _deleteVideo(String videoId) async {
    // Show confirmation dialog
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Video"),
        content: const Text("Are you sure you want to delete this video?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(adminVideoViewModelProvider.notifier).deleteVideo(videoId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminVideoViewModelProvider);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: _textDark),
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        title: Text(
          "Global Videos",
          style: GoogleFonts.poppins(
            color: _textDark,
            fontWeight: FontWeight.w700,
            fontSize: 18.sp,
          ),
        ),
      ),
      body: Builder(
        builder: (context) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.errorMessage != null && (state.videos == null || state.videos!.isEmpty)) {
            return Center(child: Text("Error: ${state.errorMessage}"));
          }

          final videos = state.videos ?? [];

          if (videos.isEmpty) {
            return Center(
              child: Text(
                "No Videos Found",
                style: GoogleFonts.poppins(fontSize: 16.sp, color: Colors.grey),
              ),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.all(5.w),
            itemCount: videos.length,
            separatorBuilder: (c, i) => SizedBox(height: 2.h),
            itemBuilder: (context, index) {
              return _buildVideoCard(videos[index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed('adminAddVideoScreen'),
        backgroundColor: _primary,
        icon: Icon(Icons.video_call_rounded, size: 20.sp, color: Colors.white),
        label: Text(
          "Upload Video",
          style: GoogleFonts.poppins(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildVideoCard(VideoModel video) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          // Thumbnail or Icon
          Container(
            height: 16.w,
            width: 16.w,
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              image: video.thumbnailUrl != null && video.thumbnailUrl!.isNotEmpty
                  ? DecorationImage(
                image: NetworkImage(video.thumbnailUrl!),
                fit: BoxFit.cover,
              )
                  : null,
            ),
            child: video.thumbnailUrl == null || video.thumbnailUrl!.isEmpty
                ? Icon(Icons.play_arrow_rounded, color: _primary, size: 26.sp)
                : null,
          ),
          SizedBox(width: 4.w),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video.title,
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 0.5.h),
                Text(
                  "${video.category} • ${video.duration}",
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: Colors.grey,
                  ),
                ),
                // Show tags if available
                if (video.tags.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 0.5.h),
                    child: Text(
                      "#${video.tags.join(" #")}",
                      style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          color: Colors.blueGrey,
                          fontStyle: FontStyle.italic
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),

          // Edit
          IconButton(
            icon: Icon(Icons.edit, color: Colors.blue, size: 18.sp),
            onPressed: () => context.pushNamed('adminEditVideoScreen', extra: video),
          ),

          // Delete
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red, size: 18.sp),
            onPressed: () => _deleteVideo(video.id!),
          ),
        ],
      ),
    );
  }
}