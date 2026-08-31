-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/timezone.test.surql
-- Fonction     : fn::validation_timezone
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Fuseau IANA valide
-- Résultat attendu : "Europe/Paris"
-- ============================================================================
RETURN fn::validation_timezone("Europe/Paris", "TIMEZONE", true);

-- ============================================================================
-- TEST 2 — Fuseau à plusieurs segments
-- Résultat attendu : "America/Argentina/Buenos_Aires"
-- ============================================================================
RETURN fn::validation_timezone(
    "America/Argentina/Buenos_Aires", "TIMEZONE", true
);

-- ============================================================================
-- TEST 3 — UTC autorisé
-- Résultat attendu : "UTC"
-- ============================================================================
RETURN fn::validation_timezone("UTC", "TIMEZONE", true);

-- ============================================================================
-- TEST 4 — UTC interdit par la convention choisie
-- Erreur attendue : TIMEZONE_INVALID_TIMEZONE
-- ============================================================================
RETURN fn::validation_timezone("UTC", "TIMEZONE", false);

-- ============================================================================
-- TEST 5 — Décalage numérique non accepté comme nom IANA
-- Erreur attendue : TIMEZONE_INVALID_TIMEZONE
-- ============================================================================
RETURN fn::validation_timezone("+02:00", "TIMEZONE", true);
