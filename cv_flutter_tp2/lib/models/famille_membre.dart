class FamilleMembre {
  final int id;
  final String nom;
  final String postnom;
  final String prenom;
  final String lieuNaissance;
  final String dateNaissance;
  final String parente;
  final String? image;

  const FamilleMembre({
    required this.id,
    required this.nom,
    required this.postnom,
    required this.prenom,
    required this.lieuNaissance,
    required this.dateNaissance,
    required this.parente,
    this.image,
  });

  String get nomComplet => '$nom $postnom $prenom'.trim();

  /// Calcule l'âge approximatif depuis date_naissance (AAAA-MM-JJ)
  int? get age {
    final dob = DateTime.tryParse(dateNaissance);
    if (dob == null) return null;
    final now = DateTime.now();
    int years = now.year - dob.year;
    if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
      years--;
    }
    return years >= 0 ? years : null;
  }

  factory FamilleMembre.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final parsedId = rawId is int ? rawId : int.tryParse('$rawId') ?? 0;

    return FamilleMembre(
      id: parsedId,
      nom: (json['nom'] ?? '').toString(),
      postnom: (json['postnom'] ?? '').toString(),
      prenom: (json['prenom'] ?? '').toString(),
      lieuNaissance: (json['lieu_naissance'] ?? '').toString(),
      dateNaissance: (json['date_naissance'] ?? '').toString(),
      parente: (json['parente'] ?? '').toString(),
      image: json['image']?.toString(),
    );
  }
}

class FamilleStats {
  final int totalMembres;
  final int totalComptes;
  final Map<String, int> parParente;
  final Map<String, int> parLieu;

  const FamilleStats({
    required this.totalMembres,
    required this.totalComptes,
    required this.parParente,
    required this.parLieu,
  });

  factory FamilleStats.fromJson(Map<String, dynamic> json) {
    final parenteMap = <String, int>{};
    if (json['par_parente'] is List) {
      for (final item in json['par_parente'] as List) {
        if (item is Map<String, dynamic>) {
          final key = (item['parente'] ?? 'Autre').toString();
          final val = int.tryParse('${item['total']}') ?? 0;
          parenteMap[key] = val;
        }
      }
    }

    final lieuMap = <String, int>{};
    if (json['par_lieu'] is List) {
      for (final item in json['par_lieu'] as List) {
        if (item is Map<String, dynamic>) {
          final key = (item['lieu_naissance'] ?? 'Inconnu').toString();
          final val = int.tryParse('${item['total']}') ?? 0;
          lieuMap[key] = val;
        }
      }
    }

    return FamilleStats(
      totalMembres: int.tryParse('${json['total_membres']}') ?? 0,
      totalComptes: int.tryParse('${json['total_comptes']}') ?? 0,
      parParente: parenteMap,
      parLieu: lieuMap,
    );
  }
}
