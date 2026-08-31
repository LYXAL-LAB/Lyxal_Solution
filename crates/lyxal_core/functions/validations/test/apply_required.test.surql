-- ============================================================================
-- LYXAL OS — TESTS VALIDATION ENGINE
-- ============================================================================
-- Fichier      : core/validation/tests/apply_required.test.surql
-- Fonction     : fn::validation_apply_required
-- Version      : 1.0.0
--
-- Les tests qui attendent un THROW doivent être exécutés individuellement.
-- ============================================================================


-- TEST 1 — Valeur requise présente
RETURN fn::validation_apply_required(
    "Lyxal",
    "NAME",
    true,
    false
);

-- TEST 2 — Valeur requise absente
-- Erreur attendue : NAME_REQUIRED
RETURN fn::validation_apply_required(
    NONE,
    "NAME",
    true,
    false
);

-- TEST 3 — NULL autorisé
RETURN fn::validation_apply_required(
    NULL,
    "DESCRIPTION",
    false,
    true
);
