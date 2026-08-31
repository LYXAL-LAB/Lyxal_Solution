-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/array_of_records.test.surql
-- Fonction     : fn::validation_array_of_records
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
-- TEST 1 — Création des enregistrements utilisés par les tests
-- Résultat attendu : création de deux enregistrements
-- ============================================================================

CREATE validation_test_user:user_001 SET
    name = "Premier utilisateur";

CREATE validation_test_user:user_002 SET
    name = "Second utilisateur";


-- ============================================================================
-- TEST 2 — Tableau de Record IDs valide sans contrôle d'existence
-- Résultat attendu : deux Record IDs
-- ============================================================================

RETURN fn::validation_array_of_records(
    [
        validation_test_user:user_001,
        validation_test_user:user_002
    ],
    "MEMBER_IDS",
    "validation_test_user",
    false
);


-- ============================================================================
-- TEST 3 — Tableau de Record IDs valide avec contrôle d'existence
-- Résultat attendu : deux Record IDs
-- ============================================================================

RETURN fn::validation_array_of_records(
    [
        validation_test_user:user_001,
        validation_test_user:user_002
    ],
    "MEMBER_IDS",
    "validation_test_user",
    true
);


-- ============================================================================
-- TEST 4 — Tableau vide
-- Résultat attendu : []
-- ============================================================================

RETURN fn::validation_array_of_records(
    [],
    "MEMBER_IDS",
    "validation_test_user",
    true
);


-- ============================================================================
-- TEST 5 — Un seul Record ID
-- Résultat attendu : [validation_test_user:user_001]
-- ============================================================================

RETURN fn::validation_array_of_records(
    [
        validation_test_user:user_001
    ],
    "MEMBER_IDS",
    "validation_test_user",
    true
);


-- ============================================================================
-- TEST 6 — Table attendue avec espaces périphériques
-- Résultat attendu : [validation_test_user:user_001]
-- ============================================================================

RETURN fn::validation_array_of_records(
    [
        validation_test_user:user_001
    ],
    "MEMBER_IDS",
    "   validation_test_user   ",
    true
);


-- ============================================================================
-- TEST 7 — Plusieurs tables autorisées
-- Résultat attendu : deux Record IDs provenant de tables différentes
-- ============================================================================

RETURN fn::validation_array_of_records(
    [
        validation_test_user:user_001,
        booking_team:team_001
    ],
    "RESOURCE_IDS",
    NONE,
    false
);


-- ============================================================================
-- TEST 8 — Record ID inexistant accepté sans contrôle d'existence
-- Résultat attendu : [validation_test_user:missing_user]
-- ============================================================================

RETURN fn::validation_array_of_records(
    [
        validation_test_user:missing_user
    ],
    "MEMBER_IDS",
    "validation_test_user",
    false
);


-- ============================================================================
-- TEST 9 — Doublons acceptés par cette fonction
-- Résultat attendu : deux Record IDs identiques
-- ============================================================================

RETURN fn::validation_array_of_records(
    [
        validation_test_user:user_001,
        validation_test_user:user_001
    ],
    "MEMBER_IDS",
    "validation_test_user",
    true
);


-- ============================================================================
-- TEST 10 — Valeur absente
-- Erreur attendue : MEMBER_IDS_REQUIRED
-- ============================================================================

RETURN fn::validation_array_of_records(
    NONE,
    "MEMBER_IDS",
    "validation_test_user",
    true
);


-- ============================================================================
-- TEST 11 — Valeur globale NULL
-- Erreur attendue : MEMBER_IDS_NULL_NOT_ALLOWED
-- ============================================================================

RETURN fn::validation_array_of_records(
    NULL,
    "MEMBER_IDS",
    "validation_test_user",
    true
);


-- ============================================================================
-- TEST 12 — Record ID seul à la place d'un tableau
-- Erreur attendue : MEMBER_IDS_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_array_of_records(
    validation_test_user:user_001,
    "MEMBER_IDS",
    "validation_test_user",
    true
);


-- ============================================================================
-- TEST 13 — Chaîne à la place d'un tableau
-- Erreur attendue : MEMBER_IDS_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_array_of_records(
    "validation_test_user:user_001",
    "MEMBER_IDS",
    "validation_test_user",
    true
);


-- ============================================================================
-- TEST 14 — Objet à la place d'un tableau
-- Erreur attendue : MEMBER_IDS_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_array_of_records(
    {
        id: validation_test_user:user_001
    },
    "MEMBER_IDS",
    "validation_test_user",
    true
);


-- ============================================================================
-- TEST 15 — Chaîne Record ID dans le tableau
-- Erreur attendue : MEMBER_IDS_ITEM_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_array_of_records(
    [
        "validation_test_user:user_001"
    ],
    "MEMBER_IDS",
    "validation_test_user",
    true
);


-- ============================================================================
-- TEST 16 — Identifiant simple sous forme de chaîne
-- Erreur attendue : MEMBER_IDS_ITEM_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_array_of_records(
    [
        "user_001"
    ],
    "MEMBER_IDS",
    "validation_test_user",
    true
);


