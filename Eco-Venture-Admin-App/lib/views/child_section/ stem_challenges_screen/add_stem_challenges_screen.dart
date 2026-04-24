import 'dart:convert';
import 'dart:ui'; // REQUIRED for PathMetrics and PathMetric
import 'dart:io';
import 'package:eco_venture_admin_portal/core/config/api_constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 1. Import Riverpod
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../models/stem_challenge_model.dart';
import '../../../viewmodels/child_section/Stem_challenges/stem_challenges_provider.dart';


class AddStemChallengeScreen extends ConsumerStatefulWidget {
  const AddStemChallengeScreen({super.key});

  @override
  ConsumerState<AddStemChallengeScreen> createState() => _AddStemChallengeScreenState();
}

class _AddStemChallengeScreenState extends ConsumerState<AddStemChallengeScreen> {
  // --- COLORS ---
  final Color _primaryBlue = const Color(0xFF1976D2);
  final Color _lightBlue = const Color(0xFFE3F2FD);
  final Color _textDark = const Color(0xFF2D3436);
  final Color _borderGrey = const Color(0xFFE0E0E0);
  final Color _dashedBorderColor = const Color(0xFFBDBDBD);

  // --- CONTROLLERS & STATE ---
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _pointsController = TextEditingController(text: "50");
  final TextEditingController _materialController = TextEditingController();

  // --- NEW FIELDS ---
  final TextEditingController _tagsController = TextEditingController();
  bool _isSensitive = false;
  // -----------------

  String _selectedCategory = 'Science';
  final List<String> _categories = ['Science', 'Technology', 'Engineering', 'Mathematics'];

  String _selectedDifficulty = 'Easy';
  final List<String> _difficultyLevels = ['Easy', 'Medium', 'Hard'];

  File? _challengeImage;
  final List<String> _materials = [];
  final List<String> _steps = [];

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
    const String backendUrl = ApiConstants.notifyByRoleEndPoints; // Use correct IP

