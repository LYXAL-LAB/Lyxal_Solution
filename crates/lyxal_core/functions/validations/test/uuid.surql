-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/uuid.test.surql
-- Fonction     : fn::validation_uuid
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW interrompent l'exécution du
-- bloc. Dans Surrealist, sélectionner uniquement le test à exécuter lorsque
-- celui-ci attend une erreur.
-- ============================================================================


-- ============================================================================
-- TEST 1 — UUID valide
-- Résultat attendu : u"018a6680-bef9-701b-9025-e1754f296a0f"
-- ============================================================================

RETURN fn::validation_uuid(
    u"018a6680-bef9-701b-9025-e1754f296a0f",
    "PUBLIC_ID"
);


-- ============================================================================
-- TEST 2 — Second UUID valide
-- Résultat attendu : u"0191f946-936f-7223-bef5-aebbc527ad80"
-- ============================================================================

RETURN fn::validation_uuid(
    u"0191f946-936f-7223-bef5-aebbc527ad80",
    "CORRELATION_ID"
);


-- ============================================================================
-- TEST 3 — UUID généré dynamiquement
-- Résultat attendu : une valeur de type uuid
-- ============================================================================

LET $generated_uuid = rand::uuid();

RETURN fn::validation_uuid(
    $generated_uuid,
    "REQUEST_ID"
);


-- ============================================================================
-- TEST 4 — Valeur absente
-- Erreur attendue : PUBLIC_ID_REQUIRED
-- ============================================================================

RETURN fn::validation_uuid(
    NONE,
    "PUBLIC_ID"
);


-- ============================================================================
-- TEST 5 — Valeur NULL
-- Erreur attendue : PUBLIC_ID_NULL_NOT_ALLOWED
-- ============================================================================

RETURN fn::validation_uuid(
    NULL,
    "PUBLIC_ID"
);


-- ============================================================================
-- TEST 6 — Chaîne contenant un UUID
-- Erreur attendue : PUBLIC_ID_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_uuid(
    "018a6680-bef9-701b-9025-e1754f296a0f",
    "PUBLIC_ID"
);


-- ============================================================================
-- TEST 7 — Record ID à la place d'un UUID
-- Erreur attendue : PUBLIC_ID_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_uuid(
    identity_user:user_001,
    "PUBLIC_ID"
);


-- ============================================================================
-- TEST 8 — Entier à la place d'un UUID
-- Erreur attendue : PUBLIC_ID_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_uuid(
    123456,
    "PUBLIC_ID"
);


-- ============================================================================
-- TEST 9 — Booléen à la place d'un UUID
-- Erreur attendue : PUBLIC_ID_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_uuid(
    true,
    "PUBLIC_ID"
);


-- ============================================================================
-- TEST 10 — Tableau à la place d'un UUID
-- Erreur attendue : PUBLIC_ID_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_uuid(
    [
        u"018a6680-bef9-701b-9025-e1754f296a0f"
    ],
    "PUBLIC_ID"
);


-- ============================================================================
-- TEST 11 — Objet à la place d'un UUID
-- Erreur attendue : PUBLIC_ID_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_uuid(
    {
        value: u"018a6680-bef9-701b-9025-e1754f296a0f"
    },
    "PUBLIC_ID"
);


-- ============================================================================
-- TEST 12 — Datetime à la place d'un UUID
-- Erreur attendue : PUBLIC_ID_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_uuid(
    d"2026-08-02T10:00:00Z",
    "PUBLIC_ID"
);


-- ============================================================================
-- TEST 13 — Conversion explicite d'une chaîne avant validation
-- Résultat attendu : u"0191f946-936f-7223-bef5-aebbc527ad80"
-- ============================================================================

LET $converted_uuid = type::uuid(
    "0191f946-936f-7223-bef5-aebbc527ad80"
);

RETURN fn::validation_uuid(
    $converted_uuid,
    "EXTERNAL_ID"
);


-- ============================================================================
-- TEST 14 — Nom technique vide
-- Erreur attendue : VALIDATION_INVALID_FIELD_NAME
-- ============================================================================

RETURN fn::validation_uuid(
    u"018a6680-bef9-701b-9025-e1754f296a0f",
    "     "
);