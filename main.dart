import 'package:flutter/material.dart';
import 'package:skin_detection_app/skin_disease_detector.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Skin Disease Detector',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: SkinDiseaseDetector(), 
    );
  }
}



