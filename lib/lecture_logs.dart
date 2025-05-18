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
  bool _isEditMode = false;
  bool _isSaving = false;
  List<dynamic> _attendanceLogs = [];
  List<Map<String, dynamic>> _editedLogs = [];
  int _presentCount = 0;
  int _absentCount = 0;
  int _notConsideredCount = 0;

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

          // Create a deep copy of the logs for editing
          _editedLogs = List<Map<String, dynamic>>.from(
              _attendanceLogs.map((log) => Map<String, dynamic>.from(log))
          );

          // Calculate counts
          _updateAttendanceCounts();
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

  // Update attendance counts
  void _updateAttendanceCounts() {
    _presentCount = _editedLogs.where((log) =>
    log['status']?.toString().toLowerCase() == 'present').length;
    _absentCount = _editedLogs.where((log) =>
    log['status']?.toString().toLowerCase() == 'absent').length;
    _notConsideredCount = _editedLogs.where((log) =>
    log['status']?.toString().toLowerCase() == 'not considered').length;
  }

  // Save attendance changes to the server
  Future<void> _saveAttendanceChanges() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final baseUrl = await DeviceUtils.getBaseUrl();

      // Prepare request data
      final Map<String, dynamic> requestData = {
        'faculty_name': widget.facultyName,
        'date': widget.date,
        'subject': widget.subject,
        'class_name': widget.className,
        'division': widget.division,
        'department': widget.department,
        'lecture_number': widget.lectureNumber,
        'updated_logs': _editedLogs,
      };

      // Make the POST request
      final response = await http.post(
        Uri.parse('$baseUrl/update_lecture_logs'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      ).timeout(const Duration(seconds: 60));

      // Parse the response
      final responseData = jsonDecode(response.body);

      // Check if update was successful
      if (responseData['status'] == 'success') {
        setState(() {
          // Update the main logs with the edited version
          _attendanceLogs = List.from(_editedLogs);
          _isEditMode = false;
        });

        Fluttertoast.showToast(
          msg: "Attendance updated successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else {
        Fluttertoast.showToast(
          msg: responseData['message'] ?? "Failed to update attendance",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (error) {
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
        _isSaving = false;
      });
    }
  }

  // Update a student's attendance status
  void _updateAttendanceStatus(int index, String newStatus, {String? reason}) {
    setState(() {
      _editedLogs[index]['status'] = newStatus;

      // Handle reason field
      if (newStatus == 'not considered' && reason != null) {
        _editedLogs[index]['reason'] = reason;
      } else if (newStatus != 'not considered') {
        // Remove reason field if not "Not Considered"
        _editedLogs[index].remove('reason');
      }

      _updateAttendanceCounts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lecture Attendance'),
        backgroundColor: Colors.blue,
        actions: [
          // Edit button
          if (!_isLoading)
            IconButton(
              icon: Icon(_isEditMode ? Icons.check : Icons.edit),
              onPressed: () {
                if (_isEditMode) {
                  _saveAttendanceChanges();
                } else {
                  setState(() {
                    _isEditMode = true;
                  });
                }
              },
            ),
          // Cancel button in edit mode
          if (_isEditMode)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  // Restore original data
                  _editedLogs = List<Map<String, dynamic>>.from(
                      _attendanceLogs.map((log) => Map<String, dynamic>.from(log))
                  );
                  _updateAttendanceCounts();
                  _isEditMode = false;
                });
              },
            ),
        ],
      ),
      body: _isLoading || _isSaving
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              _isSaving ? 'Saving changes...' : 'Loading attendance...',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      )
          : Column(
        children: [
          // Lecture Info Section
          _buildLectureInfoSection(),

          // Edit mode indicator
          if (_isEditMode)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: Colors.amber.shade100,
              child: const Text(
                'Edit Mode: Tap on a student to change their status',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
            ),

          // Attendance Stats Section
          _buildAttendanceStatsSection(),

          // Student List Section
          Expanded(
            child: _editedLogs.isEmpty
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
      padding: const EdgeInsets.all(12),
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
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              'Absent',
              _absentCount.toString(),
              Colors.red,
              Icons.cancel,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              'NC',
              _notConsideredCount.toString(),
              Colors.grey,
              Icons.remove_circle_outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String count, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
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
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            count,
            style: TextStyle(
              fontSize: 20,
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
      itemCount: _editedLogs.length,
      itemBuilder: (context, index) {
        final log = _editedLogs[index];
        final status = log['status']?.toString().toLowerCase() ?? 'absent';
        final reason = log['reason'] as String?;

        Color statusColor;
        IconData statusIcon;

        switch (status) {
          case 'present':
            statusColor = Colors.green;
            statusIcon = Icons.check_circle;
            break;
          case 'not considered':
            statusColor = Colors.grey;
            statusIcon = Icons.remove_circle_outline;
            break;
          default: // 'absent' or any other
            statusColor = Colors.red;
            statusIcon = Icons.cancel;
        }

        return GestureDetector(
          onTap: _isEditMode ? () => _showStatusChangeDialog(index) : null,
          child: Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: statusColor.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
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
                              log['student_name'] ?? 'Unknown Student',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'PRN: ${log['PRN'] ?? 'N/A'}',
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
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: statusColor.withOpacity(0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(statusIcon, size: 16, color: statusColor),
                            const SizedBox(width: 4),
                            Text(
                              _capitalizeFirstLetter(status),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Edit indicator
                      if (_isEditMode)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Icon(
                            Icons.edit,
                            size: 16,
                            color: Colors.blue.withOpacity(0.5),
                          ),
                        ),
                    ],
                  ),
                ),

                // Reason section (if applicable)
                if (reason != null && reason.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Reason:',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          reason,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[800],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  // Show dialog to change student status
  void _showStatusChangeDialog(int index) {
    final log = _editedLogs[index];
    final currentStatus = log['status']?.toString().toLowerCase() ?? 'absent';

    // Create temporary controller for reason field
    final TextEditingController reasonController = TextEditingController();
    // Initialize with existing reason if any
    reasonController.text = log['reason'] ?? '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          bool showReasonField = currentStatus == 'not considered' || reasonController.text.isNotEmpty;

          return AlertDialog(
            title: Text('Change Status for ${log['student_name'] ?? 'Student'}'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildStatusOption(
                      context,
                      index,
                      'Present',
                      currentStatus,
                      Colors.green,
                      Icons.check_circle,
                      onTap: () {
                        Navigator.pop(context);
                        _updateAttendanceStatus(index, 'present', reason: null);
                      }
                  ),
                  const SizedBox(height: 8),
                  _buildStatusOption(
                      context,
                      index,
                      'Absent',
                      currentStatus,
                      Colors.red,
                      Icons.cancel,
                      onTap: () {
                        Navigator.pop(context);
                        _updateAttendanceStatus(index, 'absent', reason: null);
                      }
                  ),
                  const SizedBox(height: 8),
                  _buildStatusOption(
                      context,
                      index,
                      'Not Considered',
                      currentStatus,
                      Colors.grey,
                      Icons.remove_circle_outline,
                      onTap: () {
                        setState(() {
                          showReasonField = true;
                        });
                      }
                  ),
                  if (showReasonField) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Reason for Not Considered:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: reasonController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter reason',
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              if (showReasonField)
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _updateAttendanceStatus(
                      index,
                      'not considered',
                      reason: reasonController.text.trim(),
                    );
                  },
                  child: const Text('Save'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // Build status option for dialog
  Widget _buildStatusOption(
      BuildContext context,
      int index,
      String status,
      String currentStatus,
      Color color,
      IconData icon,
      {VoidCallback? onTap}
      ) {
    final isSelected = status.toLowerCase() == currentStatus.toLowerCase();

    return Material(
      color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? color : Colors.transparent,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 16),
              Text(
                status,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? color : Colors.black,
                ),
              ),
              const Spacer(),
              if (isSelected)
                Icon(Icons.check, color: color),
            ],
          ),
        ),
      ),
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