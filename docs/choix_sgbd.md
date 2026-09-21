# Choix du SGBD — NetStream

## SGBD sélectionné : PostgreSQL

Pour le projet NetStream, nous avons choisi **PostgreSQL** comme système de gestion de base de données relationnelle (SGBDR).

## Justification du choix

### 1. Conformité aux standards SQL

PostgreSQL est hautement conforme au standard SQL ANSI/ISO, ce qui garantit :
- Portabilité du code SQL
- Compatibilité avec d'autres systèmes relationnels
- Utilisation de syntaxes standardisées (JOIN, sous-requêtes, etc.)

### 2. Fonctionnalités avancées nécessaires au projet

Le projet NetStream nécessite des fonctionnalités que PostgreSQL offre nativement :

#### Triggers et procédures stockées
- **Triggers** : Implémentation du système d'audit pour la table `utilisateur_archive`
- **Procédures stockées** : `lister_films_d_un_realisateur` et `ajouter_acteur_au_film`
- **Langage PL/pgSQL** : Support natif pour la logique procédurale

#### Contraintes complexes
- **CHECK** : Validation des données (âge, notes, durée)
- **FOREIGN KEY** : Intégrité référentielle avec options CASCADE/RESTRICT
- **UNIQUE** : Garantie d'unicité (email, nom_genre, nom_role)

#### Types de données avancés
- **SERIAL** : Auto-incrémentation des identifiants
- **TIMESTAMP** : Gestion précise des dates et heures
- **BOOLEAN** : Type natif pour les champs booléens
- **ARRAY** : Support des tableaux (utile pour extensions futures)

### 3. Robustesse et fiabilité

- **ACID** : Garantie de fiabilité des transactions (Atomicité, Cohérence, Isolation, Durabilité)
- **MVCC** : Multi-Version Concurrency Control pour une haute concurrence
- **Stabilité** : Réputé pour sa stabilité en production

### 4. Performance

- **Indexation avancée** : B-tree, Hash, GiST, GIN
- **Optimiseur de requêtes** sophistiqué
- **Support des jointures** complexes et performantes
- **Scalabilité** : Adapté aux bases de données de taille moyenne à grande

### 5. Extensibilité

PostgreSQL est extensible, ce qui permet d'ajouter :
- Fonctions personnalisées
- Types de données personnalisés
- Extensions (PostGIS, pgcrypto, etc.)

Cette extensibilité est un atout pour l'évolution future de NetStream.

### 6. Open source et gratuit

- **Licence PostgreSQL** : Libre et open source (BSD-like)
- **Coût total de possession** : Réduit comparé aux solutions propriétaires
- **Communauté active** : Support, documentation, mises à jour régulières

### 7. Outils et écosystème

- **pgAdmin** : Interface graphique puissante et intuitive
- **psql** : Client en ligne de commande complet
- **Drivers** : Disponibles pour tous les langages (Python, Java, Node.js, PHP, etc.)
- **ORM** : Support natif par la plupart des ORM modernes

## Alternatives considérées et raisons du rejet

### MySQL / MariaDB
**Rejet pour :**
- Moins conforme au standard SQL
- Historiquement moins performant sur les requêtes complexes
- Support des triggers et procédures stockées moins avancé

### SQLite
**Rejet pour :**
- Base de données embarquée, non adaptée à un environnement multi-utilisateur
- Pas de support natif pour les triggers complexes
- Limitations sur les types de données

### Microsoft SQL Server
**Rejet pour :**
- Solution propriétaire (coût élevé)
- Dépendance à l'écosystème Microsoft
- Surdimensionné pour les besoins actuels du projet

### Oracle Database
**Rejet pour :**
- Solution propriétaire très coûteuse
- Complexité excessive pour le projet
- Courbe d'apprentissage plus difficile

## Conclusion

PostgreSQL s'impose comme le choix optimal pour NetStream en raison de :
- Sa conformité aux standards
- Ses fonctionnalités avancées (triggers, procédures stockées)
- Sa robustesse et ses performances
- Son caractère open source
- Son écosystème riche

Ce choix garantit une base de données fiable, performante et évolutive pour la plateforme de streaming NetStream.
