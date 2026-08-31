-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/card_pan.surql
-- Fonction     : fn::validation_card_pan
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide un PAN par Luhn et détecte quelques réseaux courants.
--
-- Principes
-- ----------
--   - distinction stricte entre NONE, NULL et type invalide ;
--   - aucune conversion implicite de la valeur métier ;
--   - codes d'erreur stables construits depuis le nom technique du champ ;
--   - aucune lecture ou écriture persistante ;
--   - aucune vérification auprès d'un service bancaire ou administratif.
--
-- Permissions
-- -----------
-- PERMISSIONS FULL
--
-- Dépendances Lyxal
-- -----------------
-- fn::validation_luhn()

-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_card_pan(
    $value: option<any>,
    $field: string,
    $allowed_networks: option<array<string>>
) -> object {
    LET $pan = fn::validation_luhn($value, $field, 12, 19);
    LET $length = string::len($pan);
    LET $prefix_2 = type::int(string::slice($pan, 0, 2));
    LET $prefix_4 = type::int(string::slice($pan, 0, 4));
    LET $prefix_6 = type::int(string::slice($pan, 0, 6));

    LET $network =
        IF string::starts_with($pan, "4") AND $length IN [13, 16, 19] {
            "visa"
        } ELSE IF $length = 16 AND (
            $prefix_2 IN 51..=55 OR $prefix_4 IN 2221..=2720
        ) {
            "mastercard"
        } ELSE IF $length = 15 AND $prefix_2 IN [34, 37] {
            "amex"
        } ELSE IF $length IN [16, 19] AND (
            string::starts_with($pan, "6011")
            OR string::starts_with($pan, "65")
            OR $prefix_6 IN 622126..=622925
        ) {
            "discover"
        } ELSE {
            "unknown"
        };

    IF $allowed_networks IS NOT NONE {
        IF array::len($allowed_networks) = 0 {
            THROW "VALIDATION_EMPTY_ALLOWED_CARD_NETWORKS";
        };
        LET $allowed = array::map(
            $allowed_networks,
            |$item| string::lowercase(string::trim($item))
        );
        IF !array::contains($allowed, $network) {
            THROW string::concat(string::trim($field), "_NETWORK_NOT_ALLOWED");
        };
    };

    RETURN { pan: $pan, network: $network, length: $length };
}
COMMENT "
Valide un PAN par Luhn. Ne doit pas servir à journaliser ou stocker un PAN
complet hors cadre PCI DSS.
"
PERMISSIONS FULL;
