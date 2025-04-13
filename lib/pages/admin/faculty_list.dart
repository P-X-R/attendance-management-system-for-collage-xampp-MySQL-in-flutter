import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:attendance_app/components/custom_drawer.dart';
// import 'package:attendance/pages/admin/add_faculty.dart'; // Ensure this file exists

//import 'package:attendance/pages/admin/student_list.dart'; // Ensure this file exists
class FacultyPage extends StatefulWidget {
  final String adminName;
  final String department;

  const FacultyPage({super.key, required this.adminName, required this.department});

  @override
  _FacultyPageState createState() => _FacultyPageState();
}

class _FacultyPageState extends State<FacultyPage> {
  List<String> facultyList = [];
  List<String> filteredList = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFacultyList();
  }

  Future<void> fetchFacultyList() async {
    final url = Uri.parse(
      "http://10.0.2.2/localconnect/faculty_list.php?department=${widget.department}",
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data.containsKey('faculty')) {
          setState(() {
            facultyList = List<String>.from(data['faculty']);
            filteredList = facultyList;
            isLoading = false;
          });
        } else {
          throw Exception("Invalid response format");
        }
      } else {
        throw Exception("Failed to load faculty data");
      }
    } catch (e) {
      print("Error fetching data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deleteFaculty(String facultyName) async {
    final url = Uri.parse("http://10.0.2.2/localconnect/delete_faculty.php");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({"name": facultyName}),
      );

      final data = json.decode(response.body);
      if (data['success'] == true) {
        setState(() {
          facultyList.remove(facultyName);
          filteredList = List.from(facultyList);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$facultyName deleted successfully")),
        );
      } else {
        throw Exception(data['error']);
      }
    } catch (e) {
      print("Error deleting faculty: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to delete $facultyName")));
    }
  }

  void filterSearch(String query) {
    setState(() {
      filteredList =
          facultyList
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
              "Total Staffs: ${facultyList.length}",
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
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: searchController,
                      onChanged: filterSearch,
                      decoration: InputDecoration(
                        hintText: "Search Faculty",
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
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
                                      filterSearch(""); // Reset search
                                    });
                                  },
                                )
                                : null,
                      ),
                    ),
                  ),

                  // Faculty List
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
                          String facultyName = filteredList[index];

                          return Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.grey.shade300),
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
                                    facultyName,
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => deleteFaculty(facultyName),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Bottom Action Buttons
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // _buildActionButton(Icons.upload, "Upload", () {
                        //   print("Upload Clicked");
                        // }),
                        _buildActionButton(Icons.download, "Download", () {
                          print("Download Clicked");
                        }),
                        // _buildActionButton(Icons.add, "Add", () {
                        //   Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //       builder:
                        //           (context) =>
                        //               AddFaculty(adminName: widget.adminName),
                        //     ),
                        //   );
                        // }
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String tooltip,
    VoidCallback onPressed,
  ) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.black, size: 28),
      tooltip: tooltip,
    );
  }
}
