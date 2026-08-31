-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/array_of_strings.surql
-- Fonction     : fn::validation_array_of_strings
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Vérifie qu'une valeur obligatoire est strictement de type array et que tous
-- les éléments du tableau sont strictement de type string.
--
-- Cette fonction peut également :
--
--   - supprimer les espaces périphériques de chaque chaîne ;
--   - autoriser ou refuser les chaînes vides ;
--   - contrôler une longueur minimale pour chaque chaîne ;
--   - contrôler une longueur maximale pour chaque chaîne.
--
-- Elle est destinée aux collections textuelles telles que :
--
--   - une liste de rôles ;
--   - une liste de permissions ;
--   - une liste de tags ;
--   - une liste de catégories textuelles ;
--   - une liste d'adresses e-mail déjà validées ;
--   - une liste de langues ;
--   - une liste de codes ;
--   - une liste de valeurs sélectionnées ;
--   - une liste de noms ;
--   - une liste d'identifiants textuels.
--
-- Exemples
-- --------
-- Tableau valide :
--
--   ["owner", "admin", "member"]
--
-- Tableau invalide :
--
--   ["owner", 42, "member"]
--
-- Le second tableau est refusé, car l'un de ses éléments est un entier.
--
-- Validation stricte
-- ------------------
-- Chaque élément doit être strictement de type string.
--
-- Exemples acceptés :
--
--   []
--   ["owner"]
--   ["owner", "admin"]
--   ["", "admin"]
--
-- Le dernier exemple est accepté uniquement lorsque $allow_empty vaut true.
--
-- Exemples refusés :
--
--   [1, 2, 3]
--   ["owner", 1]
--   ["owner", true]
--   ["owner", NONE]
--   ["owner", NULL]
--   ["owner", identity_user:user_001]
--
-- La fonction ne convertit jamais automatiquement les éléments.
--
-- Ainsi :
--
--   42
--
-- ne devient jamais :
--
--   "42"
--
-- Nettoyage des éléments
-- ----------------------
-- Chaque chaîne est nettoyée avec :
--
--   string::trim()
--
-- Exemple :
--
--   ["  owner  ", " admin "]
--
-- devient :
--
--   ["owner", "admin"]
--
-- La fonction retourne donc un nouveau tableau contenant les chaînes nettoyées.
--
-- Elle ne modifie pas :
--
--   - la casse ;
--   - les accents ;
--   - les espaces internes ;
--   - les caractères spéciaux ;
--   - l'ordre des éléments.
--
-- Une normalisation plus avancée appartient au domaine core/sanitize.
--
-- Chaînes vides
-- -------------
-- Lorsque $allow_empty vaut false :
--
--   ""
--   "     "
--
-- sont refusées avec :
--
--   <FIELD>_EMPTY_STRING_NOT_ALLOWED
--
-- Lorsque $allow_empty vaut true, une chaîne vide après nettoyage est acceptée,
-- sous réserve de la longueur minimale configurée.
--
-- Attention :
--
-- Si $allow_empty vaut true et que $min_length vaut 1 ou plus, une chaîne vide
-- est refusée avec :
--
--   <FIELD>_ITEM_TOO_SHORT
--
-- Longueur des éléments
-- ----------------------
-- Les contraintes de longueur sont appliquées individuellement à chaque
-- élément après string::trim().
--
-- Exemple :
--
--   ["admin", "member"]
--
-- avec :
--
--   $min_length = 3
--   $max_length = 20
--
-- est accepté.
--
-- En revanche :
--
--   ["ad", "member"]
--
-- produit :
--
--   <FIELD>_ITEM_TOO_SHORT
--
-- Tableau vide
-- ------------
-- Cette fonction accepte un tableau vide.
--
-- Elle vérifie uniquement le type des éléments présents.
--
-- Pour imposer au moins un élément, utiliser auparavant :
--
--   fn::validation_array_not_empty()
--
-- ou :
--
--   fn::validation_array_length()
--
-- Exemple :
--
--   LET $roles = fn::validation_array_length(
--       $roles,
--       "ROLES",
--       1,
--       10
--   );
--
--   LET $roles = fn::validation_array_of_strings(
--       $roles,
--       "ROLES",
--       false,
--       1,
--       50
--   );
--
-- Doublons
-- --------
-- Cette fonction n'interdit pas les doublons.
--
-- Ainsi :
--
--   ["admin", "admin"]
--
-- est valide au regard du type string.
--
-- Pour interdire les doublons, utiliser ensuite :
--
--   fn::validation_array_unique()
--
-- Exemple :
--
--   LET $roles = fn::validation_array_of_strings(
--       $roles,
--       "ROLES",
--       false,
--       1,
--       50
--   );
--
--   LET $roles = fn::validation_array_unique(
--       $roles,
--       "ROLES"
--   );
--
-- Limites de la validation
-- ------------------------
-- Cette fonction vérifie uniquement :
--
--   - la présence du tableau ;
--   - le refus de NULL comme valeur globale ;
--   - le type array ;
--   - le type string de chaque élément ;
--   - les chaînes vides ;
--   - la longueur minimale de chaque chaîne ;
--   - la longueur maximale de chaque chaîne.
--
-- Elle ne vérifie pas :
--
--   - que le tableau est non vide ;
--   - l'unicité des chaînes ;
--   - un format e-mail ;
--   - un format URL ;
--   - un format slug ;
--   - une valeur enum ;
--   - une regex métier ;
--   - une casse particulière.
--
-- Règles appliquées
-- -----------------
--   1. Le nom technique du champ doit être renseigné ;
--   2. La longueur minimale doit être positive ou nulle ;
--   3. La longueur maximale doit être positive ou nulle ;
--   4. La longueur minimale ne doit pas dépasser la longueur maximale ;
--   5. La valeur doit être présente ;
--   6. La valeur globale ne doit pas être NULL ;
--   7. La valeur doit être strictement de type array ;
--   8. Tous les éléments doivent être strictement de type string ;
--   9. Chaque chaîne est nettoyée avec string::trim() ;
--  10. Les chaînes vides sont refusées lorsque $allow_empty vaut false ;
--  11. La longueur minimale est contrôlée pour chaque élément ;
--  12. La longueur maximale est contrôlée pour chaque élément ;
--  13. Le tableau de chaînes nettoyées est retourné.
--
-- Paramètres
-- ----------
-- $value:
--   Type : option<any>
--
--   Tableau obligatoire à contrôler.
--
--   Le type option<any> permet de produire des codes d'erreur explicites pour :
--
--     - une valeur absente ;
--     - une valeur NULL ;
--     - une valeur globale d'un type incorrect ;
--     - un élément d'un type incorrect ;
--     - une chaîne vide ;
--     - une chaîne trop courte ;
--     - une chaîne trop longue.
--
-- $field:
--   Type : string
--
--   Nom technique utilisé pour construire les codes d'erreur.
--
--   Convention recommandée :
--
--     - ROLES
--     - PERMISSIONS
--     - TAGS
--     - LANGUAGES
--     - CODES
--     - NAMES
--     - VALUES
--
-- $allow_empty:
--   Type : bool
--
--   Définit si une chaîne vide après nettoyage est autorisée.
--
-- $min_length:
--   Type : option<int>
--
--   Longueur minimale autorisée pour chaque chaîne nettoyée.
--
--   Utiliser NONE lorsqu'aucune limite minimale n'est requise.
--
-- $max_length:
--   Type : option<int>
--
--   Longueur maximale autorisée pour chaque chaîne nettoyée.
--
--   Utiliser NONE lorsqu'aucune limite maximale n'est requise.
--
-- Valeur retournée
-- ----------------
-- Type : array<string>
--
-- Retourne un nouveau tableau contenant toutes les chaînes nettoyées.
--
-- Exemple :
--
--   fn::validation_array_of_strings(
--       ["  owner  ", " admin "],
--       "ROLES",
--       false,
--       1,
--       50
--   )
--
-- retourne :
--
--   ["owner", "admin"]
--
-- Erreurs générées
-- ----------------
-- <FIELD>_REQUIRED
--   La valeur est absente ou égale à NONE.
--
-- <FIELD>_NULL_NOT_ALLOWED
--   La valeur globale est explicitement égale à NULL.
--
-- <FIELD>_INVALID_TYPE
--   La valeur globale n'est pas de type array.
--
-- <FIELD>_ITEM_INVALID_TYPE
--   Au moins un élément n'est pas de type string.
--
-- <FIELD>_EMPTY_STRING_NOT_ALLOWED
--   Au moins une chaîne est vide après nettoyage alors que $allow_empty vaut
--   false.
--
-- <FIELD>_ITEM_TOO_SHORT
--   Au moins une chaîne est plus courte que la limite minimale.
--
-- <FIELD>_ITEM_TOO_LONG
--   Au moins une chaîne dépasse la limite maximale.
--
-- VALIDATION_INVALID_FIELD_NAME
--   Le nom technique du champ est vide.
--
-- VALIDATION_INVALID_MIN_LENGTH
--   La longueur minimale configurée est négative.
--
-- VALIDATION_INVALID_MAX_LENGTH
--   La longueur maximale configurée est négative.
--
-- VALIDATION_INVALID_STRING_LENGTH_RANGE
--   La longueur minimale est supérieure à la longueur maximale.
--
-- Permissions
-- -----------
-- PERMISSIONS FULL
--
-- Cette fonction est une primitive pure :
--
--   - elle ne consulte aucune table ;
--   - elle ne crée aucune donnée ;
--   - elle ne modifie aucune donnée persistante ;
--   - elle ne supprime aucune donnée ;
--   - elle ne dépend pas du contexte d'authentification ;
--   - elle agit uniquement sur ses paramètres ;
--   - elle ne possède aucun effet secondaire.
--
-- Elle peut donc être appelée par toutes les fonctions métier autorisées.
--
-- Dépendances natives SurrealDB
-- -----------------------------
--   - string::trim()
--   - string::len()
--   - string::concat()
--   - type::is_null()
--   - type::is_array()
--   - type::is_string()
--   - array::all()
--   - array::any()
--   - array::map()
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.
--
-- Ordre de chargement
-- -------------------
-- Cette fonction est autonome.
--
-- Il est toutefois recommandé de charger les validateurs de tableaux dans
-- l'ordre logique suivant :
--
--   1. array_not_empty.surql
--   2. array_length.surql
--   3. array_unique.surql
--   4. array_of_strings.surql
--   5. array_of_records.surql
--   6. array_without_none.surql
--   7. array_without_null.surql
--
-- Exemples d'utilisation
-- ----------------------
-- Liste de rôles :
--
-- LET $roles = fn::validation_array_of_strings(
--     $roles,
--     "ROLES",
--     false,
--     1,
--     50
-- );
--
-- Liste de tags acceptant une chaîne vide :
--
-- LET $tags = fn::validation_array_of_strings(
--     $tags,
--     "TAGS",
--     true,
--     NONE,
--     100
-- );
--
-- Validation complète :
--
-- LET $roles = fn::validation_array_length(
--     $roles,
--     "ROLES",
--     1,
--     20
-- );
--
-- LET $roles = fn::validation_array_of_strings(
--     $roles,
--     "ROLES",
--     false,
--     1,
--     50
-- );
--
-- LET $roles = fn::validation_array_unique(
--     $roles,
--     "ROLES"
-- );
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_array_of_strings(
    $value: option<any>,
    $field: string,
    $allow_empty: bool,
    $min_length: option<int>,
    $max_length: option<int>
) -> array<string> {

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

    IF $min_length IS NOT NONE
        AND $min_length < 0
    {
        THROW "VALIDATION_INVALID_MIN_LENGTH";
    };

    -- ------------------------------------------------------------------------
    -- 3. Validation de la longueur maximale configurée
    -- ------------------------------------------------------------------------

    IF $max_length IS NOT NONE
        AND $max_length < 0
    {
        THROW "VALIDATION_INVALID_MAX_LENGTH";
    };

    -- ------------------------------------------------------------------------
    -- 4. Validation de la cohérence de la plage
    -- ------------------------------------------------------------------------

    IF $min_length IS NOT NONE
        AND $max_length IS NOT NONE
        AND $min_length > $max_length
    {
        THROW "VALIDATION_INVALID_STRING_LENGTH_RANGE";
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
    -- 6. Refus explicite de NULL comme valeur globale
    -- ------------------------------------------------------------------------

    IF type::is_null($value) {
        THROW string::concat(
            $clean_field,
            "_NULL_NOT_ALLOWED"
        );
    };

    -- ------------------------------------------------------------------------
    -- 7. Vérification stricte du type array
    -- ------------------------------------------------------------------------

    IF !type::is_array($value) {
        THROW string::concat(
            $clean_field,
            "_INVALID_TYPE"
        );
    };

    -- ------------------------------------------------------------------------
    -- 8. Vérification du type de tous les éléments
    -- ------------------------------------------------------------------------
    -- array::all() retourne true uniquement lorsque tous les éléments
    -- satisfont la condition fournie à la closure.
    --
    -- Un tableau vide retourne true, car aucun élément ne viole la règle.

    LET $all_items_are_strings = array::all(
        $value,
        |$item| type::is_string($item)
    );

    IF !$all_items_are_strings {
        THROW string::concat(
            $clean_field,
            "_ITEM_INVALID_TYPE"
        );
    };

    -- ------------------------------------------------------------------------
    -- 9. Nettoyage de toutes les chaînes
    -- ------------------------------------------------------------------------

    LET $clean_values = array::map(
        $value,
        |$item| string::trim($item)
    );

    -- ------------------------------------------------------------------------
    -- 10. Vérification des chaînes vides
    -- ------------------------------------------------------------------------

    IF !$allow_empty {

        LET $contains_empty_string = array::any(
            $clean_values,
            |$item| $item = ""
        );

        IF $contains_empty_string {
            THROW string::concat(
                $clean_field,
                "_EMPTY_STRING_NOT_ALLOWED"
            );
        };
    };

    -- ------------------------------------------------------------------------
    -- 11. Validation de la longueur minimale de chaque élément
    -- ------------------------------------------------------------------------

    IF $min_length IS NOT NONE {

        LET $contains_too_short_string = array::any(
            $clean_values,
            |$item| string::len($item) < $min_length
        );

        IF $contains_too_short_string {
            THROW string::concat(
                $clean_field,
                "_ITEM_TOO_SHORT"
            );
        };
    };

    -- ------------------------------------------------------------------------
    -- 12. Validation de la longueur maximale de chaque élément
    -- ------------------------------------------------------------------------

    IF $max_length IS NOT NONE {

        LET $contains_too_long_string = array::any(
            $clean_values,
            |$item| string::len($item) > $max_length
        );

        IF $contains_too_long_string {
            THROW string::concat(
                $clean_field,
                "_ITEM_TOO_LONG"
            );
        };
    };

    -- ------------------------------------------------------------------------
    -- 13. Retour du tableau nettoyé et validé
    -- ------------------------------------------------------------------------

    RETURN $clean_values;
}
COMMENT "
Valide qu'une valeur obligatoire est un tableau contenant uniquement des
chaînes. Nettoie chaque chaîne avec string::trim(), permet d'autoriser ou de
refuser les chaînes vides et contrôle facultativement la longueur minimale et
maximale de chaque élément.
"
PERMISSIONS FULL;