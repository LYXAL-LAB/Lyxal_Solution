-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/email.test.surql
-- Fonction     : fn::validation_email
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
-- TEST 1 — Adresse e-mail valide
-- Résultat attendu : "contact@example.com"
-- ============================================================================

RETURN fn::validation_email(
    "contact@example.com",
    "CONTACT_EMAIL",
    254
);


-- ============================================================================
-- TEST 2 — Suppression des espaces périphériques
-- Résultat attendu : "Contact@Example.com"
-- ============================================================================

RETURN fn::validation_email(
    "   Contact@Example.com   ",
    "CONTACT_EMAIL",
    254
);


-- ============================================================================
-- TEST 3 — Adresse avec sous-domaine
-- Résultat attendu : "contact@support.example.com"
-- ============================================================================

RETURN fn::validation_email(
    "contact@support.example.com",
    "CONTACT_EMAIL",
    254
);


-- ============================================================================
-- TEST 4 — Adresse contenant un signe plus
-- Résultat attendu : "yaniss+booking@example.com"
-- ============================================================================

RETURN fn::validation_email(
    "yaniss+booking@example.com",
    "USER_EMAIL",
    254
);


-- ============================================================================
-- TEST 5 — Adresse contenant des points dans la partie locale
-- Résultat attendu : "prenom.nom@example.com"
-- ============================================================================

RETURN fn::validation_email(
    "prenom.nom@example.com",
    "USER_EMAIL",
    254
);


-- ============================================================================
-- TEST 6 — Adresse sans limite maximale
-- Résultat attendu : "contact@example.com"
-- ============================================================================

RETURN fn::validation_email(
    "contact@example.com",
    "CONTACT_EMAIL",
    NONE
);


-- ============================================================================
-- TEST 7 — Valeur absente
-- Erreur attendue : USER_EMAIL_REQUIRED
-- ============================================================================

RETURN fn::validation_email(
    NONE,
    "USER_EMAIL",
    254
);


-- ============================================================================
-- TEST 8 — Valeur NULL
-- Erreur attendue : USER_EMAIL_NULL_NOT_ALLOWED
-- ============================================================================

RETURN fn::validation_email(
    NULL,
    "USER_EMAIL",
    254
);


-- ============================================================================
-- TEST 9 — Chaîne vide
-- Erreur attendue : USER_EMAIL_REQUIRED
-- ============================================================================

RETURN fn::validation_email(
    "",
    "USER_EMAIL",
    254
);


-- ============================================================================
-- TEST 10 — Chaîne composée uniquement d'espaces
-- Erreur attendue : USER_EMAIL_REQUIRED
-- ============================================================================

RETURN fn::validation_email(
    "     ",
    "USER_EMAIL",
    254
);


-- ============================================================================
-- TEST 11 — Entier à la place d'une chaîne
-- Erreur attendue : USER_EMAIL_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_email(
    12345,
    "USER_EMAIL",
    254
);


-- ============================================================================
-- TEST 12 — Booléen à la place d'une chaîne
-- Erreur attendue : USER_EMAIL_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_email(
    true,
    "USER_EMAIL",
    254
);


-- ============================================================================
-- TEST 13 — Tableau à la place d'une chaîne
-- Erreur attendue : USER_EMAIL_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_email(
    ["contact@example.com"],
    "USER_EMAIL",
    254
);


-- ============================================================================
-- TEST 14 — Objet à la place d'une chaîne
-- Erreur attendue : USER_EMAIL_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_email(
    {
        email: "contact@example.com"
    },
    "USER_EMAIL",
    254
);


-- ============================================================================
-- TEST 15 — Adresse sans arobase
-- Erreur attendue : USER_EMAIL_INVALID_FORMAT
-- ============================================================================

RETURN fn::validation_email(
    "contact.example.com",
    "USER_EMAIL",
    254
);


-- ============================================================================
-- TEST 16 — Adresse sans partie locale
-- Erreur attendue : USER_EMAIL_INVALID_FORMAT
-- ============================================================================

RETURN fn::validation_email(
    "@example.com",
    "USER_EMAIL",
    254
);


-- ============================================================================
-- TEST 17 — Adresse sans domaine
-- Erreur attendue : USER_EMAIL_INVALID_FORMAT
-- ============================================================================

RETURN fn::validation_email(
    "contact@",
    "USER_EMAIL",
    254
);


-- ============================================================================
-- TEST 18 — Adresse contenant des espaces internes
-- Erreur attendue : USER_EMAIL_INVALID_FORMAT
-- ============================================================================

RETURN fn::validation_email(
    "contact @example.com",
    "USER_EMAIL",
    254
);


-- ============================================================================
-- TEST 19 — Adresse dépassant la longueur maximale configurée
-- Erreur attendue : USER_EMAIL_TOO_LONG
-- ============================================================================

RETURN fn::validation_email(
    "contact-commercial@example.com",
    "USER_EMAIL",
    20
);


-- ============================================================================
-- TEST 20 — Longueur maximale égale à zéro
-- Erreur attendue : VALIDATION_INVALID_MAX_LENGTH
-- ============================================================================

RETURN fn::validation_email(
    "contact@example.com",
    "USER_EMAIL",
    0
);


-- ============================================================================
-- TEST 21 — Longueur maximale négative
-- Erreur attendue : VALIDATION_INVALID_MAX_LENGTH
-- ============================================================================

RETURN fn::validation_email(
    "contact@example.com",
    "USER_EMAIL",
    -1
);


-- ============================================================================
-- TEST 22 — Nom technique vide
-- Erreur attendue : VALIDATION_INVALID_FIELD_NAME
-- ============================================================================

RETURN fn::validation_email(
    "contact@example.com",
    "     ",
    254
);