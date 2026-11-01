-- ============================================================================
-- TEST 1 — Création de l'enregistrement utilisé par les tests
-- Résultat attendu : création de validation_test:existing_record
-- ============================================================================

CREATE validation_test:existing_record SET
    name = "Enregistrement de test";

-- ============================================================================
-- TEST 2 — Enregistrement existant
-- Résultat attendu : validation_test:existing_record
-- ============================================================================

RETURN fn::validation_record_exists(
    validation_test:existing_record,
    "TEST_RECORD_ID"
);

-- ============================================================================
-- TEST 3 — Enregistrement inexistant
-- Erreur attendue : TEST_RECORD_ID_NOT_FOUND
-- ============================================================================

RETURN fn::validation_record_exists(
    validation_test:missing_record,
    "TEST_RECORD_ID"
);

-- ============================================================================
-- TEST 4 — Nom technique vide
-- Erreur attendue : VALIDATION_INVALID_FIELD_NAME
-- ============================================================================

RETURN fn::validation_record_exists(
    validation_test:existing_record,
    "     "
);

-- ============================================================================
-- TEST 5 — Utilisation après validation d'une chaîne Record ID
-- Résultat attendu : validation_test:existing_record
-- ============================================================================

LET $record_id = fn::validation_record(
    "validation_test:existing_record",
    "TEST_RECORD_ID",
    "validation_test"
);

RETURN fn::validation_record_exists(
    $record_id,
    "TEST_RECORD_ID"
);

-- ============================================================================
-- TEST 6 — Identifiant simple puis contrôle d'existence
-- Résultat attendu : validation_test:existing_record
-- ============================================================================

LET $record_id = fn::validation_record(
    "existing_record",
    "TEST_RECORD_ID",
    "validation_test"
);

RETURN fn::validation_record_exists(
    $record_id,
    "TEST_RECORD_ID"
);

-- ============================================================================
-- TEST 7 — Suppression des données utilisées par les tests
-- Résultat attendu : suppression de validation_test:existing_record
-- ============================================================================

DELETE validation_test:existing_record;

