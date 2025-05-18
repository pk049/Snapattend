import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:eduvision/Attendance_view.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:eduvision/utils/device_utils.dart';

class CapturePage extends StatefulWidget {
  final String? department;

  // Update constructor to accept department parameter
  const CapturePage({Key? key, this.department}) : super(key: key);

  @override
  _CapturePageState createState() => _CapturePageState();
}

class _CapturePageState extends State<CapturePage> {
  String? selectedDivision = 'NA';
  String? selectedClass;
  String? selectedSubject;
  final ImagePicker _picker = ImagePicker();

  final List<String> divisions = ['NA', 'A', 'B'];
  final List<String> classes = ['FY', 'SY', 'TY', 'Final_Yr'];
  List<String> subjects = []; // Will be populated from API
  bool isLoadingSubjects = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Capture',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      backgroundColor: Colors.grey[100],
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[50]!, Colors.white],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with Department
              Container(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    Text(
                      "Select Details",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (widget.department != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "${widget.department}",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.blue[700],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 40),

              // Division Dropdown
              _buildDropdown(
                label: "Division",
                hint: "Select Division",
                value: selectedDivision,
                items: divisions,
                onChanged: (value) {
                  setState(() {
                    selectedDivision = value;
                  });
                },
                icon: Icons.group,
              ),
              SizedBox(height: 24),

              // Class Dropdown
              _buildDropdown(
                label: "Class",
                hint: "Select Class",
                value: selectedClass,
                items: classes,
                onChanged: (value) {
                  setState(() {
                    selectedClass = value;
                    selectedSubject = null; // Reset subject when class changes

                    // Fetch subjects based on class and department
                    if (value != null && widget.department != null) {
                      _fetchSubjects(value);
                    }
                  });
                },
                icon: Icons.school,
              ),
              SizedBox(height: 24),

              // Subject Dropdown
              _buildDropdown(
                label: "Subject",
                hint: isLoadingSubjects ? "Loading subjects..." : "Select Subject",
                value: selectedSubject,
                items: subjects,
                onChanged: (value) {
                  setState(() {
                    selectedSubject = value;
                  });
                },
                icon: Icons.book,
                isLoading: isLoadingSubjects,
              ),

              Spacer(),

              // Capture Button
              Container(
                height: 60,
                margin: EdgeInsets.only(bottom: 20),
                child: ElevatedButton(
                  onPressed: _canCapturePhoto() ? _captureAndNavigate : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _canCapturePhoto() ? Colors.blue : Colors.grey,
                    elevation: 8,
                    shadowColor: Colors.blue.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt,
                        size: 28,
                      ),
                      SizedBox(width: 12),
                      Text(
                        "CAPTURE",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _canCapturePhoto() {
    return selectedClass != null && selectedSubject != null;
  }

  Future<void> _fetchSubjects(String classValue) async {
    if (widget.department == null) return;

    setState(() {
      isLoadingSubjects = true;
      subjects = []; // Clear existing subjects
    });

    try {
      // Construct the class_department string as requested
      String classDepartment = "${classValue}_${widget.department}";

      final baseUrl = await DeviceUtils.getBaseUrl();

      // Make POST request to the API
      final response = await http.post(

        Uri.parse('$baseUrl/get_subjects'),

        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'class': classDepartment,
        }),
      );

      if (response.statusCode == 200) {
        // Parse the response
        final Map<String, dynamic> data = jsonDecode(response.body);

        // Update subjects list if data contains subjects
        if (data.containsKey('subjects') && data['subjects'] is List) {
          setState(() {
            subjects = List<String>.from(data['subjects']);
          });
        } else {
          // Handle case when API returns unexpected format
          _showErrorDialog("API returned an unexpected format");
        }
      } else {
        // Handle error response
        _showErrorDialog("Failed to fetch subjects. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching subjects: $e");
      _showErrorDialog("Network error: $e");
    } finally {
      setState(() {
        isLoadingSubjects = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _captureAndNavigate() async {
    try {
      // Open camera
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);

      if (photo != null) {
        // Get current time
        final now = DateTime.now();
        final currentTime = "${now.hour}:${now.minute.toString().padLeft(2, '0')}";

        // Navigate to attendance view with captured image
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AttendanceView(
              division: selectedDivision ?? 'None',
              classroom: selectedClass ?? 'None',
              subject: selectedSubject ?? 'None',
              time: currentTime,
              imagePath: photo.path,
              department: widget.department ?? 'None', // Pass department to AttendanceView
            ),
          ),
        );
      }
    } catch (e) {
      print("Error capturing image: $e");
      // Show error dialog
      _showErrorDialog("There was an error accessing the camera. Please check your camera permissions.");
    }
  }

  Widget _buildDropdown({
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    required IconData icon,
    bool isLoading = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.blue[800],
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              DropdownButtonFormField<String>(
                value: value,
                isExpanded: true,
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    icon,
                    color: Colors.blue,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                hint: Text(hint),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
                icon: isLoading
                    ? SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                )
                    : Icon(
                  Icons.arrow_drop_down_circle,
                  color: Colors.blue,
                ),
                items: items.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: isLoading ? null : onChanged,
                dropdownColor: Colors.white,
              ),
            ],
          ),
        ),
      ],
    );
  }
}