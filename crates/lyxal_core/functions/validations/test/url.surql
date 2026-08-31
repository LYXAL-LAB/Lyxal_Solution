-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/url.test.surql
-- Fonction     : fn::validation_url
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
-- TEST 1 — URL HTTPS valide
-- Résultat attendu : "https://example.com"
-- ============================================================================

RETURN fn::validation_url(
    "https://example.com",
    "WEBSITE_URL",
    2048
);


-- ============================================================================
-- TEST 2 — Suppression des espaces périphériques
-- Résultat attendu : "https://example.com/path"
-- ============================================================================

RETURN fn::validation_url(
    "   https://example.com/path   ",
    "WEBSITE_URL",
    2048
);


-- ============================================================================
-- TEST 3 — URL HTTP valide
-- Résultat attendu : "http://example.com"
-- ============================================================================

RETURN fn::validation_url(
    "http://example.com",
    "WEBSITE_URL",
    2048
);


-- ============================================================================
-- TEST 4 — URL avec chemin
-- Résultat attendu : "https://example.com/products/item"
-- ============================================================================

RETURN fn::validation_url(
    "https://example.com/products/item",
    "PRODUCT_URL",
    2048
);


-- ============================================================================
-- TEST 5 — URL avec paramètres
-- Résultat attendu : "https://example.com/search?q=lyxal&page=1"
-- ============================================================================

RETURN fn::validation_url(
    "https://example.com/search?q=lyxal&page=1",
    "SEARCH_URL",
    2048
);


-- ============================================================================
-- TEST 6 — URL avec fragment
-- Résultat attendu : "https://example.com/document#section-2"
-- ============================================================================

RETURN fn::validation_url(
    "https://example.com/document#section-2",
    "DOCUMENT_URL",
    2048
);


-- ============================================================================
-- TEST 7 — URL avec port
-- Résultat attendu : "https://example.com:8443/api"
-- ============================================================================

RETURN fn::validation_url(
    "https://example.com:8443/api",
    "API_URL",
    2048
);


-- ============================================================================
-- TEST 8 — URL avec sous-domaine
-- Résultat attendu : "https://api.example.com/v1/resources"
-- ============================================================================

RETURN fn::validation_url(
    "https://api.example.com/v1/resources",
    "API_URL",
    2048
);


-- ============================================================================
-- TEST 9 — URL sans limite maximale
-- Résultat attendu : "https://example.com"
-- ============================================================================

RETURN fn::validation_url(
    "https://example.com",
    "EXTERNAL_URL",
    NONE
);


-- ============================================================================
-- TEST 10 — Valeur absente
-- Erreur attendue : WEBSITE_URL_REQUIRED
-- ============================================================================

RETURN fn::validation_url(
    NONE,
    "WEBSITE_URL",
    2048
);


-- ============================================================================
-- TEST 11 — Valeur NULL
-- Erreur attendue : WEBSITE_URL_NULL_NOT_ALLOWED
-- ============================================================================

RETURN fn::validation_url(
    NULL,
    "WEBSITE_URL",
    2048
);


-- ============================================================================
-- TEST 12 — Chaîne vide
-- Erreur attendue : WEBSITE_URL_REQUIRED
-- ============================================================================

RETURN fn::validation_url(
    "",
    "WEBSITE_URL",
    2048
);


-- ============================================================================
-- TEST 13 — Chaîne composée uniquement d'espaces
-- Erreur attendue : WEBSITE_URL_REQUIRED
-- ============================================================================

RETURN fn::validation_url(
    "     ",
    "WEBSITE_URL",
    2048
);


-- ============================================================================
-- TEST 14 — Entier à la place d'une chaîne
-- Erreur attendue : WEBSITE_URL_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_url(
    12345,
    "WEBSITE_URL",
    2048
);


-- ============================================================================
-- TEST 15 — Booléen à la place d'une chaîne
-- Erreur attendue : WEBSITE_URL_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_url(
    true,
    "WEBSITE_URL",
    2048
);


-- ============================================================================
-- TEST 16 — Tableau à la place d'une chaîne
-- Erreur attendue : WEBSITE_URL_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_url(
    ["https://example.com"],
    "WEBSITE_URL",
    2048
);


-- ============================================================================
-- TEST 17 — Objet à la place d'une chaîne
-- Erreur attendue : WEBSITE_URL_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_url(
    {
        url: "https://example.com"
    },
    "WEBSITE_URL",
    2048
);


-- ============================================================================
-- TEST 18 — Domaine sans protocole
-- Erreur attendue : WEBSITE_URL_INVALID_FORMAT
-- ============================================================================

RETURN fn::validation_url(
    "example.com",
    "WEBSITE_URL",
    2048
);


-- ============================================================================
-- TEST 19 — Protocole sans domaine
-- Erreur attendue : WEBSITE_URL_INVALID_FORMAT
-- ============================================================================

RETURN fn::validation_url(
    "https://",
    "WEBSITE_URL",
    2048
);


-- ============================================================================
-- TEST 20 — Texte ordinaire
-- Erreur attendue : WEBSITE_URL_INVALID_FORMAT
-- ============================================================================

RETURN fn::validation_url(
    "ceci n'est pas une url",
    "WEBSITE_URL",
    2048
);


-- ============================================================================
-- TEST 21 — URL contenant un espace interne
-- Erreur attendue : WEBSITE_URL_INVALID_FORMAT
-- ============================================================================

RETURN fn::validation_url(
    "https://example.com/un chemin",
    "WEBSITE_URL",
    2048
);


-- ============================================================================
-- TEST 22 — URL dépassant la longueur maximale configurée
-- Erreur attendue : WEBSITE_URL_TOO_LONG
-- ============================================================================

RETURN fn::validation_url(
    "https://example.com/un-chemin-volontairement-trop-long",
    "WEBSITE_URL",
    20
);


-- ============================================================================
-- TEST 23 — Longueur maximale égale à zéro
-- Erreur attendue : VALIDATION_INVALID_MAX_LENGTH
-- ============================================================================

RETURN fn::validation_url(
    "https://example.com",
    "WEBSITE_URL",
    0
);


-- ============================================================================
-- TEST 24 — Longueur maximale négative
-- Erreur attendue : VALIDATION_INVALID_MAX_LENGTH
-- ============================================================================

RETURN fn::validation_url(
    "https://example.com",
    "WEBSITE_URL",
    -1
);


-- ============================================================================
-- TEST 25 — Nom technique vide
-- Erreur attendue : VALIDATION_INVALID_FIELD_NAME
-- ============================================================================

RETURN fn::validation_url(
    "https://example.com",
    "     ",
    2048
);