-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/aspect_ratio.surql
-- Fonction     : fn::validation_aspect_ratio
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide le ratio largeur/hauteur d'une image dans une plage décimale.
--
-- Paramètres
-- ----------
-- $width: option<any>
-- $height: option<any>
-- $field: string
-- $min_ratio: decimal
-- $max_ratio: decimal
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_INVALID_DIMENSION_TYPE
-- <FIELD>_INVALID_DIMENSION_VALUE
-- <FIELD>_RATIO_TOO_SMALL
-- <FIELD>_RATIO_TOO_LARGE
-- VALIDATION_INVALID_ASPECT_RATIO_RANGE
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
--   - aucun accès réseau ;
--   - aucune inspection binaire réelle du fichier ;
--   - aucune conversion implicite de la valeur validée.
--
-- Dépendances natives SurrealDB
-- -----------------------------
--   - string::trim()
--   - string::concat()
--   - type::is_null()
--   - type::is_int()
--   - type::decimal()
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.

-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_aspect_ratio(
    $width: option<any>,
    $height: option<any>,
    $field: string,
    $min_ratio: decimal,
    $max_ratio: decimal
) -> object {
    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    IF $min_ratio <= 0dec
        OR $max_ratio <= 0dec
        OR $min_ratio > $max_ratio
    {
        THROW "VALIDATION_INVALID_ASPECT_RATIO_RANGE";
    };

    IF $width IS NONE OR $height IS NONE {
        THROW string::concat($clean_field, "_REQUIRED");
    };

    IF type::is_null($width) OR type::is_null($height) {
        THROW string::concat(
            $clean_field,
            "_NULL_NOT_ALLOWED"
        );
    };

    IF !type::is_int($width) OR !type::is_int($height) {
        THROW string::concat(
            $clean_field,
            "_INVALID_DIMENSION_TYPE"
        );
    };

    IF $width <= 0 OR $height <= 0 {
        THROW string::concat(
            $clean_field,
            "_INVALID_DIMENSION_VALUE"
        );
    };

    LET $ratio = type::decimal($width) / type::decimal($height);

    IF $ratio < $min_ratio {
        THROW string::concat(
            $clean_field,
            "_RATIO_TOO_SMALL"
        );
    };

    IF $ratio > $max_ratio {
        THROW string::concat(
            $clean_field,
            "_RATIO_TOO_LARGE"
        );
    };

    RETURN {
        width: $width,
        height: $height,
        ratio: $ratio
    };
}
COMMENT "
Valide le ratio largeur/hauteur d'une image dans une plage inclusive.
"
PERMISSIONS FULL;
