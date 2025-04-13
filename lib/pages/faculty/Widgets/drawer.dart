// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:attendance_app/pages/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';  // Added for logout

class FacultyDrawer extends StatelessWidget {
  final String facultyName;

  const FacultyDrawer({super.key, required this.facultyName});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blueAccent),
            child: Text(
              facultyName,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          // ✅ Dashboard Navigation
          ListTile(
            leading: Icon(Icons.home),
            title: Text("Dashboard"),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/faculty');
            },
          ),

          // ✅ Logout Navigation with Session Clearing
          ListTile(
            leading: Icon(Icons.logout),
            title: Text("Logout"),
            onTap: () async {
              // Clear faculty session
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.clear();

              Navigator.pop(context); // Close the drawer

              // Clear all routes and push login page
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => LoginPage()),
                    (Route<dynamic> route) => false,
              );

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Logged Out")),
              );
            },
          ),
        ],
      ),
    );
  }
}
