-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/security/functions/redact_log.surql
-- Fonction : fn::security_redact_log
--
-- Masque les secrets courants dans une ligne de journal : jeton Bearer d'un
-- en-tête Authorization, api_key / api-key et password. Le préfixe est
-- réécrit sous une forme normalisée (« Authorization: Bearer », « api_key=
-- », « password= ») suivie de ***REDACTED***.
--
-- Paramètres
--   $message : string
--
-- Valeur renvoyée : string (contrat : crates/lyxal_core/Readme.md, fonctions security)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::security_redact_log(
    $message: string
) -> string {
    LET $bearer = string::replace($message, <regex>"(?i)authorization\\s*:\\s*bearer\\s+[A-Za-z0-9._~+/=-]+", "Authorization: Bearer ***REDACTED***");
    LET $api_key = string::replace($bearer, <regex>"(?i)api[_-]?key\\s*[=:]\\s*[^\\s,;]+", "api_key=***REDACTED***");
    RETURN string::replace($api_key, <regex>"(?i)password\\s*[=:]\\s*[^\\s,;]+", "password=***REDACTED***");
}
COMMENT "Masque les secrets courants dans une ligne de journal : jeton Bearer d'un en-tête Authorization, api_key / api-key et password. Le préfixe est réécrit sous une forme normalisée (« Authorization: Bearer », « api_key= », « password= ») suivie de ***REDACTED***."
PERMISSIONS FULL;
