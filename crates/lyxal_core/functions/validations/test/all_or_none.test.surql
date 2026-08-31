-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/all_or_none.test.surql
-- Fonction     : fn::validation_all_or_none
-- Domaine      : Core / Validation / Advanced
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Tout renseigné
-- Résultat attendu : tableau reçu
-- ============================================================================
RETURN fn::validation_all_or_none(
    ["30006", "00001", "12345678901", "89"],
    "RIB"
);

-- ============================================================================
-- TEST 2 — Tout absent
-- Résultat attendu : tableau reçu
-- ============================================================================
RETURN fn::validation_all_or_none(
    [NONE, NONE, NONE, NONE],
    "RIB"
);

-- ============================================================================
-- TEST 3 — Partiellement renseigné
-- Erreur attendue : RIB_ALL_OR_NONE_REQUIRED
-- ============================================================================
RETURN fn::validation_all_or_none(
    ["30006", "00001", NONE, NONE],
    "RIB"
);
