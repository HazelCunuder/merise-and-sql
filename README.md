# NetStream : Base de données Streaming

Dans le cadre de la création d'une plateforme de streaming cinématographique, ce projet constitue la première brique : **la conception et la création de la base de données relationnelle**.

Ce dépôt inclut la modélisation MERISE, le dictionnaire de données, les scripts SQL de création (avec triggers et procédures stockées) ainsi que le jeu d'essai.

## 📚 Documentation et Livrables

Tous les documents de conception sont disponibles dans le dossier `docs/` :
- [Règles de gestion](./docs/regles_gestion.md)
- [Dictionnaire de données](./docs/dictionnaire_donnees.md)
- [Modèle Conceptuel de Données (MCD)](./docs/MCD%20NetStream.png)
- [Modèle Logique de Données (MLD)](./docs/MLD%20Netstream.png)
- [Modèle Physique de Données (MPD)](./docs/MPD%20Netstream.png)
- [Benchmark & Choix du SGBDR](./docs/benchmark_sgbdr.md)

---

## ⚙️ Installation et Configuration

La base de données est conçue pour fonctionner sous **PostgreSQL**.

### Prérequis
- Avoir PostgreSQL d'installé sur sa machine.
- Avoir un client SQL (comme pgAdmin, DBeaver ou psql en ligne de commande).

### Étape 1 : Création et importation
Le fichier `netstream_database.sql` contient tout le nécessaire : création du schéma, création des tables, des procédures stockées, des triggers, et l'insertion des données de démonstration.

En ligne de commande :
```bash
# Se connecter à postgres et exécuter le script
psql -U postgres -f netstream_database.sql
```
*Note : Le script supprime et recrée le schéma `netstream` automatiquement.*

### Étape 2 : Vérification
Vous pouvez tester le bon fonctionnement de la base avec le fichier contenant les requêtes :
```bash
psql -U postgres -d postgres -f netstream_queries.sql
```

---

## 🔍 Jeu de Requêtes

Voici les requêtes demandées, testables sur la base de données. Vous pouvez également retrouver ce code dans le fichier `netstream_queries.sql`.

### 1. Titres et dates de sortie des films du plus récent au plus ancien
```sql
SELECT nom, date_sortie
FROM film
ORDER BY date_sortie DESC;
```

### 2. Noms, prénoms et âges des acteurs/actrices de plus de 30 ans dans l'ordre alphabétique
```sql
SELECT nom, prenom,
       EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_naissance)) AS age
FROM intervenant
WHERE EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_naissance)) > 30
ORDER BY nom ASC, prenom ASC;
```

### 3. Liste des acteurs/actrices principaux pour un film donné (ex: 'Inception')
```sql
SELECT i.nom, i.prenom, r.nom_role
FROM casting c
JOIN intervenant i ON i.id_intervenant = c.id_intervenant
JOIN role r ON r.id_role = c.id_role
JOIN film f ON f.id_film = c.id_film
WHERE f.nom = 'Inception'
ORDER BY i.nom, i.prenom;
```

### 4. Liste des films pour un acteur/actrice donné (ex: 'Leonardo DiCaprio')
```sql
SELECT f.nom, f.date_sortie
FROM casting c
JOIN film f ON f.id_film = c.id_film
JOIN intervenant i ON i.id_intervenant = c.id_intervenant
WHERE i.nom = 'DiCaprio' AND i.prenom = 'Leonardo'
ORDER BY f.date_sortie DESC;
```

### 5. Ajouter un film
```sql
INSERT INTO film(nom, date_sortie, duree)
VALUES ('The Matrix', '1999-03-31', 136);
```

### 6. Ajouter un acteur/actrice
```sql
INSERT INTO intervenant(nom, prenom, date_naissance, date_ajout, genre, nationalite)
VALUES ('Watson', 'Emma', '1990-04-15', CURRENT_DATE, 'F', 'Américaine');
```

### 7. Modifier un film
```sql
UPDATE film
SET duree = 150
WHERE nom = 'Inception';
```

### 8. Supprimer un acteur/actrice
```sql
DELETE FROM intervenant
WHERE nom = 'Watson' AND prenom = 'Emma';
```

### 9. Afficher les 3 derniers acteurs/actrices ajouté(e)s
```sql
SELECT nom, prenom, date_ajout
FROM intervenant
ORDER BY date_ajout DESC, id_intervenant DESC
LIMIT 3;
```

---

## 🚀 Manipulations avancées (Procédures et Triggers)

### 10. Lister grâce à une procédure stockée les films d'un réalisateur donné
```sql
-- Exemple avec Quentin Tarantino
CALL lister_films_d_un_realisateur('Tarantino', 'Quentin');
```

### 11. Opérations de CRUD via procédure pour ajouter un acteur au sein d'un film
Cette procédure permet d'ajouter un intervenant en base et de l'affecter directement au casting d'un film existant, en lui attribuant un rôle ('Acteur' par défaut).
```sql
CALL ajouter_acteur_au_film(
    'Depp', 'Johnny', '1963-06-09', 'M', 'Américaine', 'Once Upon a Time in Hollywood', 'Acteur'
);
```

### 12. Trigger de trace de modification sur les utilisateurs
Toute modification sur la table `utilisateur` déclenche l'enregistrement de l'ancienne et de la nouvelle valeur dans `utilisateur_archive`.

Exemple pour déclencher l'audit :
```sql
UPDATE utilisateur
SET email = 'nouvel.email@example.com'
WHERE id_utilisateur = 1;

-- Vérification de l'archive
SELECT * FROM utilisateur_archive;
```