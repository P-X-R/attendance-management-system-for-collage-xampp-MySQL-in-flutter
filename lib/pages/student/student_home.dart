import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:attendance_app/pages/student/stdrawer.dart';
import 'package:attendance_app/pages/student/stview.dart';
class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  _StudentDashboardState createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  String studentName = "Loading...";
  String studentId = "";
  String selectedSubject = "";
  List<Map<String, dynamic>> subjects = [];
  bool isLoading = true;
  String errorMessage = "";

  Future<void> fetchStudentDetails() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? storedStudentName = prefs.getString('student_name');
      String? storedStudentId = prefs.getString('student_id');

      if (storedStudentName != null && storedStudentId != null) {
        setState(() {
          studentName = storedStudentName;
          studentId = storedStudentId;
        });
        if (studentId.isNotEmpty) {
          await fetchSubjects();
        }
      } else {
        setState(() {
          errorMessage = "Student details not found. Please login again.";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error loading student details: $e";
        isLoading = false;
      });
    }
  }

  Future<void> fetchSubjects() async {
    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2/localconnect/student/student_subjects.php'),
        body: {'student_id': studentId},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          studentName = data['student']['name'];
          subjects = (data['subjects'] as List).map((s) => {
            "subject_id": s['subject_id'].toString(),
            "subject_name": s['subject_name'],
            "semester": s['semester'].toString(),
            "faculty_name": s['faculty_name'] ?? "Not assigned",
            "faculty_id": s['faculty_id']?.toString() ?? "",
            "department": data['student']['department'],
          }).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load subjects');
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error loading subjects: ${e.toString()}";
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchStudentDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        title: Text('Welcome, $studentName',
            style: const TextStyle(color: Colors.white)),
      ),
      drawer: StudentDrawer(studentName: studentName),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              "Your Enrolled Subjects",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (errorMessage.isNotEmpty)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: fetchSubjects,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            else if (subjects.isEmpty)
                const Center(child: Text('No subjects enrolled yet'))
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: subjects.length,
                    itemBuilder: (context, index) {
                      final subject = subjects[index];
                      return SubjectCard(
                        subject["subject_id"]!,
                        subject["subject_name"]!,
                        subject["semester"]!,
                        subject["department"]!,
                        selectedSubject,
                            (code) => setState(() => selectedSubject = code),
                        facultyName: subject["faculty_name"]!,
                      );
                    },
                  ),
                ),
            if (!isLoading && subjects.isNotEmpty) ...[
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton.icon(
                  onPressed: selectedSubject.isEmpty
                      ? null
                      : () {
                    final selectedData = subjects.firstWhere(
                          (subject) => subject["subject_id"] == selectedSubject,
                    );

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AttendanceViewPage(
                          studentId: studentId,
                          studentName: studentName,
                          subjectId: selectedData['subject_id'],
                          subjectName: selectedData['subject_name'],
                          facultyId: selectedData['faculty_id'],
                          facultyName: selectedData['faculty_name'],
                          department: selectedData['department'],
                          semester: selectedData['semester'],
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.visibility),
                  label: const Text('View Attendance'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }
}

class SubjectCard extends StatelessWidget {
  final String code;
  final String title;
  final String semester;
  final String department;
  final String facultyName;
  final String selectedSubject;
  final Function(String) onSelect;

  const SubjectCard(
      this.code,
      this.title,
      this.semester,
      this.department,
      this.selectedSubject,
      this.onSelect, {
        required this.facultyName,
        super.key,
      });

  @override
  Widget build(BuildContext context) {
    bool isSelected = selectedSubject == code;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: isSelected ? Colors.blue : Colors.grey[300]!,
          width: 1,
        ),
      ),
      elevation: isSelected ? 4 : 1,
      child: InkWell(
        onTap: () => onSelect(code),
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.blue : Colors.black,
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_circle, color: Colors.blue),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.code, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    code,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.school, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Sem $semester',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.business, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    department,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Faculty: $facultyName',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}