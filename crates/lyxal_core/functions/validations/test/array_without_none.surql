-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/array_without_none.test.surql
-- Fonction     : fn::validation_array_without_none
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
-- TEST 1 — Tableau de chaînes sans NONE
-- Résultat attendu : ["owner", "admin", "member"]
-- ============================================================================

RETURN fn::validation_array_without_none(
    ["owner", "admin", "member"],
    "ROLES"
);


-- ============================================================================
-- TEST 2 — Tableau vide
-- Résultat attendu : []
-- ============================================================================

RETURN fn::validation_array_without_none(
    [],
    "ITEMS"
);


-- ============================================================================
-- TEST 3 — Tableau contenant des entiers
-- Résultat attendu : [1, 2, 3]
-- ============================================================================

RETURN fn::validation_array_without_none(
    [1, 2, 3],
    "VALUES"
);


-- ============================================================================
-- TEST 4 — Tableau contenant false
-- Résultat attendu : [true, false]
-- ============================================================================

RETURN fn::validation_array_without_none(
    [true, false],
    "VALUES"
);


-- ============================================================================
-- TEST 5 — Tableau contenant zéro
-- Résultat attendu : [0, 1, 2]
-- ============================================================================

RETURN fn::validation_array_without_none(
    [0, 1, 2],
    "VALUES"
);


-- ============================================================================
-- TEST 6 — Tableau contenant une chaîne vide
-- Résultat attendu : ["", "admin"]
-- ============================================================================

RETURN fn::validation_array_without_none(
    ["", "admin"],
    "VALUES"
);


-- ============================================================================
-- TEST 7 — Tableau contenant une valeur NULL
-- Résultat attendu : [NULL]
-- Note : cette fonction interdit NONE mais autorise NULL
-- ============================================================================

RETURN fn::validation_array_without_none(
    [NULL],
    "VALUES"
);


-- ============================================================================
-- TEST 8 — Tableau contenant plusieurs valeurs NULL
-- Résultat attendu : [NULL, NULL]
-- Note : cette fonction ne contrôle ni NULL ni les doublons
-- ============================================================================

RETURN fn::validation_array_without_none(
    [NULL, NULL],
    "VALUES"
);


-- ============================================================================
-- TEST 9 — Tableau de Record IDs
-- Résultat attendu : deux Record IDs
-- ============================================================================

RETURN fn::validation_array_without_none(
    [
        identity_user:user_001,
        identity_user:user_002
    ],
    "MEMBER_IDS"
);


-- ============================================================================
-- TEST 10 — Tableau contenant des objets
-- Résultat attendu : deux objets
-- ============================================================================

RETURN fn::validation_array_without_none(
    [
        {
            name: "Premier"
        },
        {
            name: "Second"
        }
    ],
    "ITEMS"
);


-- ============================================================================
-- TEST 11 — Tableau contenant un objet avec une propriété NONE
-- Résultat attendu : [{ name: NONE }]
-- Note : la validation n'est pas récursive
-- ============================================================================

RETURN fn::validation_array_without_none(
    [
        {
            name: NONE
        }
    ],
    "ITEMS"
);


-- ============================================================================
-- TEST 12 — Tableau imbriqué contenant NONE
-- Résultat attendu : [[1, NONE, 3]]
-- Note : la validation porte uniquement sur le premier niveau
-- ============================================================================

RETURN fn::validation_array_without_none(
    [
        [1, NONE, 3]
    ],
    "ITEMS"
);


-- ============================================================================
-- TEST 13 — Tableau hétérogène sans NONE
-- Résultat attendu : ["texte", 42, true, NULL, identity_user:user_001]
-- ============================================================================

RETURN fn::validation_array_without_none(
    [
        "texte",
        42,
        true,
        NULL,
        identity_user:user_001
    ],
    "VALUES"
);


-- ============================================================================
-- TEST 14 — Valeur globale absente
-- Erreur attendue : VALUES_REQUIRED
-- ============================================================================

RETURN fn::validation_array_without_none(
    NONE,
    "VALUES"
);


-- ============================================================================
-- TEST 15 — Valeur globale NULL
-- Erreur attendue : VALUES_NULL_NOT_ALLOWED
-- ============================================================================

RETURN fn::validation_array_without_none(
    NULL,
    "VALUES"
);


-- ============================================================================
-- TEST 16 — Chaîne à la place d'un tableau
-- Erreur attendue : VALUES_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_array_without_none(
    "texte",
    "VALUES"
);


