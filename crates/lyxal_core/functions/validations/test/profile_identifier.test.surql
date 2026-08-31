-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/profile_identifier.test.surql
-- Fonction     : fn::validation_profile_identifier
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Identifiant valide
-- Résultat attendu : "yaniss.dubreucq"
-- ============================================================================
RETURN fn::validation_profile_identifier(
    "Yaniss.Dubreucq",
    "PROFILE_ID",
    3,
    64
);

-- ============================================================================
-- TEST 2 — Tiret valide
-- Résultat attendu : "yaniss-btp"
-- ============================================================================
RETURN fn::validation_profile_identifier(
    "yaniss-btp",
    "PROFILE_ID",
    3,
    64
);

-- ============================================================================
-- TEST 3 — Séparateur final interdit
-- Erreur attendue : PROFILE_ID_INVALID_PROFILE_IDENTIFIER
-- ============================================================================
RETURN fn::validation_profile_identifier(
    "yaniss-",
    "PROFILE_ID",
    3,
    64
);

-- ============================================================================
-- TEST 4 — Séparateur répété
-- Erreur attendue : PROFILE_ID_INVALID_BOUNDARY
-- ============================================================================
RETURN fn::validation_profile_identifier(
    "yaniss__btp",
    "PROFILE_ID",
    3,
    64
);
