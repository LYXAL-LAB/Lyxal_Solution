-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/not_blank.test.surql
-- Fonction     : fn::validation_not_blank
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW interrompent l'exécution du
-- bloc.
--
-- Dans Surrealist, sélectionner uniquement le test concerné lorsqu'une erreur
-- est attendue.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Chaîne simple valide
-- Résultat attendu : "Lyxal"
-- ============================================================================

RETURN fn::validation_not_blank(
    "Lyxal",
    "NAME"
);


-- ============================================================================
-- TEST 2 — Chaîne avec espaces périphériques
-- Résultat attendu : "Lyxal"
-- ============================================================================

RETURN fn::validation_not_blank(
    "   Lyxal   ",
    "NAME"
);


-- ============================================================================
-- TEST 3 — Chaîne contenant plusieurs mots
-- Résultat attendu : "Lyxal Operating System"
-- ============================================================================

RETURN fn::validation_not_blank(
    "Lyxal Operating System",
    "TITLE"
);


-- ============================================================================
-- TEST 4 — Espaces internes conservés
-- Résultat attendu : "Lyxal   Operating   System"
-- ============================================================================

RETURN fn::validation_not_blank(
    "   Lyxal   Operating   System   ",
    "TITLE"
);


-- ============================================================================
-- TEST 5 — Chaîne contenant un seul caractère
-- Résultat attendu : "a"
-- ============================================================================

RETURN fn::validation_not_blank(
    "a",
    "VALUE"
);


-- ============================================================================
-- TEST 6 — Chaîne contenant un chiffre
-- Résultat attendu : "0"
-- ============================================================================

RETURN fn::validation_not_blank(
    "0",
    "VALUE"
);


-- ============================================================================
-- TEST 7 — Chaîne contenant le mot false
-- Résultat attendu : "false"
-- ============================================================================

RETURN fn::validation_not_blank(
    "false",
    "VALUE"
);


-- ============================================================================
-- TEST 8 — Chaîne contenant le mot null
-- Résultat attendu : "null"
-- ============================================================================

RETURN fn::validation_not_blank(
    "null",
    "VALUE"
);


-- ============================================================================
-- TEST 9 — Chaîne contenant le mot none
-- Résultat attendu : "none"
-- ============================================================================

RETURN fn::validation_not_blank(
    "none",
    "VALUE"
);


-- ============================================================================
-- TEST 10 — Chaîne contenant uniquement un tiret
-- Résultat attendu : "-"
-- ============================================================================

RETURN fn::validation_not_blank(
    "-",
    "VALUE"
);


-- ============================================================================
-- TEST 11 — Chaîne contenant uniquement un point
-- Résultat attendu : "."
-- ============================================================================

RETURN fn::validation_not_blank(
    ".",
    "VALUE"
);


-- ============================================================================
-- TEST 12 — Chaîne avec accents
-- Résultat attendu : "Équipe réservation"
-- ============================================================================

RETURN fn::validation_not_blank(
    "   Équipe réservation   ",
    "NAME"
);


-- ============================================================================
-- TEST 13 — Chaîne en arabe
-- Résultat attendu : "مرحبا"
-- ============================================================================

RETURN fn::validation_not_blank(
    "   مرحبا   ",
    "VALUE"
);


-- ============================================================================
-- TEST 14 — Chaîne en japonais
-- Résultat attendu : "東京"
-- ============================================================================

RETURN fn::validation_not_blank(
    "   東京   ",
    "VALUE"
);


-- ============================================================================
-- TEST 15 — Emoji
-- Résultat attendu : "🚀"
-- ============================================================================

RETURN fn::validation_not_blank(
    "   🚀   ",
    "VALUE"
);


-- ============================================================================
-- TEST 16 — Chaîne contenant un retour à la ligne interne
-- Résultat attendu : "Première ligne\nDeuxième ligne"
-- ============================================================================

RETURN fn::validation_not_blank(
    "   Première ligne\nDeuxième ligne   ",
    "DESCRIPTION"
);


-- ============================================================================
-- TEST 17 — Chaîne contenant une tabulation interne
-- Résultat attendu : "Lyxal\tOS"
-- ============================================================================

RETURN fn::validation_not_blank(
    "   Lyxal\tOS   ",
    "TITLE"
);


-- ============================================================================
-- TEST 18 — Valeur absente
-- Erreur attendue : NAME_REQUIRED
-- ============================================================================

