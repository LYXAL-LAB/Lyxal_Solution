-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/lyxal_instance_name.surql
-- Fonction     : fn::validation_lyxal_instance_name
-- Domaine      : Core / Validation / Lyxal OS
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide le nom d'une instance logique Lyxal OS ou d'une marque blanche.
--
-- Règles appliquées
-- -----------------
--   1. La valeur est normalisée en minuscules.
--   2. Lettres, chiffres et tirets sont autorisés.
--   3. Un environnement peut être imposé comme suffixe : dev, test, staging ou prod.
--   4. Les doubles tirets sont interdits.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $environment: option<string>
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
-- <FIELD>_INVALID_INSTANCE_NAME
-- <FIELD>_ENVIRONMENT_SUFFIX_REQUIRED
-- VALIDATION_INVALID_INSTANCE_LENGTH_RANGE
-- VALIDATION_INVALID_INSTANCE_ENVIRONMENT
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

DEFINE FUNCTION OVERWRITE fn::validation_lyxal_instance_name(
    $value: option<any>,
    $field: string,
    $environment: option<string>,
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
        THROW "VALIDATION_INVALID_INSTANCE_LENGTH_RANGE";
    };

    LET $instance = string::lowercase($clean_value);
    LET $length = string::len($instance);

    IF $length < $min_length {
        THROW string::concat($clean_field, "_TOO_SHORT");
    };

    IF $length > $max_length {
        THROW string::concat($clean_field, "_TOO_LONG");
    };

    IF !string::matches(
        $instance,
        "^[a-z][a-z0-9-]*[a-z0-9]$"
    )
        OR string::contains($instance, "--")
    {
        THROW string::concat(
            $clean_field,
            "_INVALID_INSTANCE_NAME"
        );
    };

    IF $environment IS NOT NONE {
        LET $env = string::lowercase(string::trim($environment));

        IF !array::contains(
            ["dev", "test", "staging", "prod"],
            $env
        ) {
            THROW "VALIDATION_INVALID_INSTANCE_ENVIRONMENT";
        };

        IF !string::ends_with(
            $instance,
            string::concat("-", $env)
        ) {
            THROW string::concat(
                $clean_field,
                "_ENVIRONMENT_SUFFIX_REQUIRED"
            );
        };
    };

    RETURN $instance;
}
COMMENT "
Valide le nom d'une instance Lyxal OS et son suffixe d'environnement facultatif.
"
PERMISSIONS FULL;
