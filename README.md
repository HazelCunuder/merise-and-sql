# NetStream - Projet Merise et SQL

Projet de base de données relationnelle pour une plateforme de streaming de films, conçu selon la méthode Merise et implémenté avec PostgreSQL.

## 📋 Description

NetStream est une base de données permettant de gérer :
- Un catalogue de films avec leurs genres
- Les intervenants (acteurs, réalisateurs, scénaristes, producteurs)
- Les utilisateurs et leurs préférences (films favoris, intervenants favoris)
- Le casting des films (association intervenant/rôle/film)
- Un système d'audit pour tracer les modifications des utilisateurs

## 🗂️ Structure du projet

```
merise-and-sql/
├── docs/
│   ├── MCD NetStream.png          # Modèle Conceptuel de Données
│   ├── MLD Netstream.png          # Modèle Logique de Données
│   ├── MPD Netstream.png          # Modèle Physique de Données
│   ├── regles_gestion.md          # Règles de gestion du projet
│   ├── installation_configuration.md  # Guide d'installation
│   └── choix_sgbd.md              # Justification du choix PostgreSQL
├── netstream_database.sql         # Schéma complet + données de test
├── netstream_queries.sql          # Requêtes exemple
└── README.md                      # Ce fichier
```

## 🚀 Installation

Consultez le [guide d'installation et de configuration](docs/installation_configuration.md) pour :
- Installer PostgreSQL
- Configurer la base de données
- Importer le schéma et les données
- Exécuter les requêtes exemple

## 📚 Documentation

- **[Règles de gestion](docs/regles_gestion.md)** : Définition des règles métier
- **[Installation et configuration](docs/installation_configuration.md)** : Guide pas à pas
- **[Choix du SGBD](docs/choix_sgbd.md)** : Justification de PostgreSQL
- **[Diagrammes Merise](docs/)** : MCD, MLD, MPD

## 🗄️ Schéma de la base de données

### Tables principales

- **genre** : Catalogue des genres de films
- **role** : Types de rôles (acteur, actrice, réalisateur, scénariste, producteur)
- **intervenant** : Acteurs, réalisateurs, scénaristes
- **film** : Catalogue des films
- **utilisateur** : Utilisateurs de la plateforme
- **casting** : Association intervenant/rôle/film
- **definir_genre** : Association film/genre
- **film_favori** : Films favoris des utilisateurs
- **appreciation** : Intervenants favoris des utilisateurs
- **utilisateur_archive** : Historique des modifications utilisateurs

### Fonctionnalités avancées

- **Trigger** : `audit_utilisateur_modification` - Trace automatiquement les modifications des utilisateurs
- **Procédure stockée** : `lister_films_d_un_realisateur` - Liste les films d'un réalisateur
- **Procédure stockée** : `ajouter_acteur_au_film` - Ajoute un acteur à un film

## 💡 Exemples de requêtes

Le fichier `netstream_queries.sql` contient des exemples de requêtes :

- Liste des films triés par date de sortie
- Liste des acteurs de plus de 30 ans
- Casting d'un film spécifique
- Filmographie d'un acteur
- Ajout/modification/suppression de données
- Appel de procédures stockées
- Test du trigger d'audit

## 🛠️ Technologies

- **SGBD** : PostgreSQL 12+
- **Langage** : SQL (PL/pgSQL)
- **Méthodologie** : Merise (MCD, MLD, MPD)

## 📝 Auteurs

Projet réalisé dans le cadre d'une formation Développement IA.

## 📄 Licence

Ce projet est à but éducatif.