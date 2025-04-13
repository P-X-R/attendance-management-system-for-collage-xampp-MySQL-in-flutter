import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:attendance_app/components/custom_drawer.dart';
//import 'package:attendance/pages/admin/class_view.dart';

class AssignSubjectFacultyPage extends StatefulWidget {
  final String adminName;
  @override
  AssignSubjectFacultyPage({required this.adminName});

  _AssignSubjectFacultyPageState createState() =>
      _AssignSubjectFacultyPageState();
}

class _AssignSubjectFacultyPageState extends State<AssignSubjectFacultyPage> {
  int? selectedDepartment, selectedSemester, selectedSubject, selectedFaculty;
  List<int> semesters = [];
  List<dynamic> subjects = [], faculty = [];
  final TextEditingController newSubjectController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();

  Future<void> fetchSubjects() async {
    if (selectedDepartment == null || selectedSemester == null) {
      print("Missing department or semester");
      return;
    }

    final response = await http.get(
      Uri.parse(
        "http://10.0.2.2/localconnect/get_subjects.php?department_id=$selectedDepartment&semester=$selectedSemester",
      ),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("Response Data: $data"); // Debugging

      if (data['success']) {
        setState(() {
          subjects = data['subjects'];
        });
      } else {
        print("Failed to fetch subjects: ${data['message']}");
      }
    } else {
      print("HTTP Error: ${response.statusCode}");
    }
  }

  Future<void> fetchFaculty() async {
    final response = await http.get(
      Uri.parse("http://10.0.2.2/localconnect/get_faculty2.php"),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("Faculty API Response: $data"); // Debugging output

      if (data['success']) {
        setState(() {
          faculty = data['faculty'];
        });
      } else {
        print("Failed to fetch faculty: ${data['message']}");
      }
    } else {
      print("HTTP Error: ${response.statusCode}");
    }
  }

  Future<void> addNewSubject() async {
    String newSubject = newSubjectController.text.trim();
    if (newSubject.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Please enter a subject name")));
      return;
    }

    final response = await http.post(
      Uri.parse("http://10.0.2.2/localconnect/add_subject.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "department_id": selectedDepartment,
        "semester": selectedSemester,
        "subject_name": newSubject,
      }),
    );

    final data = jsonDecode(response.body);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(data['message'])));

    if (data['success']) {
      Navigator.pop(context); // Close dialog
      fetchSubjects(); // Refresh subjects list
    }
  }

  Future<void> assignSubjectFaculty() async {
    if (selectedDepartment == null ||
        selectedSemester == null ||
        selectedSubject == null ||
        selectedFaculty == null ||
        startDateController.text.isEmpty ||
        endDateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill in all fields, including dates")),
      );
      return;
    }

    final response = await http.post(
      Uri.parse("http://10.0.2.2/localconnect/add_subjects_faculty.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "department_id": selectedDepartment,
        "semester": selectedSemester,
        "subject_id": selectedSubject,
        "faculty_id": selectedFaculty,
        "start_date": startDateController.text, // Include start date
        "end_date": endDateController.text, // Include end date
      }),
    );

    final data = jsonDecode(response.body);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(data['message'])));

    print("Assign Faculty Response: $data");
  }

  @override
  void initState() {
    super.initState();
    fetchSubjects();
    fetchFaculty();
  }

  void updateSemesters(int departmentId) {
    setState(() {
      selectedSemester = null; // Reset selected semester
      semesters = List.generate(8, (index) => index + 1); // Semesters 1-8
    });
  }

  void showAddSubjectDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
        title: Text(
          "Add New Subject",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: newSubjectController,
          decoration: InputDecoration(labelText: "Enter Subject Name"),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Cancel", style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: addNewSubject,
            child: Text("Add", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Future<void> selectDate(
      BuildContext context,
      TextEditingController controller,
      ) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Assign Subject & Faculty"),
        backgroundColor: Colors.green[300],
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

      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Department Dropdown
              DropdownButtonFormField<int>(
                decoration: InputDecoration(
                  labelText: "Select Department",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.green),
                  ),
                  filled: true,
                  fillColor: Colors.green[50],
                ),
                items: [
                  DropdownMenuItem(value: 1, child: Text("Computer Science")),
                  DropdownMenuItem(value: 2, child: Text("Cyber Security")),
                  DropdownMenuItem(
                    value: 3,
                    child: Text("Electronics and Communication"),
                  ),
                  DropdownMenuItem(
                    value: 4,
                    child: Text("Electrical and Electronics"),
                  ),
                  DropdownMenuItem(
                    value: 5,
                    child: Text("Polymer Engineering"),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedDepartment = value;
                  });
                  updateSemesters(value!);
                  fetchFaculty(); // Fetch faculty when department is selected
                },
              ),
              SizedBox(height: 16),
              // Semester Dropdown
              DropdownButtonFormField<int>(
                decoration: InputDecoration(
                  labelText: "Select Semester",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.green),
                  ),
                  filled: true,
                  fillColor: Colors.green[50],
                ),
                value: selectedSemester,
                items:
                semesters
                    .map(
                      (sem) => DropdownMenuItem(
                    value: sem,
                    child: Text("Semester $sem"),
                  ),
                )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedSemester = value;
                  });
                  fetchSubjects(); // Fetch subjects after selecting semester
                },
              ),
              SizedBox(height: 16),
              // Subject Dropdown
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        labelText: "Select Subject",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items:
                      subjects.map((subject) {
                        return DropdownMenuItem<int>(
                          value: subject['id'],
                          child: Text(subject['subject_name']),
                        );
                      }).toList(),
                      onChanged:
                          (value) => setState(() => selectedSubject = value),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add, color: Colors.black),
                    onPressed: showAddSubjectDialog,
                    tooltip: "Add New Subject",
                  ),
                ],
              ),
              SizedBox(height: 16),
              // Faculty Dropdown
              DropdownButtonFormField<int>(
                decoration: InputDecoration(
                  labelText: "Select Faculty",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items:
                faculty.map((prof) {
                  return DropdownMenuItem<int>(
                    value: int.tryParse(
                      prof['id'].toString(),
                    ), // ✅ Convert faculty ID to int safely
                    child: Text(prof['name']),
                  );
                }).toList(),
                onChanged: (value) => setState(() => selectedFaculty = value),
              ),
              SizedBox(height: 16),
              // Start Date Field
              TextField(
                controller: startDateController,
                decoration: InputDecoration(
                  labelText: "Start Date",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.green[50],
                ),
                readOnly: true,
                onTap: () => selectDate(context, startDateController),
              ),
              SizedBox(height: 16),
              // End Date Field
              TextField(
                controller: endDateController,
                decoration: InputDecoration(
                  labelText: "End Date",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.green[50],
                ),
                readOnly: true,
                onTap: () => selectDate(context, endDateController),
              ),
              SizedBox(height: 24),
              // Assign Button
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    backgroundColor: Colors.green[200],
                  ),
                  onPressed: assignSubjectFaculty,
                  child: Text(
                    "Assign Subject & Faculty",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}