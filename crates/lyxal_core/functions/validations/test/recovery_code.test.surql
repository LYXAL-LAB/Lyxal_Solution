-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/recovery_code.test.surql
-- Fonction     : fn::validation_recovery_code
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Code valide 4x4
-- Résultat attendu : "AB12-CD34-EF56-GH78"
-- ============================================================================
RETURN fn::validation_recovery_code(
    "ab12-cd34-ef56-gh78",
    "RECOVERY_CODE",
    4,
    4
);

-- ============================================================================
-- TEST 2 — Nombre de groupes invalide
-- Erreur attendue : RECOVERY_CODE_INVALID_RECOVERY_CODE
-- ============================================================================
RETURN fn::validation_recovery_code(
    "AB12-CD34",
    "RECOVERY_CODE",
    4,
    4
);

-- ============================================================================
-- TEST 3 — Groupe trop court
-- Erreur attendue : RECOVERY_CODE_INVALID_RECOVERY_CODE
-- ============================================================================
RETURN fn::validation_recovery_code(
    "AB12-CD3-EF56-GH78",
    "RECOVERY_CODE",
    4,
    4
);
