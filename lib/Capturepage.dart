import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
// import 'package:flutter_svg/flutter_svg.dart';

class CapturePage extends StatelessWidget {
  final List<Map<String, dynamic>> timetable = [
    {"subject": "Compiler Design", "time": "9:40 - 10:40", "icon": Icons.settings},
    {"subject": "Operating Systems", "time": "10:40 - 11:40", "icon": Icons.computer},
    {"subject": "Break", "time": "10 mins", "isBreak": true},
    {"subject": "C Programming", "time": "11:50 - 12:50", "icon": Icons.code},
    {"subject": "Machine Learning", "time": "12:50 - 1:50", "icon": Icons.memory},
    {"subject": "Break", "time": "40 mins", "isBreak": true},
    {"subject": "Chemistry LAB", "time": "2:30 - 4:30", "icon": Icons.science},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('',style:TextStyle(fontSize:30,fontWeight:FontWeight.normal) ,)),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Today's Timetable",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: timetable.length,
                itemBuilder: (context, index) {
                  final item = timetable[index];
                  return item.containsKey("isBreak")
                      ? Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Center(
                      child: Text(
                        "--- ${item['subject']} (${item['time']}) ---",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ),
                  )
                      : Card(
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: Icon(item["icon"], color: Colors.blue),
                      title: Text(
                        item['subject'],
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(item['time']),
                      trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
                      onTap: () => _onTileTap(context, item['subject']),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onTileTap(BuildContext context, String subject) {
    print("Tapped on: $subject");
  }
}
