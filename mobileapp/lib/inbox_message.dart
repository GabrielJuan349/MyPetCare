//import 'dart:ffi';

class InboxMessage {
  String title, message, type, id, petName;
  bool read = false;
  InboxMessage(this.title, this.message, this.type, this.id, this.read, {this.petName=''});
  factory InboxMessage.fromFirestore(Map<String, dynamic> data) {
    return InboxMessage(
      data['title'] ?? '',
      data['message'] ?? '',
      data['type'] ?? '',
      data['id'] ?? '',
      data['read'] ?? false,
      petName: data['petName'] ?? '',
    );
  }
}



List<InboxMessage> myMessages = [
  InboxMessage("Welcome to MyPetCare", "Thanks for choosing us", "report", "firstID", false),
];

