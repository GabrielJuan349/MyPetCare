class Appointment {
  late String id;
  late String userId;
  late String petId;
  late String date;
  late String time;
  late String type;
  late String reason;
  late String clinicId;
  late String vetId;

  Appointment({
    required this.id,
    required this.petId,
    required this.date,
    required this.time,
    required this.type,
    required this.reason,
    required this.clinicId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'date': date,
      'time': time,
      'type': type,
      'reason': reason,
      'clinicId': clinicId,
    };
  }

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] ?? "",
      petId: json['petId'] ?? "",
      date: json['date'] ?? "",
      time: json['time'] ?? "",
      type: json['type'] ?? "",
      reason: json['reason'] ?? "",
      clinicId: json['clinicId'] ?? "",
    );
  }
}