import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:eduvision/Attendance_view.dart';

class CapturePage extends StatefulWidget {
  @override
  _CapturePageState createState() => _CapturePageState();
}

class _CapturePageState extends State<CapturePage> {
  String? selectedDivision;
  String? selectedClass;
  String? selectedSubject;
  final ImagePicker _picker = ImagePicker();

  final List<String> divisions = ['A', 'B'];
  final List<String> classes = ['FY', 'SY', 'TY', 'Final_year'];
  final List<String> subjects = ['Subject1', 'Subject2', 'Subject3'];

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
              // Header
              Container(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  "Select Details",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                  textAlign: TextAlign.center,
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
                  });
                },
                icon: Icons.school,
              ),
              SizedBox(height: 24),

              // Subject Dropdown
              _buildDropdown(
                label: "Subject",
                hint: "Select Subject",
                value: selectedSubject,
                items: subjects,
                onChanged: (value) {
                  setState(() {
                    selectedSubject = value;
                  });
                },
                icon: Icons.book,
              ),

              Spacer(),

              // Capture Button
              Container(
                height: 60,
                margin: EdgeInsets.only(bottom: 20),
                child: ElevatedButton(
                  onPressed: () {
                    _captureAndNavigate();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
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
            ),
          ),
        );
      }
    } catch (e) {
      print("Error capturing image: $e");
      // Show error dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Camera Error"),
            content: Text("There was an error accessing the camera. Please check your camera permissions."),
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
  }

  Widget _buildDropdown({
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    required IconData icon,
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
          child: DropdownButtonFormField<String>(
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
            icon: Icon(
              Icons.arrow_drop_down_circle,
              color: Colors.blue,
            ),
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: onChanged,
            dropdownColor: Colors.white,
          ),
        ),
      ],
    );
  }
}