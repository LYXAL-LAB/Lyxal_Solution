-- lyxal-test: assertions
-- Tests de fn::validation_socket_address (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: valeur conforme
RETURN fn::validation_socket_address(" API.example.com:443 ", true, true, true)
    == { valid: true, value: "api.example.com:443", code: NONE, details: {} };

-- test: IPv4 acceptée
RETURN fn::validation_socket_address("10.0.0.1:5432", false, true, false)
    == { valid: true, value: "10.0.0.1:5432", code: NONE, details: {} };

-- test: IPv6 entre crochets
RETURN fn::validation_socket_address("[::1]:8000", false, false, true)
    == { valid: true, value: "[::1]:8000", code: NONE, details: {} };

-- test: nom d'hôte refusé
RETURN fn::validation_socket_address("db.local:5432", false, true, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { reason: "hostname" } };

-- test: sans port
RETURN fn::validation_socket_address("api.example.com", true, true, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "socket_address" } };

-- test: port nul
RETURN fn::validation_socket_address("api.example.com:0", true, true, true).code == "CORE_VALIDATION_FORMAT";

-- test: port démesuré
RETURN fn::validation_socket_address("api.example.com:99999999999", true, true, true).code == "CORE_VALIDATION_FORMAT";

-- test: chaîne blanche
RETURN fn::validation_socket_address("  ", true, true, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_socket_address(NONE, true, true, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_socket_address(NULL, true, true, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_socket_address(42, true, true, true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: aucun type d'hôte
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_socket_address("a:1", false, false, false);
