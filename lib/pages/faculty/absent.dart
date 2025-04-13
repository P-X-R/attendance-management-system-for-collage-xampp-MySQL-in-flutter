import 'package:attendance_app/pages/faculty/Widgets/drawer.dart';
import 'package:flutter/material.dart';

class AbsenteesPage extends StatefulWidget {
  final String subjectName;
  final List<Map<String, dynamic>> absentStudents;

  const AbsenteesPage({
    super.key,
    required this.subjectName,
    required this.absentStudents,
  });

  @override
  _AbsenteesPageState createState() => _AbsenteesPageState();
}

class _AbsenteesPageState extends State<AbsenteesPage> {
  late List<Map<String, dynamic>> absentees;

  @override
  void initState() {
    super.initState();
    // Create a local copy of the absent students for toggling checkboxes
    absentees =
        widget.absentStudents.map((student) {
          return {
            "rollNumber": student["rollNumber"],
            "name": student["name"],
            "stillAbsent": true, // Initially marked absent
          };
        }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDFFFD7), // Light green background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [],
      ),
      drawer: FacultyDrawer(facultyName: "Lini Miss."),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate sizes based on screen width for responsiveness
          double screenWidth = constraints.maxWidth;
          double titleFontSize = screenWidth * 0.06; // 6% of screen width
          double infoFontSize = screenWidth * 0.045; // 4.5% of screen width
          double cardTextSize = screenWidth * 0.045; // 4.5% of screen width
          double iconSize = screenWidth * 0.07; // 7% of screen width
          double spacing = screenWidth * 0.02; // 2% of screen width

          return Padding(
            padding: EdgeInsets.all(spacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  "ABSENT",
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: spacing),
                // Display subject name and number of absentees in a single row
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        "Subject: ${widget.subjectName}",
                        style: TextStyle(
                          fontSize: infoFontSize,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    SizedBox(width: spacing),
                    Expanded(
                      flex: 1,
                      child: Text(
                        "Absentees: ${absentees.length}",
                        style: TextStyle(
                          fontSize: infoFontSize,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.right,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: spacing),
                // List of Absentees
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListView.builder(
                      itemCount: absentees.length,
                      itemBuilder: (context, index) {
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            leading: Text(
                              "${absentees[index]["rollNumber"]}",
                              style: TextStyle(fontSize: cardTextSize),
                            ),
                            title: Text(
                              absentees[index]["name"],
                              style: TextStyle(fontSize: cardTextSize),
                            ),
                            trailing: Checkbox(
                              value: absentees[index]["stillAbsent"],
                              onChanged: (bool? value) {
                                setState(() {
                                  absentees[index]["stillAbsent"] =
                                      value ?? true;
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: spacing),
                // Bottom Buttons (Back and Save)
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: FloatingActionButton(
                      backgroundColor: Colors.white,
                      onPressed: () {
                        Navigator.pushNamed(context, '/successful');
                      },
                      child: Icon(Icons.save, color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
