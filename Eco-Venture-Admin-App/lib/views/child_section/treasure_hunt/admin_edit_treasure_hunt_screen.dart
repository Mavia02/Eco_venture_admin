import 'dart:convert';
import 'package:eco_venture_admin_portal/core/config/api_constant.dart';
import 'package:http/http.dart' as http; // Add HTTP import
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../../models/qr_hunt_model.dart';
import '../../../viewmodels/child_section/qr_treasure_hunt/admin_treasure_hunt_provider.dart';

class AdminEditTreasureHuntScreen extends ConsumerStatefulWidget {
  final dynamic huntData;
  const AdminEditTreasureHuntScreen({super.key, required this.huntData});

  @override
  ConsumerState<AdminEditTreasureHuntScreen> createState() =>
      _AdminEditTreasureHuntScreenState();
}

class _AdminEditTreasureHuntScreenState
    extends ConsumerState<AdminEditTreasureHuntScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _pointsController = TextEditingController();

  // --- NEW CONTROLLERS ---
  late TextEditingController _tagsController;
  late bool _isSensitive;
  // -----------------------

  late QrHuntModel _hunt;
  String _difficulty = 'Easy';
  final List<String> _difficultyLevels = ['Easy', 'Medium', 'Hard'];
  List<TextEditingController> _clueControllers = [];

  final Color _primary = const Color(0xFF00C853);
  final Color _bg = const Color(0xFFF4F7FE);
  final Color _textDark = const Color(0xFF1B2559);
  final Color _border = const Color(0xFFE0E0E0);

  @override
  void initState() {
    super.initState();
    // 1. Parse Data
    if (widget.huntData is QrHuntModel) {
      _hunt = widget.huntData;
    } else {
      final map = Map<String, dynamic>.from(widget.huntData);
      _hunt = QrHuntModel.fromMap(map['id'], map);
    }

    _titleController.text = _hunt.title;
    _pointsController.text = _hunt.points.toString();
    _difficulty = _hunt.difficulty;

    // --- NEW: Initialize Tags & Sensitivity ---
    _tagsController = TextEditingController(text: _hunt.tags.join(', '));
    _isSensitive = _hunt.isSensitive;
    // ------------------------------------------

    for (var clue in _hunt.clues) {
      _clueControllers.add(TextEditingController(text: clue));
    }
    if (_clueControllers.isEmpty) {
      _clueControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _pointsController.dispose();
    _tagsController.dispose(); // Dispose tags controller
    for (var c in _clueControllers) c.dispose();
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
          "title": "Treasure Hunt Updated! 🗺️",
          "body": "Updates made to '$title'. Check it out!",
          "type": "QR_HUNT",
          "targetRole": "child", // Notify children only
        }),
      );

      if (response.statusCode == 200) {
        print("✅ Notification sent successfully");
      }
    } catch (e) {
      print("❌ Error calling backend: $e");
    }
  }

  Future<void> _updateHunt() async {
    if (_titleController.text.isEmpty) return;

    List<String> clues = _clueControllers
        .where((c) => c.text.isNotEmpty)
        .map((c) => c.text)
        .toList();

    if (clues.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Keep at least one valid clue"),
          backgroundColor: Colors.red,
        ),
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

    final updatedHunt = _hunt.copyWith(
      title: _titleController.text.trim(),
      points: int.tryParse(_pointsController.text.trim()) ?? 0,
      difficulty: _difficulty,
      clues: clues,
      // --- Update New Fields ---
      tags: tagsList,
      isSensitive: _isSensitive,
    );

    await ref
        .read(adminTreasureHuntViewModelProvider.notifier)
        .updateHunt(updatedHunt);

    // --- Trigger Notification (If not sensitive) ---
    if (!_isSensitive) {
      _sendNotificationToUsers(updatedHunt.title);
    }
  }

  // --- RE-PRINT PDF LOGIC (Unchanged) ---
  Future<void> _reprintPdf() async {
    if (_hunt.id == null || _titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cannot generate QR codes without ID or Title."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    try {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async {
          final doc = pw.Document();
          for (int i = 0; i < _clueControllers.length; i++) {
            final qrData = "${_hunt.id}_$i";
            doc.addPage(
              pw.Page(
                pageFormat: format,
                build: (pw.Context context) {
                  return pw.Center(
                    child: pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.Text(
                          "Clue #${i + 1}",
                          style: pw.TextStyle(
                            fontSize: 30,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 10),
                        pw.Text(
                          "Hunt: ${_titleController.text}",
                          style: pw.TextStyle(
                            fontSize: 20,
                            color: PdfColors.grey700,
                          ),
                        ),
                        pw.SizedBox(height: 40),
                        pw.BarcodeWidget(
                          barcode: pw.Barcode.qrCode(),
                          data: qrData,
                          width: 300,
                          height: 300,
                        ),
                        pw.SizedBox(height: 40),
                        pw.Text(
                          "Hide this QR code at location #${i + 1}",
                          style: pw.TextStyle(fontSize: 18),
                        ),
                        pw.SizedBox(height: 10),
                        pw.Text(
                          "Players must find this to unlock Clue #${i + 2} (or finish).",
                          style: const pw.TextStyle(
                            fontSize: 14,
                            color: PdfColors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          }
          return doc.save();
        },
      );
    } catch (e) {
      print("Print Error: $e");
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error generating PDF: $e"),
            backgroundColor: Colors.red,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminTreasureHuntViewModelProvider);

    ref.listen(adminTreasureHuntViewModelProvider, (prev, next) {
      if (next.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Hunt Updated!"),
            backgroundColor: Colors.green,
          ),
        );
        ref.read(adminTreasureHuntViewModelProvider.notifier).resetSuccess();
        Navigator.pop(context);
      }
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${next.errorMessage}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Edit QR Hunt",
          style: GoogleFonts.poppins(
            color: _textDark,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(5.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader("Edit Details"),
                SizedBox(height: 2.h),
                _buildLabel("Task Name"),
                _buildTextField(_titleController, "Title"),
                SizedBox(height: 2.h),
                _buildLabel("Points"),
                _buildTextField(_pointsController, "100", isNumber: true),
                SizedBox(height: 2.h),
                _buildLabel("Difficulty"),
                _buildDropdown(),

                // --- NEW UI ELEMENTS ---
                SizedBox(height: 2.h),
                _buildLabel("Tags (comma-separated)"),
                _buildTextField(_tagsController, "e.g. outdoors, fun, team"),

                SizedBox(height: 2.h),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _border),
                  ),
                  child: SwitchListTile(
                    activeColor: Colors.red,
                    title: Text(
                      "Sensitive Content",
                      style: GoogleFonts.poppins(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.red.shade700,
                      ),
                    ),
                    subtitle: Text(
                      "Hide from younger children",
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: Colors.grey,
                      ),
                    ),
                    value: _isSensitive,
                    onChanged: (val) => setState(() => _isSensitive = val),
                  ),
                ),

                // -----------------------
                SizedBox(height: 4.h),

                _buildSectionHeader("Edit Clues"),
                ...List.generate(
                  _clueControllers.length,
                  (i) => Padding(
                    padding: EdgeInsets.only(bottom: 2.h),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Clue ${i + 1}",
                              style: GoogleFonts.poppins(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (_clueControllers.length > 1)
                              InkWell(
                                onTap: () => setState(
                                  () => _clueControllers.removeAt(i),
                                ),
                                child: Text(
                                  "Remove",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 13.sp,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 1.h),
                        _buildTextField(_clueControllers[i], "Clue ${i + 1}"),
                      ],
                    ),
                  ),
                ),

                InkWell(
                  onTap: () => setState(
                    () => _clueControllers.add(TextEditingController()),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.add, color: _textDark, size: 18.sp),
                      SizedBox(width: 2.w),
                      Text(
                        "Add Clue",
                        style: GoogleFonts.poppins(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: _textDark,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 4.h),

                // --- RE-PRINT BUTTON ---
                SizedBox(
                  width: double.infinity,
                  height: 6.h,
                  child: OutlinedButton.icon(
                    onPressed: _reprintPdf,
                    icon: Icon(Icons.print, color: _primary),
                    label: Text(
                      "Re-Print All Codes (PDF)",
                      style: GoogleFonts.poppins(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: _primary,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: _primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 3.h),

                SizedBox(
                  width: double.infinity,
                  height: 7.h,
                  child: ElevatedButton(
                    onPressed: state.isLoading ? null : _updateHunt,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E676),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: state.isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            "Update Hunt",
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
              color: Colors.black12,
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  // Helper widgets (Same as before)
  Widget _buildSectionHeader(String title) => Text(
    title,
    style: GoogleFonts.poppins(
      fontSize: 16.sp,
      fontWeight: FontWeight.w700,
      color: _textDark,
    ),
  );
  Widget _buildLabel(String text) => Padding(
    padding: EdgeInsets.only(bottom: 1.h),
    child: Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 15.sp,
        fontWeight: FontWeight.w600,
        color: _textDark,
      ),
    ),
  );
  Widget _buildTextField(
    TextEditingController ctrl,
    String hint, {
    bool isNumber = false,
    int maxLines = 1,
  }) => TextField(
    controller: ctrl,
    keyboardType: isNumber ? TextInputType.number : TextInputType.text,
    maxLines: maxLines,
    style: GoogleFonts.poppins(fontSize: 15.sp),
    decoration: InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.all(4.w),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _border),
      ),
    ),
  );
  Widget _buildDropdown() => Container(
    padding: EdgeInsets.symmetric(horizontal: 4.w),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: _border),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: _difficulty,
        isExpanded: true,
        items: _difficultyLevels
            .map(
              (c) => DropdownMenuItem(
                value: c,
                child: Text(c, style: GoogleFonts.poppins(fontSize: 15.sp)),
              ),
            )
            .toList(),
        onChanged: (v) => setState(() => _difficulty = v!),
      ),
    ),
  );
}
