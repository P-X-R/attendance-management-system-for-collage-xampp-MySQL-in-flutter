import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:attendance_app/pages/faculty/Widgets/drawer.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:attendance_app/pages/faculty/pdf_export_service.dart';

class AttendanceViewPage extends StatefulWidget {
  final String facultyId;
  final String facultyName;
  final String semesterId;
  final String subjectId;
  final String subjectName;

  const AttendanceViewPage({
    required this.facultyId,
    required this.facultyName,
    required this.semesterId,
    required this.subjectId,
    required this.subjectName,
    Key? key,
  }) : super(key: key);

  @override
  _AttendanceViewPageState createState() => _AttendanceViewPageState();
}

class _AttendanceViewPageState extends State<AttendanceViewPage> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  List<Map<String, dynamic>> _students = [];
  int _subjectTotalHours = 0;
  int _filteredHours = 0;
  int _totalStudents = 0;
  int _totalDays = 0;
  bool _isLoading = true;
  String _errorMessage = '';
  bool _showDetailedView = false;
  bool _isEditing = false;
  final Map<int, bool> _expandedStudents = {};

  @override
  void initState() {
    super.initState();
    _fetchAttendanceData();
  }

  Future<void> _fetchAttendanceData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _expandedStudents.clear();
    });

    try {
      final response = await http.post(
        Uri.parse(
          'http://10.0.2.2/localconnect/faculty/fetch_attendance_records.php',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'subject_id': widget.subjectId,
          'faculty_id': widget.facultyId,
          'semester_id': widget.semesterId,
          'start_date': DateFormat('yyyy-MM-dd').format(_startDate),
          'end_date': DateFormat('yyyy-MM-dd').format(_endDate),
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data['success'] == true) {
          setState(() {
            _students =
                (data['students'] as List).map((student) {
                  _expandedStudents[student['id']] = false;

                  // Create the student map with direct references
                  final studentMap = {
                    'id': student['id'],
                    'number': student['number'],
                    'name': student['name'],
                    'attendance': <Map<String, dynamic>>[], // Initialize empty
                    'total_hours': student['total_hours'],
                    'present_hours': student['present_hours'],
                    'absent_hours': student['absent_hours'],
                    'attendance_dates': student['attendance_dates'] ?? [],
                  };

                  // Add attendance records while maintaining references
                  studentMap['attendance'] =
                      (student['attendance'] as List).map((att) {
                        return {
                          'date': DateTime.parse(att['date']),
                          'hours': att['hours'],
                          'status': att['status'],
                        };
                      }).toList();

                  return studentMap;
                }).toList();

            _subjectTotalHours = data['subject_total_hours'] ?? 0;
            _filteredHours = data['filtered_hours'] ?? 0;
            _totalStudents = data['total_students'] ?? 0;
            _totalDays = data['total_days'] ?? 0;
            _isLoading = false;
          });
        } else {
          throw Exception(data['error'] ?? 'Unknown error from server');
        }
      } else {
        throw Exception('Server returned status code ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $_errorMessage')));
    }
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing; // Simply toggle the state
      if (!_isEditing) {
        // If we're exiting edit mode, refresh data
        _fetchAttendanceData();
      }
    });
  }

  void _updateStudentTotals(Map<String, dynamic> student) {
    setState(() {
      student['total_hours'] =
          (student['attendance'] as List<Map<String, dynamic>>).fold<int>(
            0,
            (int sum, Map<String, dynamic> r) => sum + (r['hours'] as int),
          );

      student['present_hours'] = (student['attendance']
              as List<Map<String, dynamic>>)
          .where((r) => r['status'] == 'present')
          .fold<int>(
            0,
            (int sum, Map<String, dynamic> r) => sum + (r['hours'] as int),
          );
    });
  }

  Future<void> _selectDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );

    if (range != null) {
      setState(() {
        _startDate = range.start;
        _endDate = range.end;
      });
      _fetchAttendanceData();
    }
  }

  Future<void> _saveChanges() async {
    try {
      setState(() => _isLoading = true);

      final attendanceData = {
        'faculty_id': widget.facultyId,
        'semester_id': widget.semesterId,
        'subject_id': widget.subjectId,
        'records':
            _students
                .map(
                  (student) => {
                    'id': student['id'],
                    'attendance':
                        student['attendance']
                            .map(
                              (record) => {
                                'date': DateFormat(
                                  'yyyy-MM-dd',
                                ).format(record['date']),
                                'hours': record['hours'],
                                'status': record['status'],
                              },
                            )
                            .toList(),
                  },
                )
                .toList(),
      };

      final response = await http
          .post(
            Uri.parse(
              'http://10.0.2.2/localconnect/faculty/update_attendance.php',
            ),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(attendanceData),
          )
          .timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Attendance updated successfully!')),
        );
        setState(() => _isEditing = false); // Exit edit mode on success
        await _fetchAttendanceData(); // Refresh data
      } else {
        throw Exception(data['error'] ?? 'Update failed');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildAttendanceRow(
    Map<String, dynamic> record,
    Map<String, dynamic> student,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(
        vertical: 2,
        horizontal: 8,
      ), // Tighter spacing
      elevation: 0, // Flat design
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Date Column - Clean simple display
            SizedBox(
              width: 80,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('dd').format(record['date']),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // Always black
                    ),
                  ),
                  Text(
                    DateFormat('MMM yyyy').format(record['date']),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black, // Always black
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Hours Display
            Container(
              width: 50,
              alignment: Alignment.center,
              child: Text(
                '${record['hours']}h',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const Spacer(),

            // Status Display
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              decoration: BoxDecoration(
                color:
                    record['status'] == 'present'
                        ? Colors.green[50]
                        : Colors.red[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                record['status'] == 'present' ? 'PRESENT' : 'ABSENT',
                style: TextStyle(
                  color:
                      record['status'] == 'present'
                          ? Colors.green[800]
                          : Colors.red[800],
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // For Edit Mode - Similar but with editable fields
  Widget _buildEditableAttendanceRow(
    Map<String, dynamic> record,
    Map<String, dynamic> student,
  ) {
    return StatefulBuilder(
      builder: (context, setStateLocal) {
        // Track the current status locally for immediate visual feedback
        bool isPresent = record['status'] == 'present';

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Date Column (unchanged)
                SizedBox(
                  width: 80,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('dd').format(record['date']),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        DateFormat('MMM yyyy').format(record['date']),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Hours Input (unchanged)
                SizedBox(
                  width: 60,
                  child: TextFormField(
                    controller: TextEditingController(
                      text: record['hours'].toString(),
                    ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 15),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      border: const OutlineInputBorder(),
                      hintText: 'Hrs',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        record['hours'] = int.tryParse(value) ?? 1;
                        _updateStudentTotals(student);
                      });
                    },
                  ),
                ),

                const Spacer(),

                // Enhanced Status Toggle with immediate feedback
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setStateLocal(() {
                      isPresent = !isPresent;
                      record['status'] = isPresent ? 'present' : 'absent';
                    });
                    // Update the parent state for totals calculation
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        setState(() {
                          _updateStudentTotals(student);
                        });
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isPresent ? Colors.green[50] : Colors.red[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isPresent ? Colors.green : Colors.red,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPresent ? Icons.check_circle : Icons.cancel,
                          color:
                              isPresent ? Colors.green[800] : Colors.red[800],
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isPresent ? 'PRESENT' : 'ABSENT',
                          style: TextStyle(
                            color:
                                isPresent ? Colors.green[800] : Colors.red[800],
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMasterView() {
    return ListView.builder(
      itemCount: _students.length,
      itemBuilder: (context, index) {
        final student = _students[index];
        final attendanceRate =
            student['total_hours'] > 0
                ? (student['present_hours'] / student['total_hours'] * 100)
                    .toStringAsFixed(1)
                : '0.0';

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: InkWell(
            onTap: () {
              setState(() {
                _expandedStudents[student['id']] =
                    !(_expandedStudents[student['id']] ?? false);
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Student header row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${student['number']}. ${student['name']}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${student['total_hours']}h ($attendanceRate%)',
                        style: TextStyle(
                          color:
                              double.parse(attendanceRate) >= 75
                                  ? Colors.green
                                  : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value:
                        student['total_hours'] > 0
                            ? student['present_hours'] / student['total_hours']
                            : 0,
                    backgroundColor: Colors.grey[200],
                    color: Colors.blue,
                  ),

                  // Expanded attendance records
                  if (_expandedStudents[student['id']] ?? false) ...[
                    const SizedBox(height: 8),
                    ...student['attendance'].map(
                      (record) =>
                          _isEditing
                              ? _buildEditableAttendanceRow(record, student)
                              : _buildAttendanceRow(record, student),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTableView() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text("No")),
          DataColumn(label: Text("Name")),
          DataColumn(label: Text("Total Hours"), numeric: true),
          DataColumn(label: Text("Present"), numeric: true),
          DataColumn(label: Text("Absent"), numeric: true),
          DataColumn(label: Text("Attendance %"), numeric: true),
        ],
        rows:
            _students.map((student) {
              final attendanceRate =
                  student['total_hours'] > 0
                      ? (student['present_hours'] /
                              student['total_hours'] *
                              100)
                          .toStringAsFixed(1)
                      : '0.0';

              return DataRow(
                cells: [
                  DataCell(Text(student['number'].toString())),
                  DataCell(Text(student['name'])),
                  DataCell(Text(student['total_hours'].toString())),
                  DataCell(Text(student['present_hours'].toString())),
                  DataCell(Text(student['absent_hours'].toString())),
                  DataCell(Text('$attendanceRate%')),
                ],
              );
            }).toList(),
      ),
    );
  }

  Future<void> _exportToPDF() async {
    try {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Generating PDF report...')),
      );

      await PdfExportService.exportAttendancePDF(
        subjectName: widget.subjectName,
        semester: widget.semesterId,
        totalHours: _subjectTotalHours,
        students: _students,
        startDate: _startDate,
        endDate: _endDate,
      );

      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('PDF generated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to generate PDF: $e')));
    }
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(child: Text('Error: $_errorMessage'));
    }

    if (_students.isEmpty) {
      return const Center(child: Text('No attendance records found'));
    }

    return _showDetailedView ? _buildMasterView() : _buildTableView();
  }

  void _confirmDelete(
    BuildContext context,
    Map<String, dynamic> student,
    Map<String, dynamic> record,
  ) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Confirm Delete'),
            content: Text(
              'Delete attendance record for ${DateFormat('MMM dd').format(record['date'])}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
            ],
          ),
    );
  }

  Widget _buildEditBottomBar() {
    return BottomAppBar(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton(
              onPressed: _toggleEditing, // Use the toggle method directly
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24),
              ),
              child: const Text('SAVE CHANGES'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isEditing ? Colors.grey[50] : null,
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.subjectName,
              style: const TextStyle(color: Colors.white),
            ),
            Text(
              "Total Hours: $_subjectTotalHours",
              style: const TextStyle(fontSize: 14, color: Colors.white),
            ),
          ],
        ),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _fetchAttendanceData,
            ),
          IconButton(
            icon: Icon(_showDetailedView ? Icons.list : Icons.grid_view),
            onPressed:
                () => setState(() => _showDetailedView = !_showDetailedView),
          ),
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: _selectDateRange,
            ),
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: _toggleEditing, // Use the same toggle method
          ),
        ],
      ),
      drawer: FacultyDrawer(facultyName: widget.facultyName),
      body: _buildContent(),
      bottomNavigationBar: _isEditing ? _buildEditBottomBar() : null,
      floatingActionButton:
          !_isEditing
              ? FloatingActionButton(
                heroTag: 'pdf_export',
                backgroundColor: Colors.redAccent,
                onPressed: _exportToPDF,
                child: const Icon(Icons.picture_as_pdf, color: Colors.white),
              )
              : null,
    );
  }
}

class StatusChip extends StatelessWidget {
  final String status;

  const StatusChip(this.status, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(status.toUpperCase()),
      backgroundColor:
          status == 'present' ? Colors.green[100] : Colors.red[100],
      labelStyle: TextStyle(
        color: status == 'present' ? Colors.green[800] : Colors.red[800],
        fontSize: 12,
      ),
    );
  }
}
