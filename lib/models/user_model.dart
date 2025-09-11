class UserModel {
  final String id;
  final String name;
  final String email;
  final String? perfilImage;
  final List<String> groups;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.perfilImage,
    required this.groups,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      perfilImage: json['perfilImage'],
      groups: List<String>.from(json['groups'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'perfilImage': perfilImage,
      'groups': groups,
    };
  }
}