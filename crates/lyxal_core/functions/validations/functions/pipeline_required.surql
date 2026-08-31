-- ============================================================================
-- LYXAL OS — VALIDATION PIPELINE
-- ============================================================================
-- Fichier      : core/validation/pipeline_required.surql
-- Fonction     : fn::validation_pipeline_required
-- Domaine      : Core / Validation / Pipeline
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Applique l'étape required à une valeur.
--
-- Règles appliquées
-- -----------------
--   1. NONE est refusé.
--   2. NULL est refusé.
--   3. Une chaîne vide après trim est refusée.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_REQUIRED
-- <FIELD>_BLANK_NOT_ALLOWED
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

DEFINE FUNCTION OVERWRITE fn::validation_pipeline_required(
    $value: option<any>,
    $field: string
) -> any {
    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    IF $value IS NONE OR type::is_null($value) {
        THROW string::concat($clean_field, "_REQUIRED");
    };

    IF type::is_string($value)
        AND string::trim($value) = ""
    {
        THROW string::concat(
            $clean_field,
            "_BLANK_NOT_ALLOWED"
        );
    };

    RETURN $value;
}
COMMENT "
Applique l'étape required d'un Validation Pipeline.
"
PERMISSIONS FULL;
