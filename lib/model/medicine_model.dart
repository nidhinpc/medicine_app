class MedicineSchedule {
  final DateTime date;
  final int dose;
  final bool isTaken;

  MedicineSchedule({
    required this.date,
    required this.dose,
    required this.isTaken,
  });

  Map<String, dynamic> toJson() {
    return {'date': date.toIso8601String(), 'dose': dose, 'isTaken': isTaken};
  }

  factory MedicineSchedule.fromJson(Map<String, dynamic> json) {
    return MedicineSchedule(
      date: DateTime.parse(json['date']),
      dose: json['dose'] as int,
      isTaken: json['isTaken'] as bool,
    );
  }

  MedicineSchedule copyWith({DateTime? date, int? dose, bool? isTaken}) {
    return MedicineSchedule(
      date: date ?? this.date,
      dose: dose ?? this.dose,
      isTaken: isTaken ?? this.isTaken,
    );
  }
}
