-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/object_values_type.test.surql
-- Fonction     : fn::validation_object_values_type
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Map de strings valide
-- Résultat attendu : objet reçu
-- ============================================================================
RETURN fn::validation_object_values_type(
    { first_name: "Yaniss", city: "Cahors" },
    "METADATA",
    "string",
    false
);

-- ============================================================================
-- TEST 2 — Map d'entiers valide
-- Résultat attendu : objet reçu
-- ============================================================================
RETURN fn::validation_object_values_type(
    { min: 1, max: 10 },
    "LIMITS",
    "int",
    false
);

-- ============================================================================
-- TEST 3 — Valeur de type différent
-- Erreur attendue : METADATA_INVALID_OBJECT_VALUE_TYPE
-- ============================================================================
RETURN fn::validation_object_values_type(
    { name: "Lyxal", enabled: true },
    "METADATA",
    "string",
    false
);

-- ============================================================================
-- TEST 4 — Objet vide interdit
-- Erreur attendue : METADATA_EMPTY_NOT_ALLOWED
-- ============================================================================
RETURN fn::validation_object_values_type(
    {},
    "METADATA",
    "string",
    false
);
