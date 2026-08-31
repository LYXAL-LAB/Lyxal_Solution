-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier      : core/sanitize/uppercase.surql
-- Fonction     : fn::sanitize_uppercase
-- Domaine      : Core / Sanitize / String
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Convertit tous les caractères textuels en majuscules selon les règles Unicode du moteur.
--
-- Règles appliquées
-- -----------------
--   1. Aucun trim n'est appliqué.
--   2. La ponctuation et les chiffres sont conservés.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
--
-- Valeur retournée
-- ----------------
-- Retourne une chaîne nettoyée.
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
-- Propriétés
-- -----------
--   - fonction pure ;
--   - aucune lecture ou écriture persistante ;
--   - aucun accès réseau ;
--   - aucune conversion implicite d'un type non textuel ;
--   - résultat déterministe pour une même entrée.

-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::sanitize_uppercase(
    $value: option<any>,
    $field: string
) -> string {
    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    IF $value IS NONE {
        THROW string::concat($clean_field, "_REQUIRED");
    };

    IF type::is_null($value) {
        THROW string::concat(
            $clean_field,
            "_NULL_NOT_ALLOWED"
        );
    };

    IF !type::is_string($value) {
        THROW string::concat(
            $clean_field,
            "_INVALID_TYPE"
        );
    };

    RETURN string::uppercase($value);
}
COMMENT "
Convertit une chaîne en majuscules.
"
PERMISSIONS FULL;
