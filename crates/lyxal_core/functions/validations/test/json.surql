-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/json.test.surql
-- Fonction     : fn::validation_json
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW ou une erreur native de
-- décodage interrompent l'exécution du bloc.
--
-- Dans Surrealist, sélectionner uniquement le test concerné lorsqu'une erreur
-- est attendue.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Objet JSON valide
-- Résultat attendu : { name: "Lyxal", enabled: true }
-- ============================================================================

RETURN fn::validation_json(
    '{"name":"Lyxal","enabled":true}',
    "CONFIGURATION",
    10000
);


-- ============================================================================
-- TEST 2 — Objet JSON imbriqué valide
-- Résultat attendu : objet contenant user et tags
-- ============================================================================

RETURN fn::validation_json(
    '{"user":{"name":"Yaniss","tags":["admin","user"]}}',
    "PAYLOAD",
    10000
);


-- ============================================================================
-- TEST 3 — Tableau JSON valide
-- Résultat attendu : ["booking", "calendar", "crm"]
-- ============================================================================

RETURN fn::validation_json(
    '["booking","calendar","crm"]',
    "MODULES",
    10000
);


-- ============================================================================
-- TEST 4 — Tableau d'objets JSON valide
-- Résultat attendu : [{ id: 1, name: "Booking" }, { id: 2, name: "CRM" }]
-- ============================================================================

RETURN fn::validation_json(
    '[{"id":1,"name":"Booking"},{"id":2,"name":"CRM"}]',
    "MODULES",
    10000
);


-- ============================================================================
-- TEST 5 — Chaîne JSON valide
-- Résultat attendu : "Lyxal"
-- ============================================================================

RETURN fn::validation_json(
    '"Lyxal"',
    "VALUE",
    10000
);


-- ============================================================================
-- TEST 6 — Entier JSON valide
-- Résultat attendu : 42
-- ============================================================================

RETURN fn::validation_json(
    '42',
    "VALUE",
    10000
);


-- ============================================================================
-- TEST 7 — Nombre décimal JSON valide
-- Résultat attendu : valeur numérique 19.99
-- ============================================================================

RETURN fn::validation_json(
    '19.99',
    "VALUE",
    10000
);


-- ============================================================================
-- TEST 8 — Booléen JSON true valide
-- Résultat attendu : true
-- ============================================================================

RETURN fn::validation_json(
    'true',
    "VALUE",
    10000
);


-- ============================================================================
-- TEST 9 — Booléen JSON false valide
-- Résultat attendu : false
-- ============================================================================

RETURN fn::validation_json(
    'false',
    "VALUE",
    10000
);


-- ============================================================================
-- TEST 10 — Valeur JSON null valide
-- Résultat attendu : NULL
-- ============================================================================

RETURN fn::validation_json(
    'null',
    "VALUE",
    10000
);


-- ============================================================================
-- TEST 11 — Objet JSON vide valide
-- Résultat attendu : {}
-- ============================================================================

RETURN fn::validation_json(
    '{}',
    "CONFIGURATION",
    10000
);


-- ============================================================================
-- TEST 12 — Tableau JSON vide valide
-- Résultat attendu : []
-- ============================================================================

RETURN fn::validation_json(
    '[]',
    "ITEMS",
    10000
);


-- ============================================================================
-- TEST 13 — Suppression des espaces périphériques
-- Résultat attendu : { name: "Lyxal" }
-- ============================================================================

RETURN fn::validation_json(
    '   {"name":"Lyxal"}   ',
    "CONFIGURATION",
    10000
);


-- ============================================================================
-- TEST 14 — Espaces internes JSON valides
-- Résultat attendu : { name: "Lyxal", enabled: true }
-- ============================================================================

RETURN fn::validation_json(
    '{
        "name": "Lyxal",
        "enabled": true
    }',
    "CONFIGURATION",
    10000
);


-- ============================================================================
-- TEST 15 — Caractères Unicode valides
-- Résultat attendu : { name: "Équipe commerciale" }
-- ============================================================================

RETURN fn::validation_json(
    '{"name":"Équipe commerciale"}',
    "CONFIGURATION",
    10000
);


-- ============================================================================
-- TEST 16 — Valeur sans limite maximale
-- Résultat attendu : { name: "Lyxal" }
-- ============================================================================

RETURN fn::validation_json(
    '{"name":"Lyxal"}',
    "CONFIGURATION",
    NONE
);


-- ============================================================================
-- TEST 17 — Valeur absente
-- Erreur attendue : PAYLOAD_REQUIRED
-- ============================================================================

RETURN fn::validation_json(
    NONE,
    "PAYLOAD",
    10000
);


-- ============================================================================
-- TEST 18 — Valeur NULL au lieu d'une chaîne JSON
-- Erreur attendue : PAYLOAD_NULL_NOT_ALLOWED
-- ============================================================================

