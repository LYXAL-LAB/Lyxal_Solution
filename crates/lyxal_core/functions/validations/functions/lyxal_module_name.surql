-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/lyxal_module_name.surql
-- Fonction     : fn::validation_lyxal_module_name
-- Domaine      : Core / Validation / Lyxal OS
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide le nom canonique d'un module installable dans Lyxal OS.
--
-- Règles appliquées
-- -----------------
--   1. La valeur est normalisée en minuscules.
--   2. Le format canonique utilise des segments séparés par un tiret bas.
--   3. Chaque segment commence par une lettre.
--   4. Une liste facultative peut imposer un préfixe de module.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $allowed_prefixes: option<array<string>>
-- $min_length: int
-- $max_length: int
--
-- Valeur retournée
-- ----------------
-- Retourne la valeur validée et normalisée selon la convention de la fonction.
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_TOO_SHORT
-- <FIELD>_TOO_LONG
-- <FIELD>_INVALID_MODULE_NAME
-- <FIELD>_MODULE_PREFIX_NOT_ALLOWED
-- VALIDATION_INVALID_MODULE_LENGTH_RANGE
-- VALIDATION_EMPTY_MODULE_PREFIXES
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

DEFINE FUNCTION OVERWRITE fn::validation_lyxal_module_name(
    $value: option<any>,
    $field: string,
    $allowed_prefixes: option<array<string>>,
    $min_length: int,
    $max_length: int
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

    IF $min_length < 1 OR $max_length < 1 OR $min_length > $max_length {
        THROW "VALIDATION_INVALID_MODULE_LENGTH_RANGE";
    };

    LET $module_name = string::lowercase($clean_value);
    LET $length = string::len($module_name);

    IF $length < $min_length {
        THROW string::concat($clean_field, "_TOO_SHORT");
    };

    IF $length > $max_length {
        THROW string::concat($clean_field, "_TOO_LONG");
    };

    IF !string::matches(
        $module_name,
        "^[a-z][a-z0-9]*(?:_[a-z][a-z0-9]*)*$"
    ) {
        THROW string::concat(
            $clean_field,
            "_INVALID_MODULE_NAME"
        );
    };

    IF $allowed_prefixes IS NOT NONE {
        IF array::len($allowed_prefixes) = 0 {
            THROW "VALIDATION_EMPTY_MODULE_PREFIXES";
        };

        LET $prefixes = array::map(
            $allowed_prefixes,
            |$prefix| string::lowercase(string::trim($prefix))
        );

        IF !array::any(
            $prefixes,
            |$prefix|
                $prefix != ""
                AND string::starts_with($module_name, $prefix)
        ) {
            THROW string::concat(
                $clean_field,
                "_MODULE_PREFIX_NOT_ALLOWED"
            );
        };
    };

    RETURN $module_name;
}
COMMENT "
Valide le nom canonique d'un module installable dans Lyxal OS.
"
PERMISSIONS FULL;
