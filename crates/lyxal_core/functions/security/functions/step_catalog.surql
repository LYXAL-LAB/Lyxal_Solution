-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/security/functions/step_catalog.surql
-- Fonction : fn::security_step_catalog
--
-- Catalogue des règles de security utilisables dans un pipeline du moteur :
-- masquage et empreintes (transforment la valeur), détections (enregistrent
-- un constat, kind « finding »), permission_check (enregistre une décision,
-- kind « decision » ; options permissions, resource, action, context).
-- required liste les options obligatoires. Aucune règle n'est déclarée
-- idempotente : empreintes et masquages se cumulent, détections et décisions
-- ajoutent un enregistrement à chaque passage.
--
-- Valeur renvoyée : array<object> (contrat : crates/lyxal_core/Readme.md, fonctions security)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::security_step_catalog() -> array<object> {
    RETURN [
        { rule: "redact_card", cost: 1 },
        { rule: "redact_email", cost: 1 },
        { rule: "redact_ip", cost: 1 },
        { rule: "redact_log", cost: 1 },
        { rule: "redact_phone", cost: 1 },
        { rule: "redact_object", cost: 1, required: ["sensitive_keys"] },
        { rule: "redact_array", cost: 1, required: ["indexes"] },
        { rule: "secret_mask", cost: 1 },
        { rule: "scope", cost: 1 },
        { rule: "hash_sha256", cost: 1 },
        { rule: "hash_sha512", cost: 1 },
        { rule: "hash_blake3", cost: 1 },
        { rule: "hash_string", cost: 1, required: ["algorithm"] },
        { rule: "detect_payload", cost: 2 },
        { rule: "detect_sql_injection", cost: 2 },
        { rule: "detect_xss", cost: 2 },
        { rule: "detect_path_traversal", cost: 2 },
        { rule: "detect_command_injection", cost: 2 },
        { rule: "detect_header_injection", cost: 2 },
        { rule: "detect_open_redirect", cost: 2 },
        { rule: "detect_file_attack", cost: 2, required: ["mime"] },
        { rule: "permission_check", cost: 2, required: ["permissions", "resource", "action"] }
    ];
}
COMMENT "Catalogue des règles de security utilisables dans un pipeline du moteur : masquage et empreintes (transforment la valeur), détections (enregistrent un constat, kind « finding »), permission_check (enregistre une décision, kind « decision » ; options permissions, resource, action, context). required liste les options obligatoires. Aucune règle n'est déclarée idempotente : empreintes et masquages se cumulent, détections et décisions ajoutent un enregistrement à chaque passage."
PERMISSIONS FULL;
