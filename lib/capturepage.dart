import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class capturepage extends StatefulWidget{

  @override
  State<capturepage> createState() => _capturepageState();
}

class _capturepageState extends State<capturepage> {
  String? _selectedClass;
  final ImagePicker _picker = ImagePicker();


  Future<void> _openCamera() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      // Handle the captured photo
      print('Captured image path: ${photo.path}');
      // You can use the photo.path to display the image or upload it
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true,
          title:Text('Take Attendance ',style: TextStyle(fontSize:30, fontFamily: 'Lato',),),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            DropdownButton<String>(
              hint: Text('Select a class'),
              value: _selectedClass,
              items: <String>['Class A', 'Class B', 'Class C']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedClass = newValue;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed:_openCamera,
              child: Text('Capture Me'),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.yellow),
                foregroundColor: MaterialStateProperty.all(Colors.black),
                minimumSize: MaterialStateProperty.all(Size(double.infinity, 50)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
