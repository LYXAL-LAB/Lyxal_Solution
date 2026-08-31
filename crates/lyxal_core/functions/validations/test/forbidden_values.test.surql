-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/forbidden_values.test.surql
-- Fonction     : fn::validation_forbidden_values
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW interrompent l'exécution.
-- Dans Surrealist, sélectionner individuellement le test concerné lorsqu'une
-- erreur est attendue.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Valeur autorisée
-- Résultat attendu : "member"
-- ============================================================================
RETURN fn::validation_forbidden_values(
    "member", "ROLE", ["root", "system"], false, true
);

-- ============================================================================
-- TEST 2 — Valeur interdite
-- Erreur attendue : ROLE_FORBIDDEN_VALUE
-- ============================================================================
RETURN fn::validation_forbidden_values(
    "root", "ROLE", ["root", "system"], false, true
);

-- ============================================================================
-- TEST 3 — Interdiction insensible à la casse
-- Erreur attendue : ROLE_FORBIDDEN_VALUE
-- ============================================================================
RETURN fn::validation_forbidden_values(
    "ROOT", "ROLE", ["root"], false, true
);

-- ============================================================================
-- TEST 4 — Comparaison sensible à la casse
-- Résultat attendu : "ROOT"
-- ============================================================================
RETURN fn::validation_forbidden_values(
    "ROOT", "ROLE", ["root"], true, true
);

-- ============================================================================
-- TEST 5 — Liste vide
-- Erreur attendue : VALIDATION_EMPTY_FORBIDDEN_VALUES
-- ============================================================================
RETURN fn::validation_forbidden_values(
    "member", "ROLE", [], false, true
);
