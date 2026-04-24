import 'package:eco_venture_admin_portal/services/notifications_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'core/routes/router_provider.dart';
import 'firebase_options.dart'; // Your options file
@pragma('vm:entry-point') // Mandatory for release mode
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize the foreground/local service
  await NotificationService().init();

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
    // Assuming you have a router provider
    final router = ref.watch(goRouterProvider);

    return ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return MaterialApp.router(
          title: 'EcoVenture User App', // User App Title
          debugShowCheckedModeBanner: false,
          routerConfig: router,
        );
      },
    );
  }
}