-- ============================================================================
-- TEST 17 — Entier à la place d'un tableau
-- Erreur attendue : VALUES_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_array_without_none(
    42,
    "VALUES"
);


-- ============================================================================
-- TEST 18 — Booléen à la place d'un tableau
-- Erreur attendue : VALUES_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_array_without_none(
    true,
    "VALUES"
);


-- ============================================================================
-- TEST 19 — Objet à la place d'un tableau
-- Erreur attendue : VALUES_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_array_without_none(
    {
        value: "test"
    },
    "VALUES"
);


-- ============================================================================
-- TEST 20 — Record ID à la place d'un tableau
-- Erreur attendue : MEMBER_IDS_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_array_without_none(
    identity_user:user_001,
    "MEMBER_IDS"
);


-- ============================================================================
-- TEST 21 — Tableau contenant un seul élément NONE
-- Erreur attendue : VALUES_NONE_NOT_ALLOWED
-- ============================================================================

RETURN fn::validation_array_without_none(
    [NONE],
    "VALUES"
);


-- ============================================================================
-- TEST 22 — Tableau contenant NONE au début
-- Erreur attendue : VALUES_NONE_NOT_ALLOWED
-- ============================================================================

RETURN fn::validation_array_without_none(
    [NONE, 1, 2, 3],
    "VALUES"
);


-- ============================================================================
-- TEST 23 — Tableau contenant NONE au milieu
-- Erreur attendue : VALUES_NONE_NOT_ALLOWED
-- ============================================================================

RETURN fn::validation_array_without_none(
    [1, 2, NONE, 3],
    "VALUES"
);


-- ============================================================================
-- TEST 24 — Tableau contenant NONE à la fin
-- Erreur attendue : VALUES_NONE_NOT_ALLOWED
-- ============================================================================

RETURN fn::validation_array_without_none(
    [1, 2, 3, NONE],
    "VALUES"
);


-- ============================================================================
-- TEST 25 — Tableau contenant plusieurs valeurs NONE
-- Erreur attendue : VALUES_NONE_NOT_ALLOWED
-- ============================================================================

RETURN fn::validation_array_without_none(
    [NONE, 1, NONE, 2, NONE],
    "VALUES"
);


-- ============================================================================
-- TEST 26 — Tableau contenant NONE et NULL
-- Erreur attendue : VALUES_NONE_NOT_ALLOWED
-- ============================================================================

RETURN fn::validation_array_without_none(
    [NULL, NONE],
    "VALUES"
);


-- ============================================================================
-- TEST 27 — Tableau contenant un Record ID et NONE
-- Erreur attendue : MEMBER_IDS_NONE_NOT_ALLOWED
-- ============================================================================

RETURN fn::validation_array_without_none(
    [
        identity_user:user_001,
        NONE
    ],
    "MEMBER_IDS"
);


-- ============================================================================
-- TEST 28 — Nom technique vide
-- Erreur attendue : VALIDATION_INVALID_FIELD_NAME
-- ============================================================================

RETURN fn::validation_array_without_none(
    [1, 2, 3],
    "     "
);


-- ============================================================================
-- TEST 29 — Utilisation après validation_array_length
-- Résultat attendu : ["owner", "admin"]
-- ============================================================================

LET $roles = fn::validation_array_length(
    ["owner", "admin"],
    "ROLES",
    1,
    10
);

RETURN fn::validation_array_without_none(
    $roles,
    "ROLES"
);


-- ============================================================================
-- TEST 30 — Utilisation avec tableau de chaînes
-- Résultat attendu : ["owner", "admin"]
-- ============================================================================

LET $roles = fn::validation_array_of_strings(
    ["owner", "admin"],
    "ROLES",
    false,
    1,
    50
);

RETURN fn::validation_array_without_none(
    $roles,
    "ROLES"
);


-- ============================================================================
-- TEST 31 — Validation complète d'une liste de Record IDs
-- Résultat attendu : deux Record IDs
-- Note : les enregistrements ne sont pas obligatoirement existants ici
-- ============================================================================

LET $member_ids = fn::validation_array_length(
    [
        identity_user:user_001,
        identity_user:user_002
    ],
    "MEMBER_IDS",
    1,
    100
);

LET $member_ids = fn::validation_array_of_records(
    $member_ids,
    "MEMBER_IDS",
    "identity_user",
    false
);

LET $member_ids = fn::validation_array_without_none(
    $member_ids,
    "MEMBER_IDS"
);

RETURN fn::validation_array_unique(
    $member_ids,
    "MEMBER_IDS"
);