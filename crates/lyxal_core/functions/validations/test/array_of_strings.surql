-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/array_of_strings.test.surql
-- Fonction     : fn::validation_array_of_strings
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW interrompent l'exécution du
-- bloc. Dans Surrealist, sélectionner uniquement le test à exécuter lorsque
-- celui-ci attend une erreur.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Tableau de chaînes valide
-- Résultat attendu : ["owner", "admin", "member"]
-- ============================================================================

RETURN fn::validation_array_of_strings(
    ["owner", "admin", "member"],
    "ROLES",
    false,
    1,
    50
);


-- ============================================================================
-- TEST 2 — Nettoyage des espaces périphériques
-- Résultat attendu : ["owner", "admin", "member"]
-- ============================================================================

RETURN fn::validation_array_of_strings(
    ["  owner  ", " admin ", "member"],
    "ROLES",
    false,
    1,
    50
);


-- ============================================================================
-- TEST 3 — Tableau vide
-- Résultat attendu : []
-- ============================================================================

RETURN fn::validation_array_of_strings(
    [],
    "ROLES",
    false,
    1,
    50
);


-- ============================================================================
-- TEST 4 — Tableau contenant une chaîne vide autorisée
-- Résultat attendu : ["", "admin"]
-- ============================================================================

RETURN fn::validation_array_of_strings(
    ["", "admin"],
    "ROLES",
    true,
    NONE,
    50
);


-- ============================================================================
-- TEST 5 — Chaîne composée d'espaces acceptée puis nettoyée
-- Résultat attendu : ["", "admin"]
-- ============================================================================

RETURN fn::validation_array_of_strings(
    ["     ", "admin"],
    "ROLES",
    true,
    NONE,
    50
);


-- ============================================================================
-- TEST 6 — Longueur exactement égale au minimum
-- Résultat attendu : ["adm"]
-- ============================================================================

RETURN fn::validation_array_of_strings(
    ["adm"],
    "ROLES",
    false,
    3,
    50
);


-- ============================================================================
-- TEST 7 — Longueur exactement égale au maximum
-- Résultat attendu : ["admin"]
-- ============================================================================

RETURN fn::validation_array_of_strings(
    ["admin"],
    "ROLES",
    false,
    1,
    5
);


-- ============================================================================
-- TEST 8 — Sans limites de longueur
-- Résultat attendu : ["owner", "admin"]
-- ============================================================================

RETURN fn::validation_array_of_strings(
    ["owner", "admin"],
    "ROLES",
    false,
    NONE,
    NONE
);


-- ============================================================================
-- TEST 9 — Tableau contenant des chaînes Unicode
-- Résultat attendu : ["Équipe", "Réservation"]
-- ============================================================================

RETURN fn::validation_array_of_strings(
    ["Équipe", "Réservation"],
    "LABELS",
    false,
    1,
    100
);


-- ============================================================================
-- TEST 10 — Tableau contenant des doublons
-- Résultat attendu : ["admin", "admin"]
-- Note : cette fonction ne contrôle pas l'unicité
-- ============================================================================

RETURN fn::validation_array_of_strings(
    ["admin", "admin"],
    "ROLES",
    false,
    1,
    50
);


-- ============================================================================
-- TEST 11 — Valeur absente
-- Erreur attendue : ROLES_REQUIRED
-- ============================================================================

RETURN fn::validation_array_of_strings(
    NONE,
    "ROLES",
    false,
    1,
    50
);


-- ============================================================================
-- TEST 12 — Valeur globale NULL
-- Erreur attendue : ROLES_NULL_NOT_ALLOWED
-- ============================================================================

RETURN fn::validation_array_of_strings(
    NULL,
    "ROLES",
    false,
    1,
    50
);


-- ============================================================================
-- TEST 13 — Chaîne à la place d'un tableau
-- Erreur attendue : ROLES_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_array_of_strings(
    "admin",
    "ROLES",
    false,
    1,
    50
);


-- ============================================================================
-- TEST 14 — Objet à la place d'un tableau
-- Erreur attendue : ROLES_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_array_of_strings(
    {
        role: "admin"
    },
    "ROLES",
    false,
    1,
    50
);


-- ============================================================================
-- TEST 15 — Entier dans le tableau
-- Erreur attendue : ROLES_ITEM_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_array_of_strings(
    ["owner", 42, "admin"],
    "ROLES",
    false,
    1,
    50
);


-- ============================================================================
-- TEST 16 — Booléen dans le tableau
-- Erreur attendue : ROLES_ITEM_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_array_of_strings(
    ["owner", true, "admin"],
    "ROLES",
    false,
    1,
    50
);


-- ============================================================================
-- TEST 17 — NONE dans le tableau
-- Erreur attendue : ROLES_ITEM_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_array_of_strings(
    ["owner", NONE, "admin"],
    "ROLES",
    false,
    1,
    50
);


