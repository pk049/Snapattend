import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:eduvision/Loginpage.dart';
import 'package:flutter/material.dart';

class Navbar extends StatelessWidget {
  final String professorName;
  final String email;

  const Navbar({
    Key? key,
    required this.professorName,
    required this.email,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Padding(
        padding: EdgeInsets.zero,
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Colors.blueAccent),
              accountName: Text(
                professorName,
                style: const TextStyle(color: Colors.black, fontFamily: 'Lato'),
              ),
              accountEmail: Text(
                email,
                style: const TextStyle(fontFamily: "Lato", color: Colors.black),
              ),
              currentAccountPicture: const CircleAvatar(
                child: ClipOval(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Image(
                      height: 90,
                      width: 90,
                      fit: BoxFit.cover,
                      image: NetworkImage(
                        "https://c0.klipartz.com/pngpicture/702/92/gratis-png-steve-jobs-steve-jobs-apple-director-ejecutivo-co-fundador-pixar-steve-jobs.png",
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const ListTile(
              leading: Icon(Icons.access_time_sharp),
              title: Text("Today's logs", style: TextStyle(fontFamily: "Lato")),
            ),
            const ListTile(
              leading: Icon(Icons.settings),
              title: Text("Settings", style: TextStyle(fontFamily: "Lato")),
            ),
            const ListTile(
              leading: Icon(Icons.code),
              title: Text("About Developers", style: TextStyle(fontFamily: "Lato")),
            ),
            const ListTile(
              leading: Icon(Icons.file_copy_rounded),
              title: Text("Policies", style: TextStyle(fontFamily: "Lato")),
            ),
            const ListTile(
              leading: Icon(Icons.notification_add),
              title: Text("Notifications", style: TextStyle(fontFamily: "Lato")),
            ),
          ],
        ),
      ),
    );
  }
}
