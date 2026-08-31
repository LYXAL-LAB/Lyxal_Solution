-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/mutually_exclusive.surql
-- Fonction     : fn::validation_mutually_exclusive
-- Domaine      : Core / Validation / Advanced
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Vérifie que plusieurs valeurs ne sont pas renseignées simultanément.
--
-- Règles appliquées
-- -----------------
--   1. NONE est considéré comme absent.
--   2. NULL est considéré comme présent.
--   3. Au plus une valeur peut être présente.
--   4. Zéro valeur présente peut être autorisé ou refusé.
--
-- Paramètres
-- ----------
-- $values: array<any>
-- $field: string
-- $allow_none_present: bool
--
-- Valeur retournée
-- ----------------
-- Retourne la valeur validée ou un objet de résultat normalisé.
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_MUTUALLY_EXCLUSIVE
-- <FIELD>_ONE_VALUE_REQUIRED
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

DEFINE FUNCTION OVERWRITE fn::validation_mutually_exclusive(
    $values: array<any>,
    $field: string,
    $allow_none_present: bool
) -> array<any> {
    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    LET $present = array::filter(
        $values,
        |$item| $item IS NOT NONE
    );

    LET $count = array::len($present);

    IF $count > 1 {
        THROW string::concat(
            $clean_field,
            "_MUTUALLY_EXCLUSIVE"
        );
    };

    IF !$allow_none_present AND $count = 0 {
        THROW string::concat(
            $clean_field,
            "_ONE_VALUE_REQUIRED"
        );
    };

    RETURN $values;
}
COMMENT "
Valide qu'au plus une valeur d'un ensemble est présente.
"
PERMISSIONS FULL;
