import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:eduvision/Loginpage.dart';

class Navbar extends StatelessWidget{

  @override
  Widget build(BuildContext context)
  {
    return Drawer(
      child:Padding(padding:EdgeInsets.zero,
        child:ListView(
        children: [
          UserAccountsDrawerHeader(
            decoration:BoxDecoration(color:Colors.blueAccent,),
            accountName:Text("Prajakta Darekar",style:TextStyle(color:Colors.black,fontFamily:'Lato')),
            accountEmail:Text("pddarekar11@gmail.com",style:TextStyle(fontFamily:"lato",color:Colors.black)),currentAccountPicture:
          CircleAvatar(
            child:ClipOval(
              child: Align(
                alignment: Alignment.bottomCenter,
                child:Image.network(height: 90,width: 90, "https://c0.klipartz.com/pngpicture/702/92/gratis-png-steve-jobs-steve-jobs-apple-director-ejecutivo-co-fundador-pixar-steve-jobs.png",fit:BoxFit.cover,),
              ),
            ),
          ),
          ),


          ListTile(leading:Icon(Icons.access_time_sharp),title:Text("Todays logs",style:TextStyle(fontFamily:"lato"))),
          ListTile(leading:Icon(Icons.settings),title:Text("Settings",style:TextStyle(fontFamily:"lato"))),
          ListTile(leading:Icon(Icons.code),title:Text("About Devlopers",style:TextStyle(fontFamily:"lato"))),
          ListTile(leading:Icon(Icons.file_copy_rounded),title:Text("Policies",style:TextStyle(fontFamily:"lato"))),
          ListTile(leading:Icon(Icons.notification_add),title:Text("Notifications",style:TextStyle(fontFamily:"lato"))),
        ],)
      ),
    );
  }

}
