import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:eco_venture_admin_portal/core/config/api_constant.dart';
import 'package:http/http.dart' as http; // Add HTTP import
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:go_router/go_router.dart';

// Import your models and providers
import '../../../../models/stem_challenge_model.dart';

import '../../../viewmodels/child_section/Stem_challenges/stem_challenges_provider.dart';

class EditStemChallengeScreen extends ConsumerStatefulWidget {
  final StemChallengeModel challenge;

  const EditStemChallengeScreen({super.key, required this.challenge});

  @override
  ConsumerState<EditStemChallengeScreen> createState() =>
      _EditStemChallengeScreenState();
}

class _EditStemChallengeScreenState
    extends ConsumerState<EditStemChallengeScreen> {
  final Color _primaryBlue = const Color(0xFF1976D2);
  final Color _lightBlue = const Color(0xFFE3F2FD);
  final Color _textDark = const Color(0xFF2D3436);
  final Color _borderGrey = const Color(0xFFE0E0E0);
  final Color _dashedBorderColor = const Color(0xFFBDBDBD);

  late TextEditingController _titleController;
  late TextEditingController _pointsController;
  final TextEditingController _materialController = TextEditingController();

  // --- NEW CONTROLLERS ---
  late TextEditingController _tagsController;
  late bool _isSensitive;
  // -----------------------

  late String _selectedCategory;
  final List<String> _categories = [
    'Science',
    'Technology',
    'Engineering',
    'Mathematics',
  ];

  late String _selectedDifficulty;
  final List<String> _difficultyLevels = ['Easy', 'Medium', 'Hard'];

  File? _newImageFile;
  String? _existingImageUrl;

  late List<String> _materials;
  late List<String> _steps;

  @override
  void initState() {
    super.initState();
    // 1. Populate from Model directly
    _titleController = TextEditingController(text: widget.challenge.title);
    _pointsController = TextEditingController(
      text: widget.challenge.points.toString(),
    );

    // --- NEW: Initialize Tags & Sensitivity ---
    _tagsController = TextEditingController(
      text: widget.challenge.tags.join(', '),
    );
    _isSensitive = widget.challenge.isSensitive;
    // ------------------------------------------

    _selectedCategory = widget.challenge.category;
    _selectedDifficulty = widget.challenge.difficulty;

    // Deep copy lists
    _materials = List<String>.from(widget.challenge.materials);
    _steps = List<String>.from(widget.challenge.steps);

    _existingImageUrl = widget.challenge.imageUrl;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _pointsController.dispose();
    _materialController.dispose();
    _tagsController.dispose(); // Dispose tags controller
    super.dispose();
  }

  // --- NOTIFICATION LOGIC ---
  Future<void> _sendNotificationToUsers(String title, String category) async {
    const String backendUrl = ApiConstants.notifyByRoleEndPoints;// Use correct IP

    try {
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "title": "STEM Challenge Updated! 🔄",
          "body": "Check out the updates to '$title' in $category!",
          "type": "STEM",
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

  Future<void> _updateChallenge() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter a title")));
      return;
    }
    if (_pointsController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter points")));
      return;
    }

    final String? finalImage = _newImageFile?.path ?? _existingImageUrl;

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

    // 2. Use Model's copyWith (keeping ID and AdminID safe)
    final updatedModel = widget.challenge.copyWith(
      title: _titleController.text.trim(),
      category: _selectedCategory,
      difficulty: _selectedDifficulty,
      points: int.tryParse(_pointsController.text.trim()) ?? 0,
      imageUrl: finalImage,
      materials: _materials,
      steps: _steps,
      // --- Update New Fields ---
      tags: tagsList,
      isSensitive: _isSensitive,
    );

    await ref
        .read(stemChallengesViewModelProvider.notifier)
        .updateChallenge(updatedModel);

    // --- Trigger Notification (If not sensitive) ---
    if (!_isSensitive) {
      _sendNotificationToUsers(updatedModel.title, updatedModel.category);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModelState = ref.watch(stemChallengesViewModelProvider);

    ref.listen(stemChallengesViewModelProvider, (previous, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
      if (next.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Challenge Updated Successfully!"),
            backgroundColor: Colors.green,
          ),
        );

        ref.read(stemChallengesViewModelProvider.notifier).resetSuccess();
        Navigator.pop(context);
      }
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if(!didPop){
          context.goNamed('stemChallengesScreen');
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader("Challenge Details"),
                  SizedBox(height: 2.h),
                  _buildLabel("Challenge Title"),
                  _buildTextField(
                    controller: _titleController,
                    hint: "Enter challenge title",
                  ),
                  SizedBox(height: 2.h),

                  _buildLabel("Difficulty Level"),
                  _buildDifficultySelector(),
                  SizedBox(height: 2.h),

                  // --- NEW UI ELEMENTS ---
                  _buildLabel("Tags (comma-separated)"),
                  _buildTextField(
                    controller: _tagsController,
                    hint: "e.g. physics, water, fun",
                  ),
                  SizedBox(height: 2.h),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _borderGrey),
                    ),
                    child: SwitchListTile(
                      activeColor: Colors.red,
                      title: Text(
                        "Sensitive Content",
                        style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.red.shade700
                        ),
                      ),
                      subtitle: Text(
                        "Hide from younger children",
                        style: GoogleFonts.poppins(fontSize: 11.sp, color: Colors.grey),
                      ),
                      value: _isSensitive,
                      onChanged: (val) => setState(() => _isSensitive = val),
                    ),
                  ),
                  // -----------------------
                  SizedBox(height: 2.h),

                  _buildLabel("Points"),
                  SizedBox(
                    width: 30.w,
                    child: _buildTextField(
                      controller: _pointsController,
                      hint: "0",
                      isNumber: true,
                      isCenter: true,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  _buildLabel("Challenge Image"),
                  _buildImageUploadBox(),
                  SizedBox(height: 4.h),
                  _buildSectionHeader("Materials / Apparatus Required"),
                  SizedBox(height: 2.h),
                  _buildMaterialsWrap(),
                  SizedBox(height: 1.5.h),
                  _buildDashedAddButton(
                    label: "Add Material",
                    onTap: _showAddMaterialDialog,
                  ),
                  SizedBox(height: 4.h),
                  _buildSectionHeader("Step-by-Step Instructions"),
                  SizedBox(height: 2.h),
                  _buildStepsList(),
                  SizedBox(height: 1.5.h),
                  _buildDashedAddButton(
                    label: "Add Step",
                    onTap: _showAddStepDialog,
                  ),
                  SizedBox(height: 5.h),
                  _buildFooterButtons(viewModelState.isLoading),
                  SizedBox(height: 5.h),
                ],
              ),
            ),
            if (viewModelState.isLoading)
              Container(
                color: Colors.black54,
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  // ... [KEEP ALL EXISTING WIDGET BUILDERS UNCHANGED] ...
  // Same as your original code:
  // _buildAppBar, _buildSectionHeader, _buildLabel, _buildTextField,
  // _buildDifficultySelector, _buildImageUploadBox, _buildMaterialsWrap,
  // _buildStepsList, _buildDashedAddButton, _buildFooterButtons,
  // _showAddMaterialDialog, _showAddStepDialog

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      centerTitle: true,
      title: Column(
        children: [
          Text(
            "Edit STEM Challenge",
            style: GoogleFonts.poppins(
              color: _textDark,
              fontSize: 17.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 0.5.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCategory,
                isDense: true,
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  size: 18.sp,
                  color: _primaryBlue,
                ),
                items: _categories
                    .map(
                      (c) => DropdownMenuItem(
                    value: c,
                    child: Text(
                      c,
                      style: GoogleFonts.poppins(
                        color: _primaryBlue,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                    .toList(),
                onChanged: (val) => setState(() => _selectedCategory = val!),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) => Text(
    title,
    style: GoogleFonts.poppins(
      fontSize: 16.sp,
      fontWeight: FontWeight.w700,
      color: Colors.black,
    ),
  );

  Widget _buildLabel(String text) => Padding(
    padding: EdgeInsets.only(bottom: 1.h),
    child: Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: _textDark,
      ),
    ),
  );

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool isNumber = false,
    bool isCenter = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      textAlign: isCenter ? TextAlign.center : TextAlign.start,
      style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
          color: Colors.grey.shade400,
          fontWeight: FontWeight.w500,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _borderGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _primaryBlue, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildDifficultySelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: _difficultyLevels.map((level) {
          final isSelected = _selectedDifficulty == level;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedDifficulty = level),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 1.2.h),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isSelected
                      ? [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    level,
                    style: GoogleFonts.poppins(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? (level == 'Easy'
                          ? Colors.green
                          : (level == 'Medium'
                          ? Colors.orange
                          : Colors.red))
                          : Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildImageUploadBox() {
    ImageProvider? imageProvider;
    if (_newImageFile != null) {
      imageProvider = FileImage(_newImageFile!);
    } else if (_existingImageUrl != null && _existingImageUrl!.isNotEmpty){
      imageProvider = NetworkImage(_existingImageUrl!);
    }

    return CustomPaint(
      painter: DashedRectPainter(
        color: _dashedBorderColor,
        strokeWidth: 1.5,
        gap: 6,
      ),
      child: Container(
        height: 18.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () async {
            final ImagePicker picker = ImagePicker();
            final XFile? image = await picker.pickImage(
              source: ImageSource.gallery,
            );
            if (image != null) setState(() => _newImageFile = File(image.path));
          },
          child: imageProvider != null
              ? Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image(
                  image: imageProvider,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: InkWell(
                  onTap: () => setState(() {
                    _newImageFile = null;
                    _existingImageUrl = null;
                  }),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 14,
                    child: Icon(Icons.close, size: 16, color: Colors.red),
                  ),
                ),
              ),
            ],
          )
              : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_upload_rounded,
                size: 28.sp,
                color: Colors.grey.shade600,
              ),
              SizedBox(height: 1.h),
              Text(
                "Tap to change image",
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMaterialsWrap() {
    return Wrap(
      spacing: 2.w,
      runSpacing: 1.h,
      children: _materials
          .map(
            (material) => Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
          decoration: BoxDecoration(
            color: _lightBlue,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                material,
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: _primaryBlue,
                ),
              ),
              SizedBox(width: 1.w),
              InkWell(
                onTap: () => setState(() => _materials.remove(material)),
                child: Icon(
                  Icons.close,
                  size: 14.sp,
                  color: _primaryBlue.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      )
          .toList(),
    );
  }

  Widget _buildStepsList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _steps.length,
      separatorBuilder: (_, __) => SizedBox(height: 1.5.h),
      itemBuilder: (context, index) => Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _borderGrey),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: _primaryBlue,
              child: Text(
                "${index + 1}",
                style: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                _steps[index],
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: _textDark,
                ),
              ),
            ),
            InkWell(
              onTap: () => setState(() => _steps.removeAt(index)),
              child: Icon(
                Icons.delete_outline,
                size: 16.sp,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashedAddButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return CustomPaint(
      painter: DashedRectPainter(
        color: _dashedBorderColor,
        strokeWidth: 1.5,
        gap: 5,
        radius: 10,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 1.5.h),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle, color: _primaryBlue, size: 16.sp),
              SizedBox(width: 2.w),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: _primaryBlue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooterButtons(bool isLoading) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 6.5.h,
          child: ElevatedButton(
            onPressed: isLoading ? null : _updateChallenge,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: isLoading
                ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
                : Text(
              "Update Challenge",
              style: GoogleFonts.poppins(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(height: 2.h),
        TextButton(
          onPressed: isLoading ? null : () => Navigator.pop(context),
          child: Text(
            "Cancel",
            style: GoogleFonts.poppins(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ],
    );
  }

  void _showAddMaterialDialog() {
    _materialController.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          "Add Material",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: _materialController,
          decoration: InputDecoration(
            hintText: "e.g. 2 AA Batteries",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (_materialController.text.isNotEmpty) {
                setState(() => _materials.add(_materialController.text));
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: _primaryBlue),
            child: const Text("Add", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddStepDialog() {
    TextEditingController stepCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          "Add Instruction Step",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: stepCtrl,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: "Describe the step...",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (stepCtrl.text.isNotEmpty) {
                setState(() => _steps.add(stepCtrl.text));
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: _primaryBlue),
            child: const Text("Add", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class DashedRectPainter extends CustomPainter {
  final double strokeWidth;
  final Color color;
  final double gap;
  final double radius;
  DashedRectPainter({
    this.strokeWidth = 1.0,
    this.color = Colors.red,
    this.gap = 5.0,
    this.radius = 0,
  });
  @override
  void paint(Canvas canvas, Size size) {
    Paint dashedPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    Path path = Path();
    path.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(radius),
      ),
    );
    PathMetrics pathMetrics = path.computeMetrics();
    for (PathMetric pathMetric in pathMetrics) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        canvas.drawPath(
          pathMetric.extractPath(distance, distance + 5),
          dashedPaint,
        );
        distance += 5 + gap;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}