    try {
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "title": "New STEM Challenge! 🧪",
          "body": "Try the '$title' challenge in $category!",
          "type": "STEM",
          "targetRole": "child" // Notify children only
        }),
      );

      if (response.statusCode == 200) {
        print("✅ Notification sent successfully");
      } else {
        print("❌ Notification failed: ${response.body}");
      }
    } catch (e) {
      print("❌ Error calling backend: $e");
    }
  }

  // --- SAVE LOGIC ---
  Future<void> _saveChallenge() async {
    // Basic Validation
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a title')));
      return;
    }
    if (_pointsController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter points')));
      return;
    }

    final points = int.tryParse(_pointsController.text.trim()) ?? 0;

    // --- 1. Process Tags & Sensitivity ---
    List<String> tagsList = _tagsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    // Auto-tag logic
    if (_isSensitive && !tagsList.contains('scary')) {
      tagsList.add('scary');
    }
    if (!_isSensitive) {
      tagsList.remove('scary');
    }

    // Create Model
    final newChallenge = StemChallengeModel(
      title: _titleController.text.trim(),
      category: _selectedCategory,
      difficulty: _selectedDifficulty,
      points: points,
      imageUrl: _challengeImage?.path,
      materials: _materials,
      steps: _steps,
      // --- Pass New Fields ---
      tags: tagsList,
      isSensitive: _isSensitive,
    );

    // Call ViewModel to start upload process
    await ref.read(stemChallengesViewModelProvider.notifier).addChallenge(newChallenge);

    // --- Trigger Notification (If not sensitive) ---
    if (!_isSensitive) {
      _sendNotificationToUsers(newChallenge.title, newChallenge.category);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModelState = ref.watch(stemChallengesViewModelProvider);

    ref.listen(stemChallengesViewModelProvider, (previous, next) {
      if (next.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$_selectedCategory Challenge Saved!'), backgroundColor: Colors.green),
        );
        ref.read(stemChallengesViewModelProvider.notifier).resetSuccess();
        Navigator.pop(context);
      } else if (next.errorMessage != null && !next.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${next.errorMessage}'), backgroundColor: Colors.red),
        );
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
                  // --- SECTION 1: DETAILS ---
                  _buildSectionHeader("Challenge Details"),
                  SizedBox(height: 2.h),

                  _buildLabel("Challenge Title"),
                  _buildTextField(controller: _titleController, hint: "Enter challenge title"),
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
                    child: _buildTextField(controller: _pointsController, hint: "0", isNumber: true, isCenter: true),
                  ),
                  SizedBox(height: 2.h),

                  _buildLabel("Upload Challenge Image"),
                  _buildImageUploadBox(),
                  SizedBox(height: 4.h),

                  // --- SECTION 2: MATERIALS ---
                  _buildSectionHeader("Materials / Apparatus Required"),
                  SizedBox(height: 2.h),
                  _buildMaterialsWrap(),
                  SizedBox(height: 1.5.h),
                  _buildDashedAddButton(label: "Add Material", onTap: _showAddMaterialDialog),
                  SizedBox(height: 4.h),

                  // --- SECTION 3: STEPS ---
                  _buildSectionHeader("Step-by-Step Instructions"),
                  SizedBox(height: 2.h),
                  _buildStepsList(),
                  SizedBox(height: 1.5.h),
                  _buildDashedAddButton(label: "Add Step", onTap: _showAddStepDialog),

                  SizedBox(height: 5.h),

                  // --- FOOTER BUTTONS ---
                  _buildFooterButtons(viewModelState.isLoading),
                  SizedBox(height: 5.h),
                ],
              ),
            ),
            if (viewModelState.isLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(child: CircularProgressIndicator(color: _primaryBlue)),
              ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS (Same as before) ---

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
            "Add STEM Challenge",
            style: GoogleFonts.poppins(color: _textDark, fontSize: 17.sp, fontWeight: FontWeight.w700),
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
                icon: Icon(Icons.keyboard_arrow_down, size: 16, color: _primaryBlue),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c, style: GoogleFonts.poppins(color: _primaryBlue, fontSize: 10.sp, fontWeight: FontWeight.w600)))).toList(),
                onChanged: (val) => setState(() => _selectedCategory = val!),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 16.sp,
        fontWeight: FontWeight.w700,
        color: Colors.black,
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Text(
        text,
        style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w600, color: _textDark),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, bool isNumber = false, bool isCenter = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      textAlign: isCenter ? TextAlign.center : TextAlign.start,
      style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w600,color: Colors.grey.shade700),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400, fontWeight: FontWeight.w500),
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
                  boxShadow: isSelected ? [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))] : [],
                ),
                child: Center(
                  child: Text(
                    level,
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? (level == 'Easy' ? Colors.green : (level == 'Medium' ? Colors.orange : Colors.red))
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
    return CustomPaint(
      painter: DashedRectPainter(color: _dashedBorderColor, strokeWidth: 1.5, gap: 6),
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
            final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
            if (image != null) setState(() => _challengeImage = File(image.path));
          },
          child: _challengeImage != null
              ? Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(_challengeImage!, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
              ),
              Positioned(
                top: 8, right: 8,
                child: InkWell(
                  onTap: () => setState(() => _challengeImage = null),
                  child: CircleAvatar(backgroundColor: Colors.white, radius: 14, child: Icon(Icons.close, size: 16, color: Colors.red)),
                ),
              ),
            ],
          )
              : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_upload_rounded, size: 28.sp, color: Colors.grey.shade600),
              SizedBox(height: 1.h),
              Text("Click to upload or drag and drop", style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
              Text("SVG, PNG, JPG (MAX. 800x400px)", style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.grey.shade800)),
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
      children: _materials.map((material) {
        return Container(
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
                style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600, color: _primaryBlue),
              ),
              SizedBox(width: 1.w),
              InkWell(
                onTap: () => setState(() => _materials.remove(material)),
                child: Icon(Icons.close, size: 14.sp, color: _primaryBlue.withOpacity(0.7)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStepsList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _steps.length,
      separatorBuilder: (_, __) => SizedBox(height: 1.5.h),
      itemBuilder: (context, index) {
        return Container(
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
                  style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  _steps[index],
                  style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w500, color: _textDark),
                ),
              ),
              InkWell(
                onTap: () => setState(() => _steps.removeAt(index)),
                child: Icon(Icons.delete_outline, size: 16.sp, color: Colors.grey.shade600),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDashedAddButton({required String label, required VoidCallback onTap}) {
    return CustomPaint(
      painter: DashedRectPainter(color: _dashedBorderColor, strokeWidth: 1.5, gap: 5, radius: 10),
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
                style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w600, color: _primaryBlue),
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
            onPressed: isLoading ? null : _saveChallenge,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: isLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(
              "Save Challenge",
              style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ),
        ),
        SizedBox(height: 1.5.h),
        TextButton(
          onPressed: isLoading ? null : () => Navigator.pop(context),
          child: Text(
            "Cancel / Back to List",
            style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
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
        title: Text("Add Material", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: _materialController,
          decoration: InputDecoration(hintText: "e.g. 2 AA Batteries", border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (_materialController.text.trim().isNotEmpty) {
                setState(() => _materials.add(_materialController.text.trim()));
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
        title: Text("Add Instruction Step", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: stepCtrl,
          maxLines: 3,
          decoration: InputDecoration(hintText: "Describe the step...", border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (stepCtrl.text.trim().isNotEmpty) {
                setState(() => _steps.add(stepCtrl.text.trim()));
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

  DashedRectPainter({this.strokeWidth = 1.0, this.color = Colors.red, this.gap = 5.0, this.radius = 0});

  @override
  void paint(Canvas canvas, Size size) {
    Paint dashedPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    Path path = Path();
    path.addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(radius)
    ));

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