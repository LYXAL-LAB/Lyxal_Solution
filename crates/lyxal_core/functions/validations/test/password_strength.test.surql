-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/password_strength.test.surql
-- Fonction     : fn::validation_password_strength
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Mot de passe valide
-- Résultat attendu : valeur reçue
-- ============================================================================
RETURN fn::validation_password_strength(
    "Lyxal-2026-Secure!",
    "PASSWORD",
    12,
    128,
    true,
    true,
    true,
    true
);

-- ============================================================================
-- TEST 2 — Trop court
-- Erreur attendue : PASSWORD_TOO_SHORT
-- ============================================================================
RETURN fn::validation_password_strength(
    "Aa1!",
    "PASSWORD",
    12,
    128,
    true,
    true,
    true,
    true
);

-- ============================================================================
-- TEST 3 — Majuscule manquante
-- Erreur attendue : PASSWORD_UPPERCASE_REQUIRED
-- ============================================================================
RETURN fn::validation_password_strength(
    "lyxal-2026-secure!",
    "PASSWORD",
    12,
    128,
    true,
    true,
    true,
    true
);

-- ============================================================================
-- TEST 4 — Caractère spécial manquant
-- Erreur attendue : PASSWORD_SPECIAL_CHARACTER_REQUIRED
-- ============================================================================
RETURN fn::validation_password_strength(
    "Lyxal2026Secure",
    "PASSWORD",
    12,
    128,
    true,
    true,
    true,
    true
);
