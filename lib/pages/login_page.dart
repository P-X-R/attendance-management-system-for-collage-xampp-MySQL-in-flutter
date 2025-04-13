import 'dart:convert';
import 'package:attendance_app/pages/faculty/faculty_home.dart';
import 'package:attendance_app/pages/student/student_home.dart';
import 'package:attendance_app/pages/admin/admin_home.dart';
import 'package:attendance_app/components/my_button.dart';
import 'package:attendance_app/components/my_textfield.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final TextEditingController username = TextEditingController();
  final TextEditingController password = TextEditingController();

  Future<void> login(BuildContext context) async {
    if (username.text.trim().isEmpty || password.text.trim().isEmpty) {
      Fluttertoast.showToast(
        msg: "Please fill all fields",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2/localconnect/login.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'username': username.text, 'password': password.text},
      );

      if (response.statusCode == 200) {
        try {
          var data = json.decode(response.body);
          print("Response: $data");

          if (data["status"] == "Success") {
            String role = data["role"];

            // Save user details in SharedPreferences
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('username', username.text);

            Fluttertoast.showToast(
              msg: "Login successful",
              backgroundColor: Colors.green,
              textColor: Colors.white,
            );

            if (role == "admin") {
              await prefs.setString('admin_name', data["admin_name"]);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AdminHomePage(adminName: data["admin_name"])),
              );
            } else if (role == "faculty") {
              await prefs.setString('faculty_name', data["faculty_name"]);
              await prefs.setString('faculty_id', data["faculty_id"]);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => FacultyDashboard()),
              );
            } else if (role == "student") {
              await prefs.setString('student_id', data["student_id"]);
              await prefs.setString('student_name',data["student_name"]);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => StudentDashboard()),
              );
            } else {
              Fluttertoast.showToast(
                msg: "Unknown role: $role",
                backgroundColor: Colors.orange,
              );
            }
          } else {
            Fluttertoast.showToast(
              msg: data["message"] ?? "Invalid username or password",
              backgroundColor: Colors.red,
            );
          }
        } catch (e) {
          print("Error decoding JSON: $e");
          Fluttertoast.showToast(
            msg: "Invalid server response",
            backgroundColor: Colors.red,
          );
        }
      } else {
        Fluttertoast.showToast(
          msg: "Server error: ${response.statusCode}",
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      print("Error: $e");
      Fluttertoast.showToast(
        msg: "Server error. Please try again.",
        backgroundColor: Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[200],
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 50),
              const Icon(Icons.lock, size: 90),
              const SizedBox(height: 50),
              Text(
                "Welcome",
                style: TextStyle(color: Colors.grey[850], fontSize: 16),
              ),
              const SizedBox(height: 20),
              MyTextField(controller: username, hintText: "Username", obscureText: false),
              const SizedBox(height: 10),
              MyTextField(controller: password, hintText: "Password", obscureText: true),
              const SizedBox(height: 25),
              ButtonTheme(
                minWidth: 200,
                height: 50,
                child: MyButton(
                  onTap: () {
                    login(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}