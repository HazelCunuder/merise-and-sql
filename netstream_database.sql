BEGIN;

DROP SCHEMA IF EXISTS netstream CASCADE;
CREATE SCHEMA netstream;
SET search_path TO netstream, public;


CREATE TABLE genre (
    id_genre       SERIAL PRIMARY KEY,
    nom_genre      VARCHAR(255) NOT NULL UNIQUE,
    date_creation  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    date_modification TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE role (
    id_role        SERIAL PRIMARY KEY,
    nom_role       VARCHAR(50) NOT NULL UNIQUE,
    date_creation  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    date_modification TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE intervenant (
    id_intervenant SERIAL PRIMARY KEY,
    nom            VARCHAR(255) NOT NULL,
    prenom         VARCHAR(255) NOT NULL,
    date_naissance DATE NOT NULL,
    date_ajout     DATE NOT NULL DEFAULT CURRENT_DATE,
    genre          VARCHAR(2) NOT NULL,
    nationalite    VARCHAR(255) NOT NULL,
    date_creation  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    date_modification TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT ck_intervenant_genre
        CHECK (genre IN ('M', 'F', 'NB'))
);

CREATE TABLE utilisateur (
    id_utilisateur   SERIAL PRIMARY KEY,
    nom_utilisateur  VARCHAR(100) NOT NULL,
    prenom_utilisateur VARCHAR(100) NOT NULL,
    email            VARCHAR(255) NOT NULL UNIQUE,
    mot_de_passe     VARCHAR(255) NOT NULL,
    date_inscription DATE NOT NULL DEFAULT CURRENT_DATE,
    date_creation    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    date_modification TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE utilisateur_archive (
    id_archive        SERIAL PRIMARY KEY,
    id_utilisateur    INTEGER NOT NULL,
    colonne           VARCHAR(100) NOT NULL,
    ancienne_valeur   VARCHAR(255),
    nouvelle_valeur   VARCHAR(255),
    date_modification TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_utilisateur_archive_utilisateur
        FOREIGN KEY (id_utilisateur)
        REFERENCES utilisateur(id_utilisateur)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE film (
    id_film       SERIAL PRIMARY KEY,
    nom           VARCHAR(100) NOT NULL,
    date_sortie   DATE NOT NULL,
    duree         INTEGER NOT NULL,
    date_creation TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    date_modification TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT ck_film_duree CHECK (duree >= 0)
);

CREATE TABLE casting (
    id_intervenant INTEGER NOT NULL,
    id_role        INTEGER NOT NULL,
    id_film        INTEGER NOT NULL,
    date_creation  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    date_modification TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (id_intervenant, id_role, id_film),

    CONSTRAINT fk_casting_intervenant
        FOREIGN KEY (id_intervenant)
        REFERENCES intervenant(id_intervenant)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_casting_role
        FOREIGN KEY (id_role)
        REFERENCES role(id_role)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_casting_film
        FOREIGN KEY (id_film)
        REFERENCES film(id_film)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE definir_genre (
    id_film   INTEGER NOT NULL,
    id_genre  INTEGER NOT NULL,
    date_creation TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    date_modification TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (id_film, id_genre),

    CONSTRAINT fk_definir_genre_film
        FOREIGN KEY (id_film)
        REFERENCES film(id_film)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_definir_genre_genre
        FOREIGN KEY (id_genre)
        REFERENCES genre(id_genre)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

CREATE TABLE film_favori (
    id_utilisateur INTEGER NOT NULL,
    id_film        INTEGER NOT NULL,
    note           INTEGER,
    favori         BOOLEAN NOT NULL DEFAULT TRUE,
    date_creation  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    date_modification TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (id_utilisateur, id_film),

    CONSTRAINT fk_film_favori_utilisateur
        FOREIGN KEY (id_utilisateur)
        REFERENCES utilisateur(id_utilisateur)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_film_favori_film
        FOREIGN KEY (id_film)
        REFERENCES film(id_film)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT ck_film_favori_note
        CHECK (note IS NULL OR note BETWEEN 0 AND 10)
);

CREATE TABLE appreciation (
    id_utilisateur INTEGER NOT NULL,
    id_intervenant INTEGER NOT NULL,
    note           INTEGER,
    favori         BOOLEAN NOT NULL DEFAULT TRUE,
    date_creation  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    date_modification TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (id_utilisateur, id_intervenant),

    CONSTRAINT fk_appreciation_utilisateur
        FOREIGN KEY (id_utilisateur)
        REFERENCES utilisateur(id_utilisateur)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_appreciation_intervenant
        FOREIGN KEY (id_intervenant)
        REFERENCES intervenant(id_intervenant)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT ck_appreciation_note
        CHECK (note IS NULL OR note BETWEEN 0 AND 10)
);

CREATE OR REPLACE FUNCTION audit_utilisateur_modification()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'UPDATE' THEN
        IF OLD.nom_utilisateur IS DISTINCT FROM NEW.nom_utilisateur THEN
            INSERT INTO utilisateur_archive(id_utilisateur, colonne, ancienne_valeur, nouvelle_valeur)
            VALUES (NEW.id_utilisateur, 'nom_utilisateur', OLD.nom_utilisateur, NEW.nom_utilisateur);
        END IF;

        IF OLD.prenom_utilisateur IS DISTINCT FROM NEW.prenom_utilisateur THEN
            INSERT INTO utilisateur_archive(id_utilisateur, colonne, ancienne_valeur, nouvelle_valeur)
            VALUES (NEW.id_utilisateur, 'prenom_utilisateur', OLD.prenom_utilisateur, NEW.prenom_utilisateur);
        END IF;

        IF OLD.email IS DISTINCT FROM NEW.email THEN
            INSERT INTO utilisateur_archive(id_utilisateur, colonne, ancienne_valeur, nouvelle_valeur)
            VALUES (NEW.id_utilisateur, 'email', OLD.email, NEW.email);
        END IF;

        IF OLD.mot_de_passe IS DISTINCT FROM NEW.mot_de_passe THEN
            INSERT INTO utilisateur_archive(id_utilisateur, colonne, ancienne_valeur, nouvelle_valeur)
            VALUES (NEW.id_utilisateur, 'mot_de_passe', OLD.mot_de_passe, NEW.mot_de_passe);
        END IF;

        NEW.date_modification := CURRENT_TIMESTAMP;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trg_audit_utilisateur_update
BEFORE UPDATE ON utilisateur
FOR EACH ROW
EXECUTE FUNCTION audit_utilisateur_modification();

CREATE OR REPLACE PROCEDURE lister_films_d_un_realisateur(p_nom VARCHAR, p_prenom VARCHAR)
LANGUAGE plpgsql
AS $$
DECLARE
    film_data RECORD;
BEGIN
    FOR film_data IN
        SELECT f.nom AS nom_film, f.date_sortie
        FROM film f
        JOIN casting c ON c.id_film = f.id_film
        JOIN role r ON r.id_role = c.id_role
        JOIN intervenant i ON i.id_intervenant = c.id_intervenant
        WHERE r.nom_role = 'Réalisateur'
          AND i.nom = p_nom
          AND i.prenom = p_prenom
        ORDER BY f.date_sortie DESC
    LOOP
        RAISE NOTICE 'Film: %, sortie: %', film_data.nom_film, film_data.date_sortie;
    END LOOP;
END;
$$;

CREATE OR REPLACE PROCEDURE ajouter_acteur_au_film(
    p_nom VARCHAR,
    p_prenom VARCHAR,
    p_date_naissance DATE,
    p_genre VARCHAR,
    p_nationalite VARCHAR,
    p_nom_film VARCHAR,
    p_nom_role VARCHAR DEFAULT 'Acteur'
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_id_film INTEGER;
    v_id_role INTEGER;
    v_id_intervenant INTEGER;
BEGIN
    SELECT id_film INTO v_id_film FROM film WHERE nom = p_nom_film;
    IF v_id_film IS NULL THEN
        RAISE EXCEPTION 'Film inconnu: %', p_nom_film;
    END IF;

    SELECT id_role INTO v_id_role FROM role WHERE nom_role = p_nom_role;
    IF v_id_role IS NULL THEN
        RAISE EXCEPTION 'Rôle inconnu: %', p_nom_role;
    END IF;

    INSERT INTO intervenant(nom, prenom, date_naissance, genre, nationalite)
    VALUES (p_nom, p_prenom, p_date_naissance, p_genre, p_nationalite)
    RETURNING id_intervenant INTO v_id_intervenant;

    INSERT INTO casting(id_intervenant, id_role, id_film)
    VALUES (v_id_intervenant, v_id_role, v_id_film);
END;
$$;


INSERT INTO genre (nom_genre) VALUES
('Action'),
('Comédie'),
('Drame'),
('Science-fiction'),
('Thriller'),
('Horreur'),
('Animation'),
('Aventure'),
('Fantastique'),
('Documentaire');

INSERT INTO role (nom_role) VALUES
('Acteur'),
('Actrice'),
('Réalisateur'),
('Scénariste'),
('Producteur');

INSERT INTO utilisateur
(nom_utilisateur, prenom_utilisateur, email, mot_de_passe, date_inscription)
VALUES
('Dupont', 'Lucas', 'lucas.dupont@example.com', 'demo_hash_01', '2026-01-15'),
('Martin', 'Emma', 'emma.martin@example.com', 'demo_hash_02', '2026-02-20'),
('Bernard', 'Hugo', 'hugo.bernard@example.com', 'demo_hash_03', '2026-03-05'),
('Robert', 'Chloe', 'chloe.robert@example.com', 'demo_hash_04', '2026-04-12');

INSERT INTO intervenant
(nom, prenom, date_naissance, date_ajout, genre, nationalite)
VALUES
('Nolan', 'Christopher', '1970-07-30', '2026-01-10', 'M', 'Britannique'),
('DiCaprio', 'Leonardo', '1974-11-11', '2026-01-11', 'M', 'Américaine'),
('Robbie', 'Margot', '1990-07-02', '2026-01-12', 'F', 'Australienne'),
('Villeneuve', 'Denis', '1967-10-03', '2026-01-13', 'M', 'Canadienne'),
('Portman', 'Natalie', '1981-06-09', '2026-01-14', 'F', 'Britannique'),
('Tarantino', 'Quentin', '1963-03-27', '2026-01-16', 'M', 'Américaine'),
('Blanchett', 'Cate', '1969-05-14', '2026-01-17', 'F', 'Australienne'),
('Spielberg', 'Steven', '1946-12-18', '2026-01-18', 'M', 'Américaine'),
('Hanks', 'Tom', '1956-07-09', '2026-01-19', 'M', 'Américaine'),
('Johansson', 'Scarlett', '1984-11-22', '2026-01-20', 'F', 'Américaine');

INSERT INTO film (nom, date_sortie, duree) VALUES
('Inception', '2010-07-16', 148),
('Interstellar', '2014-11-07', 169),
('Dune', '2021-09-15', 155),
('Kill Bill', '2003-10-10', 111),
('Jurassic Park', '1993-06-11', 127),
('Forrest Gump', '1994-07-06', 142),
('Black Swan', '2010-12-03', 108),
('Once Upon a Time in Hollywood', '2019-07-26', 161);


INSERT INTO definir_genre (id_film, id_genre)
SELECT f.id_film, g.id_genre
FROM film f, genre g
WHERE (f.nom, g.nom_genre) IN (
    ('Inception', 'Science-fiction'),
    ('Inception', 'Thriller'),
    ('Interstellar', 'Science-fiction'),
    ('Interstellar', 'Aventure'),
    ('Dune', 'Science-fiction'),
    ('Dune', 'Aventure'),
    ('Kill Bill', 'Action'),
    ('Kill Bill', 'Thriller'),
    ('Jurassic Park', 'Aventure'),
    ('Jurassic Park', 'Science-fiction'),
    ('Forrest Gump', 'Drame'),
    ('Black Swan', 'Drame'),
    ('Black Swan', 'Thriller'),
    ('Once Upon a Time in Hollywood', 'Drame'),
    ('Once Upon a Time in Hollywood', 'Comédie')
);

INSERT INTO casting (id_intervenant, id_role, id_film)
SELECT i.id_intervenant, r.id_role, f.id_film
FROM intervenant i
CROSS JOIN role r
CROSS JOIN film f
WHERE (i.nom, i.prenom, r.nom_role, f.nom) IN (
    ('Nolan', 'Christopher', 'Réalisateur', 'Inception'),
    ('Nolan', 'Christopher', 'Réalisateur', 'Interstellar'),
    ('Villeneuve', 'Denis', 'Réalisateur', 'Dune'),
    ('Tarantino', 'Quentin', 'Réalisateur', 'Kill Bill'),
    ('Spielberg', 'Steven', 'Réalisateur', 'Jurassic Park'),
    ('Tarantino', 'Quentin', 'Réalisateur', 'Once Upon a Time in Hollywood')
);

INSERT INTO casting (id_intervenant, id_role, id_film)
SELECT i.id_intervenant, r.id_role, f.id_film
FROM intervenant i
CROSS JOIN role r
CROSS JOIN film f
WHERE (i.nom, i.prenom, r.nom_role, f.nom) IN (
    ('DiCaprio', 'Leonardo', 'Acteur', 'Inception'),
    ('DiCaprio', 'Leonardo', 'Acteur', 'Once Upon a Time in Hollywood'),
    ('Robbie', 'Margot', 'Actrice', 'Once Upon a Time in Hollywood'),
    ('Portman', 'Natalie', 'Actrice', 'Black Swan'),
    ('Blanchett', 'Cate', 'Actrice', 'Dune'),
    ('Hanks', 'Tom', 'Acteur', 'Forrest Gump'),
    ('Johansson', 'Scarlett', 'Actrice', 'Jurassic Park')
);

INSERT INTO film_favori (id_utilisateur, id_film, note, favori)
SELECT u.id_utilisateur, f.id_film, x.note, TRUE
FROM (
    VALUES
        ('lucas.dupont@example.com', 'Inception', 9),
        ('lucas.dupont@example.com', 'Interstellar', 10),
        ('emma.martin@example.com', 'Dune', 9),
        ('hugo.bernard@example.com', 'Forrest Gump', 10),
        ('chloe.robert@example.com', 'Black Swan', 8)
) AS x(email, film_nom, note)
JOIN utilisateur u ON u.email = x.email
JOIN film f ON f.nom = x.film_nom;

INSERT INTO appreciation (id_utilisateur, id_intervenant, note, favori)
SELECT u.id_utilisateur, i.id_intervenant, x.note, TRUE
FROM (
    VALUES
        ('lucas.dupont@example.com', 'DiCaprio', 'Leonardo', 10),
        ('emma.martin@example.com', 'Robbie', 'Margot', 9),
        ('hugo.bernard@example.com', 'Hanks', 'Tom', 10),
        ('chloe.robert@example.com', 'Portman', 'Natalie', 9)
) AS x(email, nom, prenom, note)
JOIN utilisateur u ON u.email = x.email
JOIN intervenant i ON i.nom = x.nom AND i.prenom = x.prenom;

COMMIT;