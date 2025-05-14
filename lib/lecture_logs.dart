import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:eduvision/utils/device_utils.dart';

class LectureLogs extends StatefulWidget {
  final String subject;
  final String className;
  final String division;
  final String department;
  final int lectureNumber;
  final String date;
  final String facultyName;

  const LectureLogs({
    Key? key,
    required this.subject,
    required this.className,
    required this.division,
    required this.department,
    required this.lectureNumber,
    required this.date,
    required this.facultyName,
  }) : super(key: key);

  @override
  State<LectureLogs> createState() => _LectureLogsState();
}

class _LectureLogsState extends State<LectureLogs> {
  bool _isLoading = true;
  List<dynamic> _attendanceLogs = [];
  int _presentCount = 0;
  int _absentCount = 0;

  @override
  void initState() {
    super.initState();
    fetchLectureLogs();
  }

  // Format date for display
  String get formattedDate {
    try {
      final date = DateTime.parse(widget.date);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return widget.date;
    }
  }

  // Fetch logs from API
  Future<void> fetchLectureLogs() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Prepare request data
      final Map<String, dynamic> requestData = {
        'faculty_name': widget.facultyName,
        'date': widget.date,
        'subject': widget.subject,
        'class_name': widget.className,
        'division': widget.division,
        'department': widget.department,
        'lecture_number': widget.lectureNumber,
      };

      final baseUrl = await DeviceUtils.getBaseUrl();
      // Make the POST request
      final response = await http.post(

        Uri.parse('$baseUrl/get_lecture_logs'),

        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      ).timeout(const Duration(seconds: 60));

      // Parse the response
      final responseData = jsonDecode(response.body);

      // Print response to console
      print('Lecture Logs Response: $responseData');

      // Check if fetch was successful
      if (responseData['status'] == 'success') {
        setState(() {
          _attendanceLogs = responseData['logs'] ?? [];

          // Calculate present and absent counts
          _presentCount = _attendanceLogs.where((log) =>
          log['status']?.toString().toLowerCase() == 'present').length;
          _absentCount = _attendanceLogs.length - _presentCount;
        });
      } else {
        // Show error toast
        Fluttertoast.showToast(
          msg: responseData['message'] ?? "Failed to fetch lecture logs",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (error) {
      // Handle connection errors
      print('Error: $error');
      Fluttertoast.showToast(
        msg: "Connection error. Please try again.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lecture Attendance'),
        backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Lecture Info Section
          _buildLectureInfoSection(),

          // Attendance Stats Section
          _buildAttendanceStatsSection(),

          // Student List Section
          Expanded(
            child: _attendanceLogs.isEmpty
                ? const Center(
              child: Text(
                'No attendance records found',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            )
                : _buildStudentList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLectureInfoSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            widget.subject,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Lecture ${widget.lectureNumber} • ${formattedDate}',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '${widget.className} ${widget.division != "NA" ? "• ${widget.division}" : ""} • ${widget.department}',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceStatsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Present',
              _presentCount.toString(),
              Colors.green,
              Icons.check_circle,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              'Absent',
              _absentCount.toString(),
              Colors.red,
              Icons.cancel,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String count, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            count,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentList() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _attendanceLogs.length,
      itemBuilder: (context, index) {
        final log = _attendanceLogs[index];
        final isPresent = log['status']?.toString().toLowerCase() == 'present';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isPresent ? Colors.green.withOpacity(0.5) : Colors.red.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Serial Number
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Student Photo
                _buildStudentPhoto(log),
                const SizedBox(width: 16),

                // Student Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        log['student_name'] ,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'PRN: ${log['PRN'] }',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                // Status
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isPresent
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isPresent
                          ? Colors.green.withOpacity(0.5)
                          : Colors.red.withOpacity(0.5),
                    ),
                  ),
                  child: Text(
                    isPresent ? 'Present' : 'Absent',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isPresent ? Colors.green : Colors.red,
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

  Widget _buildStudentPhoto(Map<String, dynamic> log) {
    // Try to get student details and image URL
    final studentDetails = log['student_details'];
    String? imageUrl;

    if (studentDetails != null && studentDetails is Map<String, dynamic>) {
      imageUrl = studentDetails['image_link']; // Changed from image_base64 to image_url
    }

    if (imageUrl != null && imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Image.network(
          imageUrl,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                      : null,
                  strokeWidth: 2,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            print('Error loading image: $error');
            return _buildDefaultAvatar();
          },
        ),
      );
    } else {
      return _buildDefaultAvatar();
    }
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Icon(
        Icons.person,
        color: Colors.grey.shade500,
        size: 30,
      ),
    );
  }
}