import 'package:attendance_app/pages/student/stdrawer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class AttendanceViewPage extends StatefulWidget {
  final String studentId;
  final String studentName;
  final String subjectId;
  final String subjectName;
  final String facultyId;
  final String department;
  final String semester;
  final String facultyName;

  const AttendanceViewPage({
    required this.studentId,
    required this.studentName,
    required this.subjectId,
    required this.subjectName,
    required this.facultyId,
    required this.facultyName,
    required this.department,
    required this.semester,
    Key? key,
  }) : super(key: key);

  @override
  _AttendanceViewPageState createState() => _AttendanceViewPageState();
}

class _AttendanceViewPageState extends State<AttendanceViewPage> {
  List<Map<String, dynamic>> attendanceRecords = [];
  bool isLoading = true;
  String errorMessage = '';
  DateTime? startDate;
  DateTime? endDate;
  //double attendancePercentage = 0.0;
  Map<String, dynamic> stats = {
    'percentage': 0.0,
    'total_hours': 0,
    'present_hours': 0
  };


  @override
  void initState() {
    super.initState();
    fetchAttendanceRecords();
  }


  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: startDate != null && endDate != null
          ? DateTimeRange(start: startDate!, end: endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
      });
      fetchAttendanceRecords();
    }
  }

  Future<void> fetchAttendanceRecords() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final Map<String, String> body = {
        'student_id': widget.studentId,
        'subject_id': widget.subjectId,
        'semester': widget.semester,
      };

      if (startDate != null && endDate != null) {
        body['start_date'] = DateFormat('yyyy-MM-dd').format(startDate!);
        body['end_date'] = DateFormat('yyyy-MM-dd').format(endDate!);
      }

      final response = await http.post(
        Uri.parse('http://10.0.2.2/localconnect/student/student_attendance.php'),
        body: body,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            attendanceRecords = List<Map<String, dynamic>>.from(data['records']);
            stats = Map<String, dynamic>.from(data['stats']);
            isLoading = false;
          });
        } else {
          throw Exception(data['error'] ?? 'Unknown error from server');
        }
      } else {
        throw Exception('HTTP error ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(' ${widget.subjectName}',
        style: const TextStyle(color: Colors.white),
        ),

      ),
      drawer: StudentDrawer(studentName: widget.studentName),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(),
            const SizedBox(height: 20),
            Text(
              'Attendance Records',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            _buildAttendanceList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible( // Added Flexible to prevent overflow
                  child: Text(
                    'Attendance Summary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _selectDateRange(context),
                  child: Text(
                    'Date Range',
                    style: TextStyle(fontSize: 14), // Reduced font size
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12, // Reduced padding
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (startDate != null && endDate != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  '${DateFormat('MMM d, y').format(startDate!)} - ${DateFormat('MMM d, y').format(endDate!)}',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Subject: ${widget.subjectName}'),
                      Text('Faculty: ${widget.facultyName}'),
                      const SizedBox(height: 8),
                      Text('Total Hours: ${stats['total_hours']}'),
                      Text('Present Hours: ${stats['present_hours']}'),
                    ],
                  ),
                ),
                Column(
                  children: [
                    CircularProgressIndicator(
                      value: stats['percentage'] / 100,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        stats['percentage'] >= 75 ? Colors.green : Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${stats['percentage'].toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: stats['percentage'] >= 75 ? Colors.green : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceList() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          children: [
            Text(errorMessage),
            ElevatedButton(
              onPressed: fetchAttendanceRecords,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (attendanceRecords.isEmpty) {
      return const Center(child: Text('No attendance records found'));
    }

    return Expanded(
      child: ListView.builder(
        itemCount: attendanceRecords.length,
        itemBuilder: (context, index) {
          final record = attendanceRecords[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: Icon(
                record['status'] == 'present' ? Icons.check_circle : Icons.cancel,
                color: record['status'] == 'present' ? Colors.green : Colors.red,
              ),
              title: Text(
                'Date: ${record['attendance_date']}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text('Hours: ${record['hours']}'),
              trailing: Text(
                record['status'].toString().toUpperCase(),
                style: TextStyle(
                  color: record['status'] == 'present' ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}