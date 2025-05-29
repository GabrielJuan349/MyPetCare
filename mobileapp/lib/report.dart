import 'package:intl/intl.dart';

class ReportMessage {
  final String message;
  final DateTime date;

  ReportMessage(this.message, this.date);

  factory ReportMessage.fromJson(Map<String, dynamic> json) {
    return ReportMessage(
      json['reportText'] ?? 'No description',
      DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
    );
  }

  String get formattedDate {
    return DateFormat('dd/MM/yyyy - HH:mm').format(date);
  }
}
