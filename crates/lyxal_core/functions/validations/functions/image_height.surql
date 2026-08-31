-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/image_height.surql
-- Fonction     : fn::validation_image_height
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide une hauteur d'image entière en pixels.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $min_height: int
-- $max_height: int
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_TOO_SHORT
-- <FIELD>_TOO_TALL
-- VALIDATION_INVALID_IMAGE_HEIGHT_RANGE
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
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.

-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_image_height(
    $value: option<any>,
    $field: string,
    $min_height: int,
    $max_height: int
) -> int {
    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    IF $min_height < 1
        OR $max_height < 1
        OR $min_height > $max_height
    {
        THROW "VALIDATION_INVALID_IMAGE_HEIGHT_RANGE";
    };

    IF $value IS NONE {
        THROW string::concat($clean_field, "_REQUIRED");
    };

    IF type::is_null($value) {
        THROW string::concat($clean_field, "_NULL_NOT_ALLOWED");
    };

    IF !type::is_int($value) {
        THROW string::concat($clean_field, "_INVALID_TYPE");
    };

    IF $value < $min_height {
        THROW string::concat($clean_field, "_TOO_SHORT");
    };

    IF $value > $max_height {
        THROW string::concat($clean_field, "_TOO_TALL");
    };

    RETURN $value;
}
COMMENT "
Valide une hauteur d'image entière en pixels.
"
PERMISSIONS FULL;
