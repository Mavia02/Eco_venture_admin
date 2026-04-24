import 'package:eco_venture_admin_portal/models/quiz_topic_model.dart';
import 'package:eco_venture_admin_portal/models/report_model.dart';
import 'package:eco_venture_admin_portal/models/stem_challenge_model.dart';
import 'package:eco_venture_admin_portal/views/child_section/%20stem_challenges_screen/add_stem_challenges_screen.dart';
import 'package:eco_venture_admin_portal/views/child_section/%20stem_challenges_screen/edit_stem_challenges_screen.dart';
import 'package:eco_venture_admin_portal/views/child_section/admin_child_home.dart';
import 'package:eco_venture_admin_portal/views/child_section/interactive_quiz_screen/add_quiz_screen.dart';
import 'package:eco_venture_admin_portal/views/child_section/multimedia_content/admin_add_story_screen.dart';
import 'package:eco_venture_admin_portal/views/child_section/multimedia_content/admin_add_video_screen.dart';
import 'package:eco_venture_admin_portal/views/child_section/multimedia_content/admin_edit_story_screen.dart';
import 'package:eco_venture_admin_portal/views/child_section/multimedia_content/admin_multimedia_dashboard.dart';
import 'package:eco_venture_admin_portal/views/child_section/multimedia_content/admin_edit_video_screen.dart';
import 'package:eco_venture_admin_portal/views/child_section/report_safety/admin_report_detail_screen.dart';
import 'package:eco_venture_admin_portal/views/child_section/report_safety/admin_safety_report_screen.dart' hide ReportModel;
import 'package:eco_venture_admin_portal/views/child_section/report_safety/admin_teacher_verification_screen.dart';
import 'package:eco_venture_admin_portal/views/child_section/treasure_hunt/admin_add_treasure_hunt_screen.dart';
import 'package:eco_venture_admin_portal/views/child_section/treasure_hunt/admin_edit_treasure_hunt_screen.dart';
import 'package:eco_venture_admin_portal/views/child_section/treasure_hunt/admin_treasure_hunt_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// New Detail View Imports
import 'package:eco_venture_admin_portal/views/child_section/widgets/child_detail.dart';
import 'package:eco_venture_admin_portal/views/child_section/widgets/uploaded_modules.dart';
import 'package:eco_venture_admin_portal/views/child_section/widgets/active_challenge.dart';
import 'package:eco_venture_admin_portal/views/child_section/widgets/avg_progress.dart';

import '../../navigation/bottom_nav_child.dart';
import '../../views/child_section/ stem_challenges_screen/stem_challenges_screen.dart';
import '../../views/child_section/interactive_quiz_screen/edit_quiz_screen.dart';
import '../../views/child_section/interactive_quiz_screen/interactive_quiz_screen.dart';
import '../../views/child_section/interactive_quiz_screen/quiz_topic_detail_screen.dart';
import '../../views/child_section/multimedia_content/admin_story_dashboard.dart';
import '../../views/child_section/multimedia_content/admin_video_dashboard.dart';
import '../../views/child_section/nature_photo_journal_screen/nature_photo_journal_screen.dart';
import '../constants/route_names.dart';

