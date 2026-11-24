# Application Flutter TP2 Premium — CV Complet & Gestion Familiale (ISIG GOMA)

## Nouveautés de cette version enrichie
- **Design Material 3 soigné** avec **Mode Clair / Mode Sombre** instantané.
- **CV complet (`lib/data/cv_data.dart` + `CvPage`)** : bannière profil, À propos, Formation académique, Compétences techniques avec barres de progression, Projets réalisés, Langues, Qualités, Centres d'intérêt et Coordonnées.
- **Tableau de bord Statistiques (`DashboardPage`)** connecté à MySQL (`GET /famille-membres/stats`).
- **Gestion Famille (`FamilyPage`)** : recherche en direct (`?q=`), filtres rapides par parenté (`?parente=`), fiche détaillée avec calcul automatique de l'âge, et CRUD complet (`POST`, `PUT`, `DELETE`).

## Captures incluses (`captures/`)
1. `01_flutter_login_premium.png` — Connexion & inscription API
2. `02_flutter_cv_profil_formation.png` — Mon CV : Profil, À propos & Formation
3. `03_flutter_cv_competences_langues_projets.png` — Mon CV : Compétences, Projets, Langues & Centres d'intérêt
4. `04_flutter_dashboard_stats.png` — Tableau de bord statistiques MySQL
5. `05_flutter_famille_recherche_filtres.png` — Famille : Recherche & filtres par parenté
6. `06_flutter_famille_detail_age.png` — Fiche détaillée d'un membre avec calcul d'âge
7. `07_flutter_famille_formulaire_crud.png` — Formulaire d'ajout / modification
8. `08_flutter_mode_sombre.png` — Aperçu en Mode Sombre (Dark Mode)
9. `09_backend_phpmyadmin_mysql.png` — Base MySQL `api` dans phpMyAdmin
10. `10_backend_api_json_et_terminal.png` — Réponses JSON (`/famille-membres`, `/stats`) & tests `curl.exe`

## Démonstration vidéo
[Regarder la démonstration de mon application Flutter](../video.mp4)
