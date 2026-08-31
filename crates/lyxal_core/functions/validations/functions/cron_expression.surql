-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/cron_expression.surql
-- Fonction     : fn::validation_cron_expression
-- Domaine      : Core / Validation / Workflow
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide lexicalement une expression cron standard à cinq champs ou étendue à six champs.
--
-- Règles appliquées
-- -----------------
--   1. Les espaces multiples sont interdits afin de conserver une forme canonique.
--   2. Une expression standard contient cinq champs.
--   3. Lorsque les secondes sont autorisées, six champs sont acceptés.
--   4. Les caractères cron usuels sont acceptés lexicalement.
--   5. Les macros @yearly, @monthly, @weekly, @daily et @hourly peuvent être autorisées.
--
-- Paramètres
-- ----------
-- $value: option<any>
-- $field: string
-- $allow_seconds: bool
-- $allow_macros: bool
--
-- Valeur retournée
-- ----------------
-- Retourne la valeur validée ou un objet normalisé.
--
-- Erreurs spécifiques
-- --------------------
-- <FIELD>_INVALID_CRON_EXPRESSION
-- <FIELD>_INVALID_CRON_FIELD_COUNT
-- <FIELD>_CRON_MACRO_NOT_ALLOWED
--
-- Erreurs communes
-- ----------------
-- <FIELD>_REQUIRED
-- <FIELD>_NULL_NOT_ALLOWED
-- <FIELD>_INVALID_TYPE
-- <FIELD>_BLANK_NOT_ALLOWED
-- VALIDATION_INVALID_FIELD_NAME
--
-- Permissions
-- -----------
-- PERMISSIONS FULL
--
-- Cette fonction est une primitive pure :
--
--   - aucune lecture ou écriture persistante ;
--   - aucun lancement de job ou workflow ;
--   - aucun accès réseau ;
--   - aucun effet secondaire.
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.

--
-- Limite
-- ------
-- Cette fonction valide la forme générale. La validation sémantique complète
-- de chaque plage dépend du moteur cron utilisé par Lyxal Scheduler.

-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_cron_expression(
    $value: option<any>,
    $field: string,
    $allow_seconds: bool,
    $allow_macros: bool
) -> string {
    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    IF $value IS NONE {
        THROW string::concat($clean_field, "_REQUIRED");
    };

    IF type::is_null($value) {
        THROW string::concat($clean_field, "_NULL_NOT_ALLOWED");
    };

    IF !type::is_string($value) {
        THROW string::concat($clean_field, "_INVALID_TYPE");
    };

    LET $clean_value = string::trim($value);

    IF $clean_value = "" {
        THROW string::concat($clean_field, "_BLANK_NOT_ALLOWED");
    };

    LET $cron = string::lowercase($clean_value);

    IF string::starts_with($cron, "@") {
        IF !$allow_macros {
            THROW string::concat(
                $clean_field,
                "_CRON_MACRO_NOT_ALLOWED"
            );
        };

        IF !array::contains(
            ["@yearly", "@annually", "@monthly", "@weekly", "@daily", "@midnight", "@hourly"],
            $cron
        ) {
            THROW string::concat(
                $clean_field,
                "_INVALID_CRON_EXPRESSION"
            );
        };

        RETURN $cron;
    };

    IF string::contains($cron, "  ") {
        THROW string::concat(
            $clean_field,
            "_INVALID_CRON_EXPRESSION"
        );
    };

    LET $fields = string::split($cron, " ");
    LET $count = array::len($fields);

    IF ($allow_seconds AND $count != 5 AND $count != 6)
        OR (!$allow_seconds AND $count != 5)
    {
        THROW string::concat(
            $clean_field,
            "_INVALID_CRON_FIELD_COUNT"
        );
    };

    IF !array::all(
        $fields,
        |$item|
            $item != ""
            AND string::matches(
                $item,
                "^[0-9A-Za-z*/?,#LW-]+$"
            )
    ) {
        THROW string::concat(
            $clean_field,
            "_INVALID_CRON_EXPRESSION"
        );
    };

    RETURN $cron;
}
COMMENT "
Valide lexicalement une expression cron à cinq ou six champs ou une macro
cron autorisée.
"
PERMISSIONS FULL;