class ChildRouter {
  static final routes = GoRoute(
    path: RouteNames.bottomNavChild, // "/child"
    name: 'bottomNavChild',
    builder: (context, state) => const BottomNavChild(),
    routes: [
      GoRoute(
          path: RouteNames.adminSafetyReportScreen,
          name: "adminSafetyReportScreen",
          builder: (context, state) => const AdminSafetyReportScreen(),
          routes: [
            GoRoute(
              path: RouteNames.adminTeacherVerificationScreen,
              name: "adminTeacherVerificationScreen",
              builder: (context, state) => const AdminTeacherVerificationScreen(),
            ),
            GoRoute(
              path: RouteNames.adminReportDetailScreen,
              name: "adminReportDetailScreen",
              builder: (context, state){
                final reportData=state.extra as ReportModel;
                return AdminReportDetailScreen(report: reportData);
              },
            ),
          ]
      ),

      GoRoute(
        path: RouteNames.childHome, // "/child/home"
        name: 'childHome',
        builder: (context, state) => const AdminChildHome(),
        routes: [
          // 1. CHILDREN DIRECTORY DETAILS
          GoRoute(
            path: 'children-details',
            name: 'childrenDetails',
            builder: (context, state) => const ChildrenDetailsView(),
          ),

          // 2. MODULES LIBRARY DETAILS
          GoRoute(
            path: 'modules-details',
            name: 'modulesDetails',
            builder: (context, state) => const ModulesDetailsView(),
          ),

          // 3. ACTIVE CHALLENGES DETAILS
          GoRoute(
            path: 'active-challenges-details',
            name: 'activeChallengesDetails',
            builder: (context, state) => const ActiveChallengesDetailsView(),
          ),

          // 4. AVERAGE PROGRESS DETAILS
          GoRoute(
            path: 'avg-progress-details',
            name: 'avgProgressDetails',
            builder: (context, state) => const AvgProgressDetailsView(),
          ),

          GoRoute(
            path: RouteNames.adminTreasureHuntDashboard,
            name: 'adminTreasureHuntDashboard',
            builder: (context, state) => const AdminTreasureHuntDashboard(),
            routes: [
              GoRoute(
                path: RouteNames.adminAddTreasureHuntScreen,
                name: 'adminAddTreasureHuntScreen',
                builder: (context, state) => const AdminAddTreasureHuntScreen(),
              ),
              GoRoute(
                path: RouteNames.adminEditTreasureHuntScreen,
                name: 'adminEditTreasureHuntScreen',
                builder: (context, state) {
                  final huntData = state.extra;
                  return AdminEditTreasureHuntScreen(huntData: huntData);
                },
              ),
            ],
          ),
          GoRoute(
            path: RouteNames.adminMultimediaDashboard,
            name: 'adminMultimediaDashboard',
            builder: (context, state) => const AdminMultimediaDashboard(),
            routes: [
              GoRoute(
                path: RouteNames.adminVideoDashboard,
                name: 'adminVideoDashboard',
                builder: (context, state) => const AdminVideoDashboard(),
                routes: [
                  GoRoute(
                    path: RouteNames.adminAddVideoScreen,
                    name: 'adminAddVideoScreen',
                    builder: (context, state) => const AdminAddVideoScreen(),
                  ),
                  GoRoute(
                    path: RouteNames.adminEditVideoScreen,
                    name: 'adminEditVideoScreen',
                    builder: (context, state) {
                      final videoData = state.extra;
                      return AdminEditVideoScreen(videoData: videoData);
                    },
                  ),
                ],
              ),
              GoRoute(
                path: RouteNames.adminStoryDashboard,
                name: 'adminStoryDashboard',
                builder: (context, state) => const AdminStoryDashboard(),
                routes: [
                  GoRoute(
                    path: RouteNames.adminAddStoryScreen,
                    name: 'adminAddStoryScreen',
                    builder: (context, state) => const AdminAddStoryScreen(),
                  ),
                  GoRoute(
                    path: RouteNames.adminEditStoryScreen,
                    name: 'adminEditStoryScreen',
                    builder: (context, state) {
                      final storyData = state.extra;
                      return AdminEditStoryScreen(storyData: storyData);
                    },
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: RouteNames.stemChallengesScreen,
            name: 'stemChallengesScreen',
            builder: (context, state) => const StemChallengesScreen(),
            routes: [
              GoRoute(
                path: RouteNames.addStemChallengesScreen,
                name: "addStemChallengesScreen",
                builder: (context, state) => const AddStemChallengeScreen(),
              ),
              GoRoute(
                path: RouteNames.editStemChallengeScreen,
                name: 'editStemChallengesScreen',
                builder: (context, state) {
                  final stemChallenge = state.extra as StemChallengeModel;

                  return EditStemChallengeScreen(challenge: stemChallenge);
                },
              ),
            ],
          ),
          GoRoute(
            path: RouteNames.interactiveQuiz,
            name: 'interactiveQuiz',
            builder: (context, state) => const InteractiveQuizScreen(),
            routes: [
              GoRoute(
                path: RouteNames.addQuizScreen,
                name: 'addQuizScreen',
                builder: (context, state) => const AddQuizScreen(),
              ),
              GoRoute(
                path: RouteNames.editQuizScreen,
                name: 'editQuizScreen',
                builder: (context, state) {
                  final quizEditTopicData = state.extra as QuizTopicModel;
                  return EditQuizScreen(topic: quizEditTopicData);
                },
              ),
              GoRoute(
                path: RouteNames.quizTopicDetailScreen,
                name: 'quizTopicDetailScreen',
                builder: (context, state) {
                  final quizTopicData = state.extra as QuizTopicModel;
                  return QuizTopicDetailScreen(topic: quizTopicData);
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
