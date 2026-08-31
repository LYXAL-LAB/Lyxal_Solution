-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/integer.surql
-- Fonction     : fn::validation_integer
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Vérifie qu'une valeur obligatoire est un entier SurrealDB valide.
--
-- Cette fonction permet également d'appliquer facultativement :
--
--   - une valeur minimale ;
--   - une valeur maximale ;
--   - une plage comprise entre une valeur minimale et une valeur maximale.
--
-- Elle est destinée aux champs numériques entiers tels que :
--
--   - une quantité ;
--   - un nombre de participants ;
--   - une position ;
--   - une priorité ;
--   - une durée exprimée en unités entières ;
--   - un nombre maximal de tentatives ;
--   - un délai exprimé en secondes ;
--   - un âge ;
--   - un numéro d'ordre ;
--   - un compteur.
--
-- Validation stricte
-- ------------------
-- Cette fonction n'effectue aucune conversion automatique.
--
-- Exemples :
--
--   12
--     accepté, car la valeur est de type int.
--
--   12.5
--     refusé, car la valeur n'est pas un entier.
--
--   "12"
--     refusé, car la valeur est une chaîne et non un entier.
--
--   NONE
--     refusé, car cette fonction valide un champ obligatoire.
--
-- Cette stratégie évite les conversions silencieuses pouvant masquer une
-- erreur provenant du client ou d'une fonction métier.
--
-- Une future fonction distincte pourra être créée si Lyxal OS doit convertir
-- explicitement une chaîne en entier, par exemple :
--
--   fn::sanitize_integer()
--
-- ou :
--
--   fn::conversion_integer()
--
-- Cette fonction de validation doit uniquement vérifier la valeur reçue.
--
-- Règles appliquées
-- -----------------
--   1. Le nom technique du champ doit être renseigné ;
--   2. La valeur minimale ne doit pas être supérieure à la valeur maximale ;
--   3. La valeur doit être présente ;
--   4. La valeur doit être de type int ;
--   5. La valeur doit respecter la limite minimale lorsqu'elle est définie ;
--   6. La valeur doit respecter la limite maximale lorsqu'elle est définie ;
--   7. L'entier d'origine est retourné lorsqu'il est valide.
--
-- Paramètres
-- ----------
-- $value:
--   Type : option<any>
--
--   Valeur obligatoire à contrôler.
--
--   Le type option<any> permet à la fonction de recevoir une valeur absente
--   ou d'un type incorrect afin de produire des erreurs métier explicites.
--
--   Si le paramètre était directement déclaré en option<int>, SurrealDB
--   pourrait refuser l'appel avant l'exécution du corps de la fonction.
--   L'utilisation de option<any> permet donc de retourner un code d'erreur
--   stable contrôlé par Lyxal OS.
--
-- $field:
--   Type : string
--
--   Nom technique du champ utilisé pour construire les codes d'erreur.
--
--   Convention recommandée :
--
--     - QUANTITY
--     - PARTICIPANT_COUNT
--     - MAX_RETRIES
--     - PRIORITY
--     - POSITION
--     - DURATION_SECONDS
--     - USER_AGE
--
-- $min_value:
--   Type : option<int>
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
--   Type : option<int>
--
--   Valeur maximale autorisée.
--
--   Utiliser NONE lorsqu'aucune limite maximale n'est requise.
--
--   La limite est inclusive.
--
--   Exemple :
--
--     $max_value = 100
--
--   signifie que 100 est accepté, mais que 101 est refusé.
--
-- Valeur retournée
-- ----------------
-- Type : int
--
-- Retourne l'entier d'origine sans transformation lorsqu'il est valide.
--
-- Exemple :
--
--   fn::validation_integer(
--       10,
--       "QUANTITY",
--       1,
--       100
--   )
--
-- retourne :
--
--   10
--
-- Erreurs générées
-- ----------------
-- <FIELD>_REQUIRED
--   La valeur est absente ou égale à NONE.
--
-- <FIELD>_INVALID_TYPE
--   La valeur fournie n'est pas de type int.
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
-- VALIDATION_INVALID_INTEGER_RANGE
--   La valeur minimale configurée est supérieure à la valeur maximale.
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
-- Les autorisations relatives à l'utilisation ou à la modification du champ
-- validé restent sous la responsabilité de la fonction métier appelante.
--
-- Dépendances natives SurrealDB
-- -----------------------------
--   - string::trim()
--   - string::concat()
--   - type::is_int()
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
-- Nombre compris entre 1 et 100 :
--
-- LET $quantity = fn::validation_integer(
--     $quantity,
--     "QUANTITY",
--     1,
--     100
-- );
--
-- Entier positif ou nul sans maximum :
--
-- LET $max_retries = fn::validation_integer(
--     $max_retries,
--     "MAX_RETRIES",
--     0,
--     NONE
-- );
--
-- Entier sans limites :
--
-- LET $position = fn::validation_integer(
--     $position,
--     "POSITION",
--     NONE,
--     NONE
-- );
--
-- Entier négatif ou positif dans une plage :
--
-- LET $offset = fn::validation_integer(
--     $offset,
--     "OFFSET",
--     -100,
--     100
-- );
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_integer(
    $value: option<any>,
    $field: string,
    $min_value: option<int>,
    $max_value: option<int>
) -> int {

    -- ------------------------------------------------------------------------
    -- 1. Validation du nom technique du champ
    -- ------------------------------------------------------------------------

    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    -- ------------------------------------------------------------------------
    -- 2. Validation de la configuration de la plage
    -- ------------------------------------------------------------------------
    -- Lorsque les deux limites sont définies, la valeur minimale ne peut pas
    -- être supérieure à la valeur maximale.

    IF $min_value IS NOT NONE
        AND $max_value IS NOT NONE
        AND $min_value > $max_value
    {
        THROW "VALIDATION_INVALID_INTEGER_RANGE";
    };

    -- ------------------------------------------------------------------------
    -- 3. Vérification de la présence de la valeur
    -- ------------------------------------------------------------------------

    IF $value IS NONE {
        THROW string::concat(
            $clean_field,
            "_REQUIRED"
        );
    };

    -- ------------------------------------------------------------------------
    -- 4. Vérification stricte du type
    -- ------------------------------------------------------------------------
    -- type::is_int() permet de distinguer précisément :
    --
    --   - un entier ;
    --   - un nombre décimal ;
    --   - un nombre flottant ;
    --   - une chaîne contenant des chiffres ;
    --   - tout autre type SurrealDB.

    IF !type::is_int($value) {
        THROW string::concat(
            $clean_field,
            "_INVALID_TYPE"
        );
    };

    -- ------------------------------------------------------------------------
    -- 5. Validation de la valeur minimale
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
    -- 6. Validation de la valeur maximale
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
    -- 7. Retour de l'entier validé
    -- ------------------------------------------------------------------------

    RETURN $value;
}
COMMENT "
Valide qu'une valeur obligatoire est strictement de type int et contrôle
facultativement ses limites minimale et maximale. Retourne l'entier d'origine
lorsqu'il est valide ou interrompt l'exécution avec un code d'erreur stable.
"
PERMISSIONS FULL;