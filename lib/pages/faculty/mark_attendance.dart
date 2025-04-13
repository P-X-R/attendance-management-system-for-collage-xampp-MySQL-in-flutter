// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'package:attendance_app/pages/faculty/Widgets/drawer.dart' show FacultyDrawer;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  String facultyName = "Loading...";
  String subjectName = "Loading...";
  String facultyId = "";
  String subjectId = "";
  String semesterId = "";
  List<Map<String, dynamic>> students = [];
  bool allAbsent = true;
  TextEditingController hoursController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  String currentTime = "";
  List<Map<String, dynamic>> filteredStudents = [];
  Timer? timer;

  @override
  void initState() {
    super.initState();
    retrieveAttendanceData();
    updateTime();
    timer = Timer.periodic(Duration(seconds: 60), (timer) => updateTime());
  }

  @override
  void dispose() {
    timer?.cancel();
    hoursController.dispose();
    searchController.dispose();
    super.dispose();
  }

  // Retrieve shared data from SharedPreferences
  Future<void> retrieveAttendanceData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      facultyId = prefs.getString('faculty_id') ?? "";
      facultyName = prefs.getString('faculty_name') ?? "Unknown Faculty";
      subjectId = prefs.getString('subject_id') ?? "";
      subjectName = prefs.getString('subject_name') ?? "Unknown Subject";
      semesterId = prefs.getString('semester_id') ?? "";
    });

    // Fetch students using the retrieved semester ID
    if (semesterId.isNotEmpty) {
      await fetchStudentList(semesterId);
    }
  }

  // Fetch student list with proper error handling
  Future<void> fetchStudentList(String semester) async {
    try {
      print("Fetching students for semester: $semester");

      final response = await http.get(
        Uri.parse("http://10.0.2.2/localconnect/faculty/fetch_students.php?semester=$semester"),
      ).timeout(Duration(seconds: 10));

      print("Response: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data['success'] == true) {
          // 1. Create base student list with null checks
          var studentList = (data['students'] as List)
              .where((s) => s['name'] != null && s['name'].toString().trim().isNotEmpty)
              .map((s) => Map<String, dynamic>.from(s)) // Create clean copy
              .toList();

          // 2. Sort alphabetically by name
          studentList.sort((a, b) => a['name'].compareTo(b['name']));

          // 3. Add roll numbers while preserving all original data
          setState(() {
            students = studentList.asMap().entries.map((entry) {
              int index = entry.key;
              var student = entry.value;
              return {
                ...student,
                'present': true, // Default attendance status
                'roll_no': index + 1, // 1-based roll number
              };
            }).toList();

            filteredStudents = List.from(students);
          });

          debugPrint('Students loaded: ${students.map((s) => '${s['roll_no']}:${s['name']}').join(', ')}');
        } else {
          throw Exception(data['error'] ?? 'Failed to fetch students');
        }
      } else {
        throw Exception('HTTP Error ${response.statusCode}');
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error loading students: ${e.toString().replaceAll('Exception: ', '')}"),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        students = [];
        filteredStudents = [];
      });
    }
  }
  void updateTime() {
    setState(() {
      currentTime = DateFormat('hh:mm a - dd-MM-yyyy').format(DateTime.now());
    });
  }

  bool isSaving = false;

  Future<void> saveAttendance() async {
    if (!_isSaveEnabled()) return;
setState(()=> isSaving=true);
    try {
      final now = DateTime.now();
      final formattedDate = DateFormat('yyyy-MM-dd').format(now);

      // Pre-check with backend
      final preCheckResponse = await http.post(
        Uri.parse('http://10.0.2.2/localconnect/faculty/check_attendance.php'),
        body: {
          'faculty_id': facultyId,
          'subject_id': subjectId,
          'attendance_date': formattedDate,
          'hours': hoursController.text,
        },
      );

      if (preCheckResponse.statusCode == 200) {
        final preCheckResult = jsonDecode(preCheckResponse.body);
        if (preCheckResult['exists'] == true) {
          throw Exception('Attendance already exists for these hours');
        }
      }

      // Complete save payload
      final saveResponse = await http.post(
        Uri.parse('http://10.0.2.2/localconnect/faculty/save_attendance.php'),
        body: {
          'faculty_id': facultyId,
          'semester_id': semesterId,
          'subject_id': subjectId,
          'hours': hoursController.text,
          'attendance_date': formattedDate,
          'students': jsonEncode(students.map((s) => {
            'id': s['id'],
            'present': s['present'],
          }).toList()),
        },
      );

      final result = jsonDecode(saveResponse.body);
      if (saveResponse.statusCode == 200 && result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Attendance saved successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception(result['error'] ?? 'Failed to save attendance');
      }
    }

    catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')
              .replaceAll('SocketException', 'Network error')
              .replaceAll('Failed host lookup', 'No internet connection'),),
          backgroundColor: Colors.red,
        ),
      );
    }
    finally{
      if(mounted) setState(()=> isSaving = false);
    }
  }
  Future<void> confirmAndSaveAttendance() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Save"),
        content: const Text("Are you sure you want to save this attendance record?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Save"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await saveAttendance();
    }
  }





  void filterStudents(String query) {
    query = query.toLowerCase();
    setState(() {
      filteredStudents = students.where((student) {
        String name = student["name"].toLowerCase();
        String id = student["id"].toString();
        return name.contains(query) || id.contains(query);
      }).toList();
    });
  }

  Future<void> toggleAllAttendance() async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Attendance Change"),
        content: Text(
          "Are you sure you want to mark all students as ${allAbsent ? 'Present' : 'Absent'}?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),  // Cancel
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),   // Confirm
            child: Text("Confirm"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        allAbsent = !allAbsent;
        students = students.map((student) => {
          ...student,
          'present': !allAbsent,
        }).toList();

        filteredStudents = List.from(students);
      });

      // Only show the status change message, not the save confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "All students marked as ${allAbsent ? 'Absent' : 'Present'}.",
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  String? _validateHours(String value) {
    if (value.isEmpty) return null; // Don't show error when empty
    final hours = int.tryParse(value);
    if (hours == null || hours < 1 || hours > 6) {
      return 'Enter 1-6 hours';
    }
    return null;
  }
  Widget _buildSaveButton() {
    return Container(

      height: 80,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: ElevatedButton.icon(
        icon: isSaving
            ? SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : Icon(Icons.save),
        label: isSaving
            ? Text("Saving...")
            : Text("SAVE ATTENDANCE"),
        style: ElevatedButton.styleFrom(
          backgroundColor: _isSaveEnabled() && !isSaving
              ? Colors.blue
              : Colors.grey,
          foregroundColor: Colors.white,
          minimumSize: Size(double.infinity, 50),
        ),
        onPressed: (_isSaveEnabled() && !_hasDuplicateStudents() && !isSaving)
            ? _showAbsenteeSummary
            : null,
      ),
    );
  }
  bool _isSaveEnabled() {
    // Reuse the same validation logic from hours field
    final hours = int.tryParse(hoursController.text);
    return hours != null && hours >= 1 && hours <= 6;
  }

  bool _hasDuplicateStudents() {
    final ids = students.map((s) => s['id']).toList();
    return ids.length != Set.from(ids).length;
  }

  void _validateBeforeSave() {
    if (_hasDuplicateStudents()) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Duplicate student entries detected")));
      return;
    }
    confirmAndSaveAttendance();
  }
  void _showAbsenteeSummary() {
    final absentStudents = students.where((s) => !s['present']).toList();
    title: Text("Absent Students ($_absentCount/${students.length})");
    if (absentStudents.isEmpty) {
      confirmAndSaveAttendance();
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Review Absent Students (${absentStudents.length})"),
        content: Container(
          width: double.maxFinite,
          constraints: BoxConstraints(maxHeight: 300),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: absentStudents.length,
            itemBuilder: (_, index) => ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.red[400],
                child: Text(
                  "${absentStudents[index]['roll_no']}",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              title: Text(absentStudents[index]['name']),
              tileColor: Colors.red[50],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("EDIT", style: TextStyle(color: Colors.blue)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[400],
            ),
            onPressed: () {
              Navigator.pop(context);
              confirmAndSaveAttendance();
            },
            child: Text("CONFIRM ABSENCE", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
// Add this with your other state variables
  int get _absentCount => students.where((s) => !s['present']).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: FacultyDrawer(facultyName: facultyName),
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(facultyName, style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: updateTime,
          ),
        ],
      ),
      bottomNavigationBar: _buildSaveButton(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5F5F5), Color(0xFFF5F5F5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subjectName,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                // Search Bar for filtering students
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name or ID',
                    prefixIcon: Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (value) => filterStudents(value),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: hoursController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          hintText: "Hours (1-6)",
                          errorText: _validateHours(hoursController.text)
                        ),
                        onChanged: (value) {
                        /*  int? enteredValue = int.tryParse(value);
                          if (enteredValue != null &&
                              (enteredValue < 1 || enteredValue > 6)) {
                            hoursController.clear();*/
                          setState(() {});//for real time validation
                        },

                      ),
                    ),
                    SizedBox(width: 10),
                    Row(
                      children: [
                        Text(
                          allAbsent ? "All Absent" : "All Present",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Switch(
                          value: !allAbsent,
                          onChanged: (value) => toggleAllAttendance(),
                          activeColor: Colors.green,
                          inactiveThumbColor: Colors.red,
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(currentTime),
                    Chip(
                      label: Text("$_absentCount Absent"),
                      backgroundColor: _absentCount > 0 ? Colors.red[100] : Colors.green[100],
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Expanded(
                  child: students.isEmpty
                      ? Center(
                    child: Text(
                      "No students found.",
                      style: TextStyle(fontSize: 18, color: Colors.red),
                    ),
                  )
                  :ListView.builder(
                    itemCount: filteredStudents.length,
                    itemBuilder: (context, index) {
                      var student = filteredStudents[index];
                      return Card(
                        elevation: 3,
                        margin: EdgeInsets.symmetric(vertical: 5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: student["present"]
                                ? Colors.green
                                : Colors.red,
                            child: Text(
                              "${student["roll_no"]}", // Changed from "id" to "roll_no"
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(
                            student["name"],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: student["present"]
                                  ? Colors.black
                                  : Colors.black,
                            ),
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              student["present"]
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              color: student["present"]
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            onPressed: () {
                              setState(() {
                                student["present"] = !student["present"];
                              });
                             // saveAttendance();
                            },
                          ),
                        ),
                      );
                    },
                  )
                ),
              ],
            ),
          ),
        ),
      ),
      // Normal Save Button at the bottom (not a floating button)
    /*  floatingActionButton: FloatingActionButton(
        onPressed: hoursController.text.isEmpty || int.tryParse(hoursController.text) == null
            ? null // Disable when invalid
            : confirmAndSaveAttendance,
        backgroundColor: hoursController.text.isEmpty
            ? Colors.grey // Visual feedback
            : Colors.blue,
        child: const Icon(Icons.save, color: Colors.white),
      ),*/

    );
  }
}


