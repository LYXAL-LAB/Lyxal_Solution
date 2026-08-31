-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/array_objects.test.surql
-- Fonction     : fn::validation_array_objects
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW doivent être exécutés
-- individuellement dans Surrealist.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Tableau d'objets valide
-- Résultat attendu : objets reçus
-- ============================================================================
RETURN fn::validation_array_objects(
    [{ name: "A" }, { name: "B" }],
    "ITEMS",
    false
);

-- ============================================================================
-- TEST 2 — Objet vide autorisé
-- Résultat attendu : [{}]
-- ============================================================================
RETURN fn::validation_array_objects(
    [{}],
    "ITEMS",
    true
);

-- ============================================================================
-- TEST 3 — Objet vide interdit
-- Erreur attendue : ITEMS_EMPTY_OBJECT_ITEM_NOT_ALLOWED
-- ============================================================================
RETURN fn::validation_array_objects(
    [{}],
    "ITEMS",
    false
);

-- ============================================================================
-- TEST 4 — String présente
-- Erreur attendue : ITEMS_INVALID_OBJECT_ITEM
-- ============================================================================
RETURN fn::validation_array_objects(
    [{ name: "A" }, "B"],
    "ITEMS",
    false
);
