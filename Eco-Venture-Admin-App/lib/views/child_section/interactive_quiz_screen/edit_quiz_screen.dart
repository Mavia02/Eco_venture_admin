import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../models/quiz_topic_model.dart';
import '../../../viewmodels/child_section/interactive_quiz/quiz_provider.dart';

class EditQuizScreen extends ConsumerStatefulWidget {
  final QuizTopicModel topic;

  const EditQuizScreen({super.key, required this.topic});

  @override
  ConsumerState<EditQuizScreen> createState() => _EditQuizScreenState();
}

class _EditQuizScreenState extends ConsumerState<EditQuizScreen> {
  // --- PRO COLOR PALETTE ---
  final Color _primary = const Color(0xFF05664F);
  final Color _bg = const Color(0xFFF8F9FA);
  final Color _surface = Colors.white;
  final Color _textDark = const Color(0xFF1A1D1E);
  final Color _textGrey = const Color(0xFF546E7A);
  final Color _border = const Color(0xFFE9ECEF);

  // --- CONTROLLERS ---
  late TextEditingController _topicNameController;
  late TextEditingController _tagsController;
  late bool _isSensitive;

  bool _hasSignificantChanges = false;

  // --- STATE ---
  late String _selectedCategory;
  final List<String> _categories = [
    'Animals',
    'Ecosystem',
    'Science',
    'Space',
    'Plants',
    'Mathematics',
  ];
  late List<QuizLevelModel> _levels;

  @override
  void initState() {
    super.initState();
    // Existing initialization...
    _topicNameController = TextEditingController(text: widget.topic.topicName);
    _selectedCategory = widget.topic.category;
    _levels = List<QuizLevelModel>.from(widget.topic.levels);

    // NEW: Initialize tags and sensitivity
    _tagsController = TextEditingController(
      text: widget.topic.tags?.join(', ') ?? '',
    );
    _isSensitive = widget.topic.isSensitive ?? false;
  }

  @override
  void dispose() {
    // Existing disposals...
    _topicNameController.dispose();
    _tagsController.dispose(); // NEW: Dispose tags controller
    super.dispose();
  }

  Future<void> _updateTopic() async {
    if (_topicNameController.text.trim().isEmpty) {
      _showError("Please enter a Topic Name");
      return;
    }
    if (_levels.isEmpty) {
      _showError("Please ensure there is at least one Level");
      return;
    }

    final updatedTopic = widget.topic.copyWith(
      category: _selectedCategory,
      topicName: _topicNameController.text.trim(),
      levels: _levels,
    );

    await ref.read(quizViewModelProvider.notifier).updateTopic(updatedTopic);
  }



  void _checkForChanges() {
    // Process tags for comparison
    List<String> currentTags = _tagsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    // Add/remove 'scary' based on sensitivity
    if (_isSensitive && !currentTags.contains('scary')) {
      currentTags.add('scary');
    }
    if (!_isSensitive) {
      currentTags.remove('scary');
    }

    final originalTags = widget.topic.tags ?? [];

    // Check for significant changes (trigger notifications)
    _hasSignificantChanges =
        _topicNameController.text != widget.topic.topicName ||
            _selectedCategory != widget.topic.category ||
            _isSensitive != (widget.topic.isSensitive ?? false) ||
            !_areListsEqual(currentTags, originalTags) ||
            _levels.length != widget.topic.levels.length;
  }

  bool _areListsEqual(List<String> list1, List<String> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: TextStyle(fontSize: 14.sp)),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final quizState = ref.watch(quizViewModelProvider);

