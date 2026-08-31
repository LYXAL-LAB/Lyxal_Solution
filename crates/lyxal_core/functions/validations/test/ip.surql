-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/ip.test.surql
-- Fonction     : fn::validation_ip
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
-- TEST 1 — Adresse IPv4 valide en mode any
-- Résultat attendu : "192.168.1.1"
-- ============================================================================

RETURN fn::validation_ip(
    "192.168.1.1",
    "IP_ADDRESS",
    "any"
);


-- ============================================================================
-- TEST 2 — Adresse IPv6 valide en mode any
-- Résultat attendu : "2001:db8::1"
-- ============================================================================

RETURN fn::validation_ip(
    "2001:db8::1",
    "IP_ADDRESS",
    "any"
);


-- ============================================================================
-- TEST 3 — Version non fournie avec IPv4
-- Résultat attendu : "127.0.0.1"
-- ============================================================================

RETURN fn::validation_ip(
    "127.0.0.1",
    "IP_ADDRESS",
    NONE
);


-- ============================================================================
-- TEST 4 — Version non fournie avec IPv6
-- Résultat attendu : "::1"
-- ============================================================================

RETURN fn::validation_ip(
    "::1",
    "IP_ADDRESS",
    NONE
);


-- ============================================================================
-- TEST 5 — Suppression des espaces périphériques
-- Résultat attendu : "192.168.1.1"
-- ============================================================================

RETURN fn::validation_ip(
    "   192.168.1.1   ",
    "CLIENT_IP",
    "ipv4"
);


-- ============================================================================
-- TEST 6 — IPv4 valide en mode ipv4
-- Résultat attendu : "8.8.8.8"
-- ============================================================================

RETURN fn::validation_ip(
    "8.8.8.8",
    "SERVER_IP",
    "ipv4"
);


-- ============================================================================
-- TEST 7 — Adresse IPv4 maximale valide
-- Résultat attendu : "255.255.255.255"
-- ============================================================================

RETURN fn::validation_ip(
    "255.255.255.255",
    "IP_ADDRESS",
    "ipv4"
);


-- ============================================================================
-- TEST 8 — Adresse IPv4 minimale valide
-- Résultat attendu : "0.0.0.0"
-- ============================================================================

RETURN fn::validation_ip(
    "0.0.0.0",
    "IP_ADDRESS",
    "ipv4"
);


-- ============================================================================
-- TEST 9 — Adresse IPv6 compressée valide
-- Résultat attendu : "2001:db8::1"
-- ============================================================================

RETURN fn::validation_ip(
    "2001:db8::1",
    "SERVER_IP",
    "ipv6"
);


-- ============================================================================
-- TEST 10 — Adresse IPv6 complète valide
-- Résultat attendu : "2001:0db8:85a3:0000:0000:8a2e:0370:7334"
-- ============================================================================

RETURN fn::validation_ip(
    "2001:0db8:85a3:0000:0000:8a2e:0370:7334",
    "SERVER_IP",
    "ipv6"
);


-- ============================================================================
-- TEST 11 — Boucle locale IPv6 valide
-- Résultat attendu : "::1"
-- ============================================================================

RETURN fn::validation_ip(
    "::1",
    "SERVER_IP",
    "ipv6"
);


-- ============================================================================
-- TEST 12 — Version avec majuscules et espaces
-- Résultat attendu : "192.168.1.1"
-- ============================================================================

RETURN fn::validation_ip(
    "192.168.1.1",
    "CLIENT_IP",
    "  IPV4  "
);


-- ============================================================================
-- TEST 13 — Valeur absente
-- Erreur attendue : CLIENT_IP_REQUIRED
-- ============================================================================

RETURN fn::validation_ip(
    NONE,
    "CLIENT_IP",
    "any"
);


-- ============================================================================
-- TEST 14 — Valeur NULL
-- Erreur attendue : CLIENT_IP_NULL_NOT_ALLOWED
-- ============================================================================

RETURN fn::validation_ip(
    NULL,
    "CLIENT_IP",
    "any"
);


-- ============================================================================
-- TEST 15 — Chaîne vide
-- Erreur attendue : CLIENT_IP_REQUIRED
-- ============================================================================

RETURN fn::validation_ip(
    "",
    "CLIENT_IP",
    "any"
);


-- ============================================================================
-- TEST 16 — Chaîne composée uniquement d'espaces
-- Erreur attendue : CLIENT_IP_REQUIRED
-- ============================================================================

