-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/validations/functions/card_pan.surql
-- Fonction : fn::validation_card_pan
--
-- Valide un numéro de carte bancaire (PAN) : 12 à 19 chiffres avec clé de
-- Luhn ; identifie le réseau (visa, mastercard, amex, discover, unknown),
-- facultativement parmi une liste.
--
-- Paramètres
--   $value            : any — valeur à contrôler
--   $allowed_networks : option<array<string>> — réseaux autorisés parmi ["visa", "mastercard", "amex", "discover", "unknown"], NONE pour tous
--
-- Résultat : { valid, value, code, details } (contrat : crates/lyxal_core/Readme.md)
--   valid = true  → value = { pan, network, length }, code = NONE
--   valid = false → value = NONE, code parmi :
--     CORE_VALIDATION_REQUIRED
--     CORE_VALIDATION_NULL
--     CORE_VALIDATION_TYPE
--     CORE_VALIDATION_BLANK
--     CORE_VALIDATION_FORMAT
--     CORE_VALIDATION_TOO_SHORT
--     CORE_VALIDATION_TOO_LONG
--     CORE_VALIDATION_NOT_ALLOWED
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : liste vide ou réseau inconnu
--
-- Exemple (dans une fonction de module)
--   LET $card = fn::validation_card_pan($params.pan, ["visa", "mastercard"]);
--   IF !$card.valid {
--       RETURN fn::error_result("<MODULE>_<DOMAINE>_INVALID", $params.language, { reason: $card.code });
--   };
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_card_pan(
    $value: any,
    $allowed_networks: option<array<string>>
) -> object {
    LET $allowed = IF $allowed_networks IS NONE { NONE } ELSE { array::map($allowed_networks, |$item| string::lowercase(string::trim($item))) };
    IF $allowed IS NOT NONE AND (array::len($allowed) = 0 OR array::any($allowed, |$item| $item NOT IN ["visa", "mastercard", "amex", "discover", "unknown"])) { THROW "CORE_INVALID_ARGUMENT"; };
    LET $check = fn::validation_luhn($value, 12, 19);
    IF !$check.valid { RETURN $check; };
    LET $pan = $check.value;
    LET $length = string::len($pan);
    LET $p2 = <int> string::slice($pan, 0, 2);
    LET $p4 = <int> string::slice($pan, 0, 4);
    LET $p6 = <int> string::slice($pan, 0, 6);
    LET $network = IF string::starts_with($pan, "4") AND $length IN [13, 16, 19] { "visa" }
        ELSE IF $length = 16 AND (($p2 >= 51 AND $p2 <= 55) OR ($p4 >= 2221 AND $p4 <= 2720)) { "mastercard" }
        ELSE IF $length = 15 AND $p2 IN [34, 37] { "amex" }
        ELSE IF $length IN [16, 19] AND (string::starts_with($pan, "6011") OR string::starts_with($pan, "65") OR ($p6 >= 622126 AND $p6 <= 622925)) { "discover" }
        ELSE { "unknown" };
    IF $allowed IS NOT NONE AND $network NOT IN $allowed { RETURN { valid: false, value: NONE, code: "CORE_VALIDATION_NOT_ALLOWED", details: { allowed: $allowed, actual: $network } }; };
    RETURN { valid: true, value: { pan: $pan, network: $network, length: $length }, code: NONE, details: {} };
}
COMMENT "Valide un numéro de carte et identifie son réseau. Renvoie { valid, value, code, details }."
PERMISSIONS FULL;
