-- ============================================================================
-- TEST 1 — Tableau de chaînes valide
-- Résultat attendu : ["owner", "admin"]
-- ============================================================================

RETURN fn::validation_array_not_empty(
    ["owner", "admin"],
    "ROLES"
);

-- ============================================================================
-- TEST 2 — Tableau contenant un entier
-- Résultat attendu : [1]
-- ============================================================================

RETURN fn::validation_array_not_empty(
    [1],
    "VALUES"
);

-- ============================================================================
-- TEST 3 — Tableau de Record IDs valide
-- Résultat attendu : [identity_user:user_001, identity_user:user_002]
-- ============================================================================

RETURN fn::validation_array_not_empty(
    [
        identity_user:user_001,
        identity_user:user_002
    ],
    "MEMBER_IDS"
);

-- ============================================================================
-- TEST 4 — Tableau d'objets valide
-- Résultat attendu : [{ name: "Premier élément" }]
-- ============================================================================

RETURN fn::validation_array_not_empty(
    [
        {
            name: "Premier élément"
        }
    ],
    "ITEMS"
);

-- ============================================================================
-- TEST 5 — Valeur absente
-- Erreur attendue : MEMBER_IDS_REQUIRED
-- ============================================================================

RETURN fn::validation_array_not_empty(
    NONE,
    "MEMBER_IDS"
);

-- ============================================================================
-- TEST 6 — Tableau vide
-- Erreur attendue : MEMBER_IDS_EMPTY
-- ============================================================================

RETURN fn::validation_array_not_empty(
    [],
    "MEMBER_IDS"
);

-- ============================================================================
-- TEST 7 — Chaîne à la place d'un tableau
-- Erreur attendue : MEMBER_IDS_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_array_not_empty(
    "identity_user:user_001",
    "MEMBER_IDS"
);

-- ============================================================================
-- TEST 8 — Objet à la place d'un tableau
-- Erreur attendue : ITEMS_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_array_not_empty(
    {
        name: "Premier élément"
    },
    "ITEMS"
);

-- ============================================================================
-- TEST 9 — Entier à la place d'un tableau
-- Erreur attendue : VALUES_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_array_not_empty(
    1,
    "VALUES"
);

-- ============================================================================
-- TEST 10 — Booléen à la place d'un tableau
-- Erreur attendue : VALUES_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_array_not_empty(
    true,
    "VALUES"
);

-- ============================================================================
-- TEST 11 — Nom technique vide
-- Erreur attendue : VALIDATION_INVALID_FIELD_NAME
-- ============================================================================

RETURN fn::validation_array_not_empty(
    ["owner"],
    "     "
);

-- ============================================================================
-- TEST 12 — Tableau contenant NONE
-- Résultat attendu : [NONE]
-- ============================================================================

RETURN fn::validation_array_not_empty(
    [NONE],
    "VALUES"
);