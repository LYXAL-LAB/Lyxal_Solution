-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/array_unique.test.surql
-- Fonction     : fn::validation_array_unique
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
-- TEST 1 — Tableau de chaînes sans doublon
-- Résultat attendu : ["owner", "admin", "member"]
-- ============================================================================

RETURN fn::validation_array_unique(
    ["owner", "admin", "member"],
    "ROLES"
);


-- ============================================================================
-- TEST 2 — Tableau vide
-- Résultat attendu : []
-- ============================================================================

RETURN fn::validation_array_unique(
    [],
    "ITEMS"
);


-- ============================================================================
-- TEST 3 — Tableau contenant un seul élément
-- Résultat attendu : ["owner"]
-- ============================================================================

RETURN fn::validation_array_unique(
    ["owner"],
    "ROLES"
);


-- ============================================================================
-- TEST 4 — Tableau d'entiers sans doublon
-- Résultat attendu : [1, 2, 3, 4]
-- ============================================================================

RETURN fn::validation_array_unique(
    [1, 2, 3, 4],
    "VALUES"
);


-- ============================================================================
-- TEST 5 — Tableau de booléens sans doublon
-- Résultat attendu : [true, false]
-- ============================================================================

RETURN fn::validation_array_unique(
    [true, false],
    "VALUES"
);


-- ============================================================================
-- TEST 6 — Tableau de Record IDs sans doublon
-- Résultat attendu : deux Record IDs distincts
-- ============================================================================

RETURN fn::validation_array_unique(
    [
        identity_user:user_001,
        identity_user:user_002
    ],
    "MEMBER_IDS"
);


-- ============================================================================
-- TEST 7 — Chaînes différentes uniquement par la casse
-- Résultat attendu : ["admin", "Admin"]
-- Note : la comparaison est sensible à la casse
-- ============================================================================

RETURN fn::validation_array_unique(
    ["admin", "Admin"],
    "ROLES"
);


-- ============================================================================
-- TEST 8 — Tableau contenant une seule valeur NONE
-- Résultat attendu : [NONE]
-- ============================================================================

RETURN fn::validation_array_unique(
    [NONE],
    "VALUES"
);


-- ============================================================================
-- TEST 9 — Tableau contenant une seule valeur NULL
-- Résultat attendu : [NULL]
-- ============================================================================

RETURN fn::validation_array_unique(
    [NULL],
    "VALUES"
);


-- ============================================================================
-- TEST 10 — Tableau hétérogène sans doublon
-- Résultat attendu : ["1", 1, true, NULL, NONE]
-- ============================================================================

RETURN fn::validation_array_unique(
    ["1", 1, true, NULL, NONE],
    "VALUES"
);


-- ============================================================================
-- TEST 11 — Deux chaînes identiques
-- Erreur attendue : ROLES_DUPLICATES_NOT_ALLOWED
-- ============================================================================

RETURN fn::validation_array_unique(
    ["owner", "admin", "owner"],
    "ROLES"
);


-- ============================================================================
-- TEST 12 — Deux entiers identiques
-- Erreur attendue : VALUES_DUPLICATES_NOT_ALLOWED
-- ============================================================================

RETURN fn::validation_array_unique(
    [1, 2, 1],
    "VALUES"
);


-- ============================================================================
-- TEST 13 — Plusieurs doublons
-- Erreur attendue : VALUES_DUPLICATES_NOT_ALLOWED
-- ============================================================================

RETURN fn::validation_array_unique(
    [1, 1, 2, 2, 3, 3],
    "VALUES"
);


-- ============================================================================
-- TEST 14 — Deux booléens true identiques
-- Erreur attendue : VALUES_DUPLICATES_NOT_ALLOWED
-- ============================================================================

RETURN fn::validation_array_unique(
    [true, false, true],
    "VALUES"
);


-- ============================================================================
-- TEST 15 — Deux Record IDs identiques
-- Erreur attendue : MEMBER_IDS_DUPLICATES_NOT_ALLOWED
-- ============================================================================

RETURN fn::validation_array_unique(
    [
        identity_user:user_001,
        identity_user:user_002,
        identity_user:user_001
    ],
    "MEMBER_IDS"
);


