import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:schedulelist/theme.dart';
import 'package:schedulelist/views/login.dart';
import 'package:schedulelist/views/dashboard.dart';
import 'package:schedulelist/services/notification_service.dart';
import 'package:schedulelist/services/user_session.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init database factory berdasarkan platform
  if (kIsWeb) {
    // Web: gunakan sqflite_common_ffi_web
    databaseFactory = databaseFactoryFfiWeb;
  } else if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    // Desktop: gunakan sqflite_common_ffi
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

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
