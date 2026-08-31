-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/bytes.test.surql
-- Fonction     : fn::validation_bytes
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
-- TEST 1 — Valeur bytes valide sans limites
-- Résultat attendu : b"48656C6C6F"
-- ============================================================================

RETURN fn::validation_bytes(
    b"48656C6C6F",
    "BINARY_VALUE",
    NONE,
    NONE
);


-- ============================================================================
-- TEST 2 — Valeur bytes vide sans limites
-- Résultat attendu : b""
-- ============================================================================

RETURN fn::validation_bytes(
    b"",
    "BINARY_VALUE",
    NONE,
    NONE
);


-- ============================================================================
-- TEST 3 — Valeur bytes contenant un octet
-- Résultat attendu : b"00"
-- ============================================================================

RETURN fn::validation_bytes(
    b"00",
    "BINARY_VALUE",
    NONE,
    NONE
);


-- ============================================================================
-- TEST 4 — Valeur bytes issue d'une chaîne
-- Résultat attendu : valeur bytes correspondant à "Hello"
-- ============================================================================

RETURN fn::validation_bytes(
    <bytes>"Hello",
    "BINARY_VALUE",
    NONE,
    NONE
);


-- ============================================================================
-- TEST 5 — Valeur bytes issue d'un tableau d'entiers
-- Résultat attendu : valeur bytes correspondant à "Hello"
-- ============================================================================

RETURN fn::validation_bytes(
    <bytes>[72, 101, 108, 108, 111],
    "BINARY_VALUE",
    NONE,
    NONE
);


-- ============================================================================
-- TEST 6 — Valeur comprise dans une plage de taille
-- Résultat attendu : b"48656C6C6F"
-- Note : la valeur contient cinq octets
-- ============================================================================

RETURN fn::validation_bytes(
    b"48656C6C6F",
    "BINARY_VALUE",
    1,
    10
);


-- ============================================================================
-- TEST 7 — Taille égale à la limite minimale
-- Résultat attendu : b"48656C6C6F"
-- ============================================================================

RETURN fn::validation_bytes(
    b"48656C6C6F",
    "BINARY_VALUE",
    5,
    10
);


-- ============================================================================
-- TEST 8 — Taille égale à la limite maximale
-- Résultat attendu : b"48656C6C6F"
-- ============================================================================

RETURN fn::validation_bytes(
    b"48656C6C6F",
    "BINARY_VALUE",
    1,
    5
);


-- ============================================================================
-- TEST 9 — Taille exacte
-- Résultat attendu : b"48656C6C6F"
-- ============================================================================

RETURN fn::validation_bytes(
    b"48656C6C6F",
    "BINARY_VALUE",
    5,
    5
);


-- ============================================================================
-- TEST 10 — Valeur bytes vide avec minimum égal à zéro
-- Résultat attendu : b""
-- ============================================================================

RETURN fn::validation_bytes(
    b"",
    "BINARY_VALUE",
    0,
    NONE
);


-- ============================================================================
-- TEST 11 — Valeur bytes vide avec maximum égal à zéro
-- Résultat attendu : b""
-- ============================================================================

RETURN fn::validation_bytes(
    b"",
    "BINARY_VALUE",
    NONE,
    0
);


-- ============================================================================
-- TEST 12 — Valeur bytes vide avec plage exacte zéro
-- Résultat attendu : b""
-- ============================================================================

RETURN fn::validation_bytes(
    b"",
    "BINARY_VALUE",
    0,
    0
);


-- ============================================================================
-- TEST 13 — Minimum uniquement
-- Résultat attendu : b"48656C6C6F"
-- ============================================================================

RETURN fn::validation_bytes(
    b"48656C6C6F",
    "BINARY_VALUE",
    1,
    NONE
);


-- ============================================================================
-- TEST 14 — Maximum uniquement
-- Résultat attendu : b"48656C6C6F"
-- ============================================================================

RETURN fn::validation_bytes(
    b"48656C6C6F",
    "BINARY_VALUE",
    NONE,
    10
);


-- ============================================================================
-- TEST 15 — Valeur absente
-- Erreur attendue : BINARY_VALUE_REQUIRED
-- ============================================================================

RETURN fn::validation_bytes(
    NONE,
    "BINARY_VALUE",
    NONE,
    NONE
);


-- ============================================================================
-- TEST 16 — Valeur NULL
-- Erreur attendue : BINARY_VALUE_NULL_NOT_ALLOWED
-- ============================================================================

RETURN fn::validation_bytes(
    NULL,
    "BINARY_VALUE",
    NONE,
    NONE
);


-- ============================================================================
-- TEST 17 — Chaîne hexadécimale sans type bytes
-- Erreur attendue : BINARY_VALUE_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_bytes(
    "48656C6C6F",
    "BINARY_VALUE",
    NONE,
    NONE
);


-- ============================================================================
-- TEST 18 — Chaîne ordinaire sans conversion
-- Erreur attendue : BINARY_VALUE_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_bytes(
    "Hello",
    "BINARY_VALUE",
    NONE,
    NONE
);


-- ============================================================================
-- TEST 19 — Tableau d'entiers sans conversion
-- Erreur attendue : BINARY_VALUE_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_bytes(
    [72, 101, 108, 108, 111],
    "BINARY_VALUE",
    NONE,
    NONE
);


-- ============================================================================
-- TEST 20 — Entier à la place d'une valeur bytes
-- Erreur attendue : BINARY_VALUE_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_bytes(
    42,
    "BINARY_VALUE",
    NONE,
    NONE
);


-- ============================================================================
-- TEST 21 — Float à la place d'une valeur bytes
-- Erreur attendue : BINARY_VALUE_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_bytes(
    42f,
    "BINARY_VALUE",
    NONE,
    NONE
);


