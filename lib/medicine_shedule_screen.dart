import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'medicine_model.dart';

class MedicineScheduleScreen extends StatefulWidget {
  @override
  _MedicineScheduleScreenState createState() => _MedicineScheduleScreenState();
}

class _MedicineScheduleScreenState extends State<MedicineScheduleScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, MedicineSchedule> _medicineSchedules = {};
  DateTime _startDate = DateTime(2025, 10, 1);

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _initializeSchedule();
  }

  void _initializeSchedule() {
    // Initialize the schedule starting from October 1, 2025
    DateTime currentDate = _startDate;
    int dayCount = 0;

    while (dayCount < 365) {
      // Generate schedule for 1 year
      int dose = _calculateDoseForDay(dayCount);
      _medicineSchedules[currentDate] = MedicineSchedule(
        date: currentDate,
        dose: dose,
        isTaken: false,
      );
      currentDate = currentDate.add(Duration(days: 1));
      dayCount++;
    }
  }

  int _calculateDoseForDay(int dayIndex) {
    // Pattern: 75, 100, 75, 100, ...
    return dayIndex % 2 == 0 ? 75 : 100;
  }

  void _toggleMedicineTaken(DateTime date) {
    setState(() {
      if (_medicineSchedules.containsKey(date)) {
        _medicineSchedules[date] = _medicineSchedules[date]!.copyWith(
          isTaken: !_medicineSchedules[date]!.isTaken,
        );
      }
    });
  }

  MedicineSchedule? _getScheduleForDay(DateTime day) {
    // Normalize the date to remove time component
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _medicineSchedules[normalizedDay];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medicine Tracker'),
        backgroundColor: Colors.blue[700],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Calendar Section
            Card(
              margin: EdgeInsets.all(16),
              elevation: 4,
              child: TableCalendar(
                firstDay: DateTime(2025, 1, 1),
                lastDay: DateTime(2026, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) {
                    final schedule = _getScheduleForDay(day);
                    if (schedule != null) {
                      return Container(
                        margin: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: schedule.isTaken ? Colors.green[100] : null,
                          border: Border.all(
                            color: schedule.isTaken
                                ? Colors.green
                                : Colors.transparent,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${day.day}',
                                style: TextStyle(
                                  color: isSameDay(day, DateTime.now())
                                      ? Colors.blue
                                      : Colors.black,
                                  fontWeight: isSameDay(day, DateTime.now())
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                '${schedule.dose}mg',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.red[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return null;
                  },
                  selectedBuilder: (context, day, focusedDay) {
                    return Container(
                      margin: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        border: Border.all(color: Colors.blue, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${day.day}',
                              style: TextStyle(
                                color: Colors.blue[900],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              '${_getScheduleForDay(day)?.dose ?? 0}mg',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.red[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  todayBuilder: (context, day, focusedDay) {
                    final schedule = _getScheduleForDay(day);
                    return Container(
                      margin: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        border: Border.all(color: Colors.blue, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${day.day}',
                              style: TextStyle(
                                color: Colors.blue[900],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              '${schedule?.dose ?? 0}mg',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.red[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Selected Day Info Section
            if (_selectedDay != null) ...[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          'Medicine Schedule for ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Dose Amount:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '${_getScheduleForDay(_selectedDay!)?.dose ?? 0} mg',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red[700],
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Status:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: 4),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        _getScheduleForDay(
                                              _selectedDay!,
                                            )?.isTaken ==
                                            true
                                        ? Colors.green
                                        : Colors.orange,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    _getScheduleForDay(
                                              _selectedDay!,
                                            )?.isTaken ==
                                            true
                                        ? 'TAKEN'
                                        : 'PENDING',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            _toggleMedicineTaken(_selectedDay!);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                _getScheduleForDay(_selectedDay!)?.isTaken ==
                                    true
                                ? Colors.red
                                : Colors.green,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 12,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getScheduleForDay(_selectedDay!)?.isTaken ==
                                        true
                                    ? Icons.close
                                    : Icons.check,
                              ),
                              SizedBox(width: 8),
                              Text(
                                _getScheduleForDay(_selectedDay!)?.isTaken ==
                                        true
                                    ? 'Mark as Not Taken'
                                    : 'Mark as Taken',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],

            // Pattern Info Section
            Card(
              margin: EdgeInsets.all(16),
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Medicine Pattern:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• Day 1: 75mg\n• Day 2: 100mg\n• Day 3: 75mg\n• Day 4: 100mg\n• Repeats every 2 days',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
