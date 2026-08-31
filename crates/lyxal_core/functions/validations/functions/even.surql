-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/even.surql
-- Fonction     : fn::validation_even
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Vérifie qu'une valeur obligatoire est un entier pair.
--
-- Principes
-- ----------
--   - validation stricte sans conversion implicite ;
--   - distinction entre NONE, NULL et type invalide ;
--   - codes d'erreur stables ;
--   - aucune lecture ou écriture persistante ;
--   - retour de la valeur d'origine lorsqu'elle est valide.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_NOT_EVEN
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

DEFINE FUNCTION OVERWRITE fn::validation_even(
    $value: option<any>,
    $field: string
) -> int {
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

    IF !type::is_int($value) {
        THROW string::concat($clean_field, "_INVALID_TYPE");
    };

    IF $value % 2 != 0 {
        THROW string::concat($clean_field, "_NOT_EVEN");
    };

    RETURN $value;
}
COMMENT "
Valide qu'une valeur obligatoire est strictement de type int et paire.
"
PERMISSIONS FULL;
