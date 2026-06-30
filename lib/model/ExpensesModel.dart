class ExpensesModel {
  var title, location, amount, date, id, resources_id;

  ExpensesModel({this.title, this.location, this.amount, this.date, this.id, this.resources_id});

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'location': location,
      'amount': amount,
      'date': date,
      'id': id,
      'resources_id': resources_id
    };
  }

  factory ExpensesModel.fromMap(Map<String, dynamic> map) {
    return ExpensesModel(
      title: map['title'],
      location: map['location'],
      amount: map['amount'],
      date: map['date'],
      resources_id: map['resources_id']
    );
  }
}
