import 'dart:io';
import 'dart:ui'; // Required for PathMetrics
import 'package:eco_venture_admin_portal/core/config/api_constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../../models/story_model.dart';
import '../../../viewmodels/child_section/multimedia_content/admin_multimedia_provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http; // Add HTTP import

class AdminEditStoryScreen extends ConsumerStatefulWidget {
  final dynamic storyData; // Can be Map or StoryModel
  const AdminEditStoryScreen({super.key, required this.storyData});

  @override
  ConsumerState<AdminEditStoryScreen> createState() =>
      _AdminEditStoryScreenState();
}

class _AdminEditStoryScreenState extends ConsumerState<AdminEditStoryScreen> {
  // --- PRO COLORS ---
  final Color _primaryPurple = const Color(0xFF8E2DE2);
  final Color _bg = const Color(0xFFF4F7FE);
  final Color _textDark = const Color(0xFF1B2559);
  final Color _borderGrey = const Color(0xFFE0E0E0);
  final Color _dashedBorderColor = const Color(0xFFBDBDBD);

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  // --- NEW CONTROLLERS ---
  late TextEditingController _tagsController;
  late bool _isSensitive;
  // -----------------------

  late StoryModel _story;
  File? _coverImage;
  String? _existingCoverUrl;
  late List<StoryPage> _pages;

  @override
  void initState() {
    super.initState();

    // 1. Parse Data
    if (widget.storyData is StoryModel) {
      _story = widget.storyData;
    } else {
      final map = Map<String, dynamic>.from(widget.storyData);
      final String id = map['id'] ?? '';
      _story = StoryModel.fromMap(id, map);
    }

    // 2. Pre-fill Controllers
    _titleController.text = _story.title;
    _descController.text = _story.description;

    // --- NEW: Initialize Tags & Sensitivity ---
    _tagsController = TextEditingController(text: _story.tags.join(', '));
    _isSensitive = _story.isSensitive;
    // ------------------------------------------

    _existingCoverUrl = _story.thumbnailUrl;
    _pages = List.from(_story.pages);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  // --- NOTIFICATION LOGIC ---
  Future<void> _sendNotificationToUsers(String title) async {
    const String backendUrl = ApiConstants.notifyByRoleEndPoints;

    try {
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "title": "Story Updated! 📖",
          "body": "Check out changes to '$title'.",
          "type": "STORY",
          "targetRole": "child"
        }),
      );

