-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/number.surql
-- Fonction     : fn::validation_number
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Vérifie qu'une valeur obligatoire est un nombre SurrealDB valide.
--
-- Cette fonction accepte les différents types numériques natifs :
--
--   - int
--   - float
--   - decimal
--
-- Elle permet également d'appliquer facultativement :
--
--   - une valeur minimale ;
--   - une valeur maximale ;
--   - une plage comprise entre une valeur minimale et une valeur maximale.
--
-- Elle est destinée aux champs numériques tels que :
--
--   - un prix ;
--   - un montant ;
--   - un taux ;
--   - une température ;
--   - une distance ;
--   - une durée exprimée sous forme numérique ;
--   - une latitude ou une longitude ;
--   - un pourcentage ;
--   - une quantité pouvant contenir des décimales ;
--   - une mesure.
--
-- Validation stricte
-- ------------------
-- Cette fonction n'effectue aucune conversion automatique.
--
-- Exemples :
--
--   12
--     accepté, car il s'agit d'un entier.
--
--   12.5
--     accepté, car il s'agit d'un nombre flottant.
--
--   12.5dec
--     accepté, car il s'agit d'un nombre décimal.
--
--   "12.5"
--     refusé, car il s'agit d'une chaîne.
--
--   NONE
--     refusé, car cette fonction valide une valeur obligatoire.
--
-- Cette fonction préserve le type numérique d'origine.
--
-- Ainsi :
--
--   - un int reste un int ;
--   - un float reste un float ;
--   - un decimal reste un decimal.
--
-- Pour les valeurs monétaires ou les calculs nécessitant une précision exacte,
-- il est recommandé d'utiliser le type decimal dans la fonction métier.
--
-- Cette fonction vérifie uniquement qu'une valeur est numérique. Elle ne force
-- pas l'utilisation du type decimal.
--
-- Règles appliquées
-- -----------------
--   1. Le nom technique du champ doit être renseigné ;
--   2. La limite minimale doit être numérique lorsqu'elle est définie ;
--   3. La limite maximale doit être numérique lorsqu'elle est définie ;
--   4. La limite minimale ne doit pas être supérieure à la limite maximale ;
--   5. La valeur doit être présente ;
--   6. La valeur doit être numérique ;
--   7. La valeur doit respecter la limite minimale lorsqu'elle est définie ;
--   8. La valeur doit respecter la limite maximale lorsqu'elle est définie ;
--   9. La valeur numérique d'origine est retournée lorsqu'elle est valide.
--
-- Paramètres
-- ----------
-- $value:
--   Type : option<any>
--
--   Valeur obligatoire à contrôler.
--
--   Le type option<any> permet à la fonction de recevoir une valeur absente
--   ou d'un type incorrect afin de produire un code d'erreur métier stable.
--
-- $field:
--   Type : string
--
--   Nom technique du champ utilisé pour construire les codes d'erreur.
--
--   Convention recommandée :
--
--     - PRICE
--     - AMOUNT
--     - RATE
--     - TEMPERATURE
--     - DISTANCE
--     - PERCENTAGE
--     - LATITUDE
--     - LONGITUDE
--
-- $min_value:
--   Type : option<number>
--
--   Valeur minimale autorisée.
--
--   Utiliser NONE lorsqu'aucune limite minimale n'est requise.
--
--   La limite est inclusive.
--
--   Exemple :
--
--     $min_value = 0
--
--   signifie que zéro est accepté, mais qu'une valeur négative est refusée.
--
-- $max_value:
--   Type : option<number>
--
--   Valeur maximale autorisée.
--
--   Utiliser NONE lorsqu'aucune limite maximale n'est requise.
--
--   La limite est inclusive.
--
-- Valeur retournée
-- ----------------
-- Type : number
--
-- Retourne la valeur numérique d'origine sans conversion lorsqu'elle est
-- valide.
--
-- Exemples :
--
--   fn::validation_number(
--       19.99dec,
--       "PRICE",
--       0,
--       NONE
--   )
--
-- retourne :
--
--   19.99dec
--
-- Erreurs générées
-- ----------------
-- <FIELD>_REQUIRED
--   La valeur est absente ou égale à NONE.
--
-- <FIELD>_INVALID_TYPE
--   La valeur fournie n'est pas numérique.
--
-- <FIELD>_TOO_SMALL
--   La valeur est inférieure à la limite minimale.
--
-- <FIELD>_TOO_LARGE
--   La valeur est supérieure à la limite maximale.
--
-- VALIDATION_INVALID_FIELD_NAME
--   Le nom technique du champ est vide ou composé uniquement d'espaces.
--
-- VALIDATION_INVALID_MIN_NUMBER
--   La limite minimale fournie n'est pas numérique.
--
-- VALIDATION_INVALID_MAX_NUMBER
--   La limite maximale fournie n'est pas numérique.
--
-- VALIDATION_INVALID_NUMBER_RANGE
--   La limite minimale est supérieure à la limite maximale.
--
-- Permissions
-- -----------
-- PERMISSIONS FULL
--
-- Cette fonction est une primitive pure :
--
--   - elle ne lit aucune table ;
--   - elle n'écrit aucune donnée ;
--   - elle ne dépend pas du contexte d'authentification ;
--   - elle ne révèle aucune information enregistrée ;
--   - elle agit uniquement sur les paramètres transmis ;
--   - elle ne possède aucun effet secondaire.
--
-- Elle peut donc être appelée par toutes les fonctions métier autorisées.
--
-- Les autorisations relatives au champ validé restent sous la responsabilité
-- de la fonction métier appelante.
--
-- Dépendances natives SurrealDB
-- -----------------------------
--   - string::trim()
--   - string::concat()
--   - type::is_number()
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.
--
-- Ordre de chargement
-- -------------------
-- Cette fonction est autonome et peut être importée indépendamment des autres
-- fonctions de validation.
--
-- Exemples d'utilisation
-- ----------------------
-- Prix positif ou nul :
--
-- LET $price = fn::validation_number(
--     $price,
--     "PRICE",
--     0,
--     NONE
-- );
--
-- Pourcentage compris entre 0 et 100 :
--
-- LET $percentage = fn::validation_number(
--     $percentage,
--     "PERCENTAGE",
--     0,
--     100
-- );
--
-- Température sans limites :
--
-- LET $temperature = fn::validation_number(
--     $temperature,
--     "TEMPERATURE",
--     NONE,
--     NONE
-- );
--
-- Latitude comprise entre -90 et 90 :
--
-- LET $latitude = fn::validation_number(
--     $latitude,
--     "LATITUDE",
--     -90,
--     90
-- );
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_number(
    $value: option<any>,
    $field: string,
    $min_value: option<number>,
    $max_value: option<number>
) -> number {

    -- ------------------------------------------------------------------------
    -- 1. Validation du nom technique du champ
    -- ------------------------------------------------------------------------

    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    -- ------------------------------------------------------------------------
    -- 2. Validation du type de la limite minimale
    -- ------------------------------------------------------------------------
    -- Cette vérification est principalement défensive.
    -- Le typage option<number> protège déjà l'appel dans la majorité des cas.

    IF $min_value IS NOT NONE
        AND !type::is_number($min_value)
    {
        THROW "VALIDATION_INVALID_MIN_NUMBER";
    };

    -- ------------------------------------------------------------------------
    -- 3. Validation du type de la limite maximale
    -- ------------------------------------------------------------------------

    IF $max_value IS NOT NONE
        AND !type::is_number($max_value)
    {
        THROW "VALIDATION_INVALID_MAX_NUMBER";
    };

    -- ------------------------------------------------------------------------
    -- 4. Validation de la cohérence de la plage
    -- ------------------------------------------------------------------------

    IF $min_value IS NOT NONE
        AND $max_value IS NOT NONE
        AND $min_value > $max_value
    {
        THROW "VALIDATION_INVALID_NUMBER_RANGE";
    };

    -- ------------------------------------------------------------------------
    -- 5. Vérification de la présence de la valeur
    -- ------------------------------------------------------------------------

    IF $value IS NONE {
        THROW string::concat(
            $clean_field,
            "_REQUIRED"
        );
    };

    -- ------------------------------------------------------------------------
    -- 6. Vérification stricte du type numérique
    -- ------------------------------------------------------------------------
    -- type::is_number() accepte les valeurs numériques SurrealDB :
    --
    --   - int
    --   - float
    --   - decimal
    --
    -- Une chaîne contenant des chiffres reste une chaîne et est refusée.

    IF !type::is_number($value) {
        THROW string::concat(
            $clean_field,
            "_INVALID_TYPE"
        );
    };

    -- ------------------------------------------------------------------------
    -- 7. Validation de la valeur minimale
    -- ------------------------------------------------------------------------

    IF $min_value IS NOT NONE
        AND $value < $min_value
    {
        THROW string::concat(
            $clean_field,
            "_TOO_SMALL"
        );
    };

    -- ------------------------------------------------------------------------
    -- 8. Validation de la valeur maximale
    -- ------------------------------------------------------------------------

    IF $max_value IS NOT NONE
        AND $value > $max_value
    {
        THROW string::concat(
            $clean_field,
            "_TOO_LARGE"
        );
    };

    -- ------------------------------------------------------------------------
    -- 9. Retour de la valeur numérique validée
    -- ------------------------------------------------------------------------

    RETURN $value;
}
COMMENT "
Valide qu'une valeur obligatoire est un nombre SurrealDB de type int, float ou
decimal. Contrôle facultativement ses limites minimale et maximale et retourne
la valeur numérique d'origine sans conversion lorsqu'elle est valide.
"
PERMISSIONS FULL;