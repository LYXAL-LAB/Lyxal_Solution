-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/array_length.test.surql
-- Fonction     : fn::validation_array_length
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
-- TEST 1 — Tableau valide sans limites
-- Résultat attendu : ["owner", "admin"]
-- ============================================================================

RETURN fn::validation_array_length(
    ["owner", "admin"],
    "ROLES",
    NONE,
    NONE
);


-- ============================================================================
-- TEST 2 — Tableau vide sans limites
-- Résultat attendu : []
-- ============================================================================

RETURN fn::validation_array_length(
    [],
    "ITEMS",
    NONE,
    NONE
);


-- ============================================================================
-- TEST 3 — Tableau vide avec minimum égal à zéro
-- Résultat attendu : []
-- ============================================================================

RETURN fn::validation_array_length(
    [],
    "ITEMS",
    0,
    NONE
);


-- ============================================================================
-- TEST 4 — Tableau compris dans une plage
-- Résultat attendu : ["owner", "admin"]
-- ============================================================================

RETURN fn::validation_array_length(
    ["owner", "admin"],
    "ROLES",
    1,
    5
);


-- ============================================================================
-- TEST 5 — Longueur égale à la limite minimale
-- Résultat attendu : ["owner"]
-- ============================================================================

RETURN fn::validation_array_length(
    ["owner"],
    "ROLES",
    1,
    5
);


-- ============================================================================
-- TEST 6 — Longueur égale à la limite maximale
-- Résultat attendu : ["owner", "admin", "member"]
-- ============================================================================

RETURN fn::validation_array_length(
    ["owner", "admin", "member"],
    "ROLES",
    1,
    3
);


-- ============================================================================
-- TEST 7 — Tableau de longueur exacte
-- Résultat attendu : ["red", "green", "blue"]
-- ============================================================================

RETURN fn::validation_array_length(
    ["red", "green", "blue"],
    "COLORS",
    3,
    3
);


-- ============================================================================
-- TEST 8 — Tableau de Record IDs valide
-- Résultat attendu : deux Record IDs
-- ============================================================================

RETURN fn::validation_array_length(
    [
        identity_user:user_001,
        identity_user:user_002
    ],
    "MEMBER_IDS",
    1,
    10
);


-- ============================================================================
-- TEST 9 — Tableau d'objets valide
-- Résultat attendu : deux objets
-- ============================================================================

RETURN fn::validation_array_length(
    [
        {
            name: "Premier"
        },
        {
            name: "Second"
        }
    ],
    "ITEMS",
    1,
    10
);


-- ============================================================================
-- TEST 10 — Tableau contenant NONE
-- Résultat attendu : [NONE]
-- ============================================================================

RETURN fn::validation_array_length(
    [NONE],
    "VALUES",
    1,
    1
);


-- ============================================================================
-- TEST 11 — Tableau contenant NULL, false, zéro et chaîne vide
-- Résultat attendu : [NULL, false, 0, ""]
-- ============================================================================

RETURN fn::validation_array_length(
    [NULL, false, 0, ""],
    "VALUES",
    4,
    4
);


-- ============================================================================
-- TEST 12 — Valeur absente
-- Erreur attendue : ITEMS_REQUIRED
-- ============================================================================

RETURN fn::validation_array_length(
    NONE,
    "ITEMS",
    NONE,
    NONE
);


-- ============================================================================
-- TEST 13 — Valeur NULL
-- Erreur attendue : ITEMS_NULL_NOT_ALLOWED
-- ============================================================================

RETURN fn::validation_array_length(
    NULL,
    "ITEMS",
    NONE,
    NONE
);


-- ============================================================================
-- TEST 14 — Chaîne à la place d'un tableau
-- Erreur attendue : ITEMS_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_array_length(
    "owner",
    "ITEMS",
    NONE,
    NONE
);


-- ============================================================================
-- TEST 15 — Objet à la place d'un tableau
-- Erreur attendue : ITEMS_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_array_length(
    {
        name: "Lyxal"
    },
    "ITEMS",
    NONE,
    NONE
);


-- ============================================================================
-- TEST 16 — Entier à la place d'un tableau
-- Erreur attendue : ITEMS_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_array_length(
    42,
    "ITEMS",
    NONE,
    NONE
);