RETURN fn::validation_json(
    NULL,
    "PAYLOAD",
    10000
);


-- ============================================================================
-- TEST 19 — Chaîne vide
-- Erreur attendue : PAYLOAD_REQUIRED
-- ============================================================================

RETURN fn::validation_json(
    "",
    "PAYLOAD",
    10000
);


-- ============================================================================
-- TEST 20 — Chaîne composée uniquement d'espaces
-- Erreur attendue : PAYLOAD_REQUIRED
-- ============================================================================

RETURN fn::validation_json(
    "     ",
    "PAYLOAD",
    10000
);


-- ============================================================================
-- TEST 21 — Objet SurrealQL déjà construit
-- Erreur attendue : PAYLOAD_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_json(
    {
        name: "Lyxal"
    },
    "PAYLOAD",
    10000
);


-- ============================================================================
-- TEST 22 — Tableau SurrealQL déjà construit
-- Erreur attendue : PAYLOAD_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_json(
    [
        "booking",
        "calendar"
    ],
    "PAYLOAD",
    10000
);


-- ============================================================================
-- TEST 23 — Entier SurrealQL au lieu d'une chaîne JSON
-- Erreur attendue : PAYLOAD_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_json(
    42,
    "PAYLOAD",
    10000
);


-- ============================================================================
-- TEST 24 — Booléen SurrealQL au lieu d'une chaîne JSON
-- Erreur attendue : PAYLOAD_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_json(
    true,
    "PAYLOAD",
    10000
);


-- ============================================================================
-- TEST 25 — Objet JSON avec clé sans guillemets
-- Erreur attendue : erreur native encoding::json::decode()
-- ============================================================================

RETURN fn::validation_json(
    '{name:"Lyxal"}',
    "PAYLOAD",
    10000
);


-- ============================================================================
-- TEST 26 — Objet JSON utilisant des apostrophes
-- Erreur attendue : erreur native encoding::json::decode()
-- ============================================================================

RETURN fn::validation_json(
    "{'name':'Lyxal'}",
    "PAYLOAD",
    10000
);


-- ============================================================================
-- TEST 27 — Virgule finale interdite
-- Erreur attendue : erreur native encoding::json::decode()
-- ============================================================================

RETURN fn::validation_json(
    '{"name":"Lyxal",}',
    "PAYLOAD",
    10000
);


-- ============================================================================
-- TEST 28 — Tableau avec virgule finale
-- Erreur attendue : erreur native encoding::json::decode()
-- ============================================================================

RETURN fn::validation_json(
    '["booking","calendar",]',
    "PAYLOAD",
    10000
);


-- ============================================================================
-- TEST 29 — Accolade fermante absente
-- Erreur attendue : erreur native encoding::json::decode()
-- ============================================================================

RETURN fn::validation_json(
    '{"name":"Lyxal"',
    "PAYLOAD",
    10000
);


-- ============================================================================
-- TEST 30 — Guillemets fermants absents
-- Erreur attendue : erreur native encoding::json::decode()
-- ============================================================================

RETURN fn::validation_json(
    '{"name":"Lyxal}',
    "PAYLOAD",
    10000
);


-- ============================================================================
-- TEST 31 — Commentaire interdit dans le JSON
-- Erreur attendue : erreur native encoding::json::decode()
-- ============================================================================

RETURN fn::validation_json(
    '{"name":"Lyxal" /* commentaire */}',
    "PAYLOAD",
    10000
);


-- ============================================================================
-- TEST 32 — Valeur NONE propre à SurrealQL
-- Erreur attendue : comportement du décodeur selon la syntaxe prise en charge
-- ============================================================================

RETURN fn::validation_json(
    'NONE',
    "PAYLOAD",
    10000
);


-- ============================================================================
-- TEST 33 — Chaîne dépassant la longueur maximale
-- Erreur attendue : PAYLOAD_TOO_LONG
-- ============================================================================

RETURN fn::validation_json(
    '{"name":"Lyxal","description":"Configuration volontairement trop longue"}',
    "PAYLOAD",
    20
);


-- ============================================================================
-- TEST 34 — Longueur maximale égale à zéro
-- Erreur attendue : VALIDATION_INVALID_MAX_LENGTH
-- ============================================================================

RETURN fn::validation_json(
    '{"name":"Lyxal"}',
    "PAYLOAD",
    0
);


-- ============================================================================
-- TEST 35 — Longueur maximale négative
-- Erreur attendue : VALIDATION_INVALID_MAX_LENGTH
-- ============================================================================

RETURN fn::validation_json(
    '{"name":"Lyxal"}',
    "PAYLOAD",
    -1
);


-- ============================================================================
-- TEST 36 — Nom technique vide
-- Erreur attendue : VALIDATION_INVALID_FIELD_NAME
-- ============================================================================

RETURN fn::validation_json(
    '{"name":"Lyxal"}',
    "     ",
    10000
);