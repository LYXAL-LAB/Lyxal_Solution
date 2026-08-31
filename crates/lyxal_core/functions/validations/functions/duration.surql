-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/duration.surql
-- Fonction     : fn::validation_duration
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Vérifie qu'une valeur obligatoire est strictement de type duration
-- SurrealDB.
--
-- Cette fonction permet également d'appliquer facultativement :
--
--   - une durée minimale ;
--   - une durée maximale ;
--   - une plage comprise entre une durée minimale et une durée maximale.
--
-- Elle est destinée aux champs représentant une longueur de temps, notamment :
--
--   - un délai d'expiration ;
--   - un timeout ;
--   - une durée de réservation ;
--   - une durée de session ;
--   - une durée de verrouillage ;
--   - un délai de nouvelle tentative ;
--   - un intervalle de planification ;
--   - une durée de conservation ;
--   - une période de grâce ;
--   - une durée d'exécution maximale.
--
-- Validation stricte
-- ------------------
-- Cette fonction accepte uniquement une véritable valeur duration SurrealDB.
--
-- Exemples acceptés :
--
--   30s
--   15m
--   2h
--   2h30m
--   3d
--   2w
--
-- Exemples refusés :
--
--   "30s"
--     valeur de type string.
--
--   30
--     valeur de type int.
--
--   30f
--     valeur de type float.
--
--   d"2026-08-03T10:00:00Z"
--     valeur de type datetime.
--
--   NONE
--     absence de valeur.
--
--   NULL
--     valeur explicitement vide.
--
-- La fonction n'effectue aucune conversion automatique.
--
-- Pour convertir explicitement une chaîne en duration, utiliser auparavant :
--
--   type::duration($value)
--
-- Exemple :
--
--   LET $converted_timeout = type::duration("30s");
--
--   LET $timeout = fn::validation_duration(
--       $converted_timeout,
--       "TIMEOUT",
--       1s,
--       5m
--   );
--
-- Différence entre duration et datetime
-- --------------------------------------
-- Une duration représente une longueur de temps :
--
--   2h30m
--
-- Un datetime représente un instant précis :
--
--   d"2026-08-03T10:00:00Z"
--
-- La fonction fn::validation_duration() ne valide donc pas une date ou une
-- heure absolue.
--
-- Pour valider un instant précis, utiliser :
--
--   fn::validation_datetime()
--
-- Utilisation avec datetime
-- -------------------------
-- Une duration peut être ajoutée ou soustraite à un datetime.
--
-- Exemple :
--
--   LET $expires_at = time::now() + 30m;
--
-- La présente fonction peut être utilisée pour valider la durée avant cette
-- opération :
--
--   LET $ttl = fn::validation_duration(
--       $ttl,
--       "TTL",
--       1s,
--       30d
--   );
--
--   LET $expires_at = time::now() + $ttl;
--
-- Limites minimale et maximale
-- -----------------------------
-- Les bornes sont inclusives.
--
-- Ainsi :
--
--   valeur = 30s
--   minimum = 30s
--
-- est accepté.
--
-- De même :
--
--   valeur = 24h
--   maximum = 24h
--
-- est accepté.
--
-- Une valeur inférieure à la limite minimale produit :
--
--   <FIELD>_TOO_SHORT
--
-- Une valeur supérieure à la limite maximale produit :
--
--   <FIELD>_TOO_LONG
--
-- Cohérence de la plage
-- ----------------------
-- Lorsque les deux limites sont définies, la durée minimale ne peut pas être
-- supérieure à la durée maximale.
--
-- Exemple invalide :
--
--   min = 2h
--   max = 30m
--
-- produit :
--
--   VALIDATION_INVALID_DURATION_RANGE
--
-- Durée nulle
-- ------------
-- La durée :
--
--   0ns
--
-- est une durée valide.
--
-- Elle est acceptée lorsque la limite minimale vaut NONE ou 0ns.
--
-- Pour imposer une durée strictement positive, utiliser une limite minimale
-- supérieure à zéro :
--
--   1ns
--   1ms
--   1s
--
-- Durée maximale
-- ---------------
-- SurrealDB expose la constante :
--
--   duration::max
--
-- représentant la durée maximale prise en charge.
--
-- Cette fonction n'utilise pas automatiquement cette constante, car l'absence
-- de limite maximale est déjà représentée par NONE.
--
-- Conservation du type
-- --------------------
-- La fonction retourne exactement la valeur duration reçue.
--
-- Elle ne réalise :
--
--   - aucune conversion d'unité ;
--   - aucun arrondi ;
--   - aucun formatage ;
--   - aucune transformation en secondes ;
--   - aucune transformation en millisecondes ;
--   - aucune transformation en nombre.
--
-- Pour obtenir une représentation numérique, les fonctions natives de durée
-- peuvent être utilisées séparément :
--
--   duration::secs()
--   duration::millis()
--   duration::mins()
--   duration::hours()
--   duration::days()
--
-- Exemples :
--
--   duration::secs(2m)
--
-- retourne le nombre de secondes complètes contenues dans la durée.
--
-- Précision
-- ---------
-- Une duration SurrealDB peut contenir plusieurs unités :
--
--   1h30m20s500ms
--
-- La comparaison est réalisée sur la durée effective totale et non sur sa
-- représentation textuelle.
--
-- Ainsi :
--
--   60m
--
-- et :
--
--   1h
--
-- représentent des durées équivalentes pour les comparaisons.
--
-- Limites de la validation
-- ------------------------
-- Cette fonction vérifie uniquement :
--
--   - la présence de la valeur ;
--   - le refus de NULL ;
--   - le type duration ;
--   - la durée minimale ;
--   - la durée maximale.
--
-- Elle ne vérifie pas :
--
--   - l'usage métier de la durée ;
--   - que la durée correspond à un calendrier civil ;
--   - les jours ouvrés ;
--   - les jours fériés ;
--   - les fuseaux horaires ;
--   - les récurrences ;
--   - les périodes calendaires variables ;
--   - l'association avec un datetime particulier.
--
-- Une durée comme 30d représente une longueur de temps et non nécessairement
-- un mois civil.
--
-- Règles appliquées
-- -----------------
--   1. Le nom technique du champ doit être renseigné ;
--   2. La durée minimale ne doit pas être supérieure à la durée maximale ;
--   3. La valeur doit être présente ;
--   4. La valeur ne doit pas être NULL ;
--   5. La valeur doit être strictement de type duration ;
--   6. La durée minimale est contrôlée lorsqu'elle est définie ;
--   7. La durée maximale est contrôlée lorsqu'elle est définie ;
--   8. La valeur duration d'origine est retournée lorsqu'elle est valide.
--
-- Paramètres
-- ----------
-- $value:
--   Type : option<any>
--
--   Durée obligatoire à contrôler.
--
--   Le type option<any> permet de produire des codes d'erreur explicites pour :
--
--     - une valeur absente ;
--     - une valeur NULL ;
--     - une valeur d'un type incorrect ;
--     - une durée inférieure à la limite minimale ;
--     - une durée supérieure à la limite maximale.
--
-- $field:
--   Type : string
--
--   Nom technique utilisé pour construire les codes d'erreur.
--
--   Convention recommandée :
--
--     - TIMEOUT
--     - TTL
--     - RETRY_DELAY
--     - SESSION_DURATION
--     - BOOKING_DURATION
--     - LOCK_DURATION
--     - RETENTION_PERIOD
--     - GRACE_PERIOD
--
-- $min_value:
--   Type : option<duration>
--
--   Durée minimale autorisée.
--
--   Utiliser NONE lorsqu'aucune limite minimale n'est requise.
--
--   La limite est inclusive.
--
-- $max_value:
--   Type : option<duration>
--
--   Durée maximale autorisée.
--
--   Utiliser NONE lorsqu'aucune limite maximale n'est requise.
--
--   La limite est inclusive.
--
-- Valeur retournée
-- ----------------
-- Type : duration
--
-- Retourne la valeur duration d'origine sans transformation.
--
-- Exemple :
--
--   fn::validation_duration(
--       30m,
--       "SESSION_DURATION",
--       5m,
--       24h
--   )
--
-- retourne :
--
--   30m
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
--   La valeur fournie n'est pas strictement de type duration.
--
-- <FIELD>_TOO_SHORT
--   La durée est inférieure à la limite minimale.
--
-- <FIELD>_TOO_LONG
--   La durée est supérieure à la limite maximale.
--
-- VALIDATION_INVALID_FIELD_NAME
--   Le nom technique du champ est vide ou composé uniquement d'espaces.
--
-- VALIDATION_INVALID_DURATION_RANGE
--   La durée minimale est supérieure à la durée maximale.
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
-- Les règles relatives à l'utilisation métier de la durée restent sous la
-- responsabilité de la fonction appelante.
--
-- Dépendances natives SurrealDB
-- -----------------------------
--   - string::trim()
--   - string::concat()
--   - type::is_null()
--   - type::is_duration()
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
--   - fn::validation_datetime()
--   - fn::validation_duration_range()
--   - fn::validation_future_datetime()
--   - fn::validation_time_range()
--
-- Exemples d'utilisation
-- ----------------------
-- Timeout compris entre une seconde et cinq minutes :
--
-- LET $timeout = fn::validation_duration(
--     $timeout,
--     "TIMEOUT",
--     1s,
--     5m
-- );
--
-- Durée de session maximale de vingt-quatre heures :
--
-- LET $session_duration = fn::validation_duration(
--     $session_duration,
--     "SESSION_DURATION",
--     1m,
--     24h
-- );
--
-- Durée de conservation sans maximum :
--
-- LET $retention_period = fn::validation_duration(
--     $retention_period,
--     "RETENTION_PERIOD",
--     0ns,
--     NONE
-- );
--
-- Durée sans limites :
--
-- LET $duration = fn::validation_duration(
--     $duration,
--     "DURATION",
--     NONE,
--     NONE
-- );
--
-- Conversion explicite avant validation :
--
-- LET $converted_duration = type::duration(
--     $duration_string
-- );
--
-- LET $duration = fn::validation_duration(
--     $converted_duration,
--     "DURATION",
--     1s,
--     1d
-- );
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_duration(
    $value: option<any>,
    $field: string,
    $min_value: option<duration>,
    $max_value: option<duration>
) -> duration {

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
    -- Lorsque les deux limites sont définies, la durée minimale ne peut pas
    -- être supérieure à la durée maximale.

    IF $min_value IS NOT NONE
        AND $max_value IS NOT NONE
        AND $min_value > $max_value
    {
        THROW "VALIDATION_INVALID_DURATION_RANGE";
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
    -- 5. Vérification stricte du type duration
    -- ------------------------------------------------------------------------
    -- type::is_duration() accepte uniquement une véritable valeur duration.
    --
    -- Sont notamment refusés :
    --
    --   - string ;
    --   - int ;
    --   - float ;
    --   - decimal ;
    --   - datetime ;
    --   - tout autre type SurrealDB.

    IF !type::is_duration($value) {
        THROW string::concat(
            $clean_field,
            "_INVALID_TYPE"
        );
    };

    -- ------------------------------------------------------------------------
    -- 6. Validation de la durée minimale
    -- ------------------------------------------------------------------------

    IF $min_value IS NOT NONE
        AND $value < $min_value
    {
        THROW string::concat(
            $clean_field,
            "_TOO_SHORT"
        );
    };

    -- ------------------------------------------------------------------------
    -- 7. Validation de la durée maximale
    -- ------------------------------------------------------------------------

    IF $max_value IS NOT NONE
        AND $value > $max_value
    {
        THROW string::concat(
            $clean_field,
            "_TOO_LONG"
        );
    };

    -- ------------------------------------------------------------------------
    -- 8. Retour de la valeur duration validée
    -- ------------------------------------------------------------------------

    RETURN $value;
}
COMMENT "
Valide qu'une valeur obligatoire est strictement de type duration SurrealDB.
Refuse NONE, NULL, les chaînes, les nombres, les datetimes et les autres types.
Contrôle facultativement les durées minimale et maximale et retourne la valeur
duration d'origine sans conversion ni transformation.
"
PERMISSIONS FULL;