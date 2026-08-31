-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/record_id.test.surql
-- Fonction     : fn::validation_record_id
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Record ID valide
-- Résultat attendu : user:yaniss
-- ============================================================================
RETURN fn::validation_record_id(
    user:yaniss, "USER_ID", NONE
);

-- ============================================================================
-- TEST 2 — Table autorisée
-- Résultat attendu : user:yaniss
-- ============================================================================
RETURN fn::validation_record_id(
    user:yaniss, "USER_ID", ["user", "identity_user"]
);

-- ============================================================================
-- TEST 3 — Table interdite
-- Erreur attendue : USER_ID_RECORD_TABLE_NOT_ALLOWED
-- ============================================================================
RETURN fn::validation_record_id(
    booking:one, "USER_ID", ["user"]
);

-- ============================================================================
-- TEST 4 — Chaîne non convertie
-- Erreur attendue : USER_ID_INVALID_TYPE
-- ============================================================================
RETURN fn::validation_record_id(
    "user:yaniss", "USER_ID", ["user"]
);

-- ============================================================================
-- TEST 5 — Liste de tables vide
-- Erreur attendue : VALIDATION_EMPTY_ALLOWED_TABLES
-- ============================================================================
RETURN fn::validation_record_id(
    user:yaniss, "USER_ID", []
);
