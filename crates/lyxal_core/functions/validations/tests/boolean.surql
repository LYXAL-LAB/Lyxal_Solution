-- ============================================================================
-- TEST 1 — Valeur true valide
-- Résultat attendu : true
-- ============================================================================

RETURN fn::validation_boolean(
    true,
    "ENABLED"
);

-- ============================================================================
-- TEST 2 — Valeur false valide
-- Résultat attendu : false
-- ============================================================================

RETURN fn::validation_boolean(
    false,
    "ENABLED"
);

-- ============================================================================
-- TEST 3 — Valeur absente
-- Erreur attendue : ENABLED_REQUIRED
-- ============================================================================

RETURN fn::validation_boolean(
    NONE,
    "ENABLED"
);

-- ============================================================================
-- TEST 4 — Chaîne "true"
-- Erreur attendue : ENABLED_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_boolean(
    "true",
    "ENABLED"
);

-- ============================================================================
-- TEST 5 — Chaîne "false"
-- Erreur attendue : ENABLED_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_boolean(
    "false",
    "ENABLED"
);

-- ============================================================================
-- TEST 6 — Entier 1
-- Erreur attendue : ENABLED_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_boolean(
    1,
    "ENABLED"
);

-- ============================================================================
-- TEST 7 — Entier 0
-- Erreur attendue : ENABLED_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_boolean(
    0,
    "ENABLED"
);

-- ============================================================================
-- TEST 8 — Nombre décimal
-- Erreur attendue : ENABLED_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_boolean(
    1.0dec,
    "ENABLED"
);

-- ============================================================================
-- TEST 9 — Tableau
-- Erreur attendue : ENABLED_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_boolean(
    [true],
    "ENABLED"
);

-- ============================================================================
-- TEST 10 — Objet
-- Erreur attendue : ENABLED_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_boolean(
    {
        value: true
    },
    "ENABLED"
);

-- ============================================================================
-- TEST 11 — Nom technique vide
-- Erreur attendue : VALIDATION_INVALID_FIELD_NAME
-- ============================================================================

RETURN fn::validation_boolean(
    true,
    "     "
);

