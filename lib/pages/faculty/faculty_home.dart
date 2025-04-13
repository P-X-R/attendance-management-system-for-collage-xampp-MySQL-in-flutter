
import 'package:attendance_app/pages/faculty/Widgets/drawer.dart';
import 'package:attendance_app/pages/faculty/faculty_view.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FacultyDashboard extends StatefulWidget {
  const FacultyDashboard({super.key});

  @override
  _FacultyDashboardState createState() => _FacultyDashboardState();
}

class _FacultyDashboardState extends State<FacultyDashboard> {
  String facultyName = "Loading...";
  String facultyId = "";
  String selectedSubject = "";
  List<Map<String, dynamic>> subjects = [];
  bool isLoading = true;
  String errorMessage = "";

  Future<void> fetchFacultyDetails() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? storedFacultyName = prefs.getString('faculty_name');
      String? storedFacultyId = prefs.getString('faculty_id');

      if (storedFacultyName != null && storedFacultyId != null) {
        setState(() {
          facultyName = storedFacultyName;
          facultyId = storedFacultyId;
        });
        if (facultyId.isNotEmpty) {
          await fetchSubjects();
        }
      } else {
        setState(() {
          errorMessage = "Faculty details not found. Please login again.";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error loading faculty details: $e";
        isLoading = false;
      });
    }
  }

  Future<void> fetchSubjects() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = "";
      });

      final response = await http.post(
        Uri.parse('http://10.0.2.2/localconnect/faculty/faculty_subjects.php'),
        body: {'faculty_id': facultyId},
      );

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        if (jsonData is List) {
          setState(() {
            subjects =
                jsonData.map<Map<String, dynamic>>((subject) {
                  return {
                    "code": subject["subject_id"].toString(),
                    "title": subject["subject_name"],
                    "semester": subject["semester"].toString(),
                    "department": subject["department"] ?? "N/A",
                  };
                }).toList();
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = jsonData['message'] ?? "No subjects found";
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = "Server error: ${response.statusCode}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error fetching subjects: $e";
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchFacultyDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        title: const Text('Faculty Dashboard',
            style:TextStyle(color: Colors.white)),
      ),
      drawer: FacultyDrawer(facultyName: facultyName),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome,",
                  style: TextStyle(
                    fontSize: constraints.maxWidth * 0.08,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  facultyName,
                  style: TextStyle(
                    fontSize: constraints.maxWidth * 0.07,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Your Assigned Subjects",
                  style: TextStyle(
                    fontSize: constraints.maxWidth * 0.05,
                    fontWeight: FontWeight.bold,
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
                    const Center(child: Text('No subjects assigned yet'))
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: subjects.length,
                        itemBuilder: (context, index) {
                          final subject = subjects[index];
                          return SubjectCard(
                            subject["code"]!,
                            subject["title"]!,
                            subject["semester"]!,
                            subject["department"]!,
                            selectedSubject,
                                (code) => setState(() => selectedSubject = code),
                          );
                        },
                      ),
                    ),
                if (!isLoading && subjects.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // ✅ Mark Attendance Button
                      ElevatedButton.icon(
                        onPressed: selectedSubject.isEmpty
                            ? null
                            : () async {
                          // Find the selected subject data
                          final selectedData = subjects.firstWhere(
                                (subject) => subject["code"] == selectedSubject,
                            orElse: () => {},
                          );

                          // ✅ Store parameters in SharedPreferences
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          await prefs.setString('faculty_id', facultyId);
                          await prefs.setString('faculty_name', facultyName);
                          await prefs.setString('subject_id', selectedData['code']);
                          await prefs.setString('semester_id', selectedData['semester']);
                          await prefs.setString('subject_name', selectedData['title']);

                          // ✅ Navigate without parameters
                          Navigator.pushNamed(context, '/markAttendance');
                        },

                        icon: const Icon(Icons.edit),
                        label: const Text('Mark Attendance'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),

                      // ✅ View Attendance Button
                      ElevatedButton.icon(
                        onPressed: selectedSubject.isEmpty
                            ? null
                            : () {
                          // Find the selected subject data
                          final selectedData = subjects.firstWhere(
                                (subject) => subject["code"] == selectedSubject
                          );

                          // ✅ Navigate with complete parameters
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context)=>AttendanceViewPage(
                                  facultyId: facultyId,
                                  facultyName: facultyName,
                                  semesterId: selectedData['semester'],
                                  subjectId: selectedData['code'],
                                  subjectName:  selectedData['title'],

                              ),
                            ),
                           /* arguments: {
                              'faculty_id': facultyId,
                              'faculty_name': facultyName,      // ✅ Pass faculty name
                              'subject_id': selectedData['code'],
                              'semester_id': selectedData['semester'],
                              'subject_name': selectedData['title'],
                            },*/
                          );

                        },
                        icon: const Icon(Icons.visibility),
                        label: const Text('View Attendance'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class SubjectCard extends StatelessWidget {
  final String code;
  final String title;
  final String semester;
  final String department;
  final String selectedSubject;
  final Function(String) onSelect;

  const SubjectCard(
      this.code,
      this.title,
      this.semester,
      this.department,
      this.selectedSubject,
      this.onSelect, {
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
          color: isSelected ? Colors.green : Colors.transparent,
          width: 2,
        ),
      ),
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
                    code,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.green : Colors.black,
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_circle, color: Colors.green),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: isSelected ? Colors.green : Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.school, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Semester: $semester',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.business, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    department,
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