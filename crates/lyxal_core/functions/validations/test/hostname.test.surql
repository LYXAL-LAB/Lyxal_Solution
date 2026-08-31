-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/hostname.test.surql
-- Fonction     : fn::validation_hostname
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Nom d'hôte complet
-- Résultat attendu : "api.lyxal.com"
-- ============================================================================
RETURN fn::validation_hostname("API.LYXAL.COM", "HOSTNAME", false);

-- ============================================================================
-- TEST 2 — Nom local autorisé
-- Résultat attendu : "localhost"
-- ============================================================================
RETURN fn::validation_hostname("localhost", "HOSTNAME", true);

-- ============================================================================
-- TEST 3 — Nom local interdit
-- Erreur attendue : HOSTNAME_SINGLE_LABEL_NOT_ALLOWED
-- ============================================================================
RETURN fn::validation_hostname("localhost", "HOSTNAME", false);

-- ============================================================================
-- TEST 4 — Tiret initial interdit
-- Erreur attendue : HOSTNAME_INVALID_HOSTNAME
-- ============================================================================
RETURN fn::validation_hostname("-api.lyxal.com", "HOSTNAME", false);

-- ============================================================================
-- TEST 5 — Label vide
-- Erreur attendue : HOSTNAME_INVALID_HOSTNAME
-- ============================================================================
RETURN fn::validation_hostname("api..lyxal.com", "HOSTNAME", false);
