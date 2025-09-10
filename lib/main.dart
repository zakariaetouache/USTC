import 'package:flutter/material.dart';
import 'package:ustc/screens/intial_page_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      /*theme: ThemeData(
        primaryColor: Colors.green,
      ),*/
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => InitialPageScreen(),
      },
    );
  }
}
