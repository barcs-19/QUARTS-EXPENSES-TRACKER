class CravingsModel {
  var title, location, amount, id, cravings_id;

  CravingsModel({this.title, this.location, this.amount, this.id, this.cravings_id});

  Map<String, dynamic> toMap() {
    return {'title': title, 'location': location, 'amount': amount, 'id': id, 'cravings_id': cravings_id};
  }

  factory CravingsModel.fromMap(Map<String, dynamic> map) {
    return CravingsModel(
      title: map['title'],
      location: map['location'],
      amount: map['amount'],
      cravings_id: map['cravings_id'],
      id: map['id']
    );
  }
}
