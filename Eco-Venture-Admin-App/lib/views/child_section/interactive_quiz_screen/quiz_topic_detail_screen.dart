import 'dart:convert';
import 'dart:io';
import 'package:eco_venture_admin_portal/core/config/api_constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../models/quiz_topic_model.dart';
import '../../../viewmodels/child_section/interactive_quiz/quiz_provider.dart';

class QuizTopicDetailScreen extends ConsumerStatefulWidget {
  final QuizTopicModel topic;

  const QuizTopicDetailScreen({super.key, required this.topic});

  @override
  ConsumerState<QuizTopicDetailScreen> createState() =>
      _QuizTopicDetailScreenState();
}

class _QuizTopicDetailScreenState extends ConsumerState<QuizTopicDetailScreen> {
  // --- PRO COLORS ---
  final Color _primary = const Color(0xFF05664F);
  final Color _bg = const Color(0xFFF8F9FA);
  final Color _surface = Colors.white;
  final Color _textDark = const Color(0xFF1A1D1E);
  final Color _textGrey = const Color(0xFF546E7A);
  final Color _border = const Color(0xFFE9ECEF);
  final Color _warning = const Color(0xFFDC3545);

  late QuizTopicModel _currentTopic;

  @override
  void initState() {
    super.initState();
    _currentTopic = widget.topic;
  }

