-- lyxal-test: assertions
-- Tests de fn::validation_rib_fr (format : crates/lyxal_core/implementation_plan.md §5).

-- test: RIB valide
RETURN fn::validation_rib_fr("30006", "00001", "1234567890a", "89")
    == { valid: true, value: { bank_code: "30006", branch_code: "00001", account_number: "1234567890A", rib_key: "89" }, code: NONE, details: {} };

-- test: code banque trop court
RETURN fn::validation_rib_fr("3000", "00001", "12345678901", "89")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { bound: "bank_code", expected: "^[0-9]{5}$" } };

-- test: clé absente
RETURN fn::validation_rib_fr("30006", "00001", "12345678901", NONE)
    == { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: { bound: "rib_key" } };

-- test: compte de type entier
RETURN fn::validation_rib_fr("30006", "00001", 12345678901, "89")
    == { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { bound: "account_number", expected: "string", actual: "int" } };
