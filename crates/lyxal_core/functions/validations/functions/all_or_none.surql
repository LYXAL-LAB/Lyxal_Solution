-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/all_or_none.surql
-- Fonction     : fn::validation_all_or_none
-- Domaine      : Core / Validation / Advanced
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Vérifie que toutes les valeurs d'un ensemble sont présentes ou toutes absentes.
--
-- Règles appliquées
-- -----------------
--   1. NONE est considéré comme absent.
--   2. NULL est considéré comme présent.
--   3. Un ensemble partiellement renseigné est refusé.
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
-- <FIELD>_ALL_OR_NONE_REQUIRED
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

DEFINE FUNCTION OVERWRITE fn::validation_all_or_none(
    $values: array<any>,
    $field: string
) -> array<any> {
    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    LET $present_count = array::len(
        array::filter(
            $values,
            |$item| $item IS NOT NONE
        )
    );

    LET $total = array::len($values);

    IF $present_count != 0 AND $present_count != $total {
        THROW string::concat(
            $clean_field,
            "_ALL_OR_NONE_REQUIRED"
        );
    };

    RETURN $values;
}
COMMENT "
Valide qu'un groupe est entièrement renseigné ou entièrement absent.
"
PERMISSIONS FULL;
