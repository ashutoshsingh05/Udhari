class Expenses {
  String dateTime;
  double amount;
  String context;
  String personName;

  Expenses({
    this.amount,
    this.context,
    this.dateTime,
    this.personName,
  });

  Expenses.fromSnapshot(snapshot) {
    dateTime = snapshot.data['dateTime'];
    amount = snapshot.data['amount'];
    context = snapshot.data['context'];
    personName = snapshot.data['personName'];
  }

  toJson() {
    return {
      "dateTime": dateTime,
      "amount": amount,
      "context": context,
      "personName": personName,
    };
  }
}
