-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/uuid_v7.test.surql
-- Fonction     : fn::validation_uuid_v7
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — UUID v7 typé
-- Résultat attendu : UUID reçu
-- ============================================================================
RETURN fn::validation_uuid_v7(
    u"018a6680-bef9-701b-9025-e1754f296a0f",
    "ID",
    false
);

-- ============================================================================
-- TEST 2 — UUID v7 textuel autorisé
-- Résultat attendu : chaîne reçue
-- ============================================================================
RETURN fn::validation_uuid_v7(
    "018a6680-bef9-701b-9025-e1754f296a0f",
    "ID",
    true
);

-- ============================================================================
-- TEST 3 — UUID v4 refusé
-- Erreur attendue : ID_INVALID_UUID_V7
-- ============================================================================
RETURN fn::validation_uuid_v7(
    u"550e8400-e29b-41d4-a716-446655440000",
    "ID",
    false
);

-- ============================================================================
-- TEST 4 — Chaîne interdite
-- Erreur attendue : ID_STRING_UUID_NOT_ALLOWED
-- ============================================================================
RETURN fn::validation_uuid_v7(
    "018a6680-bef9-701b-9025-e1754f296a0f",
    "ID",
    false
);
