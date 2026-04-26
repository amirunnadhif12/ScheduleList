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

class MainApp extends StatefulWidget {
  final bool isLoggedIn;
  
  const MainApp({super.key, required this.isLoggedIn});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final ThemeNotifier _themeNotifier = ThemeNotifier();

  @override
  void initState() {
    super.initState();
    _themeNotifier.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _themeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = UserSession();
    
    return ThemeNotifierProvider(
      notifier: _themeNotifier,
      child: MaterialApp(
        title: 'Schedule-List',
        theme: appTheme,
        darkTheme: appDarkTheme,
        themeMode: _themeNotifier.themeMode,
        debugShowCheckedModeBanner: false,
        home: widget.isLoggedIn
            ? DashboardScreen(
                userName: session.userName ?? '',
                userId: session.userId ?? 0,
              )
            : const LoginRegisterScreen(),
      ),
    );
  }
}

// InheritedWidget to provide ThemeNotifier down the widget tree
class ThemeNotifierProvider extends InheritedWidget {
  final ThemeNotifier notifier;

  const ThemeNotifierProvider({
    super.key,
    required this.notifier,
    required super.child,
  });

  static ThemeNotifier of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeNotifierProvider>()!.notifier;
  }

  @override
  bool updateShouldNotify(ThemeNotifierProvider oldWidget) {
    return notifier.themeMode != oldWidget.notifier.themeMode;
  }
}
