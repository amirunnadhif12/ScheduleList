import 'package:flutter/material.dart';
import 'package:schedulelist/views/login.dart';
import 'package:schedulelist/theme.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: appTheme,
      home: const LoginRegisterScreen(),
    );
  }
}
