-- Titres et dates de sortie des films du plus récent au plus ancien
SELECT nom, date_sortie
FROM film
ORDER BY date_sortie DESC;

-- Noms, prénoms et âges des acteurs/actrices de plus de 30 ans, dans l'ordre alphabétique
SELECT nom, prenom,
       EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_naissance)) AS age
FROM intervenant
WHERE EXTRACT(YEAR FROM AGE(CURRENT_DATE, date_naissance)) > 30
ORDER BY nom ASC, prenom ASC;

-- Liste des acteurs/actrices principaux pour un film donné
SELECT i.nom, i.prenom, r.nom_role
FROM casting c
JOIN intervenant i ON i.id_intervenant = c.id_intervenant
JOIN role r ON r.id_role = c.id_role
JOIN film f ON f.id_film = c.id_film
WHERE f.nom = 'Inception'
ORDER BY i.nom, i.prenom;

-- Liste des films pour un acteur/actrice donné
SELECT f.nom, f.date_sortie
FROM casting c
JOIN film f ON f.id_film = c.id_film
JOIN intervenant i ON i.id_intervenant = c.id_intervenant
WHERE i.nom = 'DiCaprio' AND i.prenom = 'Leonardo'
ORDER BY f.date_sortie DESC;

-- Ajouter un film
INSERT INTO film(nom, date_sortie, duree)
VALUES ('The Matrix', '1999-03-31', 136);

-- Ajouter un acteur/actrice
INSERT INTO intervenant(nom, prenom, date_naissance, date_ajout, genre, nationalite)
VALUES ('Watson', 'Emma', '1990-04-15', CURRENT_DATE, 'F', 'Américaine');

-- Modifier un film
UPDATE film
SET duree = 150
WHERE nom = 'Inception';

-- Supprimer un acteur/actrice
DELETE FROM intervenant
WHERE nom = 'Watson' AND prenom = 'Emma';

-- Afficher les 3 derniers acteurs/actrices ajoutés
SELECT nom, prenom, date_ajout
FROM intervenant
ORDER BY date_ajout DESC, id_intervenant DESC
LIMIT 3;

-- Procédure stockée : lister les films d'un réalisateur donné
CALL lister_films_d_un_realisateur('Tarantino', 'Quentin');

-- Procédure stockée : ajouter un acteur au sein d'un film
CALL ajouter_acteur_au_film(
    'Depp', 'Johnny', '1963-06-09', 'M', 'Américaine', 'Once Upon a Time in Hollywood', 'Acteur'
);

-- Déclencheur de trace d'audit sur les mises à jour des utilisateurs
UPDATE utilisateur
SET email = 'nouvel.email@example.com'
WHERE id_utilisateur = 1;

SELECT * FROM utilisateur_archive;