-- ============================================================================
-- TEST 17 — Booléen à la place d'un tableau
-- Erreur attendue : ITEMS_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_array_length(
    true,
    "ITEMS",
    NONE,
    NONE
);


-- ============================================================================
-- TEST 18 — Record ID à la place d'un tableau
-- Erreur attendue : MEMBER_IDS_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_array_length(
    identity_user:user_001,
    "MEMBER_IDS",
    NONE,
    NONE
);


-- ============================================================================
-- TEST 19 — Tableau vide avec minimum égal à un
-- Erreur attendue : ITEMS_TOO_SHORT
-- ============================================================================

RETURN fn::validation_array_length(
    [],
    "ITEMS",
    1,
    NONE
);


-- ============================================================================
-- TEST 20 — Tableau trop court
-- Erreur attendue : ROLES_TOO_SHORT
-- ============================================================================

RETURN fn::validation_array_length(
    ["owner"],
    "ROLES",
    2,
    5
);


-- ============================================================================
-- TEST 21 — Tableau trop long
-- Erreur attendue : ROLES_TOO_LONG
-- ============================================================================

RETURN fn::validation_array_length(
    ["owner", "admin", "member", "viewer"],
    "ROLES",
    1,
    3
);


-- ============================================================================
-- TEST 22 — Longueur exacte non respectée par défaut
-- Erreur attendue : COLORS_TOO_SHORT
-- ============================================================================

RETURN fn::validation_array_length(
    ["red", "green"],
    "COLORS",
    3,
    3
);


-- ============================================================================
-- TEST 23 — Longueur exacte dépassée
-- Erreur attendue : COLORS_TOO_LONG
-- ============================================================================

RETURN fn::validation_array_length(
    ["red", "green", "blue", "yellow"],
    "COLORS",
    3,
    3
);


-- ============================================================================
-- TEST 24 — Minimum uniquement
-- Résultat attendu : [1, 2, 3, 4, 5]
-- ============================================================================

RETURN fn::validation_array_length(
    [1, 2, 3, 4, 5],
    "VALUES",
    3,
    NONE
);


-- ============================================================================
-- TEST 25 — Maximum uniquement
-- Résultat attendu : [1, 2]
-- ============================================================================

RETURN fn::validation_array_length(
    [1, 2],
    "VALUES",
    NONE,
    3
);


-- ============================================================================
-- TEST 26 — Longueur minimale négative
-- Erreur attendue : VALIDATION_INVALID_MIN_LENGTH
-- ============================================================================

RETURN fn::validation_array_length(
    ["owner"],
    "ROLES",
    -1,
    5
);


-- ============================================================================
-- TEST 27 — Longueur maximale négative
-- Erreur attendue : VALIDATION_INVALID_MAX_LENGTH
-- ============================================================================

RETURN fn::validation_array_length(
    ["owner"],
    "ROLES",
    0,
    -1
);


-- ============================================================================
-- TEST 28 — Plage de longueur incohérente
-- Erreur attendue : VALIDATION_INVALID_ARRAY_RANGE
-- ============================================================================

RETURN fn::validation_array_length(
    ["owner"],
    "ROLES",
    10,
    2
);


-- ============================================================================
-- TEST 29 — Minimum et maximum égaux à zéro avec tableau vide
-- Résultat attendu : []
-- ============================================================================

RETURN fn::validation_array_length(
    [],
    "ITEMS",
    0,
    0
);


-- ============================================================================
-- TEST 30 — Maximum égal à zéro avec tableau non vide
-- Erreur attendue : ITEMS_TOO_LONG
-- ============================================================================

RETURN fn::validation_array_length(
    ["owner"],
    "ITEMS",
    0,
    0
);


-- ============================================================================
-- TEST 31 — Nom technique vide
-- Erreur attendue : VALIDATION_INVALID_FIELD_NAME
-- ============================================================================

RETURN fn::validation_array_length(
    ["owner"],
    "     ",
    1,
    5
);


-- ============================================================================
-- TEST 32 — Utilisation après validation_array_not_empty
-- Résultat attendu : ["owner", "admin"]
-- ============================================================================

LET $roles = fn::validation_array_not_empty(
    ["owner", "admin"],
    "ROLES"
);

RETURN fn::validation_array_length(
    $roles,
    "ROLES",
    1,
    5
);