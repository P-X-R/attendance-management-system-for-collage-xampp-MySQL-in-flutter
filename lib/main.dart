//import 'package:attendance_app/pages/faculty/faculty_view.dart';
import 'package:attendance_app/pages/login_page.dart';
import 'package:attendance_app/pages/student/student_home.dart';
import 'package:flutter/material.dart';
import 'package:attendance_app/pages/faculty/faculty_home.dart';
import 'package:attendance_app/pages/faculty/mark_attendance.dart'; // Add this line

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
      routes: {
        '/faculty': (context) => FacultyDashboard(),
        '/login': (context) => LoginPage(),
        '/markAttendance': (context) => AttendancePage(),
        '/studentt':(context)=> StudentDashboard(),
      },
    );
  }
}
