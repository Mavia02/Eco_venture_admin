import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../models/quiz_topic_model.dart';
import '../../../viewmodels/child_section/interactive_quiz/quiz_provider.dart';
import '../../../viewmodels/child_section/interactive_quiz/quiz_state.dart';

class InteractiveQuizScreen extends ConsumerStatefulWidget {
  const InteractiveQuizScreen({super.key});

  @override
  ConsumerState<InteractiveQuizScreen> createState() => _InteractiveQuizScreenState();
}

class _InteractiveQuizScreenState extends ConsumerState<InteractiveQuizScreen> {
  final Color _primary = const Color(0xFF05664F);
  final Color _bg = const Color(0xFFF5F7FA);

  String selectedCategory = 'Animals';
  final List<String> categories = ['Animals', 'Ecosystem', 'Science', 'Space','Plants','Mathematics'];

  late ScaffoldMessengerState _messenger;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _messenger = ScaffoldMessenger.of(context);
  }

  @override
  Widget build(BuildContext context) {
    final quizListAsync = ref.watch(quizListStreamProvider(selectedCategory));
    final quizState = ref.watch(quizViewModelProvider);

    ref.listen<QuizState>(quizViewModelProvider, (previous, next) {
      if (next.errorMessage != null) {
        _messenger.showSnackBar(SnackBar(content: Text("Error: ${next.errorMessage}"), backgroundColor: Colors.red));
      }
      if (next.isSuccess) {
        // Optional success message
        // _messenger.showSnackBar(SnackBar(content: Text("Action Successful"), backgroundColor: _primary));
        // We reset success elsewhere usually, but safe to ignore here for stream updates
      }
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) context.goNamed("bottomNavChild");
      },
      child: Scaffold(
        backgroundColor: _bg,
        body: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 5.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 3.h),
                    _buildSectionTitle("Managed Topics", quizListAsync.valueOrNull?.length ?? 0),
                    SizedBox(height: 2.h),
                    Expanded(
                      child: quizListAsync.when(
                        data: (topics) {
                          if (topics.isEmpty) return _buildEmptyState();
                          return ListView.separated(
                            padding: EdgeInsets.only(bottom: 12.h),
                            itemCount: topics.length,
                            separatorBuilder: (c, i) => SizedBox(height: 2.h),
                            itemBuilder: (context, index) => _buildTopicCard(topics[index]),
                          );
                        },
                        loading: () => Center(child: CircularProgressIndicator(color: _primary)),
                        error: (err, stack) => Center(child: Text('Error: $err', style: TextStyle(fontSize: 14.sp))),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: quizState.isLoading
            ? const CircularProgressIndicator()
            : _buildAddButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(top: 6.h, left: 5.w, right: 5.w, bottom: 3.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [_primary, const Color(0xFF0A8F6F)]),
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => context.goNamed("bottomNavChild"),
                child: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20.sp),
              ),
              Text('Quiz Topics', style: GoogleFonts.poppins(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold)),
              Icon(Icons.admin_panel_settings, color: Colors.white, size: 20.sp),
            ],
          ),
          SizedBox(height: 3.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: selectedCategory,
                items: categories.map((v) => DropdownMenuItem(value: v, child: Text(v, style: GoogleFonts.poppins(fontSize: 14.sp)))).toList(),
                onChanged: (val) => setState(() => selectedCategory = val!),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w600)),
        Text('$count Items', style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.grey)),
      ],
    );
  }

  // --- UPDATED TOPIC CARD WITH EDIT ICON ---
  Widget _buildTopicCard(QuizTopicModel topic) {
    return InkWell(
      // Clicking the card goes to DETAILS (Levels list)
      onTap: () => context.goNamed('quizTopicDetailScreen', extra: topic),
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              height: 14.w, width: 14.w,
              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(16)),
              child: Icon(Icons.folder_copy_rounded, color: Colors.blue, size: 20.sp),
            ),
            SizedBox(width: 4.w),

            // Text Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(topic.topicName, style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.w700)),
                  SizedBox(height: 0.5.h),
                  Text('${topic.levels.length} Levels', style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.grey)),
                ],
              ),
            ),

            // --- ACTION BUTTONS (Edit & Delete) ---
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. EDIT BUTTON (Pencil)
                InkWell(
                  onTap: () {
                    // Navigate to Edit Screen (To rename topic or change category)
                    context.goNamed('editQuizScreen', extra: topic);
                  },
                  child: Container(
                    padding: EdgeInsets.all(2.w),
                    margin: EdgeInsets.only(bottom: 1.h),
                    decoration: BoxDecoration(
                      color: _primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.edit, size: 16.sp, color: _primary),
                  ),
                ),

                // 2. DELETE BUTTON (Trash)
                InkWell(
                  onTap: () => _showDeleteDialog(topic),
                  child: Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.delete_outline, size: 16.sp, color: Colors.red),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return SizedBox(
      height: 7.h, width: 90.w,
      child: ElevatedButton(
        onPressed: () => context.goNamed('addQuizScreen'),
        style: ElevatedButton.styleFrom(backgroundColor: _primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
        child: Text('Create New Topic', style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.white)),
      ),
    );
  }

  void _showDeleteDialog(QuizTopicModel topic) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Delete Topic?", style: TextStyle(fontSize: 16.sp)),
        content: Text("This will delete '${topic.topicName}' and ALL its levels.", style: TextStyle(fontSize: 14.sp)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(onPressed: () {
            Navigator.pop(ctx);
            if (topic.id != null) ref.read(quizViewModelProvider.notifier).deleteTopic(topic.id!, topic.category);
          }, child: const Text("Delete", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(child: Text('No Topics Found', style: GoogleFonts.poppins(fontSize: 15.sp, color: Colors.grey)));
  }
}