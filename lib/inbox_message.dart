//import 'dart:ffi';

class InboxMessage {
  late String title, message, type, id;
  bool read = false;
  InboxMessage(this.title, this.message, this.type, this.id, this.read);
}



List<InboxMessage> myMessages = [
  InboxMessage("Welcome to MyPetCare", "Thanks for choosing us", "report", "firstID", false),
  InboxMessage("Medication added", "A new Medication has been added to your pet", "treatment", "secondID", false),
];

