import 'package:eduvision/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

//STATEFUL
class Loginpage extends StatefulWidget
{

  @override
  State<Loginpage> createState() => _LoginpageState();

}

class _LoginpageState extends State<Loginpage> {

  void login()
  {
     Navigator.pushReplacement(context,MaterialPageRoute(builder:(context)=>MyHomePage(title:"Eduvision")));
  }

  @override
  Widget build(BuildContext context) {
    return(Scaffold(
      body:Container(
        color: Colors.blue.withOpacity(0.12),
        height:double.infinity,
        child:Padding(padding:EdgeInsets.all(20),
            child:Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(keyboardType: TextInputType.emailAddress, // Set the keyboard type for email input
              decoration: InputDecoration(
                labelText: 'Email',

// Label for the input field
                // hintText: 'Enter your email address', // Hint text inside the field
                prefixIcon: Icon(Icons.email), // Optional: add an email icon to the left of the text field
              ),),
            SizedBox.square(dimension:20),
            TextField(obscureText: true,obscuringCharacter:"*",keyboardType: TextInputType.emailAddress, // Set the keyboard type for email input
              decoration: InputDecoration(
                labelText: 'Password',

// Label for the input field
                prefixIcon: Icon(Icons.lock_open_rounded), // Optional: add an email icon to the left of the text field
              ),),
            SizedBox.square(dimension:20),
            SizedBox(

              width: 100.0, // Adjust this value as needed
              child: ElevatedButton(

                onPressed: login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Dark Blue Button
                  padding: const EdgeInsets.symmetric(vertical: 15), // Button Padding
                ),
                child: Center(child: Text("LOGIN",style:TextStyle(fontFamily:"Lato",fontSize:16,fontWeight:FontWeight.w600,color:Colors.white70))),
              ),
            )          ],
        )),
      ),
    ));

  }
}
