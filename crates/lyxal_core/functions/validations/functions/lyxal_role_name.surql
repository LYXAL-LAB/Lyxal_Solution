-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/lyxal_role_name.surql
-- Fonction     : fn::validation_lyxal_role_name
-- Domaine      : Core / Validation / Lyxal OS
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide un nom de rôle Lyxal destiné au contrôle d'accès.
--
-- Règles appliquées
-- -----------------
--   1. La valeur est normalisée en minuscules.
--   2. Lettres, chiffres et tirets bas sont autorisés.
--   3. Une liste facultative peut interdire les rôles système réservés.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $reserved_roles: option<array<string>>
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
-- <FIELD>_INVALID_ROLE_NAME
-- <FIELD>_RESERVED_ROLE_NAME
-- VALIDATION_INVALID_ROLE_LENGTH_RANGE
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

DEFINE FUNCTION OVERWRITE fn::validation_lyxal_role_name(
    $value: option<any>,
    $field: string,
    $reserved_roles: option<array<string>>,
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
        THROW "VALIDATION_INVALID_ROLE_LENGTH_RANGE";
    };

    LET $role = string::lowercase($clean_value);
    LET $length = string::len($role);

    IF $length < $min_length {
        THROW string::concat($clean_field, "_TOO_SHORT");
    };

    IF $length > $max_length {
        THROW string::concat($clean_field, "_TOO_LONG");
    };

    IF !string::matches(
        $role,
        "^[a-z][a-z0-9_]*[a-z0-9]$"
    ) {
        THROW string::concat(
            $clean_field,
            "_INVALID_ROLE_NAME"
        );
    };

    IF $reserved_roles IS NOT NONE {
        LET $reserved = array::map(
            $reserved_roles,
            |$item| string::lowercase(string::trim($item))
        );

        IF array::contains($reserved, $role) {
            THROW string::concat(
                $clean_field,
                "_RESERVED_ROLE_NAME"
            );
        };
    };

    RETURN $role;
}
COMMENT "
Valide un nom de rôle Lyxal et peut interdire des rôles système réservés.
"
PERMISSIONS FULL;
