class AppUser {
  final String id;
  final String email;
  final String nom;
  final String prenom;
  final String role;
  final int? age;
  final DateTime? dateNaissance;
  final String? adresse;
  final String? codePostal;
  final String? ville;
  final String? telephone;
  final String? bio;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  AppUser({
    required this.id,
    required this.email,
    required this.nom,
    required this.prenom,
    required this.role,
    this.age,
    this.dateNaissance,
    this.adresse,
    this.codePostal,
    this.ville,
    this.telephone,
    this.bio,
    required this.isVerified,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'].toString(),
      email: json['email']?.toString() ?? '',
      nom: json['nom']?.toString() ?? '',
      prenom: json['prenom']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      age: json['age'] != null ? int.tryParse(json['age'].toString()) : null,
      dateNaissance:
          json['date_naissance'] != null && json['date_naissance'] is String
              ? DateTime.tryParse(json['date_naissance'])
              : null,
      adresse: json['adresse']?.toString(),
      codePostal: json['code_postal']?.toString(),
      ville: json['ville']?.toString(),
      telephone: json['telephone']?.toString(),
      bio: json['bio']?.toString(),
      isVerified: json['is_verified'] is bool
          ? json['is_verified']
          : (json['is_verified']?.toString().toLowerCase() == 'true'
              ? true
              : false),
      createdAt: (json['created_at'] != null && json['created_at'] is String)
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: (json['updated_at'] != null && json['updated_at'] is String)
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nom': nom,
      'prenom': prenom,
      'role': role,
      'age': age,
      'date_naissance': dateNaissance?.toIso8601String(),
      'adresse': adresse,
      'code_postal': codePostal,
      'ville': ville,
      'telephone': telephone,
      'bio': bio,
      'is_verified': isVerified,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
