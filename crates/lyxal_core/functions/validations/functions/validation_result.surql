-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/validation_result.surql
-- Fonction     : fn::validation_result
-- Domaine      : Core / Validation / Advanced
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Normalise le résultat d'une validation sous forme d'objet success/value/error.
--
-- Règles appliquées
-- -----------------
--   1. En cas de succès, error_code doit être absent.
--   2. En cas d'échec, error_code doit être une chaîne non vide.
--   3. La fonction ne lance pas l'erreur métier ; elle construit un résultat exploitable.
--
-- Paramètres
-- ----------
-- $success: bool
-- $value: option<any>
-- $error_code: option<string>
-- $field: string
--
-- Valeur retournée
-- ----------------
-- Retourne la valeur validée ou un objet de résultat normalisé.
--
-- Erreurs spécifiques
-- --------------------
-- VALIDATION_SUCCESS_WITH_ERROR
-- VALIDATION_FAILURE_WITHOUT_ERROR
-- VALIDATION_INVALID_RESULT_FIELD
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

DEFINE FUNCTION OVERWRITE fn::validation_result(
    $success: bool,
    $value: option<any>,
    $error_code: option<string>,
    $field: string
) -> object {
    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_RESULT_FIELD";
    };

    IF $success AND $error_code IS NOT NONE {
        THROW "VALIDATION_SUCCESS_WITH_ERROR";
    };

    IF !$success
        AND (
            $error_code IS NONE
            OR string::trim($error_code) = ""
        )
    {
        THROW "VALIDATION_FAILURE_WITHOUT_ERROR";
    };

    RETURN {
        success: $success,
        field: $clean_field,
        value: IF $success { $value } ELSE { NONE },
        error: IF $success {
            NONE
        } ELSE {
            string::trim($error_code)
        }
    };
}
COMMENT "
Construit un résultat de validation normalisé sans lancer l'erreur métier.
"
PERMISSIONS FULL;
