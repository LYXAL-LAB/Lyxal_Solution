-- lyxal-test: assertions
-- Tests de fn::validation_vat_number_fr (format : crates/lyxal_core/Readme.md, section « Tests »).

-- test: numéro valide
RETURN fn::validation_vat_number_fr(" fr 44 732829320 ", true)
    == { valid: true, value: { vat_number: "FR44732829320", country: "FR", key: "44", siren: "732829320" }, code: NONE, details: {} };

-- test: clé fausse
RETURN fn::validation_vat_number_fr("FR45732829320", true)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "vat_key" } };

-- test: clé non vérifiée
RETURN fn::validation_vat_number_fr("FR45732829320", false).valid;

-- test: SIREN invalide
RETURN fn::validation_vat_number_fr("FR44732829321", false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "siren" } };

-- test: autre pays
RETURN fn::validation_vat_number_fr("BE0123456789", false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "vat_number_fr" } };

-- test: chaîne blanche
RETURN fn::validation_vat_number_fr("  ", false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} };

-- test: valeur absente
RETURN fn::validation_vat_number_fr(NONE, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} };

-- test: valeur NULL
RETURN fn::validation_vat_number_fr(NULL, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} };

-- test: type int refusé
RETURN fn::validation_vat_number_fr(1, false)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: "int" } };
