-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/required_string.surql
-- Fonction     : fn::validation_required_string
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide une chaîne de caractères obligatoire.
--
-- Cette fonction constitue la validation primitive principale pour les champs
-- texte obligatoires utilisés dans les différents modules de Lyxal OS.
--
-- Elle vérifie successivement que :
--
--   1. La valeur a bien été fournie ;
--   2. La valeur n'est pas NONE ;
--   3. La valeur n'est pas vide après suppression des espaces périphériques ;
--   4. La longueur minimale est respectée, lorsqu'elle est définie ;
--   5. La longueur maximale est respectée, lorsqu'elle est définie.
--
-- La fonction retourne toujours la chaîne nettoyée avec string::trim().
-- La valeur retournée peut donc être utilisée directement par la fonction
-- métier appelante.
--
-- Cette fonction ne doit effectuer aucune opération métier et ne doit écrire
-- aucune donnée en base. Elle est déterministe et sans effet secondaire.
--
-- Paramètres
-- ----------
-- $value:
--   Type : option<string>
--   Chaîne à contrôler.
--   Le type option<string> permet à la fonction de produire elle-même une
--   erreur métier claire lorsque la valeur est absente.
--
-- $field:
--   Type : string
--   Nom technique du champ utilisé pour construire les codes d'erreur.
--
--   Convention recommandée :
--     - TEAM_NAME
--     - USER_FIRST_NAME
--     - BOOKING_TITLE
--     - WORKSPACE_NAME
--
-- $min_length:
--   Type : option<int>
--   Longueur minimale autorisée.
--   Utiliser NONE lorsqu'aucune limite minimale supplémentaire n'est requise.
--
-- $max_length:
--   Type : option<int>
--   Longueur maximale autorisée.
--   Utiliser NONE lorsqu'aucune limite maximale n'est requise.
--
-- Valeur retournée
-- ----------------
-- Type : string
--
-- Retourne la chaîne nettoyée avec les espaces périphériques supprimés.
--
-- Exemple :
--
--   "   Équipe commerciale   "
--
-- devient :
--
--   "Équipe commerciale"
--
-- Erreurs générées
-- ----------------
-- <FIELD>_REQUIRED
--   La valeur est NONE ou vide après nettoyage.
--
-- <FIELD>_TOO_SHORT
--   La chaîne contient moins de caractères que la limite minimale.
--
-- <FIELD>_TOO_LONG
--   La chaîne contient plus de caractères que la limite maximale.
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
-- Cette fonction est une primitive générique :
--
--   - elle ne lit aucune donnée sensible ;
--   - elle n'écrit aucune donnée ;
--   - elle ne dépend pas de l'utilisateur authentifié ;
--   - elle peut être appelée par toutes les fonctions métier autorisées.
--
-- Les contrôles d'autorisation doivent être appliqués dans les fonctions
-- métier ou dans les futures fonctions du domaine core/security.
--
-- Dépendances
-- -----------
-- Fonctions natives SurrealDB :
--
--   - string::trim()
--   - string::len()
--   - string::concat()
--
-- Exemples
-- --------
-- LET $name = fn::validation_required_string(
--     $name,
--     "TEAM_NAME",
--     1,
--     100
-- );
--
-- LET $description = fn::validation_required_string(
--     $description,
--     "DESCRIPTION",
--     NONE,
--     500
-- );
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_required_string(
    $value: option<string>,
    $field: string,
    $min_length: option<int>,
    $max_length: option<int>
) -> string {

    -- ------------------------------------------------------------------------
    -- 1. Validation de la configuration du validateur
    -- ------------------------------------------------------------------------

    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    IF $min_length IS NOT NONE AND $min_length < 0 {
        THROW "VALIDATION_INVALID_MIN_LENGTH";
    };

    IF $max_length IS NOT NONE AND $max_length < 0 {
        THROW "VALIDATION_INVALID_MAX_LENGTH";
    };

    IF $min_length IS NOT NONE
        AND $max_length IS NOT NONE
        AND $min_length > $max_length
    {
        THROW "VALIDATION_INVALID_LENGTH_RANGE";
    };

    -- ------------------------------------------------------------------------
    -- 2. Vérification de la présence de la valeur
    -- ------------------------------------------------------------------------

    IF $value IS NONE {
        THROW string::concat(
            $clean_field,
            "_REQUIRED"
        );
    };

    -- ------------------------------------------------------------------------
    -- 3. Nettoyage de la chaîne
    -- ------------------------------------------------------------------------

    LET $clean_value = string::trim($value);

    -- Une chaîne composée uniquement d'espaces est considérée comme absente.

    IF $clean_value = "" {
        THROW string::concat(
            $clean_field,
            "_REQUIRED"
        );
    };

    -- ------------------------------------------------------------------------
    -- 4. Calcul de la longueur
    -- ------------------------------------------------------------------------

    LET $value_length = string::len($clean_value);

    -- ------------------------------------------------------------------------
    -- 5. Validation de la longueur minimale
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
    -- 6. Validation de la longueur maximale
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
    -- 7. Retour de la valeur validée et nettoyée
    -- ------------------------------------------------------------------------

    RETURN $clean_value;
}
COMMENT "
Valide une chaîne obligatoire, supprime ses espaces périphériques et contrôle
facultativement ses longueurs minimale et maximale. Retourne la chaîne nettoyée
ou interrompt l'exécution avec un code d'erreur stable construit à partir du
nom technique du champ.
"
PERMISSIONS FULL;