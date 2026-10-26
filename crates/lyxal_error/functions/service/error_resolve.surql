-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::error_resolve                                                       │
-- │  Résolution et traduction d'une erreur canonique complète avec repli     │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION IF NOT EXISTS fn::error_resolve(
    $code: option<string>,
    $language: option<string>,
    $details: option<object>
) {
    IF $code == NONE OR string::len(string::trim($code)) == 0 {
        THROW "Parameter 'code' is required";
    };

    LET $clean_code = string::uppercase(string::trim($code));
    LET $lang = IF $language != NONE AND string::len(string::trim($language)) > 0 {
        string::lowercase(string::trim($language))
    } ELSE {
        "fr"
    };

    LET $definition = fn::error_get($clean_code);

    IF $definition == NONE {
        LET $fallback_det = IF $details != NONE { $details } ELSE { {} };
        RETURN {
            code: $clean_code,
            message: "Unknown Lyxal error",
            label: "Une erreur inconnue est survenue",
            description: NONE,
            resolution: NONE,
            category: "internal",
            severity: "error",
            http_status: 500,
            retryable: false,
            details: $fallback_det
        };
    };

    LET $translations = IF $definition.translations != NONE { $definition.translations } ELSE { {} };
    LET $default_lang = IF $definition.default_language != NONE { $definition.default_language } ELSE { "en" };

    LET $t_req = $translations[$lang];
    LET $t_def = $translations[$default_lang];

    LET $translation = IF $t_req != NONE {
        $t_req
    } ELSE IF $t_def != NONE {
        $t_def
    } ELSE {
        {}
    };

    LET $label = IF $translation.label != NONE { $translation.label } ELSE { $definition.message };
    LET $desc = IF $translation.description != NONE { $translation.description } ELSE { NONE };
    LET $resol = IF $translation.resolution != NONE { $translation.resolution } ELSE { NONE };
    LET $doc = IF $definition.documentation != NONE { $definition.documentation } ELSE { {} };
    LET $meta = IF $definition.metadata != NONE { $definition.metadata } ELSE { {} };
    LET $det = IF $details != NONE { $details } ELSE { {} };

    RETURN {
        code: $definition.code,
        message: $definition.message,
        label: $label,
        description: $desc,
        resolution: $resol,
        category: $definition.category,
        severity: $definition.severity,
        http_status: $definition.http_status,
        retryable: $definition.retryable,
        documentation: $doc,
        metadata: $meta,
        details: $det
    };
} COMMENT "Résout et traduit une erreur canonique complète avec repli linguistique";
