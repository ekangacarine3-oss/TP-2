# TP-2 — Application Flutter + API REST PHP/MySQL (ISIG GOMA)

Projet académique **TP2** : application Flutter Material 3 avec CV interactif, tableau de bord statistiques et gestion complète des membres de famille, connectée à une API REST PHP 8 (PDO) et une base MySQL.

## Contenu du dépôt

| Dossier | Description |
| --- | --- |
| `cv_flutter_tp2/` | Application Flutter (CV, dashboard, CRUD famille, mode clair/sombre) |
| `api-test/` | API REST PHP 8 + script SQL de la base `api` |
| `captures/` | 10 captures d'écran du projet (Flutter + backend) |
| `README_INSTALLATION.md` | Guide d'installation détaillé |

## Fonctionnalités

- CV complet : profil, formation, compétences, projets, langues, centres d'intérêt
- Authentification (inscription / connexion) via l'API
- Tableau de bord statistiques alimenté par MySQL
- Gestion des membres de famille : recherche, filtres par parenté, fiche détail avec calcul d'âge, CRUD complet
- Mode clair / mode sombre

## Installation rapide

1. Démarrer **Apache** et **MySQL** dans XAMPP.
2. Copier `api-test/` dans `C:\xampp\htdocs\api-test`.
3. Copier `api-test/.env.example` en `api-test/.env` si nécessaire (valeurs par défaut : `127.0.0.1`, base `api`, utilisateur `root`, mot de passe vide).
4. Importer `api-test/api.sql` dans la base `api` via `http://localhost/phpmyadmin`.
5. Lancer l'application :

   ```bash
   cd cv_flutter_tp2
   flutter create .
   flutter pub get
   flutter run -d windows
   ```

## Endpoints de l'API

| Méthode | Route | Description |
| --- | --- | --- |
| GET | `/api-test/public/health` | Vérification de l'API et de la base |
| POST | `/api-test/public/accounts/register` | Inscription |
| POST | `/api-test/public/accounts/login` | Connexion |
| GET | `/api-test/public/famille-membres` | Liste (recherche `?q=`, filtre `?parente=`) |
| GET | `/api-test/public/famille-membres/stats` | Statistiques du tableau de bord |
| GET | `/api-test/public/famille-membres/{id}` | Détail d'un membre |
| POST | `/api-test/public/famille-membres` | Ajout |
| PUT | `/api-test/public/famille-membres/{id}` | Modification |
| DELETE | `/api-test/public/famille-membres/{id}` | Suppression |

## Aperçu

Les 10 captures sont disponibles dans le dossier [`captures/`](./captures).

## Auteur

**ekangacarine3-oss** — ISIG GOMA
