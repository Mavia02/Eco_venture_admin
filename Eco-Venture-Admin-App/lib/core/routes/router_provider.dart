import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'app_router.dart';

/// Provide GoRouter instance across app
final goRouterProvider = Provider<GoRouter>((ref) {
  return AppRouter.router;
});
