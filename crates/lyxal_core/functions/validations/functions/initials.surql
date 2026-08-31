-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/initials.surql
-- Fonction     : fn::validation_initials
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide des initiales humaines avec points et séparateurs facultatifs.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $min_count: int
-- $max_count: int
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_INVALID_INITIALS
-- <FIELD>_TOO_FEW_INITIALS
-- <FIELD>_TOO_MANY_INITIALS
-- VALIDATION_INVALID_INITIALS_LIMITS
--
-- Erreurs communes
-- ----------------
-- <FIELD>_REQUIRED
-- <FIELD>_NULL_NOT_ALLOWED
-- <FIELD>_INVALID_TYPE
-- <FIELD>_BLANK_NOT_ALLOWED
-- VALIDATION_INVALID_FIELD_NAME
--
-- Permissions
-- -----------
-- PERMISSIONS FULL
--
-- Cette fonction est une primitive pure :
--
--   - aucune lecture ou écriture persistante ;
--   - aucune dépendance à l'authentification ;
--   - aucune consultation de registre externe ;
--   - aucune conversion implicite de la valeur métier.
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.

-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_initials(
    $value: option<any>,
    $field: string,
    $min_count: int,
    $max_count: int
) -> string {
    LET $clean_field = string::trim($field);
    IF $clean_field = "" { THROW "VALIDATION_INVALID_FIELD_NAME"; };

    IF $value IS NONE {
        THROW string::concat($clean_field, "_REQUIRED");
    };

    IF type::is_null($value) {
        THROW string::concat($clean_field, "_NULL_NOT_ALLOWED");
    };

    IF !type::is_string($value) {
        THROW string::concat($clean_field, "_INVALID_TYPE");
    };

    LET $clean_value = string::trim($value);

    IF $clean_value = "" {
        THROW string::concat($clean_field, "_BLANK_NOT_ALLOWED");
    };

    IF $min_count < 1 OR $max_count < 1 OR $min_count > $max_count {
        THROW "VALIDATION_INVALID_INITIALS_LIMITS";
    };

    LET $normalized = string::uppercase(
        string::replace(
            string::replace($clean_value, " ", ""),
            ".",
            ""
        )
    );

    IF !string::matches($normalized, "^[A-Z]+$") {
        THROW string::concat($clean_field, "_INVALID_INITIALS");
    };

    LET $count = string::len($normalized);

    IF $count < $min_count {
        THROW string::concat(
            $clean_field,
            "_TOO_FEW_INITIALS"
        );
    };

    IF $count > $max_count {
        THROW string::concat(
            $clean_field,
            "_TOO_MANY_INITIALS"
        );
    };

    RETURN $normalized;
}
COMMENT "
Valide des initiales ASCII et les retourne en majuscules sans points ni espaces.
"
PERMISSIONS FULL;
