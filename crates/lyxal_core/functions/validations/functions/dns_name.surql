-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/dns_name.surql
-- Fonction : fn::validation_dns_name
--
-- Valide un nom DNS complet, celui d'un enregistrement ou d'une cible : au
-- moins deux labels de 1 à 63 octets en lettres ASCII, chiffres, tiret (jamais
-- au bord) et tiret bas, 253 octets au plus sans le point final, dernier label
-- non entièrement numérique, forme A-label seulement (« xn-- », jamais
-- d'Unicode). Contrairement à fn::validation_domain (string::is_domain), il
-- accepte les labels de service à tiret bas (_dmarc.example.com,
-- sel._domainkey.example.com, _mta-sts.example.com, _smtp._tls.example.com).
-- Un point final unique est accepté et retiré ; la valeur renvoyée est en
-- minuscules.
--
-- Paramètres
--   $value            : any — valeur à contrôler
--   $allow_underscore : bool — true pour accepter le tiret bas dans un label
--   $allow_wildcard   : bool — true pour accepter « * » comme premier label
--                       (ex. *.example.com) ; ailleurs, « * » est refusé
--   $zone             : option<string> — nom de la zone dont le nom doit être
--                       l'apex ou un sous-nom (casse et point final ignorés) ;
--                       NONE pour ne pas contrôler la zone
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = le nom en minuscules, sans point final, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_BLANK
--     CORE_VALIDATION_TOO_LONG    : { max_length: 253, length }
--     CORE_VALIDATION_FORMAT      : { expected: "dns_name" }
--     CORE_VALIDATION_NOT_ALLOWED : { reason } parmi "underscore", "wildcard", "zone"
--
-- Erreurs levées (THROW)
--   CORE_INVALID_ARGUMENT : $zone qui n'est pas un nom DNS valide (sans joker)
--
-- Exemple (dans une fonction de module)
--   LET $name = fn::validation_dns_name($params.name, true, false, $zone.name);
--   IF !$name.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $name.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_dns_name(
    $value: any,
    $allow_underscore: bool,
    $allow_wildcard: bool,
    $zone: option<string>
) -> object {
    LET $zone_name = IF $zone IS NONE { NONE } ELSE {
        LET $zone_check = fn::validation_dns_name($zone, true, false, NONE);
        IF !$zone_check.valid { THROW "CORE_INVALID_ARGUMENT"; };
        $zone_check.value
    };
    IF $value IS NONE { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_REQUIRED", details: {} }; };
    IF type::is_null($value) { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NULL", details: {} }; };
    IF !type::is_string($value) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TYPE", details: { expected: "string", actual: type::of($value) } };
    };
    LET $trimmed = string::lowercase(string::trim($value));
    IF $trimmed = "" { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_BLANK", details: {} }; };
    LET $clean = IF string::ends_with($trimmed, ".") { string::slice($trimmed, 0, string::len($trimmed) - 1) } ELSE { $trimmed };
    IF string::len($clean) > 253 {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_TOO_LONG", details: { max_length: 253, length: string::len($clean) } };
    };
    LET $labels = string::split($clean, ".");
    LET $wildcard = $labels[0] = "*";
    LET $named = IF $wildcard { array::slice($labels, 1) } ELSE { $labels };
    IF array::len($labels) < 2
        OR array::any($named, |$label: string| string::len($label) > 63 OR !string::matches($label, "^[a-z0-9_](?:[a-z0-9_-]*[a-z0-9_])?$"))
        OR string::matches(array::last($labels), "^[0-9]+$") {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_FORMAT", details: { expected: "dns_name" } };
    };
    IF !$allow_underscore AND string::contains($clean, "_") {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { reason: "underscore" } };
    };
    IF !$allow_wildcard AND $wildcard {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { reason: "wildcard" } };
    };
    IF $zone_name IS NOT NONE AND $clean != $zone_name AND !string::ends_with($clean, "." + $zone_name) {
        RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { reason: "zone" } };
    };
    RETURN { valid: true, value: $clean, code: NONE, details: {} };
}
COMMENT "Valide un nom DNS complet (labels de 1 à 63 octets [a-z0-9_-], tiret jamais au bord, au moins deux labels, 253 octets au plus, dernier label non numérique, A-label seulement) ; tiret bas et joker « * » en premier label acceptés seulement si autorisés ; zone facultative dont le nom doit être l'apex ou un sous-nom. La valeur renvoyée est en minuscules, sans point final. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