-- ============================================================================
-- TEST 17 — Entier dans le tableau
-- Erreur attendue : MEMBER_IDS_ITEM_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_array_of_records(
    [
        validation_test_user:user_001,
        42
    ],
    "MEMBER_IDS",
    "validation_test_user",
    true
);


-- ============================================================================
-- TEST 18 — Booléen dans le tableau
-- Erreur attendue : MEMBER_IDS_ITEM_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_array_of_records(
    [
        validation_test_user:user_001,
        true
    ],
    "MEMBER_IDS",
    "validation_test_user",
    true
);


-- ============================================================================
-- TEST 19 — NONE dans le tableau
-- Erreur attendue : MEMBER_IDS_ITEM_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_array_of_records(
    [
        validation_test_user:user_001,
        NONE
    ],
    "MEMBER_IDS",
    "validation_test_user",
    true
);


-- ============================================================================
-- TEST 20 — NULL dans le tableau
-- Erreur attendue : MEMBER_IDS_ITEM_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_array_of_records(
    [
        validation_test_user:user_001,
        NULL
    ],
    "MEMBER_IDS",
    "validation_test_user",
    true
);


-- ============================================================================
-- TEST 21 — Objet dans le tableau
-- Erreur attendue : MEMBER_IDS_ITEM_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_array_of_records(
    [
        validation_test_user:user_001,
        {
            id: validation_test_user:user_002
        }
    ],
    "MEMBER_IDS",
    "validation_test_user",
    true
);


-- ============================================================================
-- TEST 22 — Tableau imbriqué
-- Erreur attendue : MEMBER_IDS_ITEM_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_array_of_records(
    [
        validation_test_user:user_001,
        [
            validation_test_user:user_002
        ]
    ],
    "MEMBER_IDS",
    "validation_test_user",
    true
);


-- ============================================================================
-- TEST 23 — Record ID appartenant à une autre table
-- Erreur attendue : MEMBER_IDS_ITEM_INVALID_TABLE
-- ============================================================================

RETURN fn::validation_array_of_records(
    [
        validation_test_user:user_001,
        booking_team:team_001
    ],
    "MEMBER_IDS",
    "validation_test_user",
    false
);


-- ============================================================================
-- TEST 24 — Tous les Record IDs appartiennent à une mauvaise table
-- Erreur attendue : MEMBER_IDS_ITEM_INVALID_TABLE
-- ============================================================================

RETURN fn::validation_array_of_records(
    [
        booking_team:team_001,
        booking_team:team_002
    ],
    "MEMBER_IDS",
    "validation_test_user",
    false
);


-- ============================================================================
-- TEST 25 — Enregistrement inexistant avec contrôle d'existence
-- Erreur attendue : MEMBER_IDS_ITEM_NOT_FOUND
-- ============================================================================

RETURN fn::validation_array_of_records(
    [
        validation_test_user:missing_user
    ],
    "MEMBER_IDS",
    "validation_test_user",
    true
);


-- ============================================================================
-- TEST 26 — Un enregistrement existant et un inexistant
-- Erreur attendue : MEMBER_IDS_ITEM_NOT_FOUND
-- ============================================================================

RETURN fn::validation_array_of_records(
    [
        validation_test_user:user_001,
        validation_test_user:missing_user
    ],
    "MEMBER_IDS",
    "validation_test_user",
    true
);


-- ============================================================================
-- TEST 27 — Table attendue vide
-- Erreur attendue : VALIDATION_INVALID_TABLE_NAME
-- ============================================================================

RETURN fn::validation_array_of_records(
    [
        validation_test_user:user_001
    ],
    "MEMBER_IDS",
    "     ",
    true
);


-- ============================================================================
-- TEST 28 — Nom technique vide
-- Erreur attendue : VALIDATION_INVALID_FIELD_NAME
-- ============================================================================

RETURN fn::validation_array_of_records(
    [
        validation_test_user:user_001
    ],
    "     ",
    "validation_test_user",
    true
);


-- ============================================================================
-- TEST 29 — Validation complète avec longueur, type et unicité
-- Résultat attendu : deux Record IDs distincts
-- ============================================================================

LET $member_ids = fn::validation_array_length(
    [
        validation_test_user:user_001,
        validation_test_user:user_002
    ],
    "MEMBER_IDS",
    1,
    100
);

LET $member_ids = fn::validation_array_of_records(
    $member_ids,
    "MEMBER_IDS",
    "validation_test_user",
    true
);

RETURN fn::validation_array_unique(
    $member_ids,
    "MEMBER_IDS"
);


-- ============================================================================
-- TEST 30 — Type valide mais doublons présents
-- Erreur attendue : MEMBER_IDS_DUPLICATES_NOT_ALLOWED
-- ============================================================================

LET $member_ids = fn::validation_array_of_records(
    [
        validation_test_user:user_001,
        validation_test_user:user_001
    ],
    "MEMBER_IDS",
    "validation_test_user",
    true
);

RETURN fn::validation_array_unique(
    $member_ids,
    "MEMBER_IDS"
);


-- ============================================================================
-- TEST 31 — Suppression des données utilisées par les tests
-- Résultat attendu : suppression des deux enregistrements
-- ============================================================================

DELETE validation_test_user:user_001;
DELETE validation_test_user:user_002;