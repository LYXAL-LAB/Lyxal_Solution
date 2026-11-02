-- ============================================================================
-- LYXAL OS — LYXAL_ERROR
-- ============================================================================
-- Fichier  : crates/lyxal_error/functions/service/error_resolve.surql
-- Fonction : fn::error_resolve
--
-- Résout et traduit une erreur canonique : traduction dans la langue
-- demandée, repli sur la langue par défaut de la définition puis sur le
-- message technique ; un code inconnu ou désactivé donne une erreur interne
-- générique.
--
-- Paramètres
--   $code : code canonique (ex. BOOKING_SLOT_ALREADY_TAKEN)
--   $language : langue souhaitée (défaut fr)
--   $details : contexte transmis tel quel
--
-- Valeur renvoyée : { code, message, label, description, resolution, category, severity, http_status, retryable, documentation, metadata, details }
--
-- Erreurs
--   CORE_INVALID_ARGUMENT : $code absent ou vide (argument de programmation)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::error_resolve(
    $code: option<string>,
    $language: option<string>,
    $details: option<object>
) -> object {
    IF $code IS NONE OR string::trim($code) == "" { THROW "CORE_INVALID_ARGUMENT"; };
    LET $clean_code = string::uppercase(string::trim($code));
    LET $lang = IF $language IS NONE OR string::trim($language) == "" { "fr" } ELSE { string::lowercase(string::trim($language)) };
    LET $definition = (SELECT * FROM error_definition WHERE code = $clean_code AND enabled = true LIMIT 1)[0];
    IF $definition IS NONE {
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
            documentation: {},
            metadata: {},
            details: $details ?? {}
        };
    };
    LET $translation = $definition.translations[$lang] ?? $definition.translations[$definition.default_language] ?? {};
    RETURN {
        code: $definition.code,
        message: $definition.message,
        label: $translation.label ?? $definition.message,
        description: $translation.description,
        resolution: $translation.resolution,
        category: $definition.category,
        severity: $definition.severity,
        http_status: $definition.http_status,
        retryable: $definition.retryable,
        documentation: $definition.documentation ?? {},
        metadata: $definition.metadata ?? {},
        details: $details ?? {}
    };
}
COMMENT "Résout et traduit une erreur canonique : traduction dans la langue demandée, repli sur la langue par défaut de la définition puis sur le message technique ; un code inconnu ou désactivé donne une erreur interne générique."
PERMISSIONS FULL;
