import 'dart:ui'; // REQUIRED for PathMetrics
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 1. Add Riverpod
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../models/stem_challenge_model.dart';
import '../../../viewmodels/child_section/Stem_challenges/stem_challenges_provider.dart';


class StemChallengesScreen extends ConsumerStatefulWidget {
  const StemChallengesScreen({super.key});

  @override
  ConsumerState<StemChallengesScreen> createState() => _StemChallengesScreenState();
}

class _StemChallengesScreenState extends ConsumerState<StemChallengesScreen> {
  final Color _primaryTeal = const Color(0xFF26A69A);
  final Color _bg = const Color(0xFFF5F7FA);
  final Color _textDark = const Color(0xFF2D3436);

  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Science', 'Technology', 'Engineering', 'Mathematics'];

  @override
  Widget build(BuildContext context) {
    final challengesAsync = ref.watch(stemChallengesStreamProvider(_selectedCategory));

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if(!didPop){
          context.goNamed('bottomNavChild');
        }
      },
      child: Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: _textDark),
            onPressed: () {
              context.goNamed('bottomNavChild');
            }, // Open drawer logic if needed
          ),
          title: Text(
            "Manage Challenges",
            style: GoogleFonts.poppins(color: _textDark, fontSize: 18.sp, fontWeight: FontWeight.w700),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Category Dropdown ---
                Text("Select Category", style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.black87)),
                SizedBox(height: 1.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCategory,
                      isExpanded: true,
                      icon:  Icon(Icons.keyboard_arrow_down,size: 8.w,),
                      items: _categories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category, style: GoogleFonts.poppins(fontSize: 14.sp)),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedCategory = newValue!;
                        });
                        // Riverpod automatically refetches because _selectedCategory is a parameter to the provider
                      },
                    ),
                  ),
                ),

                SizedBox(height: 3.h),

                // --- Add New Challenge Button ---
                CustomPaint(
                  painter: DashedRectPainter(color: _primaryTeal, strokeWidth: 1.5, gap: 5.0),
                  child: Container(
                    height: 12.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: _primaryTeal.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: InkWell(
                      onTap: () => context.goNamed('addStemChallengesScreen'),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: _primaryTeal,
                            child: const Icon(Icons.add, color: Colors.white, size: 18),
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            "Add New Challenge",
                            style: GoogleFonts.poppins(color: _primaryTeal, fontSize: 16.sp, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 3.h),

                // --- Real Challenge List ---
                challengesAsync.when(
                  data: (challenges) {
                    if (challenges.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 5.h),
                          child: Text("No challenges found.", style: GoogleFonts.poppins(color: Colors.grey)),
                        ),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: challenges.length,
                      itemBuilder: (context, index) {
                        final challenge = challenges[index];
                        return _buildChallengeCard(challenge);
                      },
                    );
                  },
                  loading: () => Center(child: CircularProgressIndicator(color: _primaryTeal)),
                  error: (err, stack) => Center(child: Text('Error: $err', style: TextStyle(color: Colors.red))),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChallengeCard(StemChallengeModel challenge) {
    // Get styles based on the category string
    final style = _getCategoryStyle(challenge.category);

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 3. Icon Container (Using Image if available, else Category Icon)
              Container(
                height: 14.w,
                width: 14.w,
                decoration: BoxDecoration(
                  color: style['bgColor'],
                  borderRadius: BorderRadius.circular(12),
                  image: (challenge.imageUrl != null && challenge.imageUrl!.isNotEmpty)
                      ? DecorationImage(image: NetworkImage(challenge.imageUrl!), fit: BoxFit.cover)
                      : null,
                ),
                child: (challenge.imageUrl != null && challenge.imageUrl!.isNotEmpty)
                    ? null
                    : Icon(style['icon'], color: (style['color'] as Color).withValues(alpha: 0.8), size: 24.sp),
              ),
              SizedBox(width: 4.w),

              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      challenge.title,
                      style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.w700, color: _textDark),
                    ),
                    SizedBox(height: 0.5.h),
                    // Show difficulty or points as subtitle
                    Text(
                      "${challenge.difficulty} • ${challenge.points} Pts",
                      style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.grey[800]),
                    ),
                    SizedBox(height: 1.5.h),
                    // Category Chip
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: style['bgColor'],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        challenge.category,
                        style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w600, color: style['color']),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),
          Divider(color: Colors.grey[100], height: 1),
          SizedBox(height: 1.5.h),

          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildActionButton(
                icon: Icons.delete_outline,
                label: "Delete",
                color: Colors.redAccent,
                onTap: () => _showDeleteDialog(challenge), // Connect Delete
              ),
              SizedBox(width: 4.w),
              _buildActionButton(
                icon: Icons.edit_outlined,
                label: "Edit",
                color: const Color(0xFF00695C),
                onTap: () {
                  // CORRECT: Pass the actual 'StemChallengeModel' object
                  context.goNamed('editStemChallengesScreen', extra: challenge);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- HELPER: Map Category String to Colors/Icons ---
  Map<String, dynamic> _getCategoryStyle(String category) {
    switch (category) {
      case 'Engineering':
        return {'icon': Icons.engineering, 'color': Color(0xFF26A69A), 'bgColor': Color(0xFFE0F2F1)};
      case 'Science':
        return {'icon': Icons.science, 'color': Color(0xFF29B6F6), 'bgColor': Color(0xFFE1F5FE)};
      case 'Technology':
        return {'icon': Icons.code, 'color': Color(0xFFAB47BC), 'bgColor': Color(0xFFF3E5F5)};
      case 'Mathematics':
        return {'icon': Icons.calculate, 'color': Color(0xFFFFA726), 'bgColor': Color(0xFFFFF3E0)};
      default:
        return {'icon': Icons.lightbulb, 'color': Colors.grey, 'bgColor': Colors.grey.shade100};
    }
  }

  Widget _buildActionButton({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 18.sp, color: color),
          SizedBox(width: 1.w),
          Text(label, style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  // --- DELETE DIALOG ---
  void _showDeleteDialog(StemChallengeModel challenge) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Delete Challenge?", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text("Are you sure you want to remove '${challenge.title}'?", style: GoogleFonts.poppins(fontSize: 10.sp)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              // Call ViewModel
              if (challenge.id != null) {
                ref.read(stemChallengesViewModelProvider.notifier).deleteChallenge(challenge.id!, challenge.category);
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
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

  DashedRectPainter({this.strokeWidth = 1.0, this.color = Colors.red, this.gap = 5.0});

  @override
  void paint(Canvas canvas, Size size) {
    Paint dashedPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    double x = size.width;
    double y = size.height;

    Path topPath = Path(); topPath.moveTo(10, 0); topPath.lineTo(x - 10, 0);
    Path rightPath = Path(); rightPath.moveTo(x, 10); rightPath.lineTo(x, y - 10);
    Path bottomPath = Path(); bottomPath.moveTo(x - 10, y); bottomPath.lineTo(10, y);
    Path leftPath = Path(); leftPath.moveTo(0, y - 10); leftPath.lineTo(0, 10);

    _drawDashedPath(canvas, topPath, dashedPaint);
    _drawDashedPath(canvas, rightPath, dashedPaint);
    _drawDashedPath(canvas, bottomPath, dashedPaint);
    _drawDashedPath(canvas, leftPath, dashedPaint);

    canvas.drawArc(Rect.fromLTWH(0, 0, 20, 20), 3.14, 1.57, false, dashedPaint);
    canvas.drawArc(Rect.fromLTWH(x - 20, 0, 20, 20), -1.57, 1.57, false, dashedPaint);
    canvas.drawArc(Rect.fromLTWH(x - 20, y - 20, 20, 20), 0, 1.57, false, dashedPaint);
    canvas.drawArc(Rect.fromLTWH(0, y - 20, 20, 20), 1.57, 1.57, false, dashedPaint);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    PathMetrics pathMetrics = path.computeMetrics();
    for (PathMetric pathMetric in pathMetrics) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        canvas.drawPath(pathMetric.extractPath(distance, distance + 5), paint);
        distance += 5 + gap;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}