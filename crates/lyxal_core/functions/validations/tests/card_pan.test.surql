-- lyxal-test: assertions
-- Tests de fn::validation_card_pan (format : crates/lyxal_core/implementation_plan.md §5).

-- test: Visa
RETURN fn::validation_card_pan("4111 1111 1111 1111", NONE)
    == { valid: true, value: { pan: "4111111111111111", network: "visa", length: 16 }, code: NONE, details: {} };

-- test: Mastercard
RETURN fn::validation_card_pan("5555555555554444", NONE).value.network == "mastercard";

-- test: American Express
RETURN fn::validation_card_pan("378282246310005", NONE).value.network == "amex";

-- test: réseau non autorisé
RETURN fn::validation_card_pan("378282246310005", ["visa"])
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { allowed: ["visa"], actual: "amex" } };

-- test: clé fausse
RETURN fn::validation_card_pan("4111111111111112", NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "luhn" } };

-- test: valeur absente
RETURN fn::validation_card_pan(NONE, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_card_pan(NULL, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_card_pan(4111111111111111, NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };

-- test: liste vide
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_card_pan("4111111111111111", []);

-- test: réseau inconnu
-- attendu-erreur: CORE_INVALID_ARGUMENT
RETURN fn::validation_card_pan("4111111111111111", ["jcb"]);
