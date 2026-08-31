-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/optional_string.surql
-- Fonction     : fn::validation_optional_string
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide une chaîne de caractères facultative.
--
-- Cette fonction est destinée aux champs texte dont la présence n'est pas
-- obligatoire, mais dont la valeur doit respecter certaines contraintes
-- lorsqu'elle est fournie.
--
-- Elle applique les règles suivantes :
--
--   1. Une valeur NONE est acceptée et retourne NONE ;
--   2. Une chaîne composée uniquement d'espaces retourne NONE ;
--   3. Une chaîne non vide est nettoyée avec string::trim() ;
--   4. La longueur minimale est contrôlée lorsqu'elle est définie ;
--   5. La longueur maximale est contrôlée lorsqu'elle est définie ;
--   6. La chaîne nettoyée est retournée lorsqu'elle est valide.
--
-- Cette fonction est particulièrement adaptée aux champs facultatifs comme :
--
--   - une description ;
--   - un sous-titre ;
--   - un numéro de téléphone secondaire ;
--   - une note interne ;
--   - une biographie ;
--   - une adresse complémentaire.
--
-- La fonction ne réalise aucune écriture en base et ne contient aucune
-- logique métier propre à un module.
--
-- Différence avec validation_required_string
-- ------------------------------------------
-- fn::validation_required_string refuse NONE et les chaînes vides.
--
-- fn::validation_optional_string accepte l'absence de valeur et retourne NONE.
-- Elle applique les contrôles de longueur uniquement lorsqu'une chaîne non
-- vide est effectivement fournie.
--
-- Paramètres
-- ----------
-- $value:
--   Type : option<string>
--
--   Valeur facultative à contrôler.
--
--   Valeurs possibles :
--
--     NONE
--       La valeur est absente. La fonction retourne NONE.
--
--     ""
--       La chaîne est vide. La fonction retourne NONE.
--
--     "     "
--       La chaîne ne contient que des espaces. La fonction retourne NONE.
--
--     " Une description "
--       La fonction retourne "Une description" après validation.
--
-- $field:
--   Type : string
--
--   Nom technique du champ utilisé pour construire les codes d'erreur.
--
--   Convention recommandée :
--
--     - TEAM_DESCRIPTION
--     - USER_BIOGRAPHY
--     - BOOKING_NOTE
--     - ADDRESS_COMPLEMENT
--
--   Le nom du champ ne doit pas être vide.
--
-- $min_length:
--   Type : option<int>
--
--   Longueur minimale autorisée lorsqu'une valeur est fournie.
--
--   Utiliser NONE lorsqu'aucune longueur minimale n'est requise.
--
--   Cette limite n'est jamais appliquée lorsque $value est NONE ou vide.
--
-- $max_length:
--   Type : option<int>
--
--   Longueur maximale autorisée lorsqu'une valeur est fournie.
--
--   Utiliser NONE lorsqu'aucune longueur maximale n'est requise.
--
-- Valeur retournée
-- ----------------
-- Type : option<string>
--
-- La fonction retourne :
--
--   - NONE lorsque la valeur est absente ou vide après nettoyage ;
--   - la chaîne nettoyée lorsque la valeur est valide.
--
-- Exemples de retour
-- ------------------
-- Entrée : NONE
-- Retour : NONE
--
-- Entrée : "     "
-- Retour : NONE
--
-- Entrée : "  Responsable commercial  "
-- Retour : "Responsable commercial"
--
-- Erreurs générées
-- ----------------
-- <FIELD>_TOO_SHORT
--   La valeur renseignée contient moins de caractères que la longueur minimale.
--
-- <FIELD>_TOO_LONG
--   La valeur renseignée contient plus de caractères que la longueur maximale.
--
-- VALIDATION_INVALID_FIELD_NAME
--   Le nom technique du champ est vide.
--
-- VALIDATION_INVALID_MIN_LENGTH
--   La longueur minimale fournie est négative.
--
-- VALIDATION_INVALID_MAX_LENGTH
--   La longueur maximale fournie est négative.
--
-- VALIDATION_INVALID_LENGTH_RANGE
--   La longueur minimale est supérieure à la longueur maximale.
--
-- Permissions
-- -----------
-- PERMISSIONS FULL
--
-- Cette fonction peut être appelée sans restriction particulière car :
--
--   - elle ne consulte aucune table ;
--   - elle ne modifie aucune donnée ;
--   - elle ne révèle aucune information ;
--   - elle ne dépend pas de l'utilisateur authentifié ;
--   - elle ne contourne aucune autorisation métier ;
--   - elle agit uniquement sur les arguments qui lui sont transmis.
--
-- Les autorisations relatives à la modification du champ doivent être
-- contrôlées par la fonction métier appelante ou par les fonctions du domaine
-- core/security.
--
-- Dépendances
-- -----------
-- Fonctions natives SurrealDB :
--
--   - string::trim()
--   - string::len()
--   - string::concat()
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.
--
-- Cette fonction est volontairement autonome afin qu'elle puisse être chargée
-- avant les fonctions métier et utilisée par tous les modules.
--
-- Exemples d'utilisation
-- ----------------------
-- LET $description = fn::validation_optional_string(
--     $description,
--     "TEAM_DESCRIPTION",
--     NONE,
--     500
-- );
--
-- LET $subtitle = fn::validation_optional_string(
--     $subtitle,
--     "EVENT_SUBTITLE",
--     3,
--     150
-- );
--
-- LET $note = fn::validation_optional_string(
--     $note,
--     "INTERNAL_NOTE",
--     NONE,
--     NONE
-- );
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_optional_string(
    $value: option<string>,
    $field: string,
    $min_length: option<int>,
    $max_length: option<int>
) -> option<string> {

    -- ------------------------------------------------------------------------
    -- 1. Validation du nom technique du champ
    -- ------------------------------------------------------------------------

    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    -- ------------------------------------------------------------------------
    -- 2. Validation de la longueur minimale configurée
    -- ------------------------------------------------------------------------

    IF $min_length IS NOT NONE AND $min_length < 0 {
        THROW "VALIDATION_INVALID_MIN_LENGTH";
    };

    -- ------------------------------------------------------------------------
    -- 3. Validation de la longueur maximale configurée
    -- ------------------------------------------------------------------------

    IF $max_length IS NOT NONE AND $max_length < 0 {
        THROW "VALIDATION_INVALID_MAX_LENGTH";
    };

    -- ------------------------------------------------------------------------
    -- 4. Vérification de la cohérence entre les deux limites
    -- ------------------------------------------------------------------------

    IF $min_length IS NOT NONE
        AND $max_length IS NOT NONE
        AND $min_length > $max_length
    {
        THROW "VALIDATION_INVALID_LENGTH_RANGE";
    };

    -- ------------------------------------------------------------------------
    -- 5. Traitement d'une valeur absente
    -- ------------------------------------------------------------------------
    -- Un champ facultatif peut ne pas être transmis.
    -- Dans ce cas, aucune autre validation n'est nécessaire.

    IF $value IS NONE {
        RETURN NONE;
    };

    -- ------------------------------------------------------------------------
    -- 6. Nettoyage de la chaîne
    -- ------------------------------------------------------------------------

    LET $clean_value = string::trim($value);

    -- Une chaîne vide ou constituée uniquement d'espaces est assimilée à
    -- l'absence de valeur pour un champ facultatif.

    IF $clean_value = "" {
        RETURN NONE;
    };

    -- ------------------------------------------------------------------------
    -- 7. Calcul de la longueur de la valeur nettoyée
    -- ------------------------------------------------------------------------

    LET $value_length = string::len($clean_value);

    -- ------------------------------------------------------------------------
    -- 8. Validation de la longueur minimale
    -- ------------------------------------------------------------------------

    IF $min_length IS NOT NONE
        AND $value_length < $min_length
    {
        THROW string::concat(
            $clean_field,
            "_TOO_SHORT"
        );
    };

    -- ------------------------------------------------------------------------
    -- 9. Validation de la longueur maximale
    -- ------------------------------------------------------------------------

    IF $max_length IS NOT NONE
        AND $value_length > $max_length
    {
        THROW string::concat(
            $clean_field,
            "_TOO_LONG"
        );
    };

    -- ------------------------------------------------------------------------
    -- 10. Retour de la chaîne nettoyée et validée
    -- ------------------------------------------------------------------------

    RETURN $clean_value;
}
COMMENT "
Valide une chaîne facultative. Retourne NONE lorsque la valeur est absente,
vide ou composée uniquement d'espaces. Lorsqu'une valeur est fournie, elle est
nettoyée et ses longueurs minimale et maximale sont contrôlées.
"
PERMISSIONS FULL;