import 'package:intl/intl.dart';

class ReportMessage {
  final String reportName;
  final String message;
  final DateTime date;

  ReportMessage(this.reportName, this.message, this.date);

  factory ReportMessage.fromJson(Map<String, dynamic> json) {
    return ReportMessage(
      json['name'] ?? 'No title',
      json['text'] ?? 'No description',
      DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
    );
  }

  String get formattedDate {
    return DateFormat('dd/MM/yyyy - HH:mm').format(date);
  }
}
