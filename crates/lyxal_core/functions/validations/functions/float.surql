-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/float.surql
-- Fonction     : fn::validation_float
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Vérifie qu'une valeur obligatoire est strictement de type float SurrealDB.
--
-- Cette fonction permet également d'appliquer facultativement :
--
--   - une valeur minimale ;
--   - une valeur maximale ;
--   - une plage comprise entre une valeur minimale et une valeur maximale.
--
-- Elle est destinée aux données numériques pour lesquelles une représentation
-- flottante est adaptée, notamment :
--
--   - une mesure scientifique ;
--   - une valeur calculée ;
--   - une température ;
--   - une distance ;
--   - une vitesse ;
--   - un ratio ;
--   - une moyenne ;
--   - une coordonnée intermédiaire ;
--   - un score ;
--   - une valeur issue d'un calcul numérique.
--
-- Validation stricte
-- ------------------
-- Cette fonction accepte uniquement une véritable valeur float SurrealDB.
--
-- Exemples acceptés :
--
--   19.99f
--   0f
--   -125.5f
--   1000f
--
-- Exemples refusés :
--
--   19
--     valeur de type int.
--
--   19.99dec
--     valeur de type decimal.
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
-- Pour convertir explicitement une autre représentation vers float, utiliser
-- avant la validation :
--
--   type::float($value)
--
-- Exemple :
--
--   LET $converted_temperature = type::float("19.5");
--
--   LET $temperature = fn::validation_float(
--       $converted_temperature,
--       "TEMPERATURE",
--       -100f,
--       100f
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
-- fn::validation_float() accepte uniquement :
--
--   - float.
--
-- Cette fonction doit donc être utilisée lorsque le type exact de la valeur
-- est important.
--
-- Différence avec validation_decimal
-- ----------------------------------
-- Le type float utilise une représentation numérique flottante binaire.
--
-- Il est adapté aux calculs, mesures et valeurs approximatives, mais il peut
-- produire de légères différences de précision pour certaines valeurs
-- décimales.
--
-- Le type decimal est préférable pour :
--
--   - les prix ;
--   - les montants financiers ;
--   - les taxes ;
--   - les remises ;
--   - les calculs nécessitant une précision décimale déterministe.
--
-- Cette fonction ne doit donc généralement pas être utilisée pour les montants
-- monétaires.
--
-- Conservation du type
-- --------------------
-- La fonction retourne exactement la valeur float reçue.
--
-- Elle ne réalise :
--
--   - aucune conversion ;
--   - aucun arrondi ;
--   - aucun formatage ;
--   - aucune modification de précision ;
--   - aucune transformation en decimal ;
--   - aucune transformation en entier.
--
-- Limites minimale et maximale
-- -----------------------------
-- Les bornes minimale et maximale sont inclusives.
--
-- Ainsi :
--
--   valeur = 0f
--   minimum = 0f
--
-- est accepté.
--
-- De même :
--
--   valeur = 100f
--   maximum = 100f
--
-- est accepté.
--
-- Une valeur inférieure à la limite minimale produit :
--
--   <FIELD>_TOO_SMALL
--
-- Une valeur supérieure à la limite maximale produit :
--
--   <FIELD>_TOO_LARGE
--
-- Cohérence de la plage
-- ----------------------
-- Lorsque les deux limites sont définies, la valeur minimale ne peut pas être
-- supérieure à la valeur maximale.
--
-- Exemple invalide :
--
--   min = 100f
--   max = 10f
--
-- produit :
--
--   VALIDATION_INVALID_FLOAT_RANGE
--
-- Valeurs spéciales
-- -----------------
-- Selon la manière dont les valeurs sont produites par le moteur ou un client,
-- un float peut théoriquement représenter des valeurs numériques particulières
-- telles qu'une valeur non finie.
--
-- Cette fonction vérifie uniquement :
--
--   - le type float ;
--   - les limites configurées.
--
-- Elle ne constitue pas un validateur spécialisé des nombres finis.
--
-- Une future fonction pourra être créée si Lyxal OS doit interdire
-- explicitement certaines valeurs flottantes particulières :
--
--   fn::validation_finite_float()
--
-- ou :
--
--   fn::validation_finite_number()
--
-- Utilisation recommandée
-- -----------------------
-- Cette fonction est adaptée lorsque :
--
--   - la donnée source est naturellement un float ;
--   - de petites approximations sont acceptables ;
--   - la valeur est utilisée dans des calculs scientifiques ou techniques ;
--   - le type exact doit rester float.
--
-- Pour accepter indifféremment int, float et decimal, utiliser :
--
--   fn::validation_number()
--
-- Pour exiger une précision décimale déterministe, utiliser :
--
--   fn::validation_decimal()
--
-- Cas d'utilisation
-- -----------------
-- Cette fonction peut notamment valider :
--
--   - TEMPERATURE ;
--   - DISTANCE ;
--   - SPEED ;
--   - SCORE ;
--   - RATIO ;
--   - AVERAGE ;
--   - MEASUREMENT ;
--   - COORDINATE ;
--   - PROGRESS ;
--   - SENSOR_VALUE.
--
-- Règles appliquées
-- -----------------
--   1. Le nom technique du champ doit être renseigné ;
--   2. La limite minimale ne doit pas être supérieure à la limite maximale ;
--   3. La valeur doit être présente ;
--   4. La valeur ne doit pas être NULL ;
--   5. La valeur doit être strictement de type float ;
--   6. La limite minimale est contrôlée lorsqu'elle est définie ;
--   7. La limite maximale est contrôlée lorsqu'elle est définie ;
--   8. La valeur float d'origine est retournée lorsqu'elle est valide.
--
-- Paramètres
-- ----------
-- $value:
--   Type : option<any>
--
--   Valeur obligatoire à contrôler.
--
--   Le type option<any> permet de produire des codes d'erreur explicites pour :
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
--     - TEMPERATURE
--     - DISTANCE
--     - SPEED
--     - SCORE
--     - RATIO
--     - AVERAGE
--     - MEASUREMENT
--     - SENSOR_VALUE
--
-- $min_value:
--   Type : option<float>
--
--   Valeur minimale autorisée.
--
--   Utiliser NONE lorsqu'aucune limite minimale n'est requise.
--
--   La limite est inclusive.
--
-- $max_value:
--   Type : option<float>
--
--   Valeur maximale autorisée.
--
--   Utiliser NONE lorsqu'aucune limite maximale n'est requise.
--
--   La limite est inclusive.
--
-- Valeur retournée
-- ----------------
-- Type : float
--
-- Retourne la valeur float d'origine sans transformation.
--
-- Exemple :
--
--   fn::validation_float(
--       19.5f,
--       "TEMPERATURE",
--       -100f,
--       100f
--   )
--
-- retourne :
--
--   19.5f
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
--   La valeur fournie n'est pas strictement de type float.
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
-- VALIDATION_INVALID_FLOAT_RANGE
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
-- Les règles concernant l'utilisation de la mesure ou du champ validé restent
-- sous la responsabilité de la fonction métier appelante.
--
-- Dépendances natives SurrealDB
-- -----------------------------
--   - string::trim()
--   - string::concat()
--   - type::is_null()
--   - type::is_float()
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
--   - fn::validation_decimal()
--   - fn::validation_percentage()
--   - fn::validation_range()
--
-- Exemples d'utilisation
-- ----------------------
-- Température comprise entre -100 et 100 :
--
-- LET $temperature = fn::validation_float(
--     $temperature,
--     "TEMPERATURE",
--     -100f,
--     100f
-- );
--
-- Distance positive ou nulle :
--
-- LET $distance = fn::validation_float(
--     $distance,
--     "DISTANCE",
--     0f,
--     NONE
-- );
--
-- Score compris entre zéro et un :
--
-- LET $score = fn::validation_float(
--     $score,
--     "SCORE",
--     0f,
--     1f
-- );
--
-- Valeur sans limites :
--
-- LET $measurement = fn::validation_float(
--     $measurement,
--     "MEASUREMENT",
--     NONE,
--     NONE
-- );
--
-- Conversion explicite avant validation :
--
-- LET $converted_value = type::float($value);
--
-- LET $measurement = fn::validation_float(
--     $converted_value,
--     "MEASUREMENT",
--     NONE,
--     NONE
-- );
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_float(
    $value: option<any>,
    $field: string,
    $min_value: option<float>,
    $max_value: option<float>
) -> float {

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
        THROW "VALIDATION_INVALID_FLOAT_RANGE";
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
    -- 5. Vérification stricte du type float
    -- ------------------------------------------------------------------------
    -- type::is_float() accepte uniquement une véritable valeur float.
    --
    -- Sont notamment refusés :
    --
    --   - int ;
    --   - decimal ;
    --   - string ;
    --   - bool ;
    --   - tout autre type SurrealDB.

    IF !type::is_float($value) {
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
    -- 8. Retour de la valeur float validée
    -- ------------------------------------------------------------------------

    RETURN $value;
}
COMMENT "
Valide qu'une valeur obligatoire est strictement de type float SurrealDB.
Refuse NONE, NULL, les entiers, les décimaux et les autres types. Contrôle
facultativement les limites minimale et maximale et retourne la valeur float
d'origine sans conversion ni transformation.
"
PERMISSIONS FULL;