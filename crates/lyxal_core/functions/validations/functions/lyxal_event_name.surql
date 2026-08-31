-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/lyxal_event_name.surql
-- Fonction     : fn::validation_lyxal_event_name
-- Domaine      : Core / Validation / Lyxal OS
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide le nom canonique d'un événement Lyxal destiné aux webhooks, workflows ou notifications.
--
-- Règles appliquées
-- -----------------
--   1. La valeur est normalisée en minuscules.
--   2. Le séparateur canonique est le point.
--   3. Chaque segment commence par une lettre.
--   4. Le nombre de segments est configurable.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $min_segments: int
-- $max_segments: int
--
-- Valeur retournée
-- ----------------
-- Retourne la valeur validée et normalisée selon la convention de la fonction.
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_INVALID_EVENT_NAME
-- <FIELD>_TOO_FEW_SEGMENTS
-- <FIELD>_TOO_MANY_SEGMENTS
-- VALIDATION_INVALID_EVENT_SEGMENT_LIMITS
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
--   - aucune dépendance à l'authentification ;
--   - aucune création de ressource Lyxal ;
--   - aucune conversion implicite de la valeur métier.
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.

-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_lyxal_event_name(
    $value: option<any>,
    $field: string,
    $min_segments: int,
    $max_segments: int
) -> string {
    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

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

    IF $min_segments < 1
        OR $max_segments < 1
        OR $min_segments > $max_segments
    {
        THROW "VALIDATION_INVALID_EVENT_SEGMENT_LIMITS";
    };

    LET $event_name = string::lowercase($clean_value);

    IF !string::matches(
        $event_name,
        "^[a-z][a-z0-9_]*(?:\.[a-z][a-z0-9_]*)*$"
    ) {
        THROW string::concat(
            $clean_field,
            "_INVALID_EVENT_NAME"
        );
    };

    LET $segments = string::split($event_name, ".");
    LET $count = array::len($segments);

    IF $count < $min_segments {
        THROW string::concat(
            $clean_field,
            "_TOO_FEW_SEGMENTS"
        );
    };

    IF $count > $max_segments {
        THROW string::concat(
            $clean_field,
            "_TOO_MANY_SEGMENTS"
        );
    };

    RETURN $event_name;
}
COMMENT "
Valide un nom d'événement Lyxal à segments séparés par des points.
"
PERMISSIONS FULL;
