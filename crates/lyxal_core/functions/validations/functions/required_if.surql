-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/required_if.surql
-- Fonction     : fn::validation_required_if
-- Domaine      : Core / Validation / Advanced
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Rend une valeur obligatoire lorsqu'une condition booléenne est vraie.
--
-- Règles appliquées
-- -----------------
--   1. Lorsque la condition est fausse, la valeur est retournée sans contrainte.
--   2. Lorsque la condition est vraie, NONE est refusé.
--   3. NULL peut être autorisé ou refusé.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $condition: bool
-- $allow_null: bool
--
-- Valeur retournée
-- ----------------
-- Retourne la valeur validée ou un objet de résultat normalisé.
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_REQUIRED_IF
-- <FIELD>_NULL_NOT_ALLOWED
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
-- Cette fonction est une primitive pure :
--
--   - aucune lecture ou écriture persistante ;
--   - aucun appel réseau ;
--   - aucune exécution dynamique de code ;
--   - aucun effet secondaire.
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.

-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_required_if(
    $value: option<any>,
    $field: string,
    $condition: bool,
    $allow_null: bool
) -> any {
    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    IF !$condition {
        RETURN $value;
    };

    IF $value IS NONE {
        THROW string::concat($clean_field, "_REQUIRED_IF");
    };

    IF !$allow_null AND type::is_null($value) {
        THROW string::concat($clean_field, "_NULL_NOT_ALLOWED");
    };

    RETURN $value;
}
COMMENT "
Rend une valeur obligatoire lorsque la condition fournie est vraie.
"
PERMISSIONS FULL;
