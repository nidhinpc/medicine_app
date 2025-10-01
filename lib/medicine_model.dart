class MedicineSchedule {
  final DateTime date;
  final int dose;
  final bool isTaken;

  MedicineSchedule({
    required this.date,
    required this.dose,
    required this.isTaken,
  });

  MedicineSchedule copyWith({DateTime? date, int? dose, bool? isTaken}) {
    return MedicineSchedule(
      date: date ?? this.date,
      dose: dose ?? this.dose,
      isTaken: isTaken ?? this.isTaken,
    );
  }
}
