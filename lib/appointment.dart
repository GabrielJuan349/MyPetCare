import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Appointment {
  late String id;
  late String ownerId;
  late String petName;
  late String date;
  late String time;
  late String type;
  late String reason;
  late String clinicName;
  late String vetName;

  Appointment({
    required this.id,
    required this.ownerId,
    required this.petName,
    required this.date,
    required this.time,
    required this.type,
    required this.reason,
    required this.clinicName,
    required this.vetName,
  });

  // Used mostly to save the appointment inside firestore
  // Convert to JSON
  Map<String, dynamic> toJson() {
    final DateTime parsedDate = DateFormat('dd/MM/yyyy').parse(date);
    return {
      'ownerId': ownerId,
      'petName': petName,
      'date': parsedDate,
      'time': time,
      'type': type,
      'reason': reason,
      'clinicName': clinicName,
      'vetName': vetName,
    };
  }

  // Convert from JSON to Appointment
  factory Appointment.fromJson(Map<String, dynamic> json) {
    final Timestamp timestamp = json['date'];
    final formattedDate = DateFormat('dd/MM/yyyy').format(timestamp.toDate());
    return Appointment(
      id: json['id'] ?? "",
      ownerId: json['ownerId'] ?? "",
      petName: json['petName'] ?? "",
      date: formattedDate,
      time: json['time'] ?? "",
      type: json['type'] ?? "",
      reason: json['reason'] ?? "",
      clinicName: json['clinicName'] ?? "",
      vetName: json['vetName'] ?? "",
    );
  }
}