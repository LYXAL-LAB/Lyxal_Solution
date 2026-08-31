-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/at_least_one.surql
-- Fonction     : fn::validation_at_least_one
-- Domaine      : Core / Validation / Advanced
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Vérifie qu'au moins une valeur d'un ensemble est présente.
--
-- Règles appliquées
-- -----------------
--   1. NONE est considéré comme absent.
--   2. NULL est considéré comme présent.
--   3. Une ou plusieurs valeurs peuvent être présentes.
--
-- Paramètres
-- ----------
-- $values: array<any>
-- $field: string
--
-- Valeur retournée
-- ----------------
-- Retourne la valeur validée ou un objet de résultat normalisé.
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_AT_LEAST_ONE_REQUIRED
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

DEFINE FUNCTION OVERWRITE fn::validation_at_least_one(
    $values: array<any>,
    $field: string
) -> array<any> {
    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    IF !array::any(
        $values,
        |$item| $item IS NOT NONE
    ) {
        THROW string::concat(
            $clean_field,
            "_AT_LEAST_ONE_REQUIRED"
        );
    };

    RETURN $values;
}
COMMENT "
Valide qu'au moins une valeur d'un ensemble est présente.
"
PERMISSIONS FULL;
