-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/locale.test.surql
-- Fonction     : fn::validation_locale
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Locale française
-- Résultat attendu : "fr-FR"
-- ============================================================================
RETURN fn::validation_locale(
    "fr_fr",
    "LOCALE",
    true
);

-- ============================================================================
-- TEST 2 — Langue seule
-- Résultat attendu : "fr"
-- ============================================================================
RETURN fn::validation_locale(
    "FR",
    "LOCALE",
    false
);

-- ============================================================================
-- TEST 3 — Région obligatoire
-- Erreur attendue : LOCALE_REGION_REQUIRED
-- ============================================================================
RETURN fn::validation_locale(
    "fr",
    "LOCALE",
    true
);

-- ============================================================================
-- TEST 4 — Locale trop complexe
-- Erreur attendue : LOCALE_INVALID_LOCALE
-- ============================================================================
RETURN fn::validation_locale(
    "zh-Hans-CN",
    "LOCALE",
    false
);