RETURN fn::validation_ip(
    "     ",
    "CLIENT_IP",
    "any"
);


-- ============================================================================
-- TEST 17 — Entier à la place d'une chaîne
-- Erreur attendue : CLIENT_IP_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_ip(
    19216811,
    "CLIENT_IP",
    "any"
);


-- ============================================================================
-- TEST 18 — Booléen à la place d'une chaîne
-- Erreur attendue : CLIENT_IP_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_ip(
    true,
    "CLIENT_IP",
    "any"
);


-- ============================================================================
-- TEST 19 — Tableau à la place d'une chaîne
-- Erreur attendue : CLIENT_IP_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_ip(
    ["192.168.1.1"],
    "CLIENT_IP",
    "any"
);


-- ============================================================================
-- TEST 20 — Objet à la place d'une chaîne
-- Erreur attendue : CLIENT_IP_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_ip(
    {
        ip: "192.168.1.1"
    },
    "CLIENT_IP",
    "any"
);


-- ============================================================================
-- TEST 21 — IPv6 fournie en mode ipv4
-- Erreur attendue : CLIENT_IP_INVALID_FORMAT
-- ============================================================================

RETURN fn::validation_ip(
    "2001:db8::1",
    "CLIENT_IP",
    "ipv4"
);


-- ============================================================================
-- TEST 22 — IPv4 fournie en mode ipv6
-- Erreur attendue : CLIENT_IP_INVALID_FORMAT
-- ============================================================================

RETURN fn::validation_ip(
    "192.168.1.1",
    "CLIENT_IP",
    "ipv6"
);


-- ============================================================================
-- TEST 23 — Adresse IPv4 contenant une valeur supérieure à 255
-- Erreur attendue : CLIENT_IP_INVALID_FORMAT
-- ============================================================================

RETURN fn::validation_ip(
    "192.168.1.256",
    "CLIENT_IP",
    "ipv4"
);


-- ============================================================================
-- TEST 24 — Adresse IPv4 incomplète
-- Erreur attendue : CLIENT_IP_INVALID_FORMAT
-- ============================================================================

RETURN fn::validation_ip(
    "192.168.1",
    "CLIENT_IP",
    "ipv4"
);


-- ============================================================================
-- TEST 25 — Adresse IPv4 contenant des lettres
-- Erreur attendue : CLIENT_IP_INVALID_FORMAT
-- ============================================================================

RETURN fn::validation_ip(
    "192.168.a.1",
    "CLIENT_IP",
    "ipv4"
);


-- ============================================================================
-- TEST 26 — Adresse IP accompagnée d'un port
-- Erreur attendue : CLIENT_IP_INVALID_FORMAT
-- ============================================================================

RETURN fn::validation_ip(
    "192.168.1.1:8080",
    "CLIENT_IP",
    "any"
);


-- ============================================================================
-- TEST 27 — Adresse IPv4 avec notation CIDR
-- Erreur attendue : CLIENT_IP_INVALID_FORMAT
-- ============================================================================

RETURN fn::validation_ip(
    "192.168.1.0/24",
    "CLIENT_IP",
    "any"
);


-- ============================================================================
-- TEST 28 — Adresse IPv6 avec notation CIDR
-- Erreur attendue : CLIENT_IP_INVALID_FORMAT
-- ============================================================================

RETURN fn::validation_ip(
    "2001:db8::/32",
    "CLIENT_IP",
    "any"
);


-- ============================================================================
-- TEST 29 — Texte ordinaire
-- Erreur attendue : CLIENT_IP_INVALID_FORMAT
-- ============================================================================

RETURN fn::validation_ip(
    "localhost",
    "CLIENT_IP",
    "any"
);


-- ============================================================================
-- TEST 30 — Version IP inconnue
-- Erreur attendue : VALIDATION_INVALID_IP_VERSION
-- ============================================================================

RETURN fn::validation_ip(
    "192.168.1.1",
    "CLIENT_IP",
    "ipv5"
);


-- ============================================================================
-- TEST 31 — Version vide
-- Erreur attendue : VALIDATION_INVALID_IP_VERSION
-- ============================================================================

RETURN fn::validation_ip(
    "192.168.1.1",
    "CLIENT_IP",
    "     "
);


-- ============================================================================
-- TEST 32 — Nom technique vide
-- Erreur attendue : VALIDATION_INVALID_FIELD_NAME
-- ============================================================================

RETURN fn::validation_ip(
    "192.168.1.1",
    "     ",
    "any"
);