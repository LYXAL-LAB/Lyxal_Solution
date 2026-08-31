-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/lyxal_namespace.test.surql
-- Fonction     : fn::validation_lyxal_namespace
-- Domaine      : Core / Validation / Lyxal OS
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Namespace valide
-- Résultat attendu : "lyxal_core"
-- ============================================================================
RETURN fn::validation_lyxal_namespace(
    "Lyxal_Core",
    "NAMESPACE",
    2,
    64
);

-- ============================================================================
-- TEST 2 — Namespace avec tiret
-- Résultat attendu : "client-france"
-- ============================================================================
RETURN fn::validation_lyxal_namespace(
    "client-france",
    "NAMESPACE",
    2,
    64
);

-- ============================================================================
-- TEST 3 — Chiffre initial interdit
-- Erreur attendue : NAMESPACE_INVALID_NAMESPACE
-- ============================================================================
RETURN fn::validation_lyxal_namespace(
    "2client",
    "NAMESPACE",
    2,
    64
);

-- ============================================================================
-- TEST 4 — Séparateur répété
-- Erreur attendue : NAMESPACE_REPEATED_SEPARATOR
-- ============================================================================
RETURN fn::validation_lyxal_namespace(
    "client__france",
    "NAMESPACE",
    2,
    64
);
