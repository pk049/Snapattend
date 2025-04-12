import 'dart:async';
import 'package:eduvision/main.dart';
import 'package:flutter/material.dart';
import 'package:eduvision/Loginpage.dart';

class Splashscreen extends StatefulWidget {
  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {


  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 4), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Loginpage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        color: Colors.blueAccent, // Changed background to blue
        padding: EdgeInsets.all(16), // Added padding for layout fix
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "SnapAttend",
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                  SizedBox(width: 10),
                  Icon(
                    Icons.remove_red_eye_rounded,
                    size: 60,
                    color: Colors.white,
                  ),
                ],
              ),
              SizedBox(height: 20),
              CircularProgressIndicator(
                color: Colors.white, // Changed indicator color to white for better contrast
              )
            ],
          ),
        ),
      ),
    );
  }
}
