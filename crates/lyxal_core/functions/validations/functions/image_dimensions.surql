-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/image_dimensions.surql
-- Fonction     : fn::validation_image_dimensions
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide conjointement la largeur, la hauteur et le nombre total de pixels d'une image.
--
-- Paramètres
-- ----------
-- $width: option<any>
-- $height: option<any>
-- $field: string
-- $min_width: int
-- $max_width: int
-- $min_height: int
-- $max_height: int
-- $max_pixels: option<int>
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_WIDTH_REQUIRED / _WIDTH_NULL_NOT_ALLOWED / _WIDTH_INVALID_TYPE
-- <FIELD>_HEIGHT_REQUIRED / _HEIGHT_NULL_NOT_ALLOWED / _HEIGHT_INVALID_TYPE
-- <FIELD>_WIDTH_OUT_OF_RANGE
-- <FIELD>_HEIGHT_OUT_OF_RANGE
-- <FIELD>_PIXEL_COUNT_TOO_LARGE
-- VALIDATION_INVALID_IMAGE_DIMENSION_RANGE
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

DEFINE FUNCTION OVERWRITE fn::validation_image_dimensions(
    $width: option<any>,
    $height: option<any>,
    $field: string,
    $min_width: int,
    $max_width: int,
    $min_height: int,
    $max_height: int,
    $max_pixels: option<int>
) -> object {
    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    IF $min_width < 1
        OR $max_width < 1
        OR $min_height < 1
        OR $max_height < 1
        OR $min_width > $max_width
        OR $min_height > $max_height
        OR ($max_pixels IS NOT NONE AND $max_pixels < 1)
    {
        THROW "VALIDATION_INVALID_IMAGE_DIMENSION_RANGE";
    };

    IF $width IS NONE {
        THROW string::concat($clean_field, "_WIDTH_REQUIRED");
    };

    IF type::is_null($width) {
        THROW string::concat(
            $clean_field,
            "_WIDTH_NULL_NOT_ALLOWED"
        );
    };

    IF !type::is_int($width) {
        THROW string::concat($clean_field, "_WIDTH_INVALID_TYPE");
    };

    IF $height IS NONE {
        THROW string::concat($clean_field, "_HEIGHT_REQUIRED");
    };

    IF type::is_null($height) {
        THROW string::concat(
            $clean_field,
            "_HEIGHT_NULL_NOT_ALLOWED"
        );
    };

    IF !type::is_int($height) {
        THROW string::concat(
            $clean_field,
            "_HEIGHT_INVALID_TYPE"
        );
    };

    IF $width < $min_width OR $width > $max_width {
        THROW string::concat(
            $clean_field,
            "_WIDTH_OUT_OF_RANGE"
        );
    };

    IF $height < $min_height OR $height > $max_height {
        THROW string::concat(
            $clean_field,
            "_HEIGHT_OUT_OF_RANGE"
        );
    };

    LET $pixels = $width * $height;

    IF $max_pixels IS NOT NONE AND $pixels > $max_pixels {
        THROW string::concat(
            $clean_field,
            "_PIXEL_COUNT_TOO_LARGE"
        );
    };

    RETURN {
        width: $width,
        height: $height,
        pixels: $pixels
    };
}
COMMENT "
Valide les dimensions d'une image et retourne son nombre total de pixels.
"
PERMISSIONS FULL;
