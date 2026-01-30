import 'package:flutter/material.dart';
import 'package:schedulelist/theme.dart';
import 'package:schedulelist/views/login.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Schedule-List',
      theme: appTheme,
      debugShowCheckedModeBanner: false,
      home: const LoginRegisterScreen(),
    );
  }
}
