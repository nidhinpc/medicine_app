import 'package:flutter/material.dart';
import 'package:medicine_app/medicine_shedule_screen.dart';

void main() {
  runApp(MedicineApp());
}

class MedicineApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medicine Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MedicineScheduleScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
