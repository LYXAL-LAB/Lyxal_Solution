-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/lyxal_bucket_name.surql
-- Fonction     : fn::validation_lyxal_bucket_name
-- Domaine      : Core / Validation / Lyxal OS
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide le nom d'un bucket logique Lyxal ou compatible stockage objet.
--
-- Règles appliquées
-- -----------------
--   1. La valeur est normalisée en minuscules.
--   2. Elle commence et finit par une lettre ou un chiffre.
--   3. Les tirets sont autorisés comme séparateurs.
--   4. Les doubles tirets et les formes ressemblant à une IPv4 sont refusés.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
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
-- <FIELD>_INVALID_BUCKET_NAME
-- <FIELD>_IP_LIKE_BUCKET_NOT_ALLOWED
-- VALIDATION_INVALID_BUCKET_LENGTH_RANGE
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

DEFINE FUNCTION OVERWRITE fn::validation_lyxal_bucket_name(
    $value: option<any>,
    $field: string,
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

    IF $min_length < 3 OR $max_length < 3 OR $min_length > $max_length {
        THROW "VALIDATION_INVALID_BUCKET_LENGTH_RANGE";
    };

    LET $bucket_name = string::lowercase($clean_value);
    LET $length = string::len($bucket_name);

    IF $length < $min_length {
        THROW string::concat($clean_field, "_TOO_SHORT");
    };

    IF $length > $max_length {
        THROW string::concat($clean_field, "_TOO_LONG");
    };

    IF !string::matches(
        $bucket_name,
        "^[a-z0-9][a-z0-9-]*[a-z0-9]$"
    )
        OR string::contains($bucket_name, "--")
    {
        THROW string::concat(
            $clean_field,
            "_INVALID_BUCKET_NAME"
        );
    };

    IF string::is_ipv4($bucket_name) {
        THROW string::concat(
            $clean_field,
            "_IP_LIKE_BUCKET_NOT_ALLOWED"
        );
    };

    RETURN $bucket_name;
}
COMMENT "
Valide un nom de bucket logique Lyxal compatible avec les conventions courantes
du stockage objet.
"
PERMISSIONS FULL;
