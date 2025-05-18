import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:eduvision/utils/device_utils.dart';

class SubjectBasedReportPage extends StatefulWidget {
  final String department;

  const SubjectBasedReportPage({Key? key, required this.department}) : super(key: key);

  @override
  State<SubjectBasedReportPage> createState() => _SubjectBasedReportPageState();
}

class _SubjectBasedReportPageState extends State<SubjectBasedReportPage> {
  String selectedClass = 'FY';
  String selectedDivision = 'NA';
  String? selectedSubject;
  bool isLoading = false;
  bool hasError = false;
  String errorMessage = '';
  List<String> subjectOptions = [];
  List<StudentAttendanceData> attendanceData = [];

  final List<String> classOptions = ['FY', 'SY', 'TY', 'Final_Yr'];
  final List<String> divisionOptions = ['A', 'B', 'NA'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        title: const Text(
          "Subject Attendance Report",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Blue header with design elements
              Container(
                padding: const EdgeInsets.only(top: 10, bottom: 30),
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      offset: const Offset(0, 10),
                      blurRadius: 15,
                      spreadRadius: -5,
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 15),
                      // Report icon with glow effect
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.2),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.assignment_ind,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Student Attendance Report",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.0,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              offset: Offset(1, 1),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Display department info
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          widget.department,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Filters Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Select Parameters",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Class Dropdown
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Class Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: const Icon(Icons.class_),
                          ),
                          value: selectedClass,
                          items: classOptions.map((String classOption) {
                            return DropdownMenuItem<String>(
                              value: classOption,
                              child: Text(classOption),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                selectedClass = newValue;
                                selectedSubject = null; // Reset subject when class changes
                                subjectOptions = []; // Clear subjects
                              });
                              _fetchSubjects(); // Fetch subjects for new class
                            }
                          },
                        ),

                        const SizedBox(height: 15),

                        // Division Dropdown
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Division',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: const Icon(Icons.safety_divider),
                          ),
                          value: selectedDivision,
                          items: divisionOptions.map((String divOption) {
                            return DropdownMenuItem<String>(
                              value: divOption,
                              child: Text(divOption),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                selectedDivision = newValue;
                                selectedSubject = null; // Reset subject when division changes
                              });
                              _fetchSubjects(); // Fetch subjects for new division
                            }
                          },
                        ),

                        const SizedBox(height: 15),

                        // Subject Dropdown
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Subject',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: const Icon(Icons.subject),
                            contentPadding: const EdgeInsets.symmetric(horizontal: -15, vertical: -15), // 👈 Customize this

                          ),
                          value: selectedSubject,
                          items: subjectOptions.map((String subject) {
                            return DropdownMenuItem<String>(
                              value: subject,
                              child: Text(subject),
                            );
                          }).toList(),
                          onChanged: subjectOptions.isEmpty
                              ? null
                              : (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                selectedSubject = newValue;
                              });
                            }
                          },
                          hint: const Text('Select'),
                        ),

                        const SizedBox(height: 25),

                        // Fetch Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.download),
                            label: const Text(
                              "Generate Report",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: (isLoading || selectedSubject == null)
                                ? null
                                : _fetchAttendanceData,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Loading indicator
              if (isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                ),

              // Error message
              if (hasError)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 60,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          errorMessage,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

              // Student Attendance Table
              if (attendanceData.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Student Attendance",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.blueAccent.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "$selectedClass - $selectedDivision",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "Subject: $selectedSubject",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildAttendanceTable(),
                          const SizedBox(height: 20),
                          _buildLegend(),
                        ],
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttendanceTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(Colors.blueAccent.withOpacity(0.1)),
        dataRowMinHeight: 48,
        dataRowMaxHeight: 64,
        columnSpacing: 24,
        horizontalMargin: 12,
        columns: const [
          DataColumn(
            label: Text(
              'PRN',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Name',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Present/Total',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Attendance %',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
        rows: attendanceData.map((data) {
          return DataRow(
            cells: [
              DataCell(Text(data.prn)),
              DataCell(Text(data.name)),
              DataCell(Text('${data.presentCount}/${data.totalLectures}')),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(data.percentage).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${data.percentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(data.percentage),
                    ),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _buildLegendItem("Excellent (≥ 90%)", Colors.green),
        _buildLegendItem("Good (70% - 89%)", Colors.blue),
        _buildLegendItem("Average (50% - 69%)", Colors.orange),
        _buildLegendItem("Poor (< 50%)", Colors.red),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Color _getStatusColor(double percentage) {
    if (percentage >= 90) {
      return Colors.green;
    } else if (percentage >= 70) {
      return Colors.blue;
    } else if (percentage >= 50) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  Future<void> _fetchSubjects() async {
    setState(() {
      isLoading = true;
      hasError = false;
      errorMessage = '';
      subjectOptions = [];
    });

    try {
      // Combine class and department as required
      String classWithDepartment = '${selectedClass}_${widget.department}';

      final baseUrl = await DeviceUtils.getBaseUrl();

      // Make the POST request to get subjects
      final response = await http.post(
        Uri.parse('$baseUrl/get_subjects'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'class': classWithDepartment,
        }),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['status'] == 'success') {
          setState(() {
            subjectOptions = List<String>.from(jsonData['subjects'] ?? []);
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
            hasError = true;
            errorMessage = jsonData['message'] ?? 'Failed to load subjects';
          });
        }
      } else {
        setState(() {
          isLoading = false;
          hasError = true;
          errorMessage = 'Failed to load subjects: HTTP ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = 'Error: ${e.toString()}';
      });
    }
  }

  Future<void> _fetchAttendanceData() async {
    if (selectedSubject == null) return;

    setState(() {
      isLoading = true;
      hasError = false;
      errorMessage = '';
      attendanceData = [];
    });

    try {
      final baseUrl = await DeviceUtils.getBaseUrl();

      // Make the POST request for subject-based report
      final response = await http.post(
        Uri.parse('$baseUrl/subject-based-report'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'class': selectedClass,
          'division': selectedDivision,
          'subject': selectedSubject,
          'department': widget.department,
        }),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['status'] == 'success') {
          final List<dynamic> reportData = jsonData['report'] ?? [];
          setState(() {
            attendanceData = reportData
                .map((item) => StudentAttendanceData.fromJson(item))
                .toList();
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
            hasError = true;
            errorMessage = jsonData['message'] ?? 'Failed to load attendance data';
          });
        }
      } else {
        setState(() {
          isLoading = false;
          hasError = true;
          errorMessage = 'Failed to load data: HTTP ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = 'Error: ${e.toString()}';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Fetch subjects when the page initializes
    _fetchSubjects();
  }
}

class StudentAttendanceData {
  final String prn;
  final String name;
  final int presentCount;
  final int totalLectures;
  final double percentage;

  StudentAttendanceData({
    required this.prn,
    required this.name,
    required this.presentCount,
    required this.totalLectures,
    required this.percentage,
  });

  factory StudentAttendanceData.fromJson(Map<String, dynamic> json) {
    return StudentAttendanceData(
      prn: json['PRN'] ?? '',
      name: json['name'] ?? '',
      presentCount: json['present_count'] ?? 0,
      totalLectures: json['total_lectures'] ?? 0,
      percentage: (json['percentage'] ?? 0).toDouble(),
    );
  }
}