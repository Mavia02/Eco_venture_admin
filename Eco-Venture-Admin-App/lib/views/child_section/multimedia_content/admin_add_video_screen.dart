import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:eco_venture_admin_portal/core/config/api_constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../../models/video_model.dart';
import '../../../viewmodels/child_section/multimedia_content/admin_multimedia_provider.dart';


class AdminAddVideoScreen extends ConsumerStatefulWidget {
  const AdminAddVideoScreen({super.key});

  @override
  ConsumerState<AdminAddVideoScreen> createState() => _AdminAddVideoScreenState();
}

class _AdminAddVideoScreenState extends ConsumerState<AdminAddVideoScreen> {
  // --- PRO COLORS ---
  final Color _primary = const Color(0xFFE53935);
  final Color _bg = const Color(0xFFF4F7FE);
  final Color _textDark = const Color(0xFF1B2559);
  final Color _borderGrey = const Color(0xFFE0E0E0);

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  // --- NEW FIELDS ---
  final TextEditingController _tagsController = TextEditingController();
  bool _isSensitive = false;
  // -----------------

  String _selectedCategory = 'Science';
  final List<String> _categories = ['Science', 'Maths', 'History', 'Ecosystem', 'Climate', 'Recycling'];

  File? _thumbnailImage;
  File? _videoFile;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _durationController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  // --- NOTIFICATION LOGIC ---
  Future<void> _sendNotificationToUsers(String title) async {
    const String backendUrl = ApiConstants.notifyByRoleEndPoints; // Use correct IP

    try {
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "title": "New Video Alert! 🎥",
          "body": "Watch the new video: '$title'!",
          "type": "VIDEO",
          "targetRole": "child" // Notify children only
        }),
      );

      if (response.statusCode == 200) {
        print("✅ Notification sent successfully");
      }
    } catch (e) {
      print("❌ Error calling backend: $e");
    }
  }

  Future<void> _pickThumbnail() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _thumbnailImage = File(image.path));
  }

  Future<void> _pickVideo() async {
    final ImagePicker picker = ImagePicker();
    final XFile? video = await picker.pickVideo(source: ImageSource.gallery);
    if (video != null) setState(() => _videoFile = File(video.path));
  }

  Future<void> _uploadVideo() async {
    if(_titleController.text.isEmpty || _videoFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Title and Video file are required"), backgroundColor: Colors.red));
      return;
    }

    // --- 1. Process Tags & Sensitivity ---
    List<String> tagsList = _tagsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (_isSensitive && !tagsList.contains('scary')) {
      tagsList.add('scary');
    }
    if (!_isSensitive) {
      tagsList.remove('scary');
    }

    final newVideo = VideoModel(
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      category: _selectedCategory,
      videoUrl: _videoFile!.path,
      thumbnailUrl: _thumbnailImage?.path,
      duration: _durationController.text.isNotEmpty ? _durationController.text : "00:00",
      createdAt: DateTime.now(),
      // --- Pass New Fields ---
      tags: tagsList,
      isSensitive: _isSensitive,
    );

    await ref.read(adminVideoViewModelProvider.notifier).addVideo(newVideo);

    // --- Trigger Notification (If not sensitive) ---
    if (!_isSensitive) {
      _sendNotificationToUsers(newVideo.title);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminVideoViewModelProvider);

    ref.listen(adminVideoViewModelProvider, (prev, next) {
      if (next.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Video Uploaded Successfully!"), backgroundColor: Colors.green));
        ref.read(adminVideoViewModelProvider.notifier).resetSuccess();
        Navigator.pop(context);
      }
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${next.errorMessage}"), backgroundColor: Colors.red));
      }
    });

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: Text("Upload Global Video", style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18.sp)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.black), onPressed: () => Navigator.pop(context)),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(5.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- SECTION 1: DETAILS ---
                _buildSectionHeader("Video Details"),
                SizedBox(height: 2.h),

                _buildLabel("Video Title"),
                _buildTextField(_titleController, "Enter title"),
                SizedBox(height: 2.h),

                _buildLabel("Description"),
                _buildTextField(_descController, "Enter description", maxLines: 3),
                SizedBox(height: 2.h),

                Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel("Category"), _buildDropdown()])),
                  SizedBox(width: 4.w),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel("Duration"), _buildTextField(_durationController, "e.g. 05:30")])),
                ]),
                SizedBox(height: 2.h),

                // --- NEW UI FIELDS ---
                _buildLabel("Tags (comma-separated)"),
                _buildTextField(_tagsController, "e.g. funny, science, short"),
                SizedBox(height: 2.h),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _borderGrey),
                  ),
                  child: SwitchListTile(
                    activeColor: Colors.red,
                    title: Text("Sensitive Content", style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.red.shade700)),
                    subtitle: Text("Hide from younger children", style: GoogleFonts.poppins(fontSize: 11.sp, color: Colors.grey)),
                    value: _isSensitive,
                    onChanged: (val) => setState(() => _isSensitive = val),
                  ),
                ),
                // ---------------------

                SizedBox(height: 4.h),

                // --- SECTION 2: MEDIA ---
                _buildSectionHeader("Media Content"),
                SizedBox(height: 2.h),

                _buildLabel("Thumbnail Image"),
                InkWell(
                  onTap: _pickThumbnail,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    height: 18.h, width: double.infinity,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade300), image: _thumbnailImage != null ? DecorationImage(image: FileImage(_thumbnailImage!), fit: BoxFit.cover) : null),
                    child: _thumbnailImage == null ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.image_rounded, size: 32.sp, color: Colors.orangeAccent), SizedBox(height: 1.h), Text("Tap to upload thumbnail", style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.grey))]) : null,
                  ),
                ),
                SizedBox(height: 4.h),

                _buildLabel("Video File"),
                InkWell(
                  onTap: _pickVideo,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    height: 20.h, width: double.infinity,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid)),
                    child: _videoFile == null
                        ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.cloud_upload_rounded, size: 40.sp, color: Colors.blue), SizedBox(height: 1.h), Text("Tap to upload MP4", style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.grey))])
                        : Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.check_circle, size: 40.sp, color: Colors.green), SizedBox(height: 1.h), Text("Video Selected", style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.green, fontWeight: FontWeight.bold))]),
                  ),
                ),

                SizedBox(height: 5.h),
                SizedBox(
                  width: double.infinity, height: 7.h,
                  child: ElevatedButton(
                    onPressed: state.isLoading ? null : _uploadVideo,
                    style: ElevatedButton.styleFrom(backgroundColor: _primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                    child: state.isLoading ? CircularProgressIndicator(color: Colors.white) : Text("Upload Video", style: GoogleFonts.poppins(fontSize: 16.sp, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          ),
          if (state.isLoading) Container(color: Colors.black26, child: Center(child: CircularProgressIndicator())),
        ],
      ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildSectionHeader(String title) => Text(title, style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w700, color: _textDark));

  Widget _buildLabel(String text) => Padding(padding: EdgeInsets.only(bottom: 1.h), child: Text(text, style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.w600, color: _textDark)));

  Widget _buildTextField(TextEditingController ctrl, String hint, {int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      style: GoogleFonts.poppins(fontSize: 15.sp),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 14.sp),
        filled: true, fillColor: Colors.white,
        contentPadding: EdgeInsets.all(4.w),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _borderGrey)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _borderGrey)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _primary, width: 1.5)),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: _borderGrey)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: _primary),
          items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c, style: GoogleFonts.poppins(fontSize: 15.sp)))).toList(),
          onChanged: (v) => setState(() => _selectedCategory = v!),
        ),
      ),
    );
  }
}