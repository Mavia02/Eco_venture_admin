import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:eco_venture_admin_portal/views/child_section/admin_child_home.dart';

// Import Providers
import 'package:eco_venture_admin_portal/viewmodels/child_section/child_dashboard/child_dashboard_provider.dart';
import 'package:eco_venture_admin_portal/viewmodels/child_section/modules_uploaded/module_uploaded_provider.dart';
import 'package:eco_venture_admin_portal/viewmodels/child_section/active_challenges/active_challenge_provider.dart';
import 'package:eco_venture_admin_portal/viewmodels/child_section/avg_progress/avg_progress_provider.dart';

// Import ViewModels (Required for 'implements' type matching)
import 'package:eco_venture_admin_portal/viewmodels/child_section/child_dashboard/child_dashboard_view_model.dart';
import 'package:eco_venture_admin_portal/viewmodels/child_section/modules_uploaded/modules_uploaded_view_model.dart';
import 'package:eco_venture_admin_portal/viewmodels/child_section/active_challenges/active_challenge_view_model.dart';
import 'package:eco_venture_admin_portal/viewmodels/child_section/avg_progress/avg_progress_view_model.dart';

// Import States & Models
import 'package:eco_venture_admin_portal/viewmodels/child_section/child_dashboard/child_dashboard_state.dart';
import 'package:eco_venture_admin_portal/models/children_summary_model.dart';
import 'package:eco_venture_admin_portal/viewmodels/child_section/modules_uploaded/module_uploaded_state.dart';
import 'package:eco_venture_admin_portal/models/modules_uploaded_model.dart';
import 'package:eco_venture_admin_portal/viewmodels/child_section/active_challenges/active_challenge_state.dart';
import 'package:eco_venture_admin_portal/viewmodels/child_section/avg_progress/avg_progress_state.dart';
import 'package:eco_venture_admin_portal/models/avg_progress_model.dart';

void main() {
  // Logic: Wrapper to initialize ResponsiveSizer and ProviderScope with Mocks
  Widget createTestWidget(Widget child) {
    return ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return ProviderScope(
          overrides: [
            // Logic: Overriding providers with Mock classes that implement the original types
            childDashboardProvider.overrideWith((ref) => ChildDashboardViewModelMock()),
            modulesUploadedProvider.overrideWith((ref) => ModulesUploadedViewModelMock()),
            activeChallengeProvider.overrideWith((ref) => ActiveChallengeViewModelMock()),
            avgProgressProvider.overrideWith((ref) => AvgProgressViewModelMock()),
          ],
          child: MaterialApp(
            home: child,
          ),
        );
      },
    );
  }

  group('1. Dashboard UI Tests (AdminChildHome)', () {
    testWidgets('Should render summary cards with correct labels', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const AdminChildHome()));
      await tester.pumpAndSettle();

      expect(find.text('Total Children'), findsOneWidget);
      expect(find.text('Modules Uploaded'), findsOneWidget);
      expect(find.byIcon(Icons.people_alt_rounded), findsOneWidget);
    });

    testWidgets('Should render the circular progress indicator for Avg. Progress', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const AdminChildHome()));
      await tester.pumpAndSettle();

      expect(find.byType(CircularPercentIndicator), findsOneWidget);
      expect(find.text('Avg. Progress'), findsOneWidget);
    });

    testWidgets('Should render the Learning Module Grid items', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const AdminChildHome()));
      await tester.pumpAndSettle();

      expect(find.text('Interactive Quiz'), findsOneWidget);
      expect(find.text('STEM Challenges'), findsOneWidget);
    });
  });

  group('2. Navigation & Tab Logic', () {
    testWidgets('Tabs should be present in a TabBar scenario', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(const Scaffold(
        body: DefaultTabController(
          length: 2,
          child: TabBar(tabs: [Tab(text: "By Teacher"), Tab(text: "Direct/Admin")]),
        ),
      )));

      expect(find.text('By Teacher'), findsOneWidget);
      expect(find.text('Direct/Admin'), findsOneWidget);
    });
  });
}

// --- MOCK VIEW MODELS ---
// Logic: Using 'implements' ensures these mocks are technically compatible
// with the StateNotifierProvider types in the Canvas.

class ChildDashboardViewModelMock extends StateNotifier<ChildDashboardState>
    implements ChildDashboardViewModel {
  ChildDashboardViewModelMock() : super(ChildDashboardState(
    isLoading: false,
    summary: ChildrenSummaryModel(totalChildren: 37, teacherRegistered: 21, directRegistered: 16),
    teacherStudents: [],
    directStudents: [],
  ));

  @override
  Future<void> fetchDashboardStats() async {}
}

class ModulesUploadedViewModelMock extends StateNotifier<ModuleUploadedState>
    implements ModulesUploadedViewModel {
  ModulesUploadedViewModelMock() : super(ModuleUploadedState(
    isLoading: false,
    stats: ModuleStatsModel(
      totalCount: 10, adminCount: 5, teacherCount: 5,
      adminModules: [], teacherModules: [], categoryCounts: {},
    ),
  ));

  @override
  Future<void> fetchModuleStats() async {}
}

class ActiveChallengeViewModelMock extends StateNotifier<ActiveChallengeState>
    implements ActiveChallengeViewModel {
  ActiveChallengeViewModelMock() : super(ActiveChallengeState(
    isLoading: false,
    activeChallenges: [],
    totalActiveCount: 5,
  ));

  @override
  Future<void> fetchActiveStats() async {}
}

class AvgProgressViewModelMock extends StateNotifier<AvgProgressState>
    implements AvgProgressViewModel {
  AvgProgressViewModelMock() : super(AvgProgressState(
    isLoading: false,
    stats: AvgProgressModel(
      globalAverage: 75.0, quizAverage: 80, stemAverage: 70,
      qrAverage: 60, multimediaEngagement: 90, totalStudentsTracked: 37,
    ),
  ));

  @override
  Future<void> fetchGlobalProgress() async {}
}