-- ============================================================================
-- TEST 18 — NULL dans le tableau
-- Erreur attendue : ROLES_ITEM_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_array_of_strings(
    ["owner", NULL, "admin"],
    "ROLES",
    false,
    1,
    50
);


-- ============================================================================
-- TEST 19 — Record ID dans le tableau
-- Erreur attendue : ROLES_ITEM_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_array_of_strings(
    [
        "owner",
        identity_user:user_001,
        "admin"
    ],
    "ROLES",
    false,
    1,
    50
);


-- ============================================================================
-- TEST 20 — Objet dans le tableau
-- Erreur attendue : ROLES_ITEM_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_array_of_strings(
    [
        "owner",
        {
            role: "admin"
        }
    ],
    "ROLES",
    false,
    1,
    50
);


-- ============================================================================
-- TEST 21 — Tableau imbriqué
-- Erreur attendue : ROLES_ITEM_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_array_of_strings(
    [
        "owner",
        ["admin"]
    ],
    "ROLES",
    false,
    1,
    50
);


-- ============================================================================
-- TEST 22 — Chaîne vide refusée
-- Erreur attendue : ROLES_EMPTY_STRING_NOT_ALLOWED
-- ============================================================================

RETURN fn::validation_array_of_strings(
    ["owner", "", "admin"],
    "ROLES",
    false,
    NONE,
    50
);


-- ============================================================================
-- TEST 23 — Chaîne composée d'espaces refusée
-- Erreur attendue : ROLES_EMPTY_STRING_NOT_ALLOWED
-- ============================================================================

RETURN fn::validation_array_of_strings(
    ["owner", "     ", "admin"],
    "ROLES",
    false,
    NONE,
    50
);


-- ============================================================================
-- TEST 24 — Chaîne vide autorisée mais trop courte
-- Erreur attendue : ROLES_ITEM_TOO_SHORT
-- ============================================================================

RETURN fn::validation_array_of_strings(
    ["", "admin"],
    "ROLES",
    true,
    1,
    50
);


-- ============================================================================
-- TEST 25 — Chaîne trop courte
-- Erreur attendue : ROLES_ITEM_TOO_SHORT
-- ============================================================================

RETURN fn::validation_array_of_strings(
    ["owner", "ad", "member"],
    "ROLES",
    false,
    3,
    50
);


-- ============================================================================
-- TEST 26 — Chaîne trop longue
-- Erreur attendue : ROLES_ITEM_TOO_LONG
-- ============================================================================

RETURN fn::validation_array_of_strings(
    [
        "owner",
        "administrateur-principal"
    ],
    "ROLES",
    false,
    1,
    10
);


-- ============================================================================
-- TEST 27 — Longueur minimale négative
-- Erreur attendue : VALIDATION_INVALID_MIN_LENGTH
-- ============================================================================

RETURN fn::validation_array_of_strings(
    ["owner"],
    "ROLES",
    false,
    -1,
    50
);


-- ============================================================================
-- TEST 28 — Longueur maximale négative
-- Erreur attendue : VALIDATION_INVALID_MAX_LENGTH
-- ============================================================================

RETURN fn::validation_array_of_strings(
    ["owner"],
    "ROLES",
    false,
    1,
    -1
);


-- ============================================================================
-- TEST 29 — Plage de longueur incohérente
-- Erreur attendue : VALIDATION_INVALID_STRING_LENGTH_RANGE
-- ============================================================================

RETURN fn::validation_array_of_strings(
    ["owner"],
    "ROLES",
    false,
    50,
    10
);


-- ============================================================================
-- TEST 30 — Nom technique vide
-- Erreur attendue : VALIDATION_INVALID_FIELD_NAME
-- ============================================================================

RETURN fn::validation_array_of_strings(
    ["owner", "admin"],
    "     ",
    false,
    1,
    50
);


-- ============================================================================
-- TEST 31 — Validation complète avec longueur et unicité
-- Résultat attendu : ["owner", "admin", "member"]
-- ============================================================================

LET $roles = fn::validation_array_length(
    ["owner", "admin", "member"],
    "ROLES",
    1,
    10
);

LET $roles = fn::validation_array_of_strings(
    $roles,
    "ROLES",
    false,
    1,
    50
);

RETURN fn::validation_array_unique(
    $roles,
    "ROLES"
);


-- ============================================================================
-- TEST 32 — Chaînes valides mais doublons présents
-- Erreur attendue : ROLES_DUPLICATES_NOT_ALLOWED
-- ============================================================================

LET $roles = fn::validation_array_of_strings(
    ["owner", "admin", "owner"],
    "ROLES",
    false,
    1,
    50
);

RETURN fn::validation_array_unique(
    $roles,
    "ROLES"
);