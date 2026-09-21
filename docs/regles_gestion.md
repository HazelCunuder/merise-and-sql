# Règles de gestion — NetStream

## 1. Catalogues

- Un film appartient à un ou plusieurs genres.
- Un rôle est un libellé de type acteur, actrice, réalisateur, scénariste, producteur.
- Un intervenant peut participer à plusieurs films et tenir plusieurs rôles dans le même film.

## 2. Utilisateurs

- Un utilisateur a un identifiant unique, un e-mail unique, un nom et un prénom.
- Un utilisateur peut enregistrer un ou plusieurs films favoris.
- Un utilisateur peut enregistrer un ou plusieurs intervenants comme favoris.

## 3. Films

- Un film possède un titre, une date de sortie et une durée positive.
- Un film peut être lié à plusieurs genres.

## 4. Intervenants

- Un intervenant possède un nom, un prénom, une date de naissance, une nationalité et un genre.
- Un intervenant peut être impliqué dans plusieurs films et tenir différents rôles.

## 5. Déclencheurs et audit

- Toute modification d’un utilisateur entraîne une trace dans la table d’archive.
- La table d’archive conserve la date de modification, l’identifiant utilisateur, la colonne modifiée, l’ancienne valeur et la nouvelle valeur.