RETURN fn::validation_not_blank(
    NONE,
    "NAME"
);


-- ============================================================================
-- TEST 19 — Valeur NULL
-- Erreur attendue : NAME_NULL_NOT_ALLOWED
-- ============================================================================

RETURN fn::validation_not_blank(
    NULL,
    "NAME"
);


-- ============================================================================
-- TEST 20 — Chaîne vide
-- Erreur attendue : NAME_BLANK_NOT_ALLOWED
-- ============================================================================

RETURN fn::validation_not_blank(
    "",
    "NAME"
);


-- ============================================================================
-- TEST 21 — Chaîne composée uniquement d'espaces
-- Erreur attendue : NAME_BLANK_NOT_ALLOWED
-- ============================================================================

RETURN fn::validation_not_blank(
    "       ",
    "NAME"
);


-- ============================================================================
-- TEST 22 — Chaîne composée uniquement d'une tabulation
-- Erreur attendue : NAME_BLANK_NOT_ALLOWED
-- ============================================================================

RETURN fn::validation_not_blank(
    "\t",
    "NAME"
);


-- ============================================================================
-- TEST 23 — Chaîne composée uniquement d'un retour à la ligne
-- Erreur attendue : NAME_BLANK_NOT_ALLOWED
-- ============================================================================

RETURN fn::validation_not_blank(
    "\n",
    "NAME"
);


-- ============================================================================
-- TEST 24 — Chaîne composée de retours à la ligne
-- Erreur attendue : NAME_BLANK_NOT_ALLOWED
-- ============================================================================

RETURN fn::validation_not_blank(
    "\n\n\n",
    "NAME"
);


-- ============================================================================
-- TEST 25 — Chaîne composée d'espaces, tabulations et retours à la ligne
-- Erreur attendue : NAME_BLANK_NOT_ALLOWED
-- ============================================================================

RETURN fn::validation_not_blank(
    "   \n\t   \n   ",
    "NAME"
);


-- ============================================================================
-- TEST 26 — Entier à la place d'une chaîne
-- Erreur attendue : VALUE_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_not_blank(
    42,
    "VALUE"
);


-- ============================================================================
-- TEST 27 — Entier zéro à la place d'une chaîne
-- Erreur attendue : VALUE_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_not_blank(
    0,
    "VALUE"
);


-- ============================================================================
-- TEST 28 — Float à la place d'une chaîne
-- Erreur attendue : VALUE_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_not_blank(
    42.5f,
    "VALUE"
);


-- ============================================================================
-- TEST 29 — Decimal à la place d'une chaîne
-- Erreur attendue : VALUE_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_not_blank(
    42.5dec,
    "VALUE"
);


-- ============================================================================
-- TEST 30 — Booléen false à la place d'une chaîne
-- Erreur attendue : VALUE_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_not_blank(
    false,
    "VALUE"
);


-- ============================================================================
-- TEST 31 — Booléen true à la place d'une chaîne
-- Erreur attendue : VALUE_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_not_blank(
    true,
    "VALUE"
);


-- ============================================================================
-- TEST 32 — Tableau à la place d'une chaîne
-- Erreur attendue : VALUE_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_not_blank(
    ["Lyxal"],
    "VALUE"
);


-- ============================================================================
-- TEST 33 — Objet à la place d'une chaîne
-- Erreur attendue : VALUE_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_not_blank(
    {
        name: "Lyxal"
    },
    "VALUE"
);


-- ============================================================================
-- TEST 34 — Record ID à la place d'une chaîne
-- Erreur attendue : VALUE_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_not_blank(
    identity_user:user_001,
    "VALUE"
);


-- ============================================================================
-- TEST 35 — Datetime à la place d'une chaîne
-- Erreur attendue : VALUE_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_not_blank(
    d"2026-08-03T10:00:00Z",
    "VALUE"
);


-- ============================================================================
-- TEST 36 — Durée à la place d'une chaîne
-- Erreur attendue : VALUE_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_not_blank(
    30m,
    "VALUE"
);


-- ============================================================================
-- TEST 37 — UUID à la place d'une chaîne
-- Erreur attendue : VALUE_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_not_blank(
    u"018a6680-bef9-701b-9025-e1754f296a0f",
    "VALUE"
);


-- ============================================================================
-- TEST 38 — Conversion explicite d'un entier avant validation
-- Résultat attendu : "42"
-- ============================================================================

LET $converted_value = type::string(
    42
);

