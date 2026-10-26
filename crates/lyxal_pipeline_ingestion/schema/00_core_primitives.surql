-- Primitives universelles de contrat Lyxal OS (Conformes à .agents/AGENTS.md)
DEFINE FUNCTION OVERWRITE fn::result_ok($data: any) {
    RETURN { ok: true, data: $data, error: NONE };
};

DEFINE FUNCTION OVERWRITE fn::error_result($code: option<string>, $language: option<string>, $details: option<object>) {
    LET $c = IF $code != NONE { <string> $code } ELSE { "UNKNOWN_ERROR" };
    RETURN {
        ok: false,
        data: NONE,
        error: {
            code: $c,
            message: $c,
            label: $c,
            category: "BUSINESS",
            severity: "ERROR",
            retryable: false,
            documentation: {},
            metadata: {},
            details: IF $details != NONE { $details } ELSE { {} }
        }
    };
};
