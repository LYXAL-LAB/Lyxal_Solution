-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/percentage.surql
-- Fonction     : fn::validation_percentage
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide un pourcentage numérique compris dans une plage configurable, généralement 0 à 100.
--
-- Principes
-- ----------
--   - validation stricte sans conversion implicite ;
--   - distinction entre NONE, NULL et type invalide ;
--   - codes d'erreur stables ;
--   - aucune lecture ou écriture persistante ;
--   - retour de la valeur d'origine lorsqu'elle est valide.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $min_value: number
-- $max_value: number
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_TOO_SMALL
-- <FIELD>_TOO_LARGE
-- VALIDATION_INVALID_PERCENTAGE_RANGE
--
-- Erreurs communes
-- ----------------
-- <FIELD>_REQUIRED
-- <FIELD>_NULL_NOT_ALLOWED
-- <FIELD>_INVALID_TYPE
-- VALIDATION_INVALID_FIELD_NAME
--
-- Permissions
-- -----------
-- PERMISSIONS FULL
--
-- Dépendances natives SurrealDB
-- -----------------------------
--   - string::trim()
--   - string::concat()
--   - type::is_null()
--   - type::is_number()
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_percentage(
    $value: option<any>,
    $field: string,
    $min_value: number,
    $max_value: number
) -> number {
    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    IF $min_value > $max_value {
        THROW "VALIDATION_INVALID_PERCENTAGE_RANGE";
    };

    IF $value IS NONE {
        THROW string::concat($clean_field, "_REQUIRED");
    };

    IF type::is_null($value) {
        THROW string::concat($clean_field, "_NULL_NOT_ALLOWED");
    };

    IF !type::is_number($value) {
        THROW string::concat($clean_field, "_INVALID_TYPE");
    };

    IF $value < $min_value {
        THROW string::concat($clean_field, "_TOO_SMALL");
    };

    IF $value > $max_value {
        THROW string::concat($clean_field, "_TOO_LARGE");
    };

    RETURN $value;
}
COMMENT "
Valide un pourcentage numérique dans une plage inclusive configurable.
"
PERMISSIONS FULL;
