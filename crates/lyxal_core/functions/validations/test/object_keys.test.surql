-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/object_keys.test.surql
-- Fonction     : fn::validation_object_keys
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Objet conforme
-- Résultat attendu : objet reçu
-- ============================================================================
RETURN fn::validation_object_keys(
    { name: "Lyxal", enabled: true },
    "CONFIG",
    ["name"],
    ["name", "enabled"]
);

-- ============================================================================
-- TEST 2 — Clé obligatoire manquante
-- Erreur attendue : CONFIG_MISSING_REQUIRED_KEY
-- ============================================================================
RETURN fn::validation_object_keys(
    { enabled: true },
    "CONFIG",
    ["name"],
    ["name", "enabled"]
);

-- ============================================================================
-- TEST 3 — Clé inconnue
-- Erreur attendue : CONFIG_UNKNOWN_KEY
-- ============================================================================
RETURN fn::validation_object_keys(
    { name: "Lyxal", secret: true },
    "CONFIG",
    ["name"],
    ["name", "enabled"]
);

-- ============================================================================
-- TEST 4 — Clé requise non autorisée par la configuration
-- Erreur attendue : VALIDATION_REQUIRED_KEY_NOT_ALLOWED
-- ============================================================================
RETURN fn::validation_object_keys(
    { name: "Lyxal" },
    "CONFIG",
    ["name"],
    ["enabled"]
);
