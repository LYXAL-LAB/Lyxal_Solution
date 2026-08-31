-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/coordinates.surql
-- Fonction     : fn::validation_coordinates
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide une paire latitude/longitude et retourne un objet normalisé.
--
-- Règles appliquées
-- -----------------
--   1. Les deux valeurs sont obligatoires et numériques.
--   2. La latitude doit être comprise entre -90 et 90.
--   3. La longitude doit être comprise entre -180 et 180.
--   4. L'ordre de sortie est explicite : latitude puis longitude.
--
-- Paramètres
-- ----------
-- $latitude: option<any>
-- $longitude: option<any>
-- $field: string
--
-- Valeur retournée
-- ----------------
-- Retourne la valeur validée et, lorsque cela est indiqué, normalisée.
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_LATITUDE_REQUIRED
-- <FIELD>_LATITUDE_NULL_NOT_ALLOWED
-- <FIELD>_LATITUDE_INVALID_TYPE
-- <FIELD>_LATITUDE_OUT_OF_RANGE
-- <FIELD>_LONGITUDE_REQUIRED
-- <FIELD>_LONGITUDE_NULL_NOT_ALLOWED
-- <FIELD>_LONGITUDE_INVALID_TYPE
-- <FIELD>_LONGITUDE_OUT_OF_RANGE
--
-- Erreurs communes
-- ----------------
-- <FIELD>_REQUIRED
--   La valeur est absente ou égale à NONE.
--
-- <FIELD>_NULL_NOT_ALLOWED
--   La valeur est explicitement égale à NULL.
--
-- <FIELD>_INVALID_TYPE
--   La valeur ne possède pas le type attendu.
--
-- <FIELD>_BLANK_NOT_ALLOWED
--   La chaîne est vide après string::trim().
--
-- VALIDATION_INVALID_FIELD_NAME
--   Le nom technique du champ est vide.
--
-- Permissions
-- -----------
-- PERMISSIONS FULL
--
-- Cette fonction est une primitive pure :
--
--   - aucune lecture ou écriture persistante ;
--   - aucun accès réseau ;
--   - aucune résolution géographique externe ;
--   - aucune conversion implicite de la valeur métier.
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

DEFINE FUNCTION OVERWRITE fn::validation_coordinates(
    $latitude: option<any>,
    $longitude: option<any>,
    $field: string
) -> object {
    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    IF $latitude IS NONE {
        THROW string::concat($clean_field, "_LATITUDE_REQUIRED");
    };

    IF type::is_null($latitude) {
        THROW string::concat(
            $clean_field,
            "_LATITUDE_NULL_NOT_ALLOWED"
        );
    };

    IF !type::is_number($latitude) {
        THROW string::concat(
            $clean_field,
            "_LATITUDE_INVALID_TYPE"
        );
    };

    IF $latitude < -90 OR $latitude > 90 {
        THROW string::concat(
            $clean_field,
            "_LATITUDE_OUT_OF_RANGE"
        );
    };

    IF $longitude IS NONE {
        THROW string::concat($clean_field, "_LONGITUDE_REQUIRED");
    };

    IF type::is_null($longitude) {
        THROW string::concat(
            $clean_field,
            "_LONGITUDE_NULL_NOT_ALLOWED"
        );
    };

    IF !type::is_number($longitude) {
        THROW string::concat(
            $clean_field,
            "_LONGITUDE_INVALID_TYPE"
        );
    };

    IF $longitude < -180 OR $longitude > 180 {
        THROW string::concat(
            $clean_field,
            "_LONGITUDE_OUT_OF_RANGE"
        );
    };

    RETURN {
        latitude: $latitude,
        longitude: $longitude
    };
}
COMMENT "
Valide une paire de coordonnées latitude/longitude et retourne un objet.
"
PERMISSIONS FULL;
