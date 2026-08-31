-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/exists.test.surql
-- Fonction     : fn::validation_exists
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW interrompent l'exécution du
-- bloc.
--
-- Dans Surrealist, sélectionner uniquement le test concerné lorsqu'une erreur
-- est attendue.
--
-- Les tests utilisent la table validation_test_exists.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Préparation de la table
-- Résultat attendu : définition de validation_test_exists
-- ============================================================================

DEFINE TABLE OVERWRITE validation_test_exists SCHEMAFULL;

DEFINE FIELD OVERWRITE email
ON TABLE validation_test_exists
TYPE string;

DEFINE FIELD OVERWRITE slug
ON TABLE validation_test_exists
TYPE string;

DEFINE FIELD OVERWRITE code
ON TABLE validation_test_exists
TYPE string;

DEFINE FIELD OVERWRITE external_id
ON TABLE validation_test_exists
TYPE uuid;

DEFINE FIELD OVERWRITE position
ON TABLE validation_test_exists
TYPE int;

DEFINE FIELD OVERWRITE profile
ON TABLE validation_test_exists
TYPE object;

DEFINE FIELD OVERWRITE profile.username
ON TABLE validation_test_exists
TYPE string;


-- ============================================================================
-- TEST 2 — Création des enregistrements de test
-- Résultat attendu : création de item_001 et item_002
-- ============================================================================

CREATE validation_test_exists:item_001 CONTENT {
    email: "first@example.com",
    slug: "first-item",
    code: "INVITATION-001",
    external_id: u"018a6680-bef9-701b-9025-e1754f296a0f",
    position: 1,
    profile: {
        username: "first"
    }
};

CREATE validation_test_exists:item_002 CONTENT {
    email: "second@example.com",
    slug: "second-item",
    code: "INVITATION-002",
    external_id: u"0191f946-936f-7223-bef5-aebbc527ad80",
    position: 2,
    profile: {
        username: "second"
    }
};


-- ============================================================================
-- TEST 3 — Adresse e-mail existante
-- Résultat attendu : "first@example.com"
-- ============================================================================

RETURN fn::validation_exists(
    "first@example.com",
    "USER_EMAIL",
    "validation_test_exists",
    "email"
);


-- ============================================================================
-- TEST 4 — Seconde adresse e-mail existante
-- Résultat attendu : "second@example.com"
-- ============================================================================

RETURN fn::validation_exists(
    "second@example.com",
    "USER_EMAIL",
    "validation_test_exists",
    "email"
);


-- ============================================================================
-- TEST 5 — Slug existant
-- Résultat attendu : "first-item"
-- ============================================================================

RETURN fn::validation_exists(
    "first-item",
    "ITEM_SLUG",
    "validation_test_exists",
    "slug"
);


-- ============================================================================
-- TEST 6 — Code existant
-- Résultat attendu : "INVITATION-001"
-- ============================================================================

RETURN fn::validation_exists(
    "INVITATION-001",
    "INVITATION_CODE",
    "validation_test_exists",
    "code"
);


-- ============================================================================
-- TEST 7 — UUID existant
-- Résultat attendu : u"018a6680-bef9-701b-9025-e1754f296a0f"
-- ============================================================================

RETURN fn::validation_exists(
    u"018a6680-bef9-701b-9025-e1754f296a0f",
    "EXTERNAL_ID",
    "validation_test_exists",
    "external_id"
);


-- ============================================================================
-- TEST 8 — Entier existant
-- Résultat attendu : 1
-- ============================================================================

RETURN fn::validation_exists(
    1,
    "POSITION",
    "validation_test_exists",
    "position"
);


-- ============================================================================
-- TEST 9 — Champ imbriqué existant
-- Résultat attendu : "first"
-- ============================================================================

RETURN fn::validation_exists(
    "first",
    "USERNAME",
    "validation_test_exists",
    "profile.username"
);


-- ============================================================================
-- TEST 10 — Adresse e-mail inexistante
-- Erreur attendue : USER_EMAIL_NOT_FOUND
-- ============================================================================

RETURN fn::validation_exists(
    "missing@example.com",
    "USER_EMAIL",
    "validation_test_exists",
    "email"
);


-- ============================================================================
-- TEST 11 — Slug inexistant
-- Erreur attendue : ITEM_SLUG_NOT_FOUND
-- ============================================================================

RETURN fn::validation_exists(
    "missing-item",
    "ITEM_SLUG",
    "validation_test_exists",
    "slug"
);


-- ============================================================================
-- TEST 12 — Code inexistant
-- Erreur attendue : INVITATION_CODE_NOT_FOUND
-- ============================================================================

RETURN fn::validation_exists(
    "INVITATION-999",
    "INVITATION_CODE",
    "validation_test_exists",
    "code"
);


-- ============================================================================
-- TEST 13 — UUID inexistant
-- Erreur attendue : EXTERNAL_ID_NOT_FOUND
-- ============================================================================

RETURN fn::validation_exists(
    u"01900000-0000-7000-8000-000000000000",
    "EXTERNAL_ID",
    "validation_test_exists",
    "external_id"
);


-- ============================================================================
-- TEST 14 — Entier inexistant
-- Erreur attendue : POSITION_NOT_FOUND
-- ============================================================================

