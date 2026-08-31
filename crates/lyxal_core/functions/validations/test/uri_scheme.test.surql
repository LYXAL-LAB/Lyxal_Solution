-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/uri_scheme.test.surql
-- Fonction     : fn::validation_uri_scheme
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Schéma HTTPS
-- Résultat attendu : "https"
-- ============================================================================
RETURN fn::validation_uri_scheme("HTTPS", "SCHEME", NONE);

-- ============================================================================
-- TEST 2 — Schéma personnalisé valide
-- Résultat attendu : "lyxal+secure"
-- ============================================================================
RETURN fn::validation_uri_scheme(
    "lyxal+secure", "SCHEME", NONE
);

-- ============================================================================
-- TEST 3 — Schéma autorisé
-- Résultat attendu : "https"
-- ============================================================================
RETURN fn::validation_uri_scheme(
    "https", "SCHEME", ["http", "https"]
);

-- ============================================================================
-- TEST 4 — Schéma interdit
-- Erreur attendue : SCHEME_URI_SCHEME_NOT_ALLOWED
-- ============================================================================
RETURN fn::validation_uri_scheme(
    "ftp", "SCHEME", ["http", "https"]
);

-- ============================================================================
-- TEST 5 — Premier caractère invalide
-- Erreur attendue : SCHEME_INVALID_URI_SCHEME
-- ============================================================================
RETURN fn::validation_uri_scheme(
    "1http", "SCHEME", NONE
);