    ref.listen(quizViewModelProvider, (previous, next) {
      if (next.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Topic Updated Successfully!",
              style: TextStyle(fontSize: 14.sp),
            ),
            backgroundColor: _primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
        ref.read(quizViewModelProvider.notifier).resetSuccess();
        Navigator.pop(context);
      }
      if (next.errorMessage != null) {
        _showError(next.errorMessage!);
      }
    });

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _surface,
        surfaceTintColor: _surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: _textDark, size: 19.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Edit Topic",
          style: GoogleFonts.poppins(
            color: _textDark,
            fontWeight: FontWeight.w700,
            fontSize: 18.sp,
          ),
        ),
        actions: [
          TextButton(
            onPressed: quizState.isLoading ? null : _updateTopic,
            child: quizState.isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _primary,
                    ),
                  )
                : Text(
                    "Save",
                    style: GoogleFonts.poppins(
                      color: _primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
          ),
          SizedBox(width: 2.w),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Container(color: _border, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SECTION 1: GENERAL INFO ---
            Text(
              "General Info",
              style: GoogleFonts.poppins(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: _textGrey,
              ),
            ),
            SizedBox(height: 1.5.h),

            Container(
              padding: EdgeInsets.all(5.w),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: _border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProLabel("Topic Category"),
                  SizedBox(height: 1.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    decoration: BoxDecoration(
                      color: _bg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCategory,
                        isExpanded: true,
                        icon: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: _textDark,
                          size: 22.sp,
                        ),
                        items: _categories
                            .map(
                              (c) => DropdownMenuItem(
                                value: c,
                                child: Text(
                                  c,
                                  style: GoogleFonts.poppins(
                                    fontSize: 15.sp,
                                    color: _textDark,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _selectedCategory = val!),
                      ),
                    ),
                  ),
                  SizedBox(height: 3.h),

                  _buildProLabel("Topic Title"),
                  // Inside the Column of "General Info" card (after topic title field):
                  SizedBox(height: 3.h),

                  _buildProLabel("Tags (comma-separated)"),
                  SizedBox(height: 1.h),
                  _buildProTextField(
                    controller: _tagsController,
                    hint: "e.g. history, fun, basics",
                    icon: Icons.tag_rounded,
                  ),
                  SizedBox(height: 2.h),

// Sensitivity Toggle
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: _isSensitive ? Colors.red.shade50 : _bg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _isSensitive ? Colors.red.shade200 : _border,
                      ),
                    ),
                    child: SwitchListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      activeColor: Colors.red,
                      activeTrackColor: Colors.red.shade200,
                      title: Text(
                        "Sensitive Content",
                        style: GoogleFonts.poppins(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: _isSensitive ? Colors.red.shade700 : _textGrey,
                        ),
                      ),
                      subtitle: Text(
                        "Hide from younger children",
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          color: _isSensitive ? Colors.red.shade600 : Colors.grey.shade500,
                        ),
                      ),
                      value: _isSensitive,
                      onChanged: (value) {
                        setState(() {
                          _isSensitive = value;
                          _checkForChanges();
                        });
                      },
                    ),
                  ),

                  if (_hasSignificantChanges) ...[
                    SizedBox(height: 2.h),
                    Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.notifications_active_rounded,
                              color: Colors.amber.shade700),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Users will be notified",
                                  style: GoogleFonts.poppins(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.amber.shade900,
                                  ),
                                ),
                                SizedBox(height: 0.5.h),
                                Text(
                                  "Significant changes will trigger notifications to children and parents",
                                  style: GoogleFonts.poppins(
                                    fontSize: 12.sp,
                                    color: Colors.amber.shade800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  SizedBox(height: 1.h),
                  _buildProTextField(
                    controller: _topicNameController,
                    hint: "e.g. Solar System",
                    icon: Icons.title_rounded,
                  ),
                ],
              ),
            ),

            SizedBox(height: 4.h),

            // --- SECTION 2: LEVELS ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Levels Config",
                  style: GoogleFonts.poppins(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: _textGrey,
                  ),
                ),
                InkWell(
                  onTap: () => _showLevelEditor(),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 1.h,
                    ),
                    decoration: BoxDecoration(
                      color: _primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.add_rounded, size: 18.sp, color: _primary),
                        SizedBox(width: 1.5.w),
                        Text(
                          "Add Level",
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: _primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.5.h),

            if (_levels.isEmpty)
              _buildEmptyState()
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _levels.length,
                separatorBuilder: (c, i) => SizedBox(height: 2.h),
                itemBuilder: (context, index) =>
                    _buildProLevelCard(index, _levels[index]),
              ),

            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }

  // --- PRO WIDGETS ---

  Widget _buildProLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 14.sp,
        fontWeight: FontWeight.w700,
        color: _textGrey,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildProTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: GoogleFonts.poppins(
        fontSize: 15.sp,
        color: _textDark,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
          color: Colors.grey.shade400,
          fontSize: 15.sp,
        ),
        prefixIcon: Icon(icon, size: 20.sp, color: _textGrey),
        filled: true,
        fillColor: _bg,
        contentPadding: EdgeInsets.symmetric(vertical: 2.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _primary, width: 2),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border, style: BorderStyle.solid),
      ),
      child: Column(
        children: [
          Icon(
            Icons.layers_clear_outlined,
            size: 32.sp,
            color: Colors.grey.shade300,
          ),
          SizedBox(height: 1.h),
          Text(
            "No Levels Added",
            style: GoogleFonts.poppins(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: _textGrey,
            ),
          ),
          Text(
            "Create a learning path by adding levels.",
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              color: Colors.grey.shade400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // --- ULTRA PRO CARD ---
  Widget _buildProLevelCard(int index, QuizLevelModel level) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: _border),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          leading: Container(
            width: 13.w,
            height: 13.w,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade50, Colors.blue.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                "${level.order}",
                style: GoogleFonts.poppins(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.blue.shade800,
                ),
              ),
            ),
          ),
          title: Text(
            level.title,
            style: GoogleFonts.poppins(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: _textDark,
            ),
          ),
          subtitle: Padding(
            padding: EdgeInsets.only(top: 0.5.h),
            child: Row(
              children: [
                _buildChip(
                  Icons.star_rounded,
                  "${level.points} pts",
                  Colors.amber,
                ),
                SizedBox(width: 2.w),
                _buildChip(
                  Icons.quiz_rounded,
                  "${level.questions.length} Qs",
                  Colors.purple,
                ),
              ],
            ),
          ),
          childrenPadding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 2.h),
          children: [
            Divider(color: _border),
            SizedBox(height: 1.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildChip(
                  Icons.check_circle_outline,
                  "Pass: ${level.passingPercentage}%",
                  Colors.green,
                ),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () =>
                          _showLevelEditor(existingLevel: level, index: index),
                      icon: Icon(
                        Icons.edit_rounded,
                        size: 17.sp,
                        color: _primary,
                      ),
                      label: Text(
                        "Edit",
                        style: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: _primary,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: _primary.withOpacity(0.1),
                      ),
                    ),
                    SizedBox(width: 2.w),
                    IconButton(
                      onPressed: () => setState(() => _levels.removeAt(index)),
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.red.shade400,
                        size: 19.sp,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.red.shade50,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: color),
        SizedBox(width: 1.w),
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: _textGrey,
          ),
        ),
      ],
    );
  }

  // ==========================================
  // LEVEL EDITOR MODAL (With Pass % & Edit Question Logic)
  // ==========================================
  void _showLevelEditor({QuizLevelModel? existingLevel, int? index}) {
    final titleCtrl = TextEditingController(text: existingLevel?.title ?? "");
    final orderCtrl = TextEditingController(
      text: existingLevel?.order.toString() ?? "${_levels.length + 1}",
    );
    final pointsCtrl = TextEditingController(
      text: existingLevel?.points.toString() ?? "10",
    );
    final passCtrl = TextEditingController(
      text: existingLevel?.passingPercentage.toString() ?? "60",
    );

    List<QuestionModel> tempQuestions = existingLevel != null
        ? List.from(existingLevel.questions)
        : [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: 92.h,
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(25),
              ),
            ),
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 2.h),
                  width: 15.w,
                  height: 5,
                  decoration: BoxDecoration(
                    color: _border,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(5.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        existingLevel == null ? "Add Level" : "Edit Level",
                        style: GoogleFonts.poppins(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w800,
                          color: _textDark,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close, color: _textGrey, size: 22.sp),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: _border),

                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(
                      horizontal: 5.w,
                      vertical: 2.h,
                    ),
                    children: [
                      _buildProLabel("Level Configuration"),
                      SizedBox(height: 1.5.h),
                      _buildProTextField(
                        controller: titleCtrl,
                        hint: "e.g. Intro to Jungle",
                        icon: Icons.text_fields_rounded,
                      ),
                      SizedBox(height: 2.h),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildProLabel("Order"),
                                SizedBox(height: 1.h),
                                _buildProTextField(
                                  controller: orderCtrl,
                                  hint: "1",
                                  icon: Icons.format_list_numbered_rounded,
                                  isNumber: true,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildProLabel("Points"),
                                SizedBox(height: 1.h),
                                _buildProTextField(
                                  controller: pointsCtrl,
                                  hint: "10",
                                  icon: Icons.star_border_rounded,
                                  isNumber: true,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),
                      _buildProLabel("Passing Percentage"),
                      SizedBox(height: 1.h),
                      _buildProTextField(
                        controller: passCtrl,
                        hint: "60",
                        icon: Icons.percent_rounded,
                        isNumber: true,
                      ),

                      SizedBox(height: 4.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Questions (${tempQuestions.length})",
                            style: GoogleFonts.poppins(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: _textDark,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => _showQuestionEditor(
                              context,
                              (newQ) =>
                                  setModalState(() => tempQuestions.add(newQ)),
                            ),
                            icon: Icon(Icons.add, size: 18.sp),
                            label: Text(
                              "Add Question",
                              style: GoogleFonts.poppins(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              foregroundColor: _primary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 1.h),

                      if (tempQuestions.isEmpty)
                        Container(
                          padding: EdgeInsets.all(3.h),
                          decoration: BoxDecoration(
                            color: _bg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _border),
                          ),
                          child: Center(
                            child: Text(
                              "No questions added yet",
                              style: GoogleFonts.poppins(
                                fontSize: 14.sp,
                                color: _textGrey,
                              ),
                            ),
                          ),
                        )
                      else
                        ...tempQuestions
                            .asMap()
                            .entries
                            .map(
                              (e) => Container(
                                margin: EdgeInsets.only(bottom: 1.5.h),
                                decoration: BoxDecoration(
                                  color: _surface,
                                  border: Border.all(color: _border),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  dense: true,
                                  title: Text(
                                    "Q${e.key + 1}: ${e.value.question}",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: _textDark,
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // --- EDIT BUTTON ADDED HERE ---
                                      IconButton(
                                        icon: Icon(
                                          Icons.edit,
                                          color: _primary,
                                          size: 20.sp,
                                        ),
                                        onPressed: () {
                                          _showQuestionEditor(
                                            context,
                                            (updatedQ) {
                                              setModalState(() {
                                                tempQuestions[e.key] = updatedQ;
                                              });
                                            },
                                            existingQuestion:
                                                e.value, // Pass existing data
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete_outline,
                                          color: Colors.red.shade300,
                                          size: 20.sp,
                                        ),
                                        onPressed: () => setModalState(
                                          () => tempQuestions.removeAt(e.key),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      SizedBox(height: 10.h),
                    ],
                  ),
                ),

                Container(
                  padding: EdgeInsets.all(5.w),
                  decoration: BoxDecoration(
                    color: _surface,
                    border: Border(top: BorderSide(color: _border)),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 7.h,
                    child: ElevatedButton(
                      onPressed: () {
                        if (titleCtrl.text.isEmpty) return;
                        final newLevel = QuizLevelModel(
                          title: titleCtrl.text,
                          order: int.tryParse(orderCtrl.text) ?? 1,
                          passingPercentage: int.tryParse(passCtrl.text) ?? 60,
                          points: int.tryParse(pointsCtrl.text) ?? 10,
                          questions: tempQuestions,
                        );

                        setState(() {
                          if (index != null)
                            _levels[index] = newLevel;
                          else
                            _levels.add(newLevel);
                          _levels.sort((a, b) => a.order.compareTo(b.order));
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _textDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        index == null ? "ADD LEVEL" : "UPDATE LEVEL",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- QUESTION EDITOR (Handles Add & Edit) ---
  void _showQuestionEditor(
    BuildContext ctx,
    Function(QuestionModel) onSave, {
    QuestionModel? existingQuestion,
  }) {
    final qTextController = TextEditingController(
      text: existingQuestion?.question ?? "",
    );
    final op1 = TextEditingController(
      text: existingQuestion?.options.isNotEmpty == true
          ? existingQuestion!.options[0]
          : "",
    );
    final op2 = TextEditingController(
      text: existingQuestion?.options.length == 4
          ? existingQuestion!.options[1]
          : "",
    );
    final op3 = TextEditingController(
      text: existingQuestion?.options.length == 4
          ? existingQuestion!.options[2]
          : "",
    );
    final op4 = TextEditingController(
      text: existingQuestion?.options.length == 4
          ? existingQuestion!.options[3]
          : "",
    );

    int correctIdx = 0;
    if (existingQuestion != null) {
      int foundIdx = existingQuestion.options.indexOf(existingQuestion.answer);
      if (foundIdx != -1) correctIdx = foundIdx;
    }

    showDialog(
      context: ctx,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          backgroundColor: _surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.all(5.w),
            height: 75.h,
            child: Column(
              children: [
                Text(
                  existingQuestion == null ? "New Question" : "Edit Question",
                  style: GoogleFonts.poppins(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 3.h),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildProTextField(
                          controller: qTextController,
                          hint: "Question Text",
                          icon: Icons.help_outline,
                        ),
                        SizedBox(height: 2.h),
                        ...List.generate(
                          4,
                          (i) => Padding(
                            padding: EdgeInsets.only(bottom: 1.h),
                            child: Row(
                              children: [
                                Radio(
                                  value: i,
                                  groupValue: correctIdx,
                                  onChanged: (v) =>
                                      setState(() => correctIdx = v!),
                                  activeColor: _primary,
                                ),
                                Expanded(
                                  child: TextField(
                                    controller: [op1, op2, op3, op4][i],
                                    style: TextStyle(fontSize: 14.sp),
                                    decoration: InputDecoration(
                                      hintText: "Option ${i + 1}",
                                      filled: true,
                                      fillColor: _bg,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
                SizedBox(
                  width: double.infinity,
                  height: 6.5.h,
                  child: ElevatedButton(
                    onPressed: () {
                      if (qTextController.text.isNotEmpty) {
                        onSave(
                          QuestionModel(
                            question: qTextController.text,
                            options: [op1.text, op2.text, op3.text, op4.text],
                            answer: [
                              op1.text,
                              op2.text,
                              op3.text,
                              op4.text,
                            ][correctIdx],
                            imageUrl: existingQuestion?.imageUrl,
                          ),
                        );
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "SAVE",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
