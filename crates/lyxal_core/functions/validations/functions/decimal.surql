-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/decimal.surql
-- Fonction     : fn::validation_decimal
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Vérifie qu'une valeur obligatoire est strictement de type decimal SurrealDB.
--
-- Cette fonction permet également d'appliquer facultativement :
--
--   - une valeur minimale ;
--   - une valeur maximale ;
--   - une plage comprise entre une valeur minimale et une valeur maximale.
--
-- Elle est particulièrement adaptée aux données qui nécessitent une précision
-- décimale déterministe, notamment :
--
--   - un prix ;
--   - un montant financier ;
--   - un taux ;
--   - une marge ;
--   - une taxe ;
--   - une remise ;
--   - une quantité décimale ;
--   - une mesure précise ;
--   - un coût horaire ;
--   - un coefficient.
--
-- Validation stricte
-- ------------------
-- Cette fonction accepte uniquement une véritable valeur decimal SurrealDB.
--
-- Exemples acceptés :
--
--   19.99dec
--   0dec
--   -125.50dec
--   1000dec
--
-- Exemples refusés :
--
--   19
--     valeur de type int.
--
--   19.99f
--     valeur de type float.
--
--   "19.99"
--     valeur de type string.
--
--   NONE
--     absence de valeur.
--
--   NULL
--     valeur explicitement vide.
--
-- La fonction n'effectue aucune conversion automatique.
--
-- Pour convertir explicitement une autre représentation vers decimal, utiliser
-- avant la validation :
--
--   type::decimal($value)
--
-- Exemple :
--
--   LET $converted_price = type::decimal("19.99");
--
--   LET $price = fn::validation_decimal(
--       $converted_price,
--       "PRICE",
--       0dec,
--       NONE
--   );
--
-- Différence avec validation_number
-- ---------------------------------
-- fn::validation_number() accepte :
--
--   - int ;
--   - float ;
--   - decimal.
--
-- fn::validation_decimal() accepte uniquement :
--
--   - decimal.
--
-- Cette fonction doit donc être utilisée lorsque le type exact est important.
--
-- Pour les prix et montants financiers, decimal est généralement préférable à
-- float, car il permet d'éviter les approximations propres aux nombres
-- flottants binaires.
--
-- Conservation du type
-- --------------------
-- La fonction retourne exactement la valeur decimal reçue.
--
-- Elle ne réalise :
--
--   - aucun arrondi ;
--   - aucun changement d'échelle ;
--   - aucune conversion monétaire ;
--   - aucune limitation du nombre de décimales ;
--   - aucun formatage.
--
-- Exemple :
--
--   19.9900dec
--
-- est retourné comme valeur decimal selon la représentation canonique choisie
-- par SurrealDB.
--
-- Nombre de décimales
-- -------------------
-- Cette fonction ne contrôle pas le nombre de chiffres après la virgule.
--
-- Une future fonction spécialisée pourra être créée :
--
--   fn::validation_decimal_scale()
--
-- ou cette règle pourra être intégrée dans :
--
--   fn::validation_money()
--
-- Par exemple, validation_money pourra limiter les montants à deux décimales.
--
-- Limites minimale et maximale
-- -----------------------------
-- Les bornes sont inclusives.
--
-- Ainsi :
--
--   valeur = 0dec
--   minimum = 0dec
--
-- est accepté.
--
-- De même :
--
--   valeur = 100dec
--   maximum = 100dec
--
-- est accepté.
--
-- Une valeur inférieure au minimum produit :
--
--   <FIELD>_TOO_SMALL
--
-- Une valeur supérieure au maximum produit :
--
--   <FIELD>_TOO_LARGE
--
-- Cohérence de la plage
-- ----------------------
-- Lorsque les deux limites sont renseignées :
--
--   $min_value
--   $max_value
--
-- la valeur minimale ne peut pas être supérieure à la valeur maximale.
--
-- Exemple invalide :
--
--   min = 100dec
--   max = 10dec
--
-- produit :
--
--   VALIDATION_INVALID_DECIMAL_RANGE
--
-- Valeurs limites
-- ----------------
-- Les limites sont elles-mêmes déclarées en option<decimal>.
--
-- Cela signifie que :
--
--   - NONE désactive une limite ;
--   - une valeur int ou float n'est pas implicitement acceptée comme borne ;
--   - les limites doivent être écrites ou converties en decimal.
--
-- Exemple :
--
--   0dec
--   100dec
--
-- ou :
--
--   type::decimal(0)
--   type::decimal(100)
--
-- Cas d'utilisation
-- -----------------
-- Cette fonction peut notamment valider :
--
--   - PRICE ;
--   - AMOUNT ;
--   - HOURLY_RATE ;
--   - TAX_RATE ;
--   - DISCOUNT ;
--   - MARGIN ;
--   - QUANTITY ;
--   - COEFFICIENT ;
--   - COST ;
--   - TOTAL.
--
-- Règles appliquées
-- -----------------
--   1. Le nom technique du champ doit être renseigné ;
--   2. La limite minimale ne doit pas être supérieure à la limite maximale ;
--   3. La valeur doit être présente ;
--   4. La valeur ne doit pas être NULL ;
--   5. La valeur doit être strictement de type decimal ;
--   6. La limite minimale est contrôlée lorsqu'elle est définie ;
--   7. La limite maximale est contrôlée lorsqu'elle est définie ;
--   8. La valeur decimal d'origine est retournée lorsqu'elle est valide.
--
-- Paramètres
-- ----------
-- $value:
--   Type : option<any>
--
--   Valeur obligatoire à contrôler.
--
--   Le type option<any> permet de produire des erreurs métier explicites pour :
--
--     - une valeur absente ;
--     - une valeur NULL ;
--     - une valeur d'un type incorrect ;
--     - une valeur inférieure à la limite minimale ;
--     - une valeur supérieure à la limite maximale.
--
-- $field:
--   Type : string
--
--   Nom technique utilisé pour construire les codes d'erreur.
--
--   Convention recommandée :
--
--     - PRICE
--     - AMOUNT
--     - HOURLY_RATE
--     - TAX_RATE
--     - DISCOUNT
--     - MARGIN
--     - QUANTITY
--     - COEFFICIENT
--
-- $min_value:
--   Type : option<decimal>
--
--   Valeur minimale autorisée.
--
--   Utiliser NONE lorsqu'aucune limite minimale n'est requise.
--
--   La limite est inclusive.
--
-- $max_value:
--   Type : option<decimal>
--
--   Valeur maximale autorisée.
--
--   Utiliser NONE lorsqu'aucune limite maximale n'est requise.
--
--   La limite est inclusive.
--
-- Valeur retournée
-- ----------------
-- Type : decimal
--
-- Retourne la valeur decimal d'origine sans transformation.
--
-- Exemple :
--
--   fn::validation_decimal(
--       19.99dec,
--       "PRICE",
--       0dec,
--       1000dec
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
-- <FIELD>_NULL_NOT_ALLOWED
--   La valeur est explicitement égale à NULL.
--
-- <FIELD>_INVALID_TYPE
--   La valeur fournie n'est pas strictement de type decimal.
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
-- VALIDATION_INVALID_DECIMAL_RANGE
--   La limite minimale est supérieure à la limite maximale.
--
-- Permissions
-- -----------
-- PERMISSIONS FULL
--
-- Cette fonction est une primitive pure :
--
--   - elle ne consulte aucune table ;
--   - elle ne crée aucune donnée ;
--   - elle ne modifie aucune donnée ;
--   - elle ne supprime aucune donnée ;
--   - elle ne dépend pas du contexte d'authentification ;
--   - elle ne révèle aucune information enregistrée ;
--   - elle agit uniquement sur les paramètres transmis ;
--   - elle ne possède aucun effet secondaire.
--
-- Elle peut donc être appelée par toutes les fonctions métier autorisées.
--
-- Les règles concernant l'utilisation du montant, de la devise ou du champ
-- validé restent sous la responsabilité de la fonction métier appelante.
--
-- Dépendances natives SurrealDB
-- -----------------------------
--   - string::trim()
--   - string::concat()
--   - type::is_null()
--   - type::is_decimal()
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.
--
-- Ordre de chargement
-- -------------------
-- Cette fonction est autonome et peut être importée indépendamment.
--
-- Elle est toutefois logiquement liée aux fonctions :
--
--   - fn::validation_integer()
--   - fn::validation_number()
--   - fn::validation_float()
--   - fn::validation_money()
--
-- Exemples d'utilisation
-- ----------------------
-- Prix positif ou nul :
--
-- LET $price = fn::validation_decimal(
--     $price,
--     "PRICE",
--     0dec,
--     NONE
-- );
--
-- Taux compris entre zéro et cent :
--
-- LET $tax_rate = fn::validation_decimal(
--     $tax_rate,
--     "TAX_RATE",
--     0dec,
--     100dec
-- );
--
-- Montant sans limites :
--
-- LET $amount = fn::validation_decimal(
--     $amount,
--     "AMOUNT",
--     NONE,
--     NONE
-- );
--
-- Valeur négative ou positive :
--
-- LET $balance = fn::validation_decimal(
--     $balance,
--     "BALANCE",
--     -1000000dec,
--     1000000dec
-- );
--
-- Conversion explicite avant validation :
--
-- LET $converted_price = type::decimal($price);
--
-- LET $price = fn::validation_decimal(
--     $converted_price,
--     "PRICE",
--     0dec,
--     NONE
-- );
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_decimal(
    $value: option<any>,
    $field: string,
    $min_value: option<decimal>,
    $max_value: option<decimal>
) -> decimal {

    -- ------------------------------------------------------------------------
    -- 1. Validation du nom technique du champ
    -- ------------------------------------------------------------------------

    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    -- ------------------------------------------------------------------------
    -- 2. Validation de la cohérence de la plage
    -- ------------------------------------------------------------------------
    -- Lorsque les deux limites sont définies, la borne minimale ne peut pas
    -- être supérieure à la borne maximale.

    IF $min_value IS NOT NONE
        AND $max_value IS NOT NONE
        AND $min_value > $max_value
    {
        THROW "VALIDATION_INVALID_DECIMAL_RANGE";
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
    -- 4. Refus explicite de NULL
    -- ------------------------------------------------------------------------

    IF type::is_null($value) {
        THROW string::concat(
            $clean_field,
            "_NULL_NOT_ALLOWED"
        );
    };

    -- ------------------------------------------------------------------------
    -- 5. Vérification stricte du type decimal
    -- ------------------------------------------------------------------------
    -- type::is_decimal() accepte uniquement une véritable valeur decimal.
    --
    -- Sont notamment refusés :
    --
    --   - int ;
    --   - float ;
    --   - string ;
    --   - bool ;
    --   - tout autre type SurrealDB.

    IF !type::is_decimal($value) {
        THROW string::concat(
            $clean_field,
            "_INVALID_TYPE"
        );
    };

    -- ------------------------------------------------------------------------
    -- 6. Validation de la limite minimale
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
    -- 7. Validation de la limite maximale
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
    -- 8. Retour de la valeur decimal validée
    -- ------------------------------------------------------------------------

    RETURN $value;
}
COMMENT "
Valide qu'une valeur obligatoire est strictement de type decimal SurrealDB.
Refuse NONE, NULL, les entiers, les flottants et les autres types. Contrôle
facultativement les limites minimale et maximale et retourne la valeur decimal
d'origine sans conversion ni transformation.
"
PERMISSIONS FULL;