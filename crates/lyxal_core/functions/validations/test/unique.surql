-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/unique.test.surql
-- Fonction     : fn::validation_unique
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW interrompent l'exécution du
-- bloc.
--
-- Dans Surrealist, sélectionner uniquement le test à exécuter lorsque celui-ci
-- attend une erreur.
--
-- Les tests utilisent la table validation_test_unique.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Préparation de la table de test
-- Résultat attendu : définition de validation_test_unique
-- ============================================================================

DEFINE TABLE OVERWRITE validation_test_unique SCHEMAFULL;

DEFINE FIELD OVERWRITE email
ON TABLE validation_test_unique
TYPE string;

DEFINE FIELD OVERWRITE slug
ON TABLE validation_test_unique
TYPE string;

DEFINE FIELD OVERWRITE profile
ON TABLE validation_test_unique
TYPE object;

DEFINE FIELD OVERWRITE profile.username
ON TABLE validation_test_unique
TYPE string;


-- ============================================================================
-- TEST 2 — Création des enregistrements de test
-- Résultat attendu : création de user_001 et user_002
-- ============================================================================

CREATE validation_test_unique:user_001 CONTENT {
    email: "first@example.com",
    slug: "first-user",
    profile: {
        username: "first"
    }
};

CREATE validation_test_unique:user_002 CONTENT {
    email: "second@example.com",
    slug: "second-user",
    profile: {
        username: "second"
    }
};


-- ============================================================================
-- TEST 3 — Adresse e-mail disponible
-- Résultat attendu : "available@example.com"
-- ============================================================================

RETURN fn::validation_unique(
    "available@example.com",
    "USER_EMAIL",
    "validation_test_unique",
    "email",
    NONE
);


-- ============================================================================
-- TEST 4 — Slug disponible
-- Résultat attendu : "available-user"
-- ============================================================================

RETURN fn::validation_unique(
    "available-user",
    "USER_SLUG",
    "validation_test_unique",
    "slug",
    NONE
);


-- ============================================================================
-- TEST 5 — Valeur déjà existante lors d'une création
-- Erreur attendue : USER_EMAIL_ALREADY_EXISTS
-- ============================================================================

RETURN fn::validation_unique(
    "first@example.com",
    "USER_EMAIL",
    "validation_test_unique",
    "email",
    NONE
);


-- ============================================================================
-- TEST 6 — Slug déjà existant lors d'une création
-- Erreur attendue : USER_SLUG_ALREADY_EXISTS
-- ============================================================================

RETURN fn::validation_unique(
    "first-user",
    "USER_SLUG",
    "validation_test_unique",
    "slug",
    NONE
);


-- ============================================================================
-- TEST 7 — Mise à jour en conservant sa propre adresse
-- Résultat attendu : "first@example.com"
-- ============================================================================

RETURN fn::validation_unique(
    "first@example.com",
    "USER_EMAIL",
    "validation_test_unique",
    "email",
    validation_test_unique:user_001
);


-- ============================================================================
-- TEST 8 — Mise à jour en conservant son propre slug
-- Résultat attendu : "first-user"
-- ============================================================================

RETURN fn::validation_unique(
    "first-user",
    "USER_SLUG",
    "validation_test_unique",
    "slug",
    validation_test_unique:user_001
);


-- ============================================================================
-- TEST 9 — Mise à jour avec l'adresse d'un autre enregistrement
-- Erreur attendue : USER_EMAIL_ALREADY_EXISTS
-- ============================================================================

RETURN fn::validation_unique(
    "second@example.com",
    "USER_EMAIL",
    "validation_test_unique",
    "email",
    validation_test_unique:user_001
);


-- ============================================================================
-- TEST 10 — Mise à jour avec le slug d'un autre enregistrement
-- Erreur attendue : USER_SLUG_ALREADY_EXISTS
-- ============================================================================

RETURN fn::validation_unique(
    "second-user",
    "USER_SLUG",
    "validation_test_unique",
    "slug",
    validation_test_unique:user_001
);


-- ============================================================================
-- TEST 11 — Validation d'un champ imbriqué disponible
-- Résultat attendu : "third"
-- ============================================================================

RETURN fn::validation_unique(
    "third",
    "USERNAME",
    "validation_test_unique",
    "profile.username",
    NONE
);


-- ============================================================================
-- TEST 12 — Validation d'un champ imbriqué déjà utilisé
-- Erreur attendue : USERNAME_ALREADY_EXISTS
-- ============================================================================

RETURN fn::validation_unique(
    "first",
    "USERNAME",
    "validation_test_unique",
    "profile.username",
    NONE
);


-- ============================================================================
-- TEST 13 — Champ imbriqué conservé pendant une mise à jour
-- Résultat attendu : "first"
-- ============================================================================

RETURN fn::validation_unique(
    "first",
    "USERNAME",
    "validation_test_unique",
    "profile.username",
    validation_test_unique:user_001
);


-- ============================================================================
-- TEST 14 — Valeur absente
-- Erreur attendue : USER_EMAIL_REQUIRED
-- ============================================================================

RETURN fn::validation_unique(
    NONE,
    "USER_EMAIL",
    "validation_test_unique",
    "email",
    NONE
);


-- ============================================================================
-- TEST 15 — Valeur NULL
-- Erreur attendue : USER_EMAIL_NULL_NOT_ALLOWED
-- ============================================================================

