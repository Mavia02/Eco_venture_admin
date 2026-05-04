import 'package:eco_venture_admin_portal/services/notifications_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'core/routes/router_provider.dart'; // Logic: Preserving your path
import 'firebase_options.dart';

// Logic: Preserved your background handler with a safety check
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }
  debugPrint("Handling a background message: ${message.messageId}");
}

void main() async {
  // Logic: Mandatory for Firebase/Plugin initialization
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Logic: Critical fix for [core/duplicate-app] error.
    // We only initialize if no app instance exists yet.
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint("✅ Firebase Initialized Successfully");
    }
  } catch (e) {
    // Logic: If initialization fails or is already done, we catch it to prevent the "Blank Screen" crash
    debugPrint("⚠️ Firebase Init Note: $e");
  }

  // Logic: Register background handler after initialization
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Logic: Initialize your foreground/local service (Preserving your logic)
  final notificationService = NotificationService();
  await notificationService.init();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Logic: Preserving your router provider integration
    final router = ref.watch(goRouterProvider);

    return ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return MaterialApp.router(
          title: 'EcoVenture Admin Portal',
          debugShowCheckedModeBanner: false,
          routerConfig: router,
        );
      },
    );
  }
}