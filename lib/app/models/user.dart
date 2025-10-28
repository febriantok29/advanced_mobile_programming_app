enum Gender {
  male,
  female;

  static Gender? get(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value == 0 ? male : (value == 1 ? female : null);
    }

    final valueStr = value.toString().toLowerCase();

    switch (valueStr) {
      case 'male':
      case 'm':
        return male;
      case 'female':
      case 'f':
        return female;
      default:
        return null;
    }
  }

  String get label {
    switch (this) {
      case male:
        return 'Laki-laki';
      case female:
        return 'Perempuan';
    }
  }

  @override
  String toString() {
    switch (this) {
      case male:
        return 'Male';
      case female:
        return 'Female';
    }
  }
}

class User {
  num? id;
  String? firstName;
  String? lastName;
  String? email;
  Gender? gender;

  User({this.id, this.firstName, this.lastName, this.email, this.gender});

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    firstName: json['first_name'],
    lastName: json['last_name'],
    email: json['email'],
    gender: Gender.get('${json['gender']}'),
  );

  User copyWith({
    num? id,
    String? firstName,
    String? lastName,
    String? email,
    Gender? gender,
  }) => User(
    id: id ?? this.id,
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    email: email ?? this.email,
    gender: gender ?? this.gender,
  );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};

    num? id = this.id;

    if (id == null) {
      final now = DateTime.now();
      id = now.microsecondsSinceEpoch;
    }

    map['id'] = id;
    map['first_name'] = firstName;
    map['last_name'] = lastName;
    map['email'] = email;
    map['gender'] = '$gender';

    return map;
  }

  void validate() {
    if (firstName == null || firstName!.isEmpty) {
      throw 'Nama depan harus diisi!';
    }

    if (gender == null) {
      throw 'Jenis kelamin harus diisi!';
    }
  }

  void reset() {
    id = null;
    firstName = null;
    lastName = null;
    email = null;
    gender = null;
  }
}
