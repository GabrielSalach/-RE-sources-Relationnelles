class Resource {
  final int id;
  final String nom;
  final int format;
  final String contenu;
  final String description;
  final DateTime date;
  final int nbCom;
  final int nbLike;
  final int nbReport;
  final bool visible;

  Resource({
    required this.id,
    required this.nom,
    required this.format,
    required this.contenu,
    required this.description,
    required this.date,
    required this.nbCom,
    required this.nbLike,
    required this.nbReport,
    required this.visible,
  });

  factory Resource.fromJson(Map<String, dynamic> json) {
    return Resource(
      id: json['id'] as int,
      nom: json['nom'] as String,
      format: json['format'] as int,
      contenu: json['contenue'] as String,
      description: json['description'] ?? '',
      date:
          json['date'] != null
              ? DateTime.parse(json['date'] as String)
              : DateTime.now(),
      nbCom: json['nbCom'] as int? ?? 0,
      nbLike: json['nbLike'] as int? ?? 0,
      nbReport: json['nbReport'] as int? ?? 0,
      visible: json['visible'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'format': format,
      'contenue': contenu,
      'description': description,
      'date': date.toIso8601String(),
      'nbCom': nbCom,
      'nbLike': nbLike,
      'nbReport': nbReport,
      'visible': visible,
    };
  }
}
