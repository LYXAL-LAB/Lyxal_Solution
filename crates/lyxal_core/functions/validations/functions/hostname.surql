-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/hostname.surql
-- Fonction     : fn::validation_hostname
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide un nom d'hôte DNS ASCII, avec domaine complet ou nom local selon la configuration.
--
-- Règles appliquées
-- -----------------
--   1. La valeur est normalisée en minuscules.
--   2. Chaque label commence et finit par un caractère alphanumérique.
--   3. Le tiret est autorisé uniquement à l'intérieur d'un label.
--   4. Les labels ne dépassent pas 63 caractères.
--   5. La longueur totale ne dépasse pas 253 caractères.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $allow_single_label: bool
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_BLANK_NOT_ALLOWED
-- <FIELD>_INVALID_HOSTNAME
-- <FIELD>_SINGLE_LABEL_NOT_ALLOWED
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
-- Cette fonction est une primitive pure : aucune lecture ou écriture
-- persistante, aucun accès réseau et aucun effet secondaire.
--
-- Dépendances natives SurrealDB
-- -----------------------------
--   - string::trim()
--   - string::lowercase()
--   - string::matches()
--   - string::len()
--   - string::split()
--   - string::concat()
--   - type::is_null()
--   - type::is_string()
--   - array::len()
--   - array::any()
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_hostname(
    $value: option<any>,
    $field: string,
    $allow_single_label: bool
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

    LET $hostname = string::lowercase($clean_value);

    IF string::len($hostname) > 253 {
        THROW string::concat($clean_field, "_INVALID_HOSTNAME");
    };

    LET $labels = string::split($hostname, ".");

    IF !$allow_single_label AND array::len($labels) < 2 {
        THROW string::concat($clean_field, "_SINGLE_LABEL_NOT_ALLOWED");
    };

    LET $invalid_label = array::any(
        $labels,
        |$label|
            string::len($label) = 0
            OR string::len($label) > 63
            OR !string::matches(
                $label,
                "^[a-z0-9](?:[a-z0-9-]*[a-z0-9])?$"
            )
    );

    IF $invalid_label {
        THROW string::concat($clean_field, "_INVALID_HOSTNAME");
    };

    RETURN $hostname;
}
COMMENT "
Valide et normalise un nom d'hôte DNS ASCII.
"
PERMISSIONS FULL;
