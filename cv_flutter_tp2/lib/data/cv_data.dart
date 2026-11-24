class SkillItem {
  final String name;
  final double level; // 0.0 à 1.0
  final String category;

  const SkillItem({
    required this.name,
    required this.level,
    required this.category,
  });
}

class EducationItem {
  final String period;
  final String degree;
  final String institution;
  final String details;

  const EducationItem({
    required this.period,
    required this.degree,
    required this.institution,
    required this.details,
  });
}

class ProjectItem {
  final String title;
  final String stack;
  final String description;

  const ProjectItem({
    required this.title,
    required this.stack,
    required this.description,
  });
}

class LanguageItem {
  final String name;
  final String level;
  final double progress;

  const LanguageItem({
    required this.name,
    required this.level,
    required this.progress,
  });
}

/// Données complètes du CV (modifiables en un seul endroit)
class CvData {
  static const String fullName = 'Justin Kidumu Kabhil';
  static const String initials = 'JK';
  static const String title = 'Étudiant Licence 3 — Informatique de Gestion';
  static const String subtitle = 'Développeur Mobile Flutter & API REST PHP/MySQL';
  static const String location = 'Goma, Nord-Kivu, RD Congo';
  static const String institution = 'ISIG GOMA';
  static const String phone = '+243 970 000 000';
  static const String githubUrl = 'https://github.com/Ir-Justin-KK/cv_flutter_justin';

  static const String about =
      'Étudiant passionné en Licence 3 Informatique de Gestion à l\'ISIG GOMA, '
      'spécialisé dans la conception d\'applications mobiles multiplateformes avec Flutter '
      'et l\'intégration d\'API REST sécurisées en PHP / MySQL. Rigoureux, curieux et '
      'orienté résultats dans la résolution de problèmes numériques.';

  static const List<EducationItem> educations = [
    EducationItem(
      period: '2025 – 2026',
      degree: 'Licence 3 — Informatique de Gestion',
      institution: 'Institut Supérieur d\'Informatique et de Gestion (ISIG GOMA)',
      details: 'Programmation Mobile (Flutter), Architectures Web & API REST, Génie Logiciel.',
    ),
    EducationItem(
      period: '2023 – 2025',
      degree: 'Licence 1 & 2 — Informatique de Gestion',
      institution: 'ISIG GOMA',
      details: 'Bases de données relationnelles MySQL, Programmation Orientée Objet, Réseaux.',
    ),
    EducationItem(
      period: '2022 – 2023',
      degree: 'Diplôme d\'État',
      institution: 'Enseignement Secondaire — Goma',
      details: 'Formation générale scientifique et informatique de base.',
    ),
  ];

  static const List<SkillItem> skills = [
    SkillItem(name: 'Flutter & Dart (UI Material 3, HTTP)', level: 0.88, category: 'Mobile'),
    SkillItem(name: 'PHP 8 & API REST (PDO, JSON)', level: 0.85, category: 'Backend'),
    SkillItem(name: 'MySQL & phpMyAdmin (Modélisation SQL)', level: 0.84, category: 'Base de données'),
    SkillItem(name: 'Git, GitHub & Déploiement XAMPP', level: 0.86, category: 'Outils'),
    SkillItem(name: 'HTML5, CSS3 & JavaScript', level: 0.80, category: 'Web'),
  ];

  static const List<ProjectItem> projects = [
    ProjectItem(
      title: 'TP2 — Gestion dynamique de la famille (Flutter + API REST)',
      stack: 'Flutter • PHP 8 • MySQL • XAMPP',
      description:
          'Authentification réelle via /accounts/login, CRUD complet, recherche multicritère, '
          'filtres par lien de parenté, tableau de bord statistiques et thème clair/sombre.',
    ),
    ProjectItem(
      title: 'TP1 — Application CV Mobile Multi-écrans',
      stack: 'Flutter • Dart • Material 3',
      description:
          'Création de l\'interface CV structurée présentant le parcours académique, '
          'les compétences techniques et les informations familiales.',
    ),
    ProjectItem(
      title: 'API REST de gestion académique & familiale',
      stack: 'PHP PDO • MySQL • JSON',
      description:
          'Développement d\'endpoints RESTful sécurisés avec requêtes préparées, '
          'hachage des mots de passe (password_hash) et validation des entrées.',
    ),
  ];

  static const List<LanguageItem> languages = [
    LanguageItem(name: 'Français', level: 'Courant (Professionnel)', progress: 0.95),
    LanguageItem(name: 'Swahili', level: 'Courant (Langue maternelle)', progress: 0.98),
    LanguageItem(name: 'Anglais', level: 'Technique / Intermédiaire', progress: 0.72),
  ];

  static const List<String> softSkills = [
    'Esprit analytique',
    'Travail en équipe',
    'Autonomie',
    'Veille technologique',
    'Gestion de projet',
    'Communication',
  ];

  static const List<String> interests = [
    'Développement Mobile',
    'Open Source',
    'Architecture Cloud & API',
    'Lecture technique',
    'Football',
  ];
}
