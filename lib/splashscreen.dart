import 'dart:async';
import 'package:eduvision/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:eduvision/Loginpage.dart';
import 'package:google_fonts/google_fonts.dart';

class Splashscrren extends StatefulWidget{

  @override
  State<Splashscrren> createState() => _SplashscrrenState();


}

class _SplashscrrenState extends State<Splashscrren> {

  @override
  void initState()
  {
    super.initState();
    Timer(Duration(seconds: 2),(){
      Navigator.pushReplacement(context,MaterialPageRoute(builder:(context)=>Loginpage()));
    });
  }


  @override
  Widget build(BuildContext context)
  {
     return Scaffold(
       body:Container(
         height:double.infinity,
         width: double.infinity,
         color:Colors.yellowAccent,
         child: Center(
           child:Column( mainAxisAlignment:MainAxisAlignment.center, children: [  Row(
             mainAxisAlignment:MainAxisAlignment.center,
             children: [Text("Eduvision",style:TextStyle(fontFamily: 'Lato',
               fontSize: 40)),
                         Container(width: 10,),
                         Icon(Icons.remove_red_eye_rounded,size:60,)],
           ),Container(height:10),
           CircularProgressIndicator(
             color: Colors.black,
             backgroundColor: Colors.black.withOpacity(0.4),
             strokeWidth:6.0,
           )]),
         ),
       ) ,
     );
  }
}
