# Choix du SGBDR : PostgreSQL (Benchmark)

Pour la conception et le déploiement de la base de données NetStream, le choix du Système de Gestion de Base de Données Relationnelle (SGBDR) s'est porté sur **PostgreSQL**.

Voici les raisons justifiant ce choix par rapport aux alternatives comme MySQL, SQLite ou les bases NoSQL (non autorisées selon les contraintes).

## 1. Respect du Modèle Relationnel (ACID)
PostgreSQL est réputé pour sa stricte conformité aux standards SQL et sa robustesse quant au respect des propriétés ACID (Atomicité, Cohérence, Isolation, Durabilité).
Dans le contexte de NetStream, où des données critiques comme la gestion des utilisateurs, les favoris et les castings croisent de multiples tables, la cohérence des données est essentielle.

## 2. Fonctionnalités Avancées (Procédures stockées et Triggers)
Le cahier des charges exige la mise en place de **déclencheurs (triggers)** pour l'historisation (table d'archive des utilisateurs) et de **procédures stockées** pour des requêtes complexes (comme l'ajout d'un acteur à un film).
PostgreSQL propose le langage `PL/pgSQL`, un langage procédural extrêmement puissant, expressif et natif pour écrire ces procédures et triggers avec une grande facilité et sécurité par rapport aux autres SGBDR Open Source.

## 3. Gestion des Contraintes Complexes
L'intégrité de la base de données NetStream repose sur de nombreuses contraintes :
- `CHECK` sur les durées de film (>= 0)
- `CHECK` sur les genres (M, F, NB)
- `CHECK` sur les notes (0 à 10)
PostgreSQL gère les contraintes `CHECK` de manière native et très performante, garantissant qu'aucune donnée incohérente ne peut être insérée en base, y compris via les contraintes de clés étrangères `ON DELETE CASCADE`.

## 4. Performance sur les requêtes complexes (Jointures multiples)
NetStream nécessite de lier des Intervenants, des Films, et des Rôles (Table de jonction `casting`). Les requêtes demandées font parfois appel à 3 ou 4 jointures simultanées (ex: "Liste des acteurs/actrices principaux pour un film donné"). L'optimiseur de requêtes (Query Planner) de PostgreSQL est l'un des plus performants du marché pour les jointures complexes sur de forts volumes de données.

## 5. Extensibilité et Open Source
PostgreSQL est 100% Open Source et libre (licence PostgreSQL). Il n'entraîne aucun coût de licence pour un projet de cette envergure tout en offrant des performances de niveau "Enterprise".

---
**En conclusion**, bien que MySQL soit plus populaire pour de petits sites web simples, les exigences de procédures stockées, de triggers d'audit et la robustesse des contraintes de NetStream rendent PostgreSQL incontournable comme meilleur candidat.