  // --- NOTIFICATION LOGIC ---
  Future<void> _sendNotificationToUsers(String topicName, String action) async {
    const String backendUrl = ApiConstants.notifyByRoleEndPoints;

    try {
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "title": "Quiz Update! 🔔",
          "body":
              "The quiz '$topicName' has been updated ($action). Check it out!",
          "type": "Quiz",
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

  // --- ENHANCED NOTIFICATION METHOD ---
  Future<void> _sendUpdateNotification(
    QuizTopicModel topic,
    String changeType,
  ) async {
    const String backendUrl = ApiConstants.notifyByRoleEndPoints;

    try {
      // Determine notification content based on change type
      Map<String, Map<String, String>> messages = {
        'level_added': {
          'title': 'New Level Added! 🆕',
          'body': 'A new level has been added to "${topic.topicName}"',
        },
        'level_deleted': {
          'title': 'Level Removed',
          'body': 'A level was removed from "${topic.topicName}"',
        },
        'level_updated': {
          'title': 'Level Updated 📝',
          'body': 'A level in "${topic.topicName}" has been updated',
        },
        'general_update': {
          'title': 'Quiz Updated',
          'body': 'Quiz "${topic.topicName}" has been modified',
        },
        'name_changed': {
          'title': 'Quiz Renamed',
          'body': 'Quiz renamed to "${topic.topicName}"',
        },
        'details_updated': {
          'title': 'Quiz Details Updated',
          'body': 'Details for "${topic.topicName}" have been updated',
        },
      };

      final msg = messages[changeType] ?? messages['general_update']!;

      // Notify Children (only if not sensitive)
      if (!(topic.isSensitive ?? false)) {
        await http.post(
          Uri.parse(backendUrl),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "title": msg['title'],
            "body": msg['body'],
            "type": "Quiz_Update",
            "targetRole": "child",
            "quizId": topic.id,
            "category": topic.category,
            "changeType": changeType,
          }),
        );
      }

      // Always notify Parents
      String parentMessage = (topic.isSensitive ?? false)
          ? 'Content updated in "${topic.topicName}" (sensitive)'
          : msg['body']!;

      await http.post(
        Uri.parse(backendUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "title": "Content Updated",
          "body": parentMessage,
          "type": "Quiz_Update",
          "targetRole": "parent",
          "quizId": topic.id,
          "isSensitive": topic.isSensitive ?? false,
          "changeType": changeType,
        }),
      );

      print("✅ Update notification sent for: $changeType");
    } catch (e) {
      print("❌ Notification error: $e");
    }
  }

  // --- ACTIONS ---
  Future<void> _deleteLevel(int index) async {
    final confirmed = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Delete Level?"),
        content: Text(
          "This will remove level '${_currentTopic.levels[index].title}'. Users will be notified.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: _warning),
            child: Text("Delete"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      List<QuizLevelModel> updatedLevels = List.from(_currentTopic.levels);
      updatedLevels.removeAt(index);

      final updatedTopic = _currentTopic.copyWith(levels: updatedLevels);
      await _saveChanges(
        updatedTopic,
        notifyUsers: true,
        changeType: 'level_deleted',
      );
    }
  }

  Future<void> _saveChanges(
    QuizTopicModel updatedTopic, {
    bool notifyUsers = false,
    String changeType = 'general_update',
  }) async {
    await ref.read(quizViewModelProvider.notifier).updateTopic(updatedTopic);

    if (notifyUsers) {
      await _sendUpdateNotification(updatedTopic, changeType);
    }

    setState(() {
      _currentTopic = updatedTopic;
    });
  }

  Future<void> _editTopicDetails() async {
    final nameCtrl = TextEditingController(text: _currentTopic.topicName);
    final tagsCtrl = TextEditingController(
      text: _currentTopic.tags?.join(', ') ?? '',
    );
    bool isSensitive = _currentTopic.isSensitive ?? false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: _surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Edit Details",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 17.sp,
              color: _textDark,
            ),
          ),
          content: SizedBox(
            width: 80.w,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildProTextField(
                    controller: nameCtrl,
                    hint: "Topic Name",
                    icon: Icons.edit,
                  ),
                  SizedBox(height: 2.h),
                  _buildProTextField(
                    controller: tagsCtrl,
                    hint: "Tags (comma-separated)",
                    icon: Icons.tag,
                  ),
                  SizedBox(height: 2.h),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    activeThumbColor: Colors.red,
                    title: Text(
                      "Sensitive Content",
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    value: isSensitive,
                    onChanged: (v) => setDialogState(() => isSensitive = v),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                "Cancel",
                style: TextStyle(fontSize: 14.sp, color: _textGrey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.isNotEmpty) {
                  // Process Tags
                  List<String> tagsList = tagsCtrl.text
                      .split(',')
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty)
                      .toList();

                  // Auto-tag logic
                  if (isSensitive && !tagsList.contains('scary')) {
                    tagsList.add('scary');
                  }
                  if (!isSensitive) {
                    tagsList.remove('scary');
                  }

                  final newTopic = _currentTopic.copyWith(
                    topicName: nameCtrl.text.trim(),
                    tags: tagsList,
                    isSensitive: isSensitive,
                  );

                  _saveChanges(
                    newTopic,
                    notifyUsers: true,
                    changeType: 'details_updated',
                  );
                  Navigator.pop(ctx);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: _primary),
              child: Text(
                "Save",
                style: TextStyle(color: Colors.white, fontSize: 14.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTopicInfo() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: 50.h,
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
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
                    "Topic Information",
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
            Divider(color: _border),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(5.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category
                    _buildInfoRow(
                      icon: Icons.category_rounded,
                      label: "Category",
                      value: _currentTopic.category,
                    ),
                    SizedBox(height: 2.h),

                    // Created Info
                    _buildInfoRow(
                      icon: Icons.person_outline,
                      label: "Created By",
                      value: _currentTopic.createdBy,
                    ),

                    // Check if createdAt field exists, if not use current time or a placeholder
                    SizedBox(height: 2.h),

                    // Tags Section
                    if (_currentTopic.tags != null &&
                        _currentTopic.tags!.isNotEmpty) ...[
                      Text(
                        "Tags",
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: _textGrey,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Wrap(
                        spacing: 1.w,
                        runSpacing: 1.h,
                        children: _currentTopic.tags!
                            .map(
                              (tag) => Chip(
                                label: Text(
                                  tag,
                                  style: GoogleFonts.poppins(fontSize: 12.sp),
                                ),
                                backgroundColor: tag == 'scary'
                                    ? Colors.red.shade50
                                    : Colors.blue.shade50,
                                side: BorderSide(
                                  color: tag == 'scary'
                                      ? Colors.red.shade200
                                      : Colors.blue.shade200,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      SizedBox(height: 2.h),
                    ],

                    // Sensitivity Warning
                    if (_currentTopic.isSensitive == true) ...[
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.red,
                            ),
                            SizedBox(width: 3.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Sensitive Content",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                  SizedBox(height: 0.5.h),
                                  Text(
                                    "Hidden from younger children",
                                    style: GoogleFonts.poppins(
                                      fontSize: 12.sp,
                                      color: Colors.red.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Statistics
                    SizedBox(height: 3.h),
                    Text(
                      "Statistics",
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: _textGrey,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Row(
                      children: [
                        _buildStatCard(
                          icon: Icons.layers_rounded,
                          value: _currentTopic.levels.length.toString(),
                          label: "Levels",
                          color: Colors.blue,
                        ),
                        SizedBox(width: 3.w),
                        _buildStatCard(
                          icon: Icons.quiz_rounded,
                          value: _currentTopic.levels
                              .fold(
                                0,
                                (sum, level) => sum + level.questions.length,
                              )
                              .toString(),
                          label: "Questions",
                          color: Colors.purple,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
            content: Text("Changes Saved!", style: TextStyle(fontSize: 14.sp)),
            backgroundColor: Colors.green,
          ),
        );
        ref.read(quizViewModelProvider.notifier).resetSuccess();
      }
    });
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: _textDark, size: 19.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _currentTopic.topicName,
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: _textDark,
          ),
        ),
        actions: [
          // Info Button
          IconButton(
            icon: Icon(
              Icons.info_outline_rounded,
              color: _primary,
              size: 20.sp,
            ),
            onPressed: _showTopicInfo,
            tooltip: "Topic Details",
          ),
          // Edit Button
          IconButton(
            icon: Icon(Icons.settings_outlined, color: _textDark, size: 20.sp),
            onPressed: _editTopicDetails, // Call updated edit function
            tooltip: "Edit Details",
          ),
          // Notification Test Button (Optional - for admin testing)
          if (_currentTopic.createdBy == 'admin') ...[
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: _textDark),
              onSelected: (value) {
                if (value == 'test_notification') {
                  _sendUpdateNotification(_currentTopic, 'test_notification');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Test notification sent"),
                      backgroundColor: _primary,
                    ),
                  );
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'test_notification',
                  child: Row(
                    children: [
                      Icon(Icons.notifications_active, size: 18.sp),
                      SizedBox(width: 2.w),
                      Text("Test Notification"),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Container(color: _border, height: 1),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with tags preview
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Sub-Topics (Levels)",
                            style: GoogleFonts.poppins(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: _textGrey,
                            ),
                          ),
                          if (_currentTopic.tags != null &&
                              _currentTopic.tags!.isNotEmpty) ...[
                            SizedBox(height: 0.5.h),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: _currentTopic.tags!
                                    .take(3)
                                    .map(
                                      (tag) => Container(
                                        margin: EdgeInsets.only(right: 1.w),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 3.w,
                                          vertical: 0.5.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: tag == 'scary'
                                              ? Colors.red.shade50
                                              : Colors.blue.shade50,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          border: Border.all(
                                            color: tag == 'scary'
                                                ? Colors.red.shade200
                                                : Colors.blue.shade200,
                                          ),
                                        ),
                                        child: Text(
                                          tag,
                                          style: GoogleFonts.poppins(
                                            fontSize: 11.sp,
                                            color: tag == 'scary'
                                                ? Colors.red.shade700
                                                : Colors.blue.shade700,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Sensitivity Indicator
                    if (_currentTopic.isSensitive == true)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 3.w,
                          vertical: 1.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.warning_amber,
                              size: 14.sp,
                              color: Colors.red.shade700,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              "Sensitive",
                              style: GoogleFonts.poppins(
                                fontSize: 11.sp,
                                color: Colors.red.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 1.5.h),

                Expanded(
                  child: _currentTopic.levels.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.layers_clear,
                                size: 32.sp,
                                color: Colors.grey.shade300,
                              ),
                              SizedBox(height: 1.h),
                              Text(
                                "No levels yet.",
                                style: GoogleFonts.poppins(
                                  fontSize: 15.sp,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              ElevatedButton.icon(
                                onPressed: () => _showLevelEditor(),
                                icon: Icon(Icons.add, size: 18.sp),
                                label: Text("Add First Level"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _primary,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          itemCount: _currentTopic.levels.length,
                          separatorBuilder: (c, i) => SizedBox(height: 2.h),
                          itemBuilder: (context, index) {
                            final level = _currentTopic.levels[index];
                            return _buildLevelTile(level, index);
                          },
                        ),
                ),
              ],
            ),
          ),
          if (quizState.isLoading)
            Container(
              color: Colors.black26,
              child: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showLevelEditor(),
        backgroundColor: _primary,
        icon: Icon(Icons.add, size: 20.sp),
        label: Text(
          "Add Level",
          style: GoogleFonts.poppins(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12.sp,
            color: _textGrey,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 0.5.h),
        Row(
          children: [
            Icon(icon, size: 16.sp, color: _textGrey),
            SizedBox(width: 2.w),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: _textDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18.sp),
            SizedBox(height: 0.5.h),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(fontSize: 11.sp, color: _textGrey),
            ),
          ],
        ),
      ),
    );
  }

  // --- PRO WIDGETS ---
  Widget _buildBadge(String text, Color bg, Color textCol) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textCol.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: textCol,
        ),
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
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
          color: Colors.grey.shade400,
          fontSize: 14.sp,
        ),
        prefixIcon: Icon(icon, size: 20.sp, color: _textGrey),
        filled: true,
        fillColor: _bg,
        contentPadding: EdgeInsets.symmetric(vertical: 1.8.h),
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
          borderSide: BorderSide(color: _primary, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildProLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 14.sp,
        fontWeight: FontWeight.w700,
        color: _textGrey,
      ),
    );
  }

  Widget _buildLevelTile(QuizLevelModel level, int index) {
    return Container(
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
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
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
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: _textDark,
          ),
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 0.5.h),
          child: Text(
            "${level.questions.length} Qs • ${level.points} Pts • Pass: ${level.passingPercentage}%",
            style: GoogleFonts.poppins(fontSize: 13.sp, color: _textGrey),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit_rounded, color: Colors.blue, size: 20.sp),
              onPressed: () =>
                  _showLevelEditor(existingLevel: level, index: index),
            ),
            IconButton(
              icon: Icon(
                Icons.delete_outline_rounded,
                color: Colors.red.shade400,
                size: 20.sp,
              ),
              onPressed: () => _deleteLevel(index),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // LEVEL EDITOR (With Pass % & Question Edit)
  // ==========================================
  void _showLevelEditor({QuizLevelModel? existingLevel, int? index}) {
    final titleCtrl = TextEditingController(text: existingLevel?.title ?? "");
    final orderCtrl = TextEditingController(
      text:
          existingLevel?.order.toString() ??
          "${_currentTopic.levels.length + 1}",
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
            padding: EdgeInsets.fromLTRB(
              5.w,
              2.h,
              5.w,
              MediaQuery.of(context).viewInsets.bottom + 2.h,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 15.w,
                  height: 0.6.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                SizedBox(height: 2.h),

                Row(
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
                Divider(height: 1, color: _border),
                SizedBox(height: 2.h),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProLabel("Level Title"),
                        SizedBox(height: 1.h),
                        _buildProTextField(
                          controller: titleCtrl,
                          hint: "e.g. Basics",
                          icon: Icons.title_rounded,
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

                        // --- Pass Percentage Field ---
                        _buildProLabel("Passing Percentage"),
                        SizedBox(height: 1.h),
                        _buildProTextField(
                          controller: passCtrl,
                          hint: "60",
                          icon: Icons.percent_rounded,
                          isNumber: true,
                        ),

                        SizedBox(height: 3.h),
                        Divider(thickness: 1, color: _border),
                        SizedBox(height: 1.h),

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
                              onPressed: () {
                                _showQuestionEditor(context, (newQ) {
                                  setModalState(() => tempQuestions.add(newQ));
                                });
                              },
                              icon: Icon(Icons.add_circle, size: 18.sp),
                              label: Text(
                                "Add",
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

                        if (tempQuestions.isEmpty)
                          Center(
                            child: Padding(
                              padding: EdgeInsets.all(2.h),
                              child: Text(
                                "Add at least one question",
                                style: TextStyle(
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
                            itemCount: tempQuestions.length,
                            separatorBuilder: (c, i) => SizedBox(height: 1.5.h),
                            itemBuilder: (c, i) {
                              final q = tempQuestions[i];
                              return Container(
                                decoration: BoxDecoration(
                                  color: _bg,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: _border),
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 3.w,
                                    vertical: 0.5.h,
                                  ),
                                  title: Text(
                                    "Q${i + 1}: ${q.question}",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w600,
                                      color: _textDark,
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // --- EDIT QUESTION BUTTON ---
                                      IconButton(
                                        icon: Icon(
                                          Icons.edit,
                                          color: _primary,
                                          size: 20.sp,
                                        ),
                                        onPressed: () {
                                          _showQuestionEditor(
                                            context,
                                            (updatedQ) => setModalState(
                                              () => tempQuestions[i] = updatedQ,
                                            ),
                                            existingQuestion:
                                                q, // Pass existing data
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
                                          () => tempQuestions.removeAt(i),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 2.h),
                SizedBox(
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

                      List<QuizLevelModel> updatedLevels = List.from(
                        _currentTopic.levels,
                      );
                      final String changeType;

                      if (index != null) {
                        updatedLevels[index] = newLevel;
                        changeType = 'level_updated';
                      } else {
                        updatedLevels.add(newLevel);
                        changeType = 'level_added';
                      }

                      updatedLevels.sort((a, b) => a.order.compareTo(b.order));

                      _saveChanges(
                        _currentTopic.copyWith(levels: updatedLevels),
                        notifyUsers: true,
                        changeType: changeType,
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _textDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      index == null ? "ADD LEVEL" : "UPDATE LEVEL",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
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

    File? newImageFile;
    String? existingImageUrl = existingQuestion?.imageUrl;

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

                        // Image Logic
                        InkWell(
                          onTap: () async {
                            final ImagePicker picker = ImagePicker();
                            final XFile? img = await picker.pickImage(
                              source: ImageSource.gallery,
                            );
                            if (img != null) {
                              setState(() {
                                newImageFile = File(img.path);
                                existingImageUrl = null;
                              });
                            }
                          },
                          child: Container(
                            height: 12.h,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              border: Border.all(color: _border),
                              borderRadius: BorderRadius.circular(12),
                              image: newImageFile != null
                                  ? DecorationImage(
                                      image: FileImage(newImageFile!),
                                      fit: BoxFit.cover,
                                    )
                                  : (existingImageUrl != null
                                        ? DecorationImage(
                                            image: NetworkImage(
                                              existingImageUrl!,
                                            ),
                                            fit: BoxFit.cover,
                                          )
                                        : null),
                            ),
                            child:
                                (newImageFile == null &&
                                    existingImageUrl == null)
                                ? Center(
                                    child: Text(
                                      "Tap to add Image (Optional)",
                                      style: GoogleFonts.poppins(
                                        fontSize: 13.sp,
                                        color: _primary,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
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
                                    style: TextStyle(fontSize: 15.sp),
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
                            imageUrl: newImageFile?.path ?? existingImageUrl,
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
                        fontSize: 16.sp,
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
