import 'package:flutter/material.dart';
import 'package:medicine_app/view/medicine_shedule_screen.dart';

void main() {
  runApp(MedicineApp());
}

class MedicineApp extends StatelessWidget {
  const MedicineApp({super.key});

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