-- ============================================================================
-- TEST 16 — Deux valeurs NONE
-- Erreur attendue : VALUES_DUPLICATES_NOT_ALLOWED
-- ============================================================================

RETURN fn::validation_array_unique(
    [NONE, NONE],
    "VALUES"
);


-- ============================================================================
-- TEST 17 — Deux valeurs NULL
-- Erreur attendue : VALUES_DUPLICATES_NOT_ALLOWED
-- ============================================================================

RETURN fn::validation_array_unique(
    [NULL, NULL],
    "VALUES"
);


-- ============================================================================
-- TEST 18 — Deux chaînes vides
-- Erreur attendue : VALUES_DUPLICATES_NOT_ALLOWED
-- ============================================================================

RETURN fn::validation_array_unique(
    ["", ""],
    "VALUES"
);


-- ============================================================================
-- TEST 19 — Deux objets structurellement identiques
-- Résultat attendu :
-- soit erreur ITEMS_DUPLICATES_NOT_ALLOWED si l'égalité structurelle est
-- appliquée, soit tableau inchangé selon le comportement exact de la version
-- ============================================================================

RETURN fn::validation_array_unique(
    [
        {
            name: "Lyxal"
        },
        {
            name: "Lyxal"
        }
    ],
    "ITEMS"
);


-- ============================================================================
-- TEST 20 — Deux tableaux imbriqués identiques
-- Résultat attendu :
-- soit erreur ITEMS_DUPLICATES_NOT_ALLOWED si l'égalité structurelle est
-- appliquée, soit tableau inchangé selon le comportement exact de la version
-- ============================================================================

RETURN fn::validation_array_unique(
    [
        [1, 2],
        [1, 2]
    ],
    "ITEMS"
);


-- ============================================================================
-- TEST 21 — Valeur absente
-- Erreur attendue : ITEMS_REQUIRED
-- ============================================================================

RETURN fn::validation_array_unique(
    NONE,
    "ITEMS"
);


-- ============================================================================
-- TEST 22 — Valeur globale NULL
-- Erreur attendue : ITEMS_NULL_NOT_ALLOWED
-- ============================================================================

RETURN fn::validation_array_unique(
    NULL,
    "ITEMS"
);


-- ============================================================================
-- TEST 23 — Chaîne à la place d'un tableau
-- Erreur attendue : ITEMS_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_array_unique(
    "owner",
    "ITEMS"
);


-- ============================================================================
-- TEST 24 — Objet à la place d'un tableau
-- Erreur attendue : ITEMS_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_array_unique(
    {
        name: "Lyxal"
    },
    "ITEMS"
);


-- ============================================================================
-- TEST 25 — Entier à la place d'un tableau
-- Erreur attendue : ITEMS_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_array_unique(
    42,
    "ITEMS"
);


-- ============================================================================
-- TEST 26 — Booléen à la place d'un tableau
-- Erreur attendue : ITEMS_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_array_unique(
    true,
    "ITEMS"
);


-- ============================================================================
-- TEST 27 — Record ID à la place d'un tableau
-- Erreur attendue : MEMBER_IDS_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_array_unique(
    identity_user:user_001,
    "MEMBER_IDS"
);


-- ============================================================================
-- TEST 28 — Nom technique vide
-- Erreur attendue : VALIDATION_INVALID_FIELD_NAME
-- ============================================================================

RETURN fn::validation_array_unique(
    ["owner", "admin"],
    "     "
);


-- ============================================================================
-- TEST 29 — Utilisation après validation_array_length
-- Résultat attendu : ["owner", "admin", "member"]
-- ============================================================================

LET $roles = fn::validation_array_length(
    ["owner", "admin", "member"],
    "ROLES",
    1,
    10
);

RETURN fn::validation_array_unique(
    $roles,
    "ROLES"
);


-- ============================================================================
-- TEST 30 — Longueur valide mais présence d'un doublon
-- Erreur attendue : ROLES_DUPLICATES_NOT_ALLOWED
-- ============================================================================

LET $roles = fn::validation_array_length(
    ["owner", "admin", "owner"],
    "ROLES",
    1,
    10
);

RETURN fn::validation_array_unique(
    $roles,
    "ROLES"
);