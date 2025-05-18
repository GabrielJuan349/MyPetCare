class InboxMessage {
  late String title, message;
  InboxMessage(this.title, this.message);
}

List<InboxMessage> myMessages = [
  InboxMessage("Welcome to MyPetCare", "Thanks for choosing us"),
  InboxMessage("Medication added", "A new Medication has been added to your pet"),
];