      if (response.statusCode == 200) {
        print("✅ Notification sent successfully");
      }
    } catch (e) {
      print("❌ Error calling backend: $e");
    }
  }

  // --- UPDATE LOGIC ---
  Future<void> _updateStory() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Title is required"), backgroundColor: Colors.red),
      );
      return;
    }
    if (_pages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Story must have at least one page"), backgroundColor: Colors.red),
      );
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

    // Create updated model
    final updatedStory = _story.copyWith(
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      thumbnailUrl: _coverImage?.path ?? _existingCoverUrl,
      pages: _pages,
      // --- Update New Fields ---
      tags: tagsList,
      isSensitive: _isSensitive,
    );

    await ref.read(adminMultimediaViewModelProvider.notifier).updateStory(updatedStory);

    // --- Trigger Notification (If not sensitive) ---
    if (!_isSensitive) {
      _sendNotificationToUsers(updatedStory.title);
    }
  }

  Future<void> _pickCoverImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? img = await picker.pickImage(source: ImageSource.gallery);
    if (img != null) {
      setState(() {
        _coverImage = File(img.path);
        _existingCoverUrl = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminMultimediaViewModelProvider);

    ref.listen(adminMultimediaViewModelProvider, (prev, next) {
      if (next.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Story Updated Successfully!"), backgroundColor: Colors.green),
        );
        ref.read(adminMultimediaViewModelProvider.notifier).resetSuccess();
        Navigator.pop(context);
      }
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${next.errorMessage}"), backgroundColor: Colors.red),
        );
      }
    });

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: Text(
          "Edit Story",
          style: GoogleFonts.poppins(
            color: _textDark,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader("Story Details"),
                SizedBox(height: 2.h),
                Container(
                  padding: EdgeInsets.all(5.w),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Story Title"),
                      _buildTextField(
                        controller: _titleController,
                        hint: "e.g. The Brave Little Rabbit",
                      ),
                      SizedBox(height: 2.h),
                      _buildLabel("Description"),
                      _buildTextField(
                        controller: _descController,
                        hint: "Short summary...",
                        maxLines: 3,
                      ),

                      // --- NEW UI FIELDS ---
                      SizedBox(height: 2.h),
                      _buildLabel("Tags (comma-separated)"),
                      _buildTextField(controller: _tagsController, hint: "e.g. animals, moral"),

                      SizedBox(height: 2.h),
                      Container(
                        decoration: BoxDecoration(
                          color: _bg,
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

                      SizedBox(height: 3.h),
                      _buildLabel("Cover Illustration"),
                      _buildCoverUpload(),
                    ],
                  ),
                ),
                SizedBox(height: 4.h),

                // --- SECTION 2: PAGES ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionHeader("Pages (${_pages.length})"),
                    InkWell(
                      onTap: () => _showPageEditor(),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 3.w,
                          vertical: 0.8.h,
                        ),
                        decoration: BoxDecoration(
                          color: _primaryPurple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.add, size: 16.sp, color: _primaryPurple),
                            SizedBox(width: 1.w),
                            Text(
                              "Add Page",
                              style: GoogleFonts.poppins(
                                fontSize: 12.sp,
                                color: _primaryPurple,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),

                if (_pages.isEmpty)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(4.h),
                      child: Text(
                        "No pages yet.",
                        style: GoogleFonts.poppins(
                          color: Colors.grey,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _pages.length,
                    separatorBuilder: (c, i) => SizedBox(height: 2.h),
                    itemBuilder: (context, index) => _buildPageCard(index),
                  ),

                SizedBox(height: 5.h),

                // --- UPDATE BUTTON ---
                SizedBox(
                  width: double.infinity,
                  height: 7.h,
                  child: ElevatedButton(
                    onPressed: state.isLoading ? null : _updateStory,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 5,
                    ),
                    child: state.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                      "Update Story",
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 5.h),
              ],
            ),
          ),
          if (state.isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  // --- WIDGETS (Unchanged) ---
  Widget _buildSectionHeader(String title) => Text(title, style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w700, color: _textDark));
  Widget _buildLabel(String text) => Padding(padding: EdgeInsets.only(bottom: 1.h), child: Text(text, style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.grey[700])));

  Widget _buildTextField({required TextEditingController controller, required String hint, int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.poppins(fontSize: 15.sp),
      decoration: InputDecoration(
        hintText: hint,
        filled: true, fillColor: const Color(0xFFF8F9FA),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _borderGrey)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _borderGrey)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _primaryPurple, width: 1.5)),
      ),
    );
  }

  Widget _buildCoverUpload() {
    ImageProvider? imgProvider;
    if (_coverImage != null) {
      imgProvider = FileImage(_coverImage!);
    } else if (_existingCoverUrl != null && _existingCoverUrl!.isNotEmpty) {
      imgProvider = NetworkImage(_existingCoverUrl!);
    }

    return CustomPaint(
      painter: DashedRectPainter(color: _dashedBorderColor, strokeWidth: 1.5, gap: 6, radius: 12),
      child: InkWell(
        onTap: _pickCoverImage,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 20.h, width: double.infinity,
          decoration: imgProvider == null ? BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)) : null,
          child: imgProvider != null
              ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image(image: imgProvider, fit: BoxFit.cover, width: double.infinity))
              : Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.image_rounded, size: 32.sp, color: Colors.grey), SizedBox(height: 1.h), Text("Upload Cover Art", style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.grey))]),
        ),
      ),
    );
  }

  Widget _buildPageCard(int index) {
    final page = _pages[index];
    ImageProvider? pageImgProvider;
    if (page.imageUrl.isNotEmpty) {
      if (page.imageUrl.startsWith('http')) {
        pageImgProvider = NetworkImage(page.imageUrl);
      } else {
        pageImgProvider = FileImage(File(page.imageUrl));
      }
    }

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10)]),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(radius: 14.sp, backgroundColor: _primaryPurple.withOpacity(0.1), child: Text("${index + 1}", style: TextStyle(color: _primaryPurple, fontWeight: FontWeight.bold, fontSize: 14.sp))),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(page.text, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 14.sp, color: _textDark)),
                if (pageImgProvider != null) ...[
                  SizedBox(height: 1.h),
                  ClipRRect(borderRadius: BorderRadius.circular(8), child: Image(image: pageImgProvider, height: 8.h, width: 15.w, fit: BoxFit.cover)),
                ]
              ],
            ),
          ),
          Column(
            children: [
              IconButton(icon: Icon(Icons.edit, color: Colors.blue, size: 18.sp), onPressed: () => _showPageEditor(existingIndex: index)),
              IconButton(icon: Icon(Icons.delete, color: Colors.red, size: 18.sp), onPressed: () => setState(() => _pages.removeAt(index))),
            ],
          )
        ],
      ),
    );
  }

  void _showPageEditor({int? existingIndex}) {
    final textCtrl = TextEditingController(text: existingIndex != null ? _pages[existingIndex].text : "");
    File? pageImageFile;
    String? pageImageUrl;

    if (existingIndex != null && _pages[existingIndex].imageUrl.isNotEmpty) {
      if (_pages[existingIndex].imageUrl.startsWith('http')) {
        pageImageUrl = _pages[existingIndex].imageUrl;
      } else {
        pageImageFile = File(_pages[existingIndex].imageUrl);
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
          builder: (context, setModalState) {
            ImageProvider? editorImgProvider;
            if (pageImageFile != null) editorImgProvider = FileImage(pageImageFile!);
            else if (pageImageUrl != null) editorImgProvider = NetworkImage(pageImageUrl!);

            return Container(
              height: 85.h,
              padding: EdgeInsets.fromLTRB(5.w, 2.h, 5.w, MediaQuery.of(context).viewInsets.bottom + 2.h),
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
              child: Column(
                children: [
                  Container(width: 15.w, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
                  SizedBox(height: 2.h),
                  Text(existingIndex == null ? "Add New Page" : "Edit Page ${existingIndex + 1}", style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.bold, color: _textDark)),
                  SizedBox(height: 3.h),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Story Text"),
                          TextField(
                            controller: textCtrl,
                            maxLines: 5,
                            style: TextStyle(fontSize: 15.sp),
                            decoration: InputDecoration(hintText: "Once upon a time...", filled: true, fillColor: const Color(0xFFF8F9FA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                          ),
                          SizedBox(height: 3.h),
                          _buildLabel("Illustration (Optional)"),
                          InkWell(
                            onTap: () async {
                              final ImagePicker picker = ImagePicker();
                              final XFile? img = await picker.pickImage(source: ImageSource.gallery);
                              if(img != null) {
                                setModalState(() {
                                  pageImageFile = File(img.path);
                                  pageImageUrl = null;
                                });
                              }
                            },
                            child: Container(
                              height: 20.h, width: double.infinity,
                              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300), image: editorImgProvider != null ? DecorationImage(image: editorImgProvider, fit: BoxFit.cover) : null),
                              child: editorImgProvider == null ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_photo_alternate, color: _primaryPurple, size: 24.sp), Text("Add Image", style: TextStyle(color: _primaryPurple))])) : null,
                            ),
                          ),
                          if (editorImgProvider != null)
                            Padding(padding: EdgeInsets.only(top: 1.h), child: Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () => setModalState(() { pageImageFile = null; pageImageUrl = null; }), child: Text("Remove Image", style: TextStyle(color: Colors.red))))),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  SizedBox(
                    width: double.infinity, height: 7.h,
                    child: ElevatedButton(
                      onPressed: () {
                        if (textCtrl.text.trim().isEmpty && pageImageFile == null && pageImageUrl == null) return;
                        final String? finalImgPath = pageImageFile?.path ?? pageImageUrl;
                        final newPage = StoryPage(text: textCtrl.text, imageUrl: finalImgPath ?? "");
                        setState(() {
                          if (existingIndex != null) _pages[existingIndex] = newPage;
                          else _pages.add(newPage);
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: _primaryPurple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                      child: Text("Save Page", style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  )
                ],
              ),
            );
          }
      ),
    );
  }
}

class DashedRectPainter extends CustomPainter {
  final double strokeWidth; final Color color; final double gap; final double radius;
  DashedRectPainter({this.strokeWidth = 1.0, this.color = Colors.red, this.gap = 5.0, this.radius = 0});
  @override void paint(Canvas canvas, Size size) { Paint dashedPaint = Paint()..color = color..strokeWidth = strokeWidth..style = PaintingStyle.stroke; Path path = Path()..addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), Radius.circular(radius))); PathMetrics pathMetrics = path.computeMetrics(); for (PathMetric pathMetric in pathMetrics) { double distance = 0.0; while (distance < pathMetric.length) { canvas.drawPath(pathMetric.extractPath(distance, distance + 5), dashedPaint); distance += 5 + gap; } } }
  @override bool shouldRepaint(CustomPainter oldDelegate) => false;
}