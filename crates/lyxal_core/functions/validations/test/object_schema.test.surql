-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/object_schema.test.surql
-- Fonction     : fn::validation_object_schema
-- Domaine      : Core / Validation / Advanced
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
RETURN fn::validation_object_schema(
    {
        name: "Lyxal",
        enabled: true,
        retries: 3
    },
    "CONFIG",
    {
        name: "string",
        enabled: "bool",
        retries: "int"
    },
    ["name", "enabled"],
    false
);

-- ============================================================================
-- TEST 2 — Clé obligatoire manquante
-- Erreur attendue : CONFIG_MISSING_REQUIRED_KEY
-- ============================================================================
RETURN fn::validation_object_schema(
    {
        enabled: true
    },
    "CONFIG",
    {
        name: "string",
        enabled: "bool"
    },
    ["name"],
    false
);

-- ============================================================================
-- TEST 3 — Type incorrect
-- Erreur attendue : CONFIG_SCHEMA_TYPE_MISMATCH
-- ============================================================================
RETURN fn::validation_object_schema(
    {
        name: "Lyxal",
        enabled: "true"
    },
    "CONFIG",
    {
        name: "string",
        enabled: "bool"
    },
    ["name", "enabled"],
    false
);
