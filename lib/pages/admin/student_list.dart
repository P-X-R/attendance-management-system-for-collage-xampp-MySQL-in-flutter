import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:attendance_app/components/custom_drawer.dart';

class StudentPage extends StatefulWidget {
  final String adminName;
  final String department;

  const StudentPage({super.key, required this.adminName, required this.department});

  @override
  _StudentPageState createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  List<String> studentList = [];
  List<String> filteredList = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = true;
  String selectedSemester = 'S1';

  @override
  void initState() {
    super.initState();
    fetchStudentList();
  }

  Future<void> fetchStudentList() async {
    final url = Uri.parse("http://10.0.2.2/localconnect/get_students.php");

    try {
      final response = await http.post(
        url,
        body: {'department': widget.department, 'semester': selectedSemester},
      );

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}"); // Debugging

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final data = json.decode(response.body);

        if (data.containsKey('students')) {
          setState(() {
            studentList = List<String>.from(data['students']);
            filteredList = studentList;
            isLoading = false;
          });
        } else {
          throw Exception("Invalid response format");
        }
      } else {
        throw Exception("Empty or invalid response from server");
      }
    } catch (e) {
      print("Error fetching data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deleteStudent(String studentName) async {
    final url = Uri.parse("http://10.0.2.2/localconnect/delete_student.php");

    try {
      final response = await http.post(url, body: {'name': studentName});

      if (response.statusCode == 200) {
        setState(() {
          studentList.remove(studentName);
          filteredList.remove(studentName);
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Student deleted successfully")));
      } else {
        throw Exception("Failed to delete student");
      }
    } catch (e) {
      print("Error deleting student: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error deleting student")));
    }
  }

  void filterSearch(String query) {
    setState(() {
      filteredList =
          studentList
              .where((name) => name.toLowerCase().contains(query.toLowerCase()))
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Department: ${widget.department}",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "Total Students: ${studentList.length}",
              style: TextStyle(fontSize: 14),
            ),
          ],
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
      drawer: CustomDrawer(adminName: widget.adminName),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: DropdownButton<String>(
                            value: selectedSemester,
                            onChanged: (newValue) {
                              setState(() {
                                selectedSemester = newValue!;
                                isLoading = true;
                              });
                              fetchStudentList();
                            },
                            items:
                                [
                                  'S1',
                                  'S2',
                                  'S3',
                                  'S4',
                                  'S5',
                                  'S6',
                                  'S7',
                                  'S8',
                                ].map((String semester) {
                                  return DropdownMenuItem<String>(
                                    value: semester,
                                    child: Text("Semester $semester"),
                                  );
                                }).toList(),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: searchController,
                            onChanged: filterSearch,
                            decoration: InputDecoration(
                              hintText: "Search Students",
                              prefixIcon: Icon(
                                Icons.search,
                                color: Colors.grey,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              suffixIcon:
                                  searchController.text.isNotEmpty
                                      ? IconButton(
                                        icon: Icon(Icons.clear),
                                        onPressed: () {
                                          setState(() {
                                            searchController.clear();
                                            filterSearch("");
                                          });
                                        },
                                      )
                                      : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 4),
                        ],
                      ),
                      child: ListView.builder(
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          String studentName = filteredList[index];
                          return ListTile(
                            //title: Text(studentName),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                deleteStudent(studentName);
                              },
                            ),
                            subtitle: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    "${index + 1}",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 20),
                                  Expanded(
                                    child: Text(
                                      studentName,
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}
