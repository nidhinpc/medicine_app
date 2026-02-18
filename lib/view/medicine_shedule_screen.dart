import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:medicine_app/model/medicine_model.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MedicineScheduleScreen extends StatefulWidget {
  const MedicineScheduleScreen({super.key});

  @override
  State<MedicineScheduleScreen> createState() => _MedicineScheduleScreenState();
}

class _MedicineScheduleScreenState extends State<MedicineScheduleScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final Map<String, MedicineSchedule> _medicineSchedules = {};
  final DateTime _startDate = DateTime(2025, 10, 1);
  final String _storageKey = 'medicine_schedules';

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _initializeSchedule();
  }

  Future<void> _initializeSchedule() async {
    await _loadSchedules();

    if (_medicineSchedules.isEmpty) {
      _generateDefaultSchedule();
      await _saveSchedules();
    }

    setState(() {});
  }

  void _generateDefaultSchedule() {
    DateTime currentDate = _startDate;
    int dayCount = 0;

    while (dayCount < 365) {
      String dateKey = _dateToKey(currentDate);

      _medicineSchedules[dateKey] = MedicineSchedule(
        date: currentDate,
        dose: 100,
        isTaken: false,
      );

      currentDate = currentDate.add(const Duration(days: 1));
      dayCount++;
    }
  }

  String _dateToKey(DateTime date) => "${date.year}-${date.month}-${date.day}";

  Future<void> _toggleMedicineTaken(DateTime date) async {
    String key = _dateToKey(date);

    if (_medicineSchedules.containsKey(key)) {
      setState(() {
        _medicineSchedules[key] = _medicineSchedules[key]!.copyWith(
          isTaken: !_medicineSchedules[key]!.isTaken,
        );
      });
      await _saveSchedules();
    }
  }

  Future<void> _saveSchedules() async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> data = {};

    _medicineSchedules.forEach((key, value) {
      data[key] = value.toJson();
    });

    await prefs.setString(_storageKey, jsonEncode(data));
    debugPrint("Saved ${_medicineSchedules.length} schedules");
  }

  Future<void> _loadSchedules() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);

    if (jsonString != null && jsonString.isNotEmpty) {
      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
      _medicineSchedules.clear();

      decoded.forEach((key, value) {
        _medicineSchedules[key] = MedicineSchedule.fromJson(value);
      });

      debugPrint("Loaded ${_medicineSchedules.length} schedules");
    }
  }

  MedicineSchedule? _getSchedule(DateTime day) =>
      _medicineSchedules[_dateToKey(day)];

  Color _getDateColor(MedicineSchedule? schedule) {
    if (schedule == null) return Colors.transparent;
    if (schedule.isTaken) return Colors.green.withAlpha(70);
    return Colors.transparent;
  }

  Border? _getDateBorder(MedicineSchedule? schedule) {
    if (schedule?.isTaken == true) {
      return Border.all(color: Colors.green, width: 2);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final schedule = _selectedDay != null ? _getSchedule(_selectedDay!) : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Medicine Tracker",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blue.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _showResetDialog,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              /// CALENDAR
              Card(
                margin: const EdgeInsets.all(16),
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: TableCalendar(
                    firstDay: DateTime(2025, 1, 1),
                    lastDay: DateTime(2026, 12, 31),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: (selected, focused) {
                      setState(() {
                        _selectedDay = selected;
                        _focusedDay = focused;
                      });
                    },
                    onFormatChanged: (format) =>
                        setState(() => _calendarFormat = format),
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, focused) {
                        final s = _getSchedule(day);
                        return _buildDayCell(day, s);
                      },
                      selectedBuilder: (context, day, focused) {
                        final s = _getSchedule(day);
                        return _buildDayCell(day, s, selected: true);
                      },
                      todayBuilder: (context, day, focused) {
                        final s = _getSchedule(day);
                        return _buildDayCell(day, s, isToday: true);
                      },
                    ),
                  ),
                ),
              ),

              /// SELECTED DAY INFO
              if (_selectedDay != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text(
                            "Schedule for ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade800,
                            ),
                          ),
                          const SizedBox(height: 20),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "${schedule?.dose ?? 0} mg",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red.shade700,
                                ),
                              ),
                              Chip(
                                label: Text(
                                  schedule?.isTaken == true
                                      ? "TAKEN"
                                      : "PENDING",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                backgroundColor: schedule?.isTaken == true
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          ElevatedButton.icon(
                            onPressed: () {
                              _toggleMedicineTaken(_selectedDay!);
                            },
                            icon: Icon(
                              schedule?.isTaken == true
                                  ? Icons.close
                                  : Icons.check,
                              color: Colors.white,
                            ),
                            label: Text(
                              schedule?.isTaken == true
                                  ? "Mark as Not Taken"
                                  : "Mark as Taken",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: schedule?.isTaken == true
                                  ? Colors.red
                                  : Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              /// PATTERN CARD
              Card(
                margin: const EdgeInsets.all(16),
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Medicine Pattern",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text("100mg Daily"),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDayCell(
    DateTime day,
    MedicineSchedule? schedule, {
    bool selected = false,
    bool isToday = false,
  }) {
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _getDateColor(schedule),
        border: selected || isToday
            ? Border.all(color: Colors.blue, width: 2)
            : _getDateBorder(schedule),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          "${day.day}",
          style: TextStyle(
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Reset Data"),
        content: const Text("Are you sure you want to reset all data?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove(_storageKey);
              _medicineSchedules.clear();
              _generateDefaultSchedule();
              await _saveSchedules();
              setState(() {});
            },
            child: const Text("Reset", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
