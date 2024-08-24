import 'package:eduvision/splashscreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eduvision/Navbar.dart';
import 'package:eduvision/Loginpage.dart';
import 'package:eduvision/capturepage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        textTheme: GoogleFonts.latoTextTheme(),
        primarySwatch:Colors.yellow,
        visualDensity:VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      home:Splashscrren()
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

  void attendance()
  {
       Navigator.push(context,MaterialPageRoute(builder:(context)=>capturepage()));
  }


  void report()
  {

  }

  void logs()
  {

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       drawer: Navbar(),
        appBar: AppBar(
          backgroundColor:Colors.yellow,
          title:Text('Smartvision',style: TextStyle(fontSize:30, fontFamily: 'Lato',),),
          centerTitle: true,
        ),
        body:
        Padding (padding:EdgeInsets.all(10),child:  Center(
          child:Column(
            mainAxisAlignment:MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: attendance,
                child: Text("TAKE ATTENDANCE",style:TextStyle(fontFamily: 'Lato',fontSize:19)),
                style: ButtonStyle(
                  backgroundColor:WidgetStateProperty.all(Colors.yellow),
                  foregroundColor: WidgetStateProperty.all(Colors.black),
                  side: WidgetStateProperty.all(BorderSide(color: Colors.black)),
                  minimumSize: WidgetStateProperty.all(Size(double.infinity, 50)), // Width more
                ),
              ),
              SizedBox.square(dimension: 20),
              ElevatedButton(
                onPressed: report,
                child: Text("SEE REPORTS",style:TextStyle(fontFamily: 'Lato',fontSize:19)),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.yellow),
                  foregroundColor: WidgetStateProperty.all(Colors.black),
                  side: WidgetStateProperty.all(BorderSide(color: Colors.black)),
                  minimumSize:WidgetStateProperty.all(Size(double.infinity, 50)), // Width more
                ),
              ),SizedBox.square(dimension: 20),
              ElevatedButton(
                onPressed: logs,
                child: Text("TODAY'S LOGS",style:TextStyle(fontFamily: 'Lato',fontSize: 19),),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.yellow),
                  foregroundColor: WidgetStateProperty.all(Colors.black),
                  side:WidgetStateProperty.all(BorderSide(color: Colors.black)),
                  minimumSize:WidgetStateProperty.all(Size(double.infinity, 50)), // Width more
                ),
              ),

            ],
          )),
        )
    );
  }

}
