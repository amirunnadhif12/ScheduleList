import 'package:flutter/material.dart';
import 'package:schedulelist/theme.dart';
import 'package:schedulelist/views/login.dart';
import 'package:schedulelist/views/dashboard.dart';
import 'package:schedulelist/services/notification_service.dart';
import 'package:schedulelist/services/user_session.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize notification service
  await NotificationService().initialize();
  
  // Load user session
  final isLoggedIn = await UserSession().loadSession();
  
  runApp(MainApp(isLoggedIn: isLoggedIn));
}

class MainApp extends StatelessWidget {
  final bool isLoggedIn;
  
  const MainApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    final session = UserSession();
    
    return MaterialApp(
      title: 'Schedule-List',
      theme: appTheme,
      debugShowCheckedModeBanner: false,
      home: isLoggedIn
          ? DashboardScreen(
              userName: session.userName ?? '',
              userId: session.userId ?? 0,
            )
          : const LoginRegisterScreen(),
    );
  }
}
