-- ============================================================================
-- LYXAL OS — VALIDATION ENGINE
-- ============================================================================
-- Fichier      : core/validation/apply_required.surql
-- Fonction     : fn::validation_apply_required
-- Domaine      : Core / Validation / Engine
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Applique les règles required et nullable à une valeur.
--
-- Règles appliquées
-- -----------------
--   1. NONE est refusé uniquement si required est vrai.
--   2. NULL est refusé uniquement si nullable est faux.
--   3. La valeur est retournée sans transformation.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $required: bool
-- $nullable: bool
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_REQUIRED
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
-- Sécurité
-- --------
-- Le moteur utilise un ensemble fermé de règles. Il n'exécute jamais un nom
-- de fonction arbitraire fourni dans un schéma.
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.

-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_apply_required(
    $value: option<any>,
    $field: string,
    $required: bool,
    $nullable: bool
) -> any {
    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    IF $required AND $value IS NONE {
        THROW string::concat($clean_field, "_REQUIRED");
    };

    IF $value IS NOT NONE
        AND !$nullable
        AND type::is_null($value)
    {
        THROW string::concat(
            $clean_field,
            "_NULL_NOT_ALLOWED"
        );
    };

    RETURN $value;
}
COMMENT "
Applique les règles required et nullable d'un schéma déclaratif.
"
PERMISSIONS FULL;
