# Guide d'installation et de configuration — NetStream

## Prérequis

- **PostgreSQL** (version 12 ou supérieure)
- **pgAdmin** (optionnel, pour l'interface graphique)
- Accès administrateur à la base de données

## Installation de PostgreSQL

### Windows
1. Télécharger PostgreSQL depuis [https://www.postgresql.org/download/windows/](https://www.postgresql.org/download/windows/)
2. Exécuter l'installateur
3. Choisir un mot de passe pour l'utilisateur `postgres`
4. Conserver les ports par défaut (5432)
5. Installer pgAdmin (recommandé)

### Linux (Ubuntu/Debian)
```bash
sudo apt update
sudo apt install postgresql postgresql-contrib
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

### macOS
```bash
brew install postgresql
brew services start postgresql
```

## Configuration de la base de données

### 1. Connexion au serveur PostgreSQL

**Via pgAdmin :**
- Ouvrir pgAdmin
- Créer une nouvelle connexion au serveur
- Host: `localhost`
- Port: `5432`
- Utilisateur: `postgres`
- Mot de passe: celui défini lors de l'installation

**Via ligne de commande :**
```bash
psql -U postgres
```

### 2. Création de la base de données

Option 1 : Via pgAdmin
- Clic droit sur "Databases" → "Create" → "Database"
- Nom: `netstream_db`

Option 2 : Via SQL
```sql
CREATE DATABASE netstream_db;
```

### 3. Importation du schéma et des données

**Via pgAdmin :**
1. Ouvrir l'éditeur SQL (Query Tool)
2. Ouvrir le fichier `netstream_database.sql`
3. Exécuter le script (F5 ou clic sur "Execute")

**Via ligne de commande :**
```bash
psql -U postgres -d netstream_db -f netstream_database.sql
```

### 4. Vérification de l'installation

Exécuter les requêtes suivantes pour vérifier :

```sql
-- Vérifier que le schéma existe
SELECT schema_name 
FROM information_schema.schemata 
WHERE schema_name = 'netstream';

-- Vérifier les tables
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'netstream'
ORDER BY table_name;

-- Vérifier les données
SELECT COUNT(*) FROM netstream.film;
SELECT COUNT(*) FROM netstream.intervenant;
SELECT COUNT(*) FROM netstream.utilisateur;
```

## Exécution des requêtes exemple

Le fichier `netstream_queries.sql` contient des exemples de requêtes.

**Via pgAdmin :**
- Ouvrir le fichier `netstream_queries.sql`
- Exécuter les requêtes une par une ou en bloc

**Via ligne de commande :**
```bash
psql -U postgres -d netstream_db -f netstream_queries.sql
```

## Structure de la base de données

### Tables principales

- **genre** : Catalogue des genres de films
- **role** : Types de rôles (acteur, réalisateur, etc.)
- **intervenant** : Acteurs, réalisateurs, scénaristes
- **film** : Catalogue des films
- **utilisateur** : Utilisateurs de la plateforme
- **casting** : Association intervenant/rôle/film
- **definir_genre** : Association film/genre
- **film_favori** : Films favoris des utilisateurs
- **appreciation** : Intervenants favoris des utilisateurs
- **utilisateur_archive** : Historique des modifications utilisateurs

### Fonctionnalités avancées

- **Trigger** : `audit_utilisateur_modification` - Trace les modifications des utilisateurs
- **Procédure** : `lister_films_d_un_realisateur` - Liste les films d'un réalisateur
- **Procédure** : `ajouter_acteur_au_film` - Ajoute un acteur à un film

## Dépannage

### Erreur "relation does not exist"
Vérifier que le schéma `netstream` est bien dans le search_path :
```sql
SET search_path TO netstream, public;
```

### Erreur de connexion
Vérifier que le service PostgreSQL est démarré :
- Windows: Services PostgreSQL
- Linux: `sudo systemctl status postgresql`
- macOS: `brew services list`

### Permissions
Si nécessaire, accorder les permissions :
```sql
GRANT ALL PRIVILEGES ON DATABASE netstream_db TO postgres;
GRANT ALL PRIVILEGES ON SCHEMA netstream TO postgres;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA netstream TO postgres;
```

## Sauvegarde et restauration

### Sauvegarde
```bash
pg_dump -U postgres -d netstream_db > netstream_backup.sql
```

### Restauration
```bash
psql -U postgres -d netstream_db < netstream_backup.sql
```

## Ressources utiles

- [Documentation PostgreSQL](https://www.postgresql.org/docs/)
- [Documentation pgAdmin](https://www.pgadmin.org/docs/)
- [Diagrammes Merise](./) - MCD, MLD, MPD dans le dossier `docs`
- [Règles de gestion](./regles_gestion.md)
