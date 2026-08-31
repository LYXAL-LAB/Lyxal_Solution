-- ============================================================================
-- LYXAL OS — CORE SANITIZE
-- ============================================================================
-- Fichier      : core/sanitize/capitalize.surql
-- Fonction     : fn::sanitize_capitalize
-- Domaine      : Core / Sanitize / String
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Met en majuscule le premier caractère de la chaîne et conserve le reste en minuscules.
--
-- Règles appliquées
-- -----------------
--   1. Les espaces extérieurs sont conservés.
--   2. Une chaîne vide est retournée telle quelle.
--   3. Seul le premier caractère global est capitalisé.
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

DEFINE FUNCTION OVERWRITE fn::sanitize_capitalize(
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

    IF string::len($value) = 0 {
        RETURN "";
    };

    LET $lowercase = string::lowercase($value);

    RETURN string::concat(
        string::uppercase(
            string::slice($lowercase, 0, 1)
        ),
        string::slice(
            $lowercase,
            1,
            string::len($lowercase)
        )
    );
}
COMMENT "
Met en majuscule le premier caractère global et le reste en minuscules.
"
PERMISSIONS FULL;