RETURN fn::validation_unique(
    NULL,
    "USER_EMAIL",
    "validation_test_unique",
    "email",
    NONE
);


-- ============================================================================
-- TEST 16 — Nom technique vide
-- Erreur attendue : VALIDATION_INVALID_FIELD_NAME
-- ============================================================================

RETURN fn::validation_unique(
    "available@example.com",
    "     ",
    "validation_test_unique",
    "email",
    NONE
);


-- ============================================================================
-- TEST 17 — Nom de table vide
-- Erreur attendue : VALIDATION_INVALID_TABLE_NAME
-- ============================================================================

RETURN fn::validation_unique(
    "available@example.com",
    "USER_EMAIL",
    "     ",
    "email",
    NONE
);


-- ============================================================================
-- TEST 18 — Nom de champ cible vide
-- Erreur attendue : VALIDATION_INVALID_TARGET_FIELD
-- ============================================================================

RETURN fn::validation_unique(
    "available@example.com",
    "USER_EMAIL",
    "validation_test_unique",
    "     ",
    NONE
);


-- ============================================================================
-- TEST 19 — Exclusion fournie sous forme de chaîne
-- Erreur attendue : VALIDATION_INVALID_EXCLUDE_RECORD
-- ============================================================================

RETURN fn::validation_unique(
    "first@example.com",
    "USER_EMAIL",
    "validation_test_unique",
    "email",
    "validation_test_unique:user_001"
);


-- ============================================================================
-- TEST 20 — Exclusion fournie sous forme d'entier
-- Erreur attendue : VALIDATION_INVALID_EXCLUDE_RECORD
-- ============================================================================

RETURN fn::validation_unique(
    "first@example.com",
    "USER_EMAIL",
    "validation_test_unique",
    "email",
    123
);


-- ============================================================================
-- TEST 21 — Exclusion provenant d'une autre table
-- Erreur attendue : VALIDATION_INVALID_EXCLUDE_TABLE
-- ============================================================================

RETURN fn::validation_unique(
    "first@example.com",
    "USER_EMAIL",
    "validation_test_unique",
    "email",
    identity_user:user_001
);


-- ============================================================================
-- TEST 22 — Record ID inexistant utilisé comme exclusion
-- Résultat attendu : "available@example.com"
-- Note : l'existence de l'enregistrement exclu n'est pas contrôlée
-- ============================================================================

RETURN fn::validation_unique(
    "available@example.com",
    "USER_EMAIL",
    "validation_test_unique",
    "email",
    validation_test_unique:missing_user
);


-- ============================================================================
-- TEST 23 — Record ID inexistant n'excluant pas un vrai doublon
-- Erreur attendue : USER_EMAIL_ALREADY_EXISTS
-- ============================================================================

RETURN fn::validation_unique(
    "first@example.com",
    "USER_EMAIL",
    "validation_test_unique",
    "email",
    validation_test_unique:missing_user
);


-- ============================================================================
-- TEST 24 — Comparaison sensible à la casse
-- Résultat attendu : "FIRST@EXAMPLE.COM"
-- Note : la valeur enregistrée est "first@example.com"
-- ============================================================================

RETURN fn::validation_unique(
    "FIRST@EXAMPLE.COM",
    "USER_EMAIL",
    "validation_test_unique",
    "email",
    NONE
);


-- ============================================================================
-- TEST 25 — Comparaison sensible aux espaces
-- Résultat attendu : " first@example.com "
-- Note : cette fonction ne normalise pas la valeur
-- ============================================================================

RETURN fn::validation_unique(
    " first@example.com ",
    "USER_EMAIL",
    "validation_test_unique",
    "email",
    NONE
);


-- ============================================================================
-- TEST 26 — Validation après validation_email
-- Résultat attendu : "available@example.com"
-- ============================================================================

LET $email = fn::validation_email(
    "  available@example.com  ",
    "USER_EMAIL",
    254
);

RETURN fn::validation_unique(
    $email,
    "USER_EMAIL",
    "validation_test_unique",
    "email",
    NONE
);


-- ============================================================================
-- TEST 27 — Validation après validation_slug
-- Résultat attendu : "available-user"
-- ============================================================================

LET $slug = fn::validation_slug(
    "Available-User",
    "USER_SLUG",
    100
);

RETURN fn::validation_unique(
    $slug,
    "USER_SLUG",
    "validation_test_unique",
    "slug",
    NONE
);


-- ============================================================================
-- TEST 28 — Exemple de mise à jour complète
-- Résultat attendu : "first@example.com"
-- ============================================================================

LET $user_id = fn::validation_record_type(
    validation_test_unique:user_001,
    "USER_ID",
    "validation_test_unique"
);

LET $email = fn::validation_email(
    "first@example.com",
    "USER_EMAIL",
    254
);

RETURN fn::validation_unique(
    $email,
    "USER_EMAIL",
    "validation_test_unique",
    "email",
    $user_id
);


-- ============================================================================
-- TEST 29 — Suppression des données de test
-- Résultat attendu : suppression des enregistrements
-- ============================================================================

DELETE validation_test_unique:user_001;
DELETE validation_test_unique:user_002;


-- ============================================================================
-- TEST 30 — Suppression de la table de test
-- Résultat attendu : suppression de validation_test_unique
-- ============================================================================

REMOVE TABLE validation_test_unique;