import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:eduvision/Navbar.dart';
import 'package:eduvision/Capturepage.dart';
import 'package:eduvision/splashscreen.dart';

// MAIN FUNCTION
void main() {
  runApp(const MyApp());
}

// STATELESS
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smartvision',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: Splashscreen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void attendance() {
    Navigator.push(context, MaterialPageRoute(builder: (context) =>CapturePage()));
  }

  void report() {}

  void logs() {}

  void schedule() {}

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.blueAccent, // Makes notification bar blue
      statusBarIconBrightness: Brightness.light, // White icons in status bar
    ));

    return Scaffold(
      drawer: Navbar(),
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        title: Column(
          children: [
            const Text(
              "Friday, 11 April 2025",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4), // Small gap
            const Text(
              "Pratik Kumbhar",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.normal,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, size: 45, color: Colors.white70),
            onPressed: () {
              // Profile action
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView( // Prevents overflow
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Good Morning Message at the Top
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                height: 200,
                color: Colors.blueAccent,
                padding: const EdgeInsets.all(20),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Good Morning",
                        style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "12:30 PM",
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // Vertical layout for buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildRectangularTile("Take Attendance", Icons.camera_alt, attendance),
                    const SizedBox(height: 15),
                    _buildRectangularTile("See Reports", Icons.insert_chart, report),
                    const SizedBox(height: 15),
                    _buildRectangularTile("Today's Logs", Icons.history, logs),
                    const SizedBox(height: 15),
                    _buildRectangularTile("Schedule", Icons.calendar_today, schedule),
                  ],
                ),
              ),
              const SizedBox(height: 20), // Added spacing at the bottom
            ],
          ),
        ),
      ),
    );
  }

  // Function to create rectangular buttons
  Widget _buildRectangularTile(String text, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 130,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5), // Inner black shadow
              blurRadius: 8,
              spreadRadius: -3,
              offset: const Offset(3, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Row(
                children: [
                  Icon(icon, size: 28, color: Colors.blueAccent),
                  const SizedBox(width: 15),
                  Text(
                    text,
                    style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 20),
              child: Icon(Icons.arrow_forward_ios, size: 30, color: Colors.blueAccent), // White Right Arrow
            ),
          ],
        ),
      ),
    );
  }
}
