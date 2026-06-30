
class UserModel {
  var email, password, id;

  UserModel({required this.email, required this.password, this.id});

  Map<String, dynamic> toMap() {
    return {'email': email, 'password': password};
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(email: map['email'], password: map['password'], id: map['id']);
  }
}
