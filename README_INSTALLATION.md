# TP2 Premium — Projet complet Flutter + API REST PHP + MySQL + 10 Captures

## Contenu de l'archive
- **`api-test/`** : API REST PHP 8+ (PDO) prête pour XAMPP + base MySQL **`api-test/api.sql`** + routes bonus `/health` et `/famille-membres/stats`.
- **`cv_flutter_tp2/`** : Application Flutter Material 3 complète (CV détaillé, Mode Clair/Sombre, Tableau de bord MySQL, CRUD Famille + recherche + filtres + fiche détail).
- **`captures/`** : 10 captures d'écran haute résolution (1280×800) de toutes les pages Flutter (dont le CV complet et le mode sombre) ainsi que du backend (phpMyAdmin, API JSON et terminal).

## Installation rapide
1. Démarrer **Apache** et **MySQL** dans XAMPP.
2. Copier `api-test/` dans `C:\xampp\htdocs\api-test`.
3. Importer `api-test/api.sql` dans la base `api` sur `http://localhost/phpmyadmin`.
4. Dans `cv_flutter_tp2/`, exécuter :
   ```bash
   flutter create .
   flutter pub get
   flutter analyze
   flutter run -d windows
   ```
