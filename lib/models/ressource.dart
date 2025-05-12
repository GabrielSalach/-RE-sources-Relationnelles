class Ressource {
  final int id;
  final String nom;
  final int format; // 1=texte, 2=photo, 3=vidéo
  final String contenue;
  final String description;
  final DateTime date;
  final int nbCom;
  final int nbLike;
  final int nbReport;
  final bool visible;
  final String categorie;
  final String? imageUrl;

  Ressource({
    required this.id,
    required this.nom,
    required this.format,
    required this.contenue,
    required this.description,
    required this.date,
    required this.nbCom,
    required this.nbLike,
    required this.nbReport,
    required this.visible,
    required this.categorie,
    this.imageUrl,
  });

  factory Ressource.fromJson(Map<String, dynamic> json) {
    return Ressource(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      nom: json['nom'] ?? '',
      format: json['format'] is int
          ? json['format']
          : int.parse(json['format'].toString()),
      contenue: json['contenue'] ?? '',
      description: json['description'] ?? '',
      date: DateTime.parse(json['date']),
      nbCom: json['nbCom'] is int
          ? json['nbCom']
          : int.parse(json['nbCom'].toString()),
      nbLike: json['nbLike'] is int
          ? json['nbLike']
          : int.parse(json['nbLike'].toString()),
      nbReport: json['nbReport'] is int
          ? json['nbReport']
          : int.parse(json['nbReport'].toString()),
      visible: json['visible'] == true || json['visible'] == 'TRUE',
      categorie: json['categorie'] ?? '',
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'format': format,
      'contenue': contenue,
      'description': description,
      'date': date.toIso8601String(),
      'nbCom': nbCom,
      'nbLike': nbLike,
      'nbReport': nbReport,
      'visible': visible,
      'categorie': categorie,
      'imageUrl': imageUrl,
    };
  }

  // Obtenir l'URL de l'image en fonction du format
  String? getDisplayUrl() {
    if (format == 2) {
      // Photo
      return imageUrl ?? contenue;
    } else if (format == 3) {
      // Vidéo
      return imageUrl; // L'URL de la miniature de la vidéo
    }
    return null;
  }
}
