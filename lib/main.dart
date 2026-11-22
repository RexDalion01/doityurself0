
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const TaskApp());
}

class TaskApp extends StatelessWidget {
  const TaskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task App',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8F9F8),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF20A879),
        ),
        fontFamily: 'roboto',
      ),
      home: const HomeScreen(),
    );
  }
}