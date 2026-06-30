class Resourcemodel {
  String? title;
  int? id, resources_id;
  double? balance;

  Resourcemodel({this.title, this.id, this.balance, this.resources_id});

  Map<String, dynamic> toMap() {
    return {'title': title, 'balance': balance, 'id': id, 'resources_id': resources_id};
  }

  factory Resourcemodel.fromMap(Map<String, dynamic> map) {
    return Resourcemodel(
      title: map['title'],
      id: map['id'],
      balance: (map['balance'] as num?)?.toDouble(),
      resources_id: map['resources_id']
    );
  }
}