RETURN fn::validation_not_blank(
    $converted_value,
    "VALUE"
);


-- ============================================================================
-- TEST 39 — Conversion explicite d'un booléen avant validation
-- Résultat attendu : "false"
-- ============================================================================

LET $converted_value = type::string(
    false
);

RETURN fn::validation_not_blank(
    $converted_value,
    "VALUE"
);


-- ============================================================================
-- TEST 40 — Conversion explicite d'un Record ID avant validation
-- Résultat attendu : représentation textuelle du Record ID
-- ============================================================================

LET $converted_value = type::string(
    identity_user:user_001
);

RETURN fn::validation_not_blank(
    $converted_value,
    "VALUE"
);


-- ============================================================================
-- TEST 41 — Enchaînement avec validation_min_length
-- Résultat attendu : "Lyxal"
-- ============================================================================

LET $name = fn::validation_not_blank(
    "   Lyxal   ",
    "NAME"
);

RETURN fn::validation_min_length(
    $name,
    "NAME",
    3
);


-- ============================================================================
-- TEST 42 — Enchaînement avec validation_max_length
-- Résultat attendu : "Lyxal"
-- ============================================================================

LET $name = fn::validation_not_blank(
    "   Lyxal   ",
    "NAME"
);

RETURN fn::validation_max_length(
    $name,
    "NAME",
    100
);


-- ============================================================================
-- TEST 43 — Enchaînement avec longueur minimale non respectée
-- Erreur attendue : NAME_TOO_SHORT
-- ============================================================================

LET $name = fn::validation_not_blank(
    "a",
    "NAME"
);

RETURN fn::validation_min_length(
    $name,
    "NAME",
    2
);


-- ============================================================================
-- TEST 44 — Enchaînement avec longueur maximale dépassée
-- Erreur attendue : NAME_TOO_LONG
-- ============================================================================

LET $name = fn::validation_not_blank(
    "Lyxal Operating System",
    "NAME"
);

RETURN fn::validation_max_length(
    $name,
    "NAME",
    10
);


-- ============================================================================
-- TEST 45 — Enchaînement avec validation_regex
-- Résultat attendu : "lyxal-core"
-- ============================================================================

LET $identifier = fn::validation_not_blank(
    "   lyxal-core   ",
    "IDENTIFIER"
);

RETURN fn::validation_regex(
    $identifier,
    "IDENTIFIER",
    "^[a-z-]+$"
);


-- ============================================================================
-- TEST 46 — Enchaînement avec validation_unique
-- Résultat attendu : dépend du contenu de la table
-- Note : exemple d'intégration uniquement
-- ============================================================================

LET $name = fn::validation_not_blank(
    "   Nouveau projet   ",
    "PROJECT_NAME"
);

RETURN $name;


-- ============================================================================
-- TEST 47 — Vérification de la longueur après nettoyage
-- Résultat attendu : 5
-- ============================================================================

LET $name = fn::validation_not_blank(
    "   Lyxal   ",
    "NAME"
);

RETURN string::len($name);


-- ============================================================================
-- TEST 48 — Vérification que les espaces internes sont conservés
-- Résultat attendu : 13
-- Note : "Lyxal   Studio" contient les espaces internes
-- ============================================================================

LET $name = fn::validation_not_blank(
    "   Lyxal   Studio   ",
    "NAME"
);

RETURN string::len($name);


-- ============================================================================
-- TEST 49 — Nom technique avec espaces périphériques
-- Résultat attendu : "Lyxal"
-- Note : le nom technique est nettoyé pour construire les erreurs
-- ============================================================================

RETURN fn::validation_not_blank(
    "Lyxal",
    "   NAME   "
);


-- ============================================================================
-- TEST 50 — Nom technique vide
-- Erreur attendue : VALIDATION_INVALID_FIELD_NAME
-- ============================================================================

RETURN fn::validation_not_blank(
    "Lyxal",
    ""
);


-- ============================================================================
-- TEST 51 — Nom technique composé uniquement d'espaces
-- Erreur attendue : VALIDATION_INVALID_FIELD_NAME
-- ============================================================================

RETURN fn::validation_not_blank(
    "Lyxal",
    "     "
);


-- ============================================================================
-- TEST 52 — Nom technique composé uniquement d'une tabulation
-- Erreur attendue : VALIDATION_INVALID_FIELD_NAME
-- ============================================================================

RETURN fn::validation_not_blank(
    "Lyxal",
    "\t"
);