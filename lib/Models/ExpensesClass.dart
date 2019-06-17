class Expenses {
  String dateTime;
  double amount;
  String context;
  String personName;
  String epochTime;
  String displayPicture;

  Expenses(
      {this.amount,
      this.context,
      this.dateTime,
      this.personName,
      this.epochTime,
      this.displayPicture});

  Expenses.fromSnapshot(snapshot) {
    dateTime = snapshot.data['dateTime'];
    amount = snapshot.data['amount'];
    context = snapshot.data['context'];
    personName = snapshot.data['personName'];
    epochTime = snapshot.data['epochTime'];
    displayPicture = snapshot.data['displayPicture'];
  }

  toJson() {
    return {
      "dateTime": dateTime,
      "amount": amount,
      "context": context,
      "personName": personName,
      "epochTime": epochTime,
      "displayPicture": displayPicture,
    };
  }
}
