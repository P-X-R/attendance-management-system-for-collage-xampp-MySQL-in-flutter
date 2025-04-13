import 'package:flutter/material.dart';

//import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// import 'package:admin1/screens/faculty_page.dart';
// import 'package:admin1/screens/student_page.dart';
import 'package:attendance_app/components/custom_drawer.dart';
import 'package:attendance_app/pages/admin/faculty_list.dart';
import 'package:attendance_app/pages/admin/student_list.dart';

class AdminHomePage extends StatefulWidget {
  final String adminName;

  const AdminHomePage({super.key, required this.adminName});

  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  bool isFacultySelected = true;
  List<String> departments = [];
  List<String> usernames = [];
  @override
  void initState() {
    super.initState();
    fetchDepartments();
  }

  Future<void> fetchuser() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2/localconnect/login.php'),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      setState(() {
        usernames = List<String>.from(data);
      });
    } else {
      throw Exception('Failed to load departments');
    }
  }

  Future<void> fetchDepartments() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2/localconnect/departments.php'),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      setState(() {
        departments = List<String>.from(data);
      });
    } else {
      throw Exception('Failed to load departments');
    }
  }

  void navigateToPage(String department) {
    if (isFacultySelected) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => FacultyPage(
                department: department,
                adminName: widget.adminName,
              ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => StudentPage(
                department: department,
                adminName: widget.adminName,
              ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        title: Text(
          " ${widget.adminName}",
          style: TextStyle(
            color: Colors.grey.shade800,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: Icon(Icons.menu, color: Colors.black),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
        ),
      ),

      drawer: CustomDrawer(adminName: widget.adminName,),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isFacultySelected = true;
                      });
                    },
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color:
                            isFacultySelected
                                ? Colors.white
                                : Colors.transparent,
                        border: Border.all(color: Colors.green[800]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Faculty",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isFacultySelected = false;
                      });
                    },
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color:
                            !isFacultySelected
                                ? Colors.white
                                : Colors.transparent,
                        border: Border.all(color: Colors.green[800]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Students",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Container(
                margin: EdgeInsets.all(16),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
                ),
                child:
                    departments.isEmpty
                        ? Center(
                          child: CircularProgressIndicator(color: Colors.teal),
                        )
                        : ListView.builder(
                          shrinkWrap: true,
                          itemCount: departments.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                ),
                                onPressed: () {
                                  navigateToPage(departments[index]);
                                },
                                child: Text(
                                  departments[index],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Faculty Page
// class FacultyPage extends StatelessWidget {
//   final String department;
//   FacultyPage({required this.department});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("$department - Faculty")),
//       body: Center(child: Text("Welcome to the Faculty Page of $department")),
//     );
//   }
// }

// Student Page
// class StudentPage extends StatelessWidget {
//   final String department;
//   StudentPage({required this.department});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("$department - Student")),
//       body: Center(child: Text("Welcome to the Student Page of $department")),
//     );
//   }
// }
