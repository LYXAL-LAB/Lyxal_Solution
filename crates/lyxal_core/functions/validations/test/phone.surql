-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/phone.test.surql
-- Fonction     : fn::validation_phone
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
-- TEST 1 — Numéro français valide
-- Résultat attendu : "+33612345678"
-- ============================================================================

RETURN fn::validation_phone(
    "+33612345678",
    "USER_PHONE"
);


-- ============================================================================
-- TEST 2 — Suppression des espaces périphériques
-- Résultat attendu : "+33612345678"
-- ============================================================================

RETURN fn::validation_phone(
    "   +33612345678   ",
    "USER_PHONE"
);


-- ============================================================================
-- TEST 3 — Numéro britannique valide
-- Résultat attendu : "+442071234567"
-- ============================================================================

RETURN fn::validation_phone(
    "+442071234567",
    "CONTACT_PHONE"
);


-- ============================================================================
-- TEST 4 — Numéro américain valide
-- Résultat attendu : "+12125551234"
-- ============================================================================

RETURN fn::validation_phone(
    "+12125551234",
    "CONTACT_PHONE"
);


-- ============================================================================
-- TEST 5 — Numéro marocain valide
-- Résultat attendu : "+212612345678"
-- ============================================================================

RETURN fn::validation_phone(
    "+212612345678",
    "CONTACT_PHONE"
);


-- ============================================================================
-- TEST 6 — Numéro contenant exactement 8 chiffres
-- Résultat attendu : "+12345678"
-- ============================================================================

RETURN fn::validation_phone(
    "+12345678",
    "CONTACT_PHONE"
);


-- ============================================================================
-- TEST 7 — Numéro contenant exactement 15 chiffres
-- Résultat attendu : "+123456789012345"
-- ============================================================================

RETURN fn::validation_phone(
    "+123456789012345",
    "CONTACT_PHONE"
);


-- ============================================================================
-- TEST 8 — Valeur absente
-- Erreur attendue : USER_PHONE_REQUIRED
-- ============================================================================

RETURN fn::validation_phone(
    NONE,
    "USER_PHONE"
);


-- ============================================================================
-- TEST 9 — Valeur NULL
-- Erreur attendue : USER_PHONE_NULL_NOT_ALLOWED
-- ============================================================================

RETURN fn::validation_phone(
    NULL,
    "USER_PHONE"
);


-- ============================================================================
-- TEST 10 — Chaîne vide
-- Erreur attendue : USER_PHONE_REQUIRED
-- ============================================================================

RETURN fn::validation_phone(
    "",
    "USER_PHONE"
);


-- ============================================================================
-- TEST 11 — Chaîne composée uniquement d'espaces
-- Erreur attendue : USER_PHONE_REQUIRED
-- ============================================================================

RETURN fn::validation_phone(
    "     ",
    "USER_PHONE"
);


-- ============================================================================
-- TEST 12 — Entier à la place d'une chaîne
-- Erreur attendue : USER_PHONE_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_phone(
    33612345678,
    "USER_PHONE"
);


-- ============================================================================
-- TEST 13 — Booléen à la place d'une chaîne
-- Erreur attendue : USER_PHONE_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_phone(
    true,
    "USER_PHONE"
);


-- ============================================================================
-- TEST 14 — Tableau à la place d'une chaîne
-- Erreur attendue : USER_PHONE_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_phone(
    ["+33612345678"],
    "USER_PHONE"
);


-- ============================================================================
-- TEST 15 — Objet à la place d'une chaîne
-- Erreur attendue : USER_PHONE_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_phone(
    {
        phone: "+33612345678"
    },
    "USER_PHONE"
);


-- ============================================================================
-- TEST 16 — Numéro français au format national
-- Erreur attendue : USER_PHONE_INVALID_FORMAT
-- ============================================================================

RETURN fn::validation_phone(
    "0612345678",
    "USER_PHONE"
);


-- ============================================================================
-- TEST 17 — Préfixe international écrit avec 00
-- Erreur attendue : USER_PHONE_INVALID_FORMAT
-- ============================================================================

RETURN fn::validation_phone(
    "0033612345678",
    "USER_PHONE"
);


-- ============================================================================
-- TEST 18 — Numéro contenant des espaces internes
-- Erreur attendue : USER_PHONE_INVALID_FORMAT
-- ============================================================================

RETURN fn::validation_phone(
    "+33 6 12 34 56 78",
    "USER_PHONE"
);


-- ============================================================================
-- TEST 19 — Numéro contenant des tirets
-- Erreur attendue : USER_PHONE_INVALID_FORMAT
-- ============================================================================

RETURN fn::validation_phone(
    "+33-6-12-34-56-78",
    "USER_PHONE"
);


-- ============================================================================
-- TEST 20 — Numéro contenant des points
-- Erreur attendue : USER_PHONE_INVALID_FORMAT
-- ============================================================================

RETURN fn::validation_phone(
    "+33.6.12.34.56.78",
    "USER_PHONE"
);


-- ============================================================================
-- TEST 21 — Numéro contenant des parenthèses
-- Erreur attendue : USER_PHONE_INVALID_FORMAT
-- ============================================================================

RETURN fn::validation_phone(
    "(+33)612345678",
    "USER_PHONE"
);


-- ============================================================================
-- TEST 22 — Premier chiffre égal à zéro après le signe +
-- Erreur attendue : USER_PHONE_INVALID_FORMAT
-- ============================================================================

RETURN fn::validation_phone(
    "+0612345678",
    "USER_PHONE"
);


-- ============================================================================
-- TEST 23 — Numéro trop court
-- Erreur attendue : USER_PHONE_INVALID_FORMAT
-- ============================================================================

RETURN fn::validation_phone(
    "+1234567",
    "USER_PHONE"
);


-- ============================================================================
-- TEST 24 — Numéro trop long
-- Erreur attendue : USER_PHONE_INVALID_FORMAT
-- ============================================================================

RETURN fn::validation_phone(
    "+1234567890123456",
    "USER_PHONE"
);


-- ============================================================================
-- TEST 25 — Numéro contenant une lettre
-- Erreur attendue : USER_PHONE_INVALID_FORMAT
-- ============================================================================

RETURN fn::validation_phone(
    "+33612345A78",
    "USER_PHONE"
);


-- ============================================================================
-- TEST 26 — Signe + uniquement
-- Erreur attendue : USER_PHONE_INVALID_FORMAT
-- ============================================================================

RETURN fn::validation_phone(
    "+",
    "USER_PHONE"
);


-- ============================================================================
-- TEST 27 — Nom technique vide
-- Erreur attendue : VALIDATION_INVALID_FIELD_NAME
-- ============================================================================

RETURN fn::validation_phone(
    "+33612345678",
    "     "
);