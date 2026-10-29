-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/bytes.surql
-- Fonction     : fn::validation_bytes
-- Domaine      : Core / Validation
-- Version      : 1.0.1
-- Statut       : Stable
--
-- Description
-- -----------
-- Vérifie qu'une valeur obligatoire est strictement de type bytes SurrealDB.
--
-- Cette fonction permet également d'appliquer facultativement :
--
--   - une longueur minimale en octets ;
--   - une longueur maximale en octets ;
--   - une plage comprise entre une longueur minimale et une longueur maximale.
--
-- Validation stricte
-- ------------------
-- Cette fonction accepte uniquement une véritable valeur bytes SurrealDB
-- (littéral b"...", <bytes>"...", <bytes>[...]).
--
-- La fonction n'effectue aucune conversion implicite et retourne la valeur
-- bytes d'origine intacte.
--
-- Codes d'erreurs levés (THROW)
-- -----------------------------
--   - VALIDATION_INVALID_FIELD_NAME   : si $field est vide ou composé d'espaces
--   - VALIDATION_INVALID_MIN_LENGTH   : si $min_length < 0
--   - VALIDATION_INVALID_MAX_LENGTH   : si $max_length < 0
--   - VALIDATION_INVALID_BYTES_RANGE  : si $min_length > $max_length
--   - <FIELD>_REQUIRED                : si $value est NONE
--   - <FIELD>_NULL_NOT_ALLOWED        : si $value est NULL
--   - <FIELD>_INVALID_TYPE            : si $value n'est pas de type bytes
--   - <FIELD>_TOO_SHORT               : si bytes::len($value) < $min_length
--   - <FIELD>_TOO_LONG                : si bytes::len($value) > $max_length
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_bytes(
    $value: any,
    $field: string,
    $min_length: option<int>,
    $max_length: option<int>
) -> bytes {

    -- ------------------------------------------------------------------------
    -- 1. Validation du nom technique du champ
    -- ------------------------------------------------------------------------

    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    -- ------------------------------------------------------------------------
    -- 2. Validation des bornes de longueur en octets
    -- ------------------------------------------------------------------------

    IF $min_length IS NOT NONE
        AND $min_length < 0
    {
        THROW "VALIDATION_INVALID_MIN_LENGTH";
    };

    IF $max_length IS NOT NONE
        AND $max_length < 0
    {
        THROW "VALIDATION_INVALID_MAX_LENGTH";
    };

    IF $min_length IS NOT NONE
        AND $max_length IS NOT NONE
        AND $min_length > $max_length
    {
        THROW "VALIDATION_INVALID_BYTES_RANGE";
    };

    -- ------------------------------------------------------------------------
    -- 3. Vérification de la présence de la valeur
    -- ------------------------------------------------------------------------

    IF $value IS NONE {
        THROW string::concat(
            $clean_field,
            "_REQUIRED"
        );
    };

    -- ------------------------------------------------------------------------
    -- 4. Refus explicite de NULL
    -- ------------------------------------------------------------------------

    IF type::is_null($value) {
        THROW string::concat(
            $clean_field,
            "_NULL_NOT_ALLOWED"
        );
    };

    -- ------------------------------------------------------------------------
    -- 5. Vérification stricte du type bytes
    -- ------------------------------------------------------------------------

    IF !type::is_bytes($value) {
        THROW string::concat(
            $clean_field,
            "_INVALID_TYPE"
        );
    };

    -- ------------------------------------------------------------------------
    -- 6. Validation de la longueur minimale et maximale en octets
    -- ------------------------------------------------------------------------

    LET $byte_length = bytes::len($value);

    IF $min_length IS NOT NONE
        AND $byte_length < $min_length
    {
        THROW string::concat(
            $clean_field,
            "_TOO_SHORT"
        );
    };

    IF $max_length IS NOT NONE
        AND $byte_length > $max_length
    {
        THROW string::concat(
            $clean_field,
            "_TOO_LONG"
        );
    };

    -- ------------------------------------------------------------------------
    -- 7. Retour de la valeur bytes validée
    -- ------------------------------------------------------------------------

    RETURN $value;
}
COMMENT "
Valide qu'une valeur obligatoire est strictement de type bytes SurrealDB.
Refuse NONE, NULL, les chaînes, les tableaux, les nombres et les autres types.
Contrôle facultativement les longueurs minimale et maximale en octets et retourne
la valeur bytes d'origine sans conversion ni transformation.
"
PERMISSIONS FULL;
