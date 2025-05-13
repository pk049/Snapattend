import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:eduvision/lecture_logs.dart';

class LogViewPage extends StatefulWidget {
  final String facultyName;
  final String department;

  const LogViewPage({
    Key? key,
    required this.facultyName,
    required this.department
  }) : super(key: key);

  @override
  State<LogViewPage> createState() => _LogViewPageState();
}

class _LogViewPageState extends State<LogViewPage> {
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  List<dynamic> _logs = [];

  // Modern blue theme colors based on screenshot
  final Color primaryBlue = Color(0xFF4285F4);     // Bright blue
  final Color accentBlue = Color(0xFF5C9CE6);      // Lighter blue accent
  final Color lightBlue = Color(0xFFE8F0FE);       // Very light blue background
  final Color textColor = Color(0xFF333333);       // Dark text for readability
  final Color backgroundColor = Colors.white;      // Clean white background

  @override
  void initState() {
    super.initState();
    // Fetch logs when page loads
    fetchLogs();
  }

  // Format date for display
  String get formattedDate {
    return DateFormat('yyyy-MM-dd').format(_selectedDate);
  }

  // Format date for header display
  String get formattedDateHeader {
    return DateFormat('EEEE, d MMMM yyyy').format(_selectedDate);
  }

  // Open date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: primaryBlue,
            colorScheme: ColorScheme.light(primary: primaryBlue),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      fetchLogs();
    }
  }

  // Fetch logs from API
  Future<void> fetchLogs() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Prepare request data
      final Map<String, String> requestData = {
        'faculty_name': widget.facultyName,
        'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
        'department': widget.department,
      };

      // Make the POST request
      final response = await http.post(

        Uri.parse('http://10.0.2.2:5000/get_logs'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );

      // Parse the response
      final responseData = jsonDecode(response.body);

      // Check if fetch was successful
      if (responseData['status'] == 'success') {
        setState(() {
          _logs = responseData['logs'] ?? [];
        });
      } else {
        // Show error toast
        Fluttertoast.showToast(
          msg: responseData['message'] ?? "Failed to fetch logs",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red[400],
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (error) {
      // Handle connection errors
      Fluttertoast.showToast(
        msg: "Connection error. Please try again.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red[400],
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
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryBlue,
        centerTitle: true,
        title: Text(
          'SNAPATTEND',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _isLoading ? null : fetchLogs,
            tooltip: 'Refresh',
          ),
        ],
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            // Show menu
            Scaffold.of(context).openDrawer();
          },
        ),
      ),
      body: Column(
        children: [
          // Top blue section with branch name, history logo, and "Records" text
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: primaryBlue,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            padding: EdgeInsets.only(left: 24, right: 24, bottom: 30, top: 10),
            child: Column(
              children: [
                // Branch name in circular frame
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.2),
                  ),
                  padding: EdgeInsets.all(16),
                  child: Text(
                    widget.department.substring(0, widget.department.length > 5 ? 5 : widget.department.length),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),

                SizedBox(height: 16),

                // History logo
                Icon(
                  Icons.history,
                  color: Colors.white,
                  size: 40,
                ),

                SizedBox(height: 16),

                // Records text in large font
                Text(
                  'Records',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),

                SizedBox(height: 16),

                // Date picker button
                InkWell(
                  onTap: () => _selectDate(context),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          color: Colors.white,
                          size: 18,
                        ),
                        SizedBox(width: 12),
                        Text(
                          formattedDateHeader,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          // Faculty info card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Card(
              elevation: 2,
              shadowColor: Colors.black12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: lightBlue,
                      child: Icon(
                        Icons.person,
                        size: 30,
                        color: primaryBlue,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.facultyName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            widget.department,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.refresh,
                        color: primaryBlue,
                      ),
                      onPressed: fetchLogs,
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: 20),

          // Lectures count card - Only showing lectures, removed classes
          if (!_isLoading && _logs.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      spreadRadius: 0,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.book_outlined,
                      color: primaryBlue,
                      size: 28,
                    ),
                    SizedBox(height: 8),
                    Text(
                      '${_logs.length}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Lectures',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          SizedBox(height: 16),

          // Main content area
          Expanded(
            child: _isLoading
                ? _buildLoadingView()
                : _logs.isEmpty
                ? _buildEmptyStateView()
                : _buildLogsList(),
          ),
        ],
      ),
      // Floating action button has been removed
    );
  }

  // Loading state view
  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: primaryBlue,
            strokeWidth: 3,
          ),
          SizedBox(height: 16),
          Text(
            'Loading lecture records...',
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // Empty state view
  Widget _buildEmptyStateView() {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: lightBlue,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.event_busy_outlined,
                size: 60,
                color: primaryBlue,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'No Lecture Records',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'There are no lecture records available for ${formattedDateHeader}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _selectDate(context),
              icon: Icon(Icons.calendar_today),
              label: Text('Select Another Date'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Main logs list view
  Widget _buildLogsList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ListView.separated(
        physics: BouncingScrollPhysics(),
        itemCount: _logs.length,
        separatorBuilder: (context, index) => SizedBox(height: 16),
        itemBuilder: (context, index) {
          final log = _logs[index];
          return _buildLogCard(log);
        },
      ),
    );
  }

  // Build individual log card with modern design
  Widget _buildLogCard(Map<String, dynamic> log) {
    final String subject = log['subject'] ?? 'Unknown Subject';
    final int lectureNumber = log['lecture_number'] ?? 0;
    final String className = log['class_name'] ?? 'N/A';
    final String division = log['division'] ?? 'N/A';

    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LectureLogs(
                subject: subject,
                className: className,
                division: division,
                lectureNumber: lectureNumber,
                date: DateFormat('yyyy-MM-dd').format(_selectedDate),
                facultyName: widget.facultyName,
                department: widget.department,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left side - Lecture number in circle
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: primaryBlue,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    lectureNumber.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16),

              // Right side - Subject and class details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.class_outlined,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        SizedBox(width: 6),
                        Text(
                          className,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(width: 16),
                        Icon(
                          Icons.group_outlined,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Division: $division',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow icon on right
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: primaryBlue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}