RETURN fn::validation_exists(
    999,
    "POSITION",
    "validation_test_exists",
    "position"
);


-- ============================================================================
-- TEST 15 — Champ imbriqué inexistant
-- Erreur attendue : USERNAME_NOT_FOUND
-- ============================================================================

RETURN fn::validation_exists(
    "missing",
    "USERNAME",
    "validation_test_exists",
    "profile.username"
);


-- ============================================================================
-- TEST 16 — Valeur absente
-- Erreur attendue : USER_EMAIL_REQUIRED
-- ============================================================================

RETURN fn::validation_exists(
    NONE,
    "USER_EMAIL",
    "validation_test_exists",
    "email"
);


-- ============================================================================
-- TEST 17 — Valeur NULL
-- Erreur attendue : USER_EMAIL_NULL_NOT_ALLOWED
-- ============================================================================

RETURN fn::validation_exists(
    NULL,
    "USER_EMAIL",
    "validation_test_exists",
    "email"
);


-- ============================================================================
-- TEST 18 — Nom technique vide
-- Erreur attendue : VALIDATION_INVALID_FIELD_NAME
-- ============================================================================

RETURN fn::validation_exists(
    "first@example.com",
    "     ",
    "validation_test_exists",
    "email"
);


-- ============================================================================
-- TEST 19 — Nom de table vide
-- Erreur attendue : VALIDATION_INVALID_TABLE_NAME
-- ============================================================================

RETURN fn::validation_exists(
    "first@example.com",
    "USER_EMAIL",
    "     ",
    "email"
);


-- ============================================================================
-- TEST 20 — Nom du champ cible vide
-- Erreur attendue : VALIDATION_INVALID_TARGET_FIELD
-- ============================================================================

RETURN fn::validation_exists(
    "first@example.com",
    "USER_EMAIL",
    "validation_test_exists",
    "     "
);


-- ============================================================================
-- TEST 21 — Comparaison sensible à la casse
-- Erreur attendue : USER_EMAIL_NOT_FOUND
-- Note : la valeur stockée est "first@example.com"
-- ============================================================================

RETURN fn::validation_exists(
    "FIRST@EXAMPLE.COM",
    "USER_EMAIL",
    "validation_test_exists",
    "email"
);


-- ============================================================================
-- TEST 22 — Comparaison sensible aux espaces
-- Erreur attendue : USER_EMAIL_NOT_FOUND
-- Note : cette fonction ne normalise pas la valeur
-- ============================================================================

RETURN fn::validation_exists(
    " first@example.com ",
    "USER_EMAIL",
    "validation_test_exists",
    "email"
);


-- ============================================================================
-- TEST 23 — Validation après validation_email
-- Résultat attendu : "first@example.com"
-- ============================================================================

LET $email = fn::validation_email(
    "   first@example.com   ",
    "USER_EMAIL",
    254
);

RETURN fn::validation_exists(
    $email,
    "USER_EMAIL",
    "validation_test_exists",
    "email"
);


-- ============================================================================
-- TEST 24 — Validation après validation_slug
-- Résultat attendu : "first-item"
-- ============================================================================

LET $slug = fn::validation_slug(
    "First-Item",
    "ITEM_SLUG",
    100
);

RETURN fn::validation_exists(
    $slug,
    "ITEM_SLUG",
    "validation_test_exists",
    "slug"
);


-- ============================================================================
-- TEST 25 — Validation après validation_uuid
-- Résultat attendu : u"018a6680-bef9-701b-9025-e1754f296a0f"
-- ============================================================================

LET $external_id = fn::validation_uuid(
    u"018a6680-bef9-701b-9025-e1754f296a0f",
    "EXTERNAL_ID"
);

RETURN fn::validation_exists(
    $external_id,
    "EXTERNAL_ID",
    "validation_test_exists",
    "external_id"
);


-- ============================================================================
-- TEST 26 — Validation après validation_integer
-- Résultat attendu : 1
-- ============================================================================

LET $position = fn::validation_integer(
    1,
    "POSITION",
    0,
    NONE
);

RETURN fn::validation_exists(
    $position,
    "POSITION",
    "validation_test_exists",
    "position"
);


-- ============================================================================
-- TEST 27 — Comparaison avec validation_unique sur une valeur existante
-- Erreur attendue : USER_EMAIL_ALREADY_EXISTS
-- ============================================================================

LET $email = fn::validation_exists(
    "first@example.com",
    "USER_EMAIL",
    "validation_test_exists",
    "email"
);

RETURN fn::validation_unique(
    $email,
    "USER_EMAIL",
    "validation_test_exists",
    "email",
    NONE
);


-- ============================================================================
-- TEST 28 — Valeur disponible validée par validation_unique
-- Résultat attendu : "available@example.com"
-- ============================================================================

RETURN fn::validation_unique(
    "available@example.com",
    "USER_EMAIL",
    "validation_test_exists",
    "email",
    NONE
);


-- ============================================================================
-- TEST 29 — Suppression des enregistrements de test
-- Résultat attendu : suppression des deux enregistrements
-- ============================================================================

DELETE validation_test_exists:item_001;
DELETE validation_test_exists:item_002;


-- ============================================================================
-- TEST 30 — Suppression de la table de test
-- Résultat attendu : suppression de validation_test_exists
-- ============================================================================

REMOVE TABLE validation_test_exists;