-- ============================================================================
-- TEST 22 — Decimal à la place d'une valeur bytes
-- Erreur attendue : BINARY_VALUE_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_bytes(
    42dec,
    "BINARY_VALUE",
    NONE,
    NONE
);


-- ============================================================================
-- TEST 23 — Booléen à la place d'une valeur bytes
-- Erreur attendue : BINARY_VALUE_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_bytes(
    true,
    "BINARY_VALUE",
    NONE,
    NONE
);


-- ============================================================================
-- TEST 24 — Objet à la place d'une valeur bytes
-- Erreur attendue : BINARY_VALUE_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_bytes(
    {
        value: b"48656C6C6F"
    },
    "BINARY_VALUE",
    NONE,
    NONE
);


-- ============================================================================
-- TEST 25 — UUID à la place d'une valeur bytes
-- Erreur attendue : BINARY_VALUE_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_bytes(
    u"018a6680-bef9-701b-9025-e1754f296a0f",
    "BINARY_VALUE",
    NONE,
    NONE
);


-- ============================================================================
-- TEST 26 — Record ID à la place d'une valeur bytes
-- Erreur attendue : BINARY_VALUE_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_bytes(
    binary_data:item_001,
    "BINARY_VALUE",
    NONE,
    NONE
);


-- ============================================================================
-- TEST 27 — Valeur trop courte
-- Erreur attendue : BINARY_VALUE_TOO_SHORT
-- Note : la valeur contient cinq octets
-- ============================================================================

RETURN fn::validation_bytes(
    b"48656C6C6F",
    "BINARY_VALUE",
    6,
    NONE
);


-- ============================================================================
-- TEST 28 — Valeur trop longue
-- Erreur attendue : BINARY_VALUE_TOO_LONG
-- Note : la valeur contient cinq octets
-- ============================================================================

RETURN fn::validation_bytes(
    b"48656C6C6F",
    "BINARY_VALUE",
    NONE,
    4
);


-- ============================================================================
-- TEST 29 — Valeur vide refusée par un minimum positif
-- Erreur attendue : BINARY_VALUE_TOO_SHORT
-- ============================================================================

RETURN fn::validation_bytes(
    b"",
    "BINARY_VALUE",
    1,
    NONE
);


-- ============================================================================
-- TEST 30 — Longueur minimale négative
-- Erreur attendue : VALIDATION_INVALID_MIN_LENGTH
-- ============================================================================

RETURN fn::validation_bytes(
    b"48656C6C6F",
    "BINARY_VALUE",
    -1,
    10
);


-- ============================================================================
-- TEST 31 — Longueur maximale négative
-- Erreur attendue : VALIDATION_INVALID_MAX_LENGTH
-- ============================================================================

RETURN fn::validation_bytes(
    b"48656C6C6F",
    "BINARY_VALUE",
    0,
    -1
);


-- ============================================================================
-- TEST 32 — Plage de taille incohérente
-- Erreur attendue : VALIDATION_INVALID_BYTES_RANGE
-- ============================================================================

RETURN fn::validation_bytes(
    b"48656C6C6F",
    "BINARY_VALUE",
    10,
    5
);


-- ============================================================================
-- TEST 33 — Taille exacte inférieure
-- Erreur attendue : HASH_BYTES_TOO_SHORT
-- Note : deux octets reçus, trois attendus
-- ============================================================================

RETURN fn::validation_bytes(
    b"AABB",
    "HASH_BYTES",
    3,
    3
);


-- ============================================================================
-- TEST 34 — Taille exacte supérieure
-- Erreur attendue : HASH_BYTES_TOO_LONG
-- Note : quatre octets reçus, trois attendus
-- ============================================================================

RETURN fn::validation_bytes(
    b"AABBCCDD",
    "HASH_BYTES",
    3,
    3
);


-- ============================================================================
-- TEST 35 — Taille exacte valide
-- Résultat attendu : b"AABBCC"
-- ============================================================================

RETURN fn::validation_bytes(
    b"AABBCC",
    "HASH_BYTES",
    3,
    3
);


-- ============================================================================
-- TEST 36 — Vérification directe de la taille
-- Résultat attendu : 5
-- ============================================================================

LET $binary_value = fn::validation_bytes(
    b"48656C6C6F",
    "BINARY_VALUE",
    1,
    10
);

RETURN bytes::len($binary_value);


-- ============================================================================
-- TEST 37 — Conversion en chaîne après validation
-- Résultat attendu : "Hello"
-- ============================================================================

LET $binary_value = fn::validation_bytes(
    b"48656C6C6F",
    "BINARY_VALUE",
    5,
    5
);

RETURN <string>$binary_value;


-- ============================================================================
-- TEST 38 — Conversion en tableau d'entiers après validation
-- Résultat attendu : [72, 101, 108, 108, 111]
-- ============================================================================

LET $binary_value = fn::validation_bytes(
    b"48656C6C6F",
    "BINARY_VALUE",
    5,
    5
);

RETURN <array>$binary_value;


-- ============================================================================
-- TEST 39 — Chaîne Unicode convertie en bytes
-- Résultat attendu : valeur bytes valide
-- Note : la taille dépend de l'encodage UTF-8
-- ============================================================================

LET $binary_value = <bytes>"Équipe";

RETURN fn::validation_bytes(
    $binary_value,
    "BINARY_VALUE",
    1,
    100
);


-- ============================================================================
-- TEST 40 — Nom technique vide
-- Erreur attendue : VALIDATION_INVALID_FIELD_NAME
-- ============================================================================

RETURN fn::validation_bytes(
    b"48656C6C6F",
    "     ",
    NONE,
    NONE
);