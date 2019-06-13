class Expenses {
  String dateTime;
  double amount;
  String context;
  String personName;
  String epochTime;

  Expenses({
    this.amount,
    this.context,
    this.dateTime,
    this.personName,
    this.epochTime,
  });

  Expenses.fromSnapshot(snapshot) {
    dateTime = snapshot.data['dateTime'];
    amount = snapshot.data['amount'];
    context = snapshot.data['context'];
    personName = snapshot.data['personName'];
    epochTime = snapshot.data['epochTime'];
  }

  toJson() {
    return {
      "dateTime": dateTime,
      "amount": amount,
      "context": context,
      "personName": personName,
      "epochTime": epochTime,
    };
  }
}
