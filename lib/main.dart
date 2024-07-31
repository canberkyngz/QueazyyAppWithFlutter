import 'package:flutter/material.dart';
import 'package:sozluk_projesi/pages/lists.dart';
import 'package:sozluk_projesi/pages/temprory.dart';
import 'package:flutter_statusbarcolor_ns/flutter_statusbarcolor_ns.dart';
void main() {

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {

    FlutterStatusbarcolor.setStatusBarColor(Colors.white);
    FlutterStatusbarcolor.setNavigationBarWhiteForeground(false);
    return MaterialApp(
      routes: {
        '/lists':(context)=>const ListsPage()
      },
      debugShowCheckedModeBanner: false,
      title: 'Sözlük Uygulaması',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:const TemproryPage(),
    );
  }
}


