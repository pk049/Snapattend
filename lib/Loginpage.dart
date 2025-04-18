import 'package:eduvision/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';

//STATEFUL
class Loginpage extends StatefulWidget {
  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
  // Controllers to get text field values
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Loading state
  bool _isLoading = false;

  Future<void> login() async {
    // Set loading state
    setState(() {
      _isLoading = true;
    });

    try {
      // Prepare request data
      final Map<String, String> requestData = {
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
      };

      // Make the POST request
      final response = await http.post(
        Uri.parse('http://192.168.1.4:5000/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );

      // Parse the response
      final responseData = jsonDecode(response.body);

      // Print response to console
      print('Login Response: $responseData');

      // Check if login was successful
      if (responseData['status'] == 'success') {
        final String department = responseData['department'] ?? 'Unknown Department';
        final String name = responseData['name'] ?? 'Unknown Professor';

        // Navigate to home page on success
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyHomePage(title: "Eduvision", professorName: name,
            department: department,)),
        );
      } else {
        // Show error toast
        Fluttertoast.showToast(
          msg: "Incorrect email or password",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
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
      // Reset loading state
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.blue.withOpacity(0.12),
        height: double.infinity,
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              SizedBox.square(dimension: 20),
              TextField(
                controller: _passwordController,
                obscureText: true,
                obscuringCharacter: "*",
                keyboardType: TextInputType.visiblePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock_open_rounded),
                ),
              ),
              SizedBox.square(dimension: 20),
              SizedBox(
                width: 100.0,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white70)
                      : Text(
                    "LOGIN",
                    style: TextStyle(
                      fontFamily: "Lato",
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}