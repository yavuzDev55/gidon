import 'package:flutter/material.dart';
import 'features/navigation/main_navigation_screen.dart';
import 'services/background/background_service.dart';
import 'services/location/isar_service.dart';
import 'core/permissions/location_permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final isarService = IsarService();
  await isarService.initialize();

  // Registers the background service with Android. This does not
  // start tracking yet — it just prepares the service so it can be
  // started later when the user presses "Start Ride".
  await LocationPermissionHandler.ensureNotificationPermission();
  await initializeBackgroundService();

  runApp(GidonApp(isarService: isarService));
}

class GidonApp extends StatelessWidget {
  final IsarService isarService;

  const GidonApp({super.key, required this.isarService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainNavigationScreen(isarService: isarService),
    );
  }
}
