-- ============================================================================
-- LYXAL OS — VALIDATION PIPELINE
-- ============================================================================
-- Fichier      : core/validation/pipeline_default.surql
-- Fonction     : fn::validation_pipeline_default
-- Domaine      : Core / Validation / Pipeline
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Applique une valeur par défaut uniquement lorsque la valeur est NONE.
--
-- Règles appliquées
-- -----------------
--   1. NONE est remplacé par la valeur par défaut.
--   2. NULL est conservé.
--   3. Toute autre valeur est conservée.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $default_value: any
--
-- Erreurs spécifiques
-- --------------------
-- Aucune erreur spécifique supplémentaire.
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
-- Sécurité
-- --------
-- Le pipeline utilise uniquement des étapes explicitement prises en charge.
-- Aucun nom de fonction arbitraire n'est exécuté.
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.

-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_pipeline_default(
    $value: option<any>,
    $field: string,
    $default_value: any
) -> any {
    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    RETURN IF $value IS NONE {
        $default_value
    } ELSE {
        $value
    };
}
COMMENT "
Applique une valeur par défaut uniquement lorsque la valeur est NONE.
"
PERMISSIONS FULL;
