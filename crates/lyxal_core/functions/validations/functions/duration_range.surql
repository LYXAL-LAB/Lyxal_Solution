-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/duration_range.surql
-- Fonction     : fn::validation_duration_range
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Vérifie qu'une plage de durées obligatoire est composée de deux valeurs
-- duration cohérentes :
--
--   - une durée minimale ;
--   - une durée maximale.
--
-- Cette fonction permet également :
--
--   - d'autoriser ou de refuser une plage exacte ;
--   - d'imposer une étendue minimale entre les deux bornes ;
--   - d'imposer une étendue maximale entre les deux bornes ;
--   - de retourner les deux bornes validées ainsi que leur étendue.
--
-- Une plage exacte est une plage dont les deux bornes sont identiques :
--
--   minimum = 30m
--   maximum = 30m
--
-- Son étendue est alors :
--
--   0ns
--
-- Cette fonction est adaptée aux configurations telles que :
--
--   - une durée minimale et maximale de réservation ;
--   - une plage de timeout autorisée ;
--   - une plage de délai de nouvelle tentative ;
--   - une plage de durée de session ;
--   - une plage de conservation ;
--   - une plage de validité ;
--   - une plage de durée d'exécution ;
--   - une plage d'intervalle de planification ;
--   - une plage de durée de verrouillage ;
--   - une plage de délai de grâce.
--
-- Exemple simple
-- --------------
-- Durée minimale :
--
--   30m
--
-- Durée maximale :
--
--   8h
--
-- Étendue calculée :
--
--   7h30m
--
-- Exemple d'appel :
--
--   fn::validation_duration_range(
--       30m,
--       8h,
--       "BOOKING_DURATION_RANGE",
--       false,
--       NONE,
--       NONE
--   )
--
-- retourne :
--
--   {
--       min_duration: 30m,
--       max_duration: 8h,
--       span: 7h30m
--   }
--
-- Différence avec validation_duration
-- -----------------------------------
-- fn::validation_duration() valide une seule durée :
--
--   2h
--
-- et peut contrôler que cette valeur se trouve entre deux limites.
--
-- fn::validation_duration_range() valide une configuration contenant elle-même
-- deux durées :
--
--   min_duration
--   max_duration
--
-- Exemple :
--
--   configuration de réservation :
--
--     min_duration = 30m
--     max_duration = 8h
--
-- La première fonction valide une valeur métier.
--
-- La seconde valide les bornes utilisées pour encadrer cette valeur métier.
--
-- Exemple d'enchaînement :
--
--   LET $range = fn::validation_duration_range(
--       $min_duration,
--       $max_duration,
--       "BOOKING_DURATION_RANGE",
--       false,
--       NONE,
--       NONE
--   );
--
--   LET $booking_duration = fn::validation_duration(
--       $booking_duration,
--       "BOOKING_DURATION",
--       $range.min_duration,
--       $range.max_duration
--   );
--
-- Validation stricte
-- ------------------
-- Les deux valeurs doivent être de véritables valeurs duration SurrealDB.
--
-- Exemples acceptés :
--
--   30m
--   2h
--   1d12h
--   0ns
--
-- Exemples refusés :
--
--   "30m"
--     chaîne non convertie.
--
--   30
--     entier.
--
--   30f
--     float.
--
--   d"2026-08-03T10:00:00Z"
--     datetime.
--
--   NONE
--     absence de valeur.
--
--   NULL
--     valeur explicitement vide.
--
-- La fonction n'effectue aucune conversion automatique.
--
-- Une chaîne peut être convertie avant validation :
--
--   LET $min_duration = type::duration(
--       "30m"
--   );
--
--   LET $max_duration = type::duration(
--       "8h"
--   );
--
--   RETURN fn::validation_duration_range(
--       $min_duration,
--       $max_duration,
--       "BOOKING_DURATION_RANGE",
--       false,
--       NONE,
--       NONE
--   );
--
-- Ordre des bornes
-- ----------------
-- La durée maximale ne peut pas être inférieure à la durée minimale.
--
-- Exemple invalide :
--
--   min_duration = 8h
--   max_duration = 30m
--
-- produit :
--
--   <FIELD>_INVALID_ORDER
--
-- Cette vérification est appliquée avant le calcul de l'étendue.
--
-- Plage exacte
-- ------------
-- Une plage exacte possède deux bornes identiques.
--
-- Exemple :
--
--   min_duration = 1h
--   max_duration = 1h
--
-- Étendue :
--
--   0ns
--
-- Lorsque $allow_exact vaut true, cette configuration est acceptée, sous
-- réserve de l'étendue minimale configurée.
--
-- Lorsque $allow_exact vaut false, elle produit :
--
--   <FIELD>_EXACT_RANGE_NOT_ALLOWED
--
-- Attention :
--
-- Si $allow_exact vaut true mais que $min_span est supérieure à zéro, une
-- plage exacte est refusée avec :
--
--   <FIELD>_SPAN_TOO_SMALL
--
-- Étendue de la plage
-- -------------------
-- L'étendue est calculée avec :
--
--   $max_duration - $min_duration
--
-- Exemple :
--
--   8h - 30m
--
-- produit :
--
--   7h30m
--
-- Comme l'ordre des bornes est validé auparavant, le résultat est toujours une
-- durée positive ou nulle.
--
-- Étendue minimale
-- ----------------
-- Le paramètre $min_span permet d'imposer un écart minimal entre les deux
-- bornes.
--
-- Exemple :
--
--   min_span = 1h
--
-- Une plage :
--
--   30m .. 1h30m
--
-- possède une étendue de :
--
--   1h
--
-- et est acceptée.
--
-- Une plage :
--
--   30m .. 1h
--
-- possède une étendue de :
--
--   30m
--
-- et produit :
--
--   <FIELD>_SPAN_TOO_SMALL
--
-- Étendue maximale
-- ----------------
-- Le paramètre $max_span permet de limiter l'écart maximal entre les deux
-- bornes.
--
-- Exemple :
--
--   max_span = 24h
--
-- Une plage dont l'étendue est exactement égale à vingt-quatre heures est
-- acceptée.
--
-- Une plage plus étendue produit :
--
--   <FIELD>_SPAN_TOO_LARGE
--
-- Étendue exacte
-- --------------
-- Pour imposer une étendue exacte, utiliser la même valeur pour les deux
-- paramètres :
--
--   min_span = 2h
--   max_span = 2h
--
-- La différence entre la durée maximale et la durée minimale devra alors être
-- exactement égale à deux heures.
--
-- Cohérence des limites d'étendue
-- --------------------------------
-- Lorsque $min_span et $max_span sont définies, l'étendue minimale ne peut pas
-- être supérieure à l'étendue maximale.
--
-- Exemple invalide :
--
--   min_span = 8h
--   max_span = 2h
--
-- produit :
--
--   VALIDATION_INVALID_DURATION_SPAN_RANGE
--
-- Configuration impossible
-- -------------------------
-- Lorsque les plages exactes sont interdites et que $max_span vaut 0ns, aucune
-- plage ne peut être valide.
--
-- La configuration impose simultanément :
--
--   - une étendue strictement supérieure à zéro ;
--   - une étendue inférieure ou égale à zéro.
--
-- Cette configuration produit :
--
--   VALIDATION_IMPOSSIBLE_DURATION_RANGE
--
-- Durées nulles
-- --------------
-- Une durée individuelle peut être égale à :
--
--   0ns
--
-- Exemple valide :
--
--   min_duration = 0ns
--   max_duration = 30m
--
-- Cette plage possède une étendue de :
--
--   30m
--
-- Le fait qu'une borne soit nulle ne signifie donc pas que la plage est
-- exacte.
--
-- Seule l'égalité des deux bornes constitue une plage exacte.
--
-- Durées non négatives
-- --------------------
-- Le type duration SurrealDB ne permet pas de représenter une durée négative.
--
-- Cette fonction n'a donc pas besoin de vérifier séparément :
--
--   min_duration >= 0
--   max_duration >= 0
--
-- Une valeur négative ne peut pas être construite comme duration valide.
--
-- Limite maximale native
-- ----------------------
-- La plus grande durée prise en charge par SurrealDB est disponible avec :
--
--   duration::max
--
-- Cette valeur peut être utilisée comme borne.
--
-- Exemple :
--
--   fn::validation_duration_range(
--       0ns,
--       duration::max,
--       "GLOBAL_DURATION_RANGE",
--       false,
--       NONE,
--       duration::max
--   )
--
-- Attention :
--
-- certaines opérations arithmétiques proches de duration::max peuvent produire
-- un dépassement si elles tentent de créer une durée supérieure à cette limite.
--
-- Conservation des valeurs
-- -------------------------
-- La fonction retourne les deux durées d'origine sans :
--
--   - conversion d'unité ;
--   - arrondi ;
--   - formatage ;
--   - transformation en secondes ;
--   - transformation en millisecondes ;
--   - modification des bornes ;
--   - ajustement automatique de l'ordre.
--
-- Une configuration inversée est refusée et n'est jamais corrigée
-- automatiquement.
--
-- Retour sous forme d'objet
-- --------------------------
-- La fonction retourne :
--
--   {
--       min_duration: duration,
--       max_duration: duration,
--       span: duration
--   }
--
-- Exemple d'utilisation :
--
--   LET $range = fn::validation_duration_range(...);
--
--   RETURN $range.min_duration;
--   RETURN $range.max_duration;
--   RETURN $range.span;
--
-- Cette structure permet d'utiliser directement les bornes validées dans une
-- autre fonction.
--
-- Limites de la validation
-- ------------------------
-- Cette fonction vérifie uniquement :
--
--   - la présence des deux bornes ;
--   - le refus de NULL ;
--   - le type duration des deux valeurs ;
--   - l'ordre des bornes ;
--   - l'autorisation d'une plage exacte ;
--   - l'étendue minimale ;
--   - l'étendue maximale.
--
-- Elle ne vérifie pas :
--
--   - qu'une durée métier se trouve dans la plage ;
--   - la disponibilité d'une ressource ;
--   - les horaires d'ouverture ;
--   - les jours ouvrés ;
--   - les périodes calendaires variables ;
--   - les permissions métier ;
--   - la cohérence avec un module particulier ;
--   - la compatibilité avec un scheduler ;
--   - la précision attendue par un protocole ;
--   - la conversion d'une durée en unités métier.
--
-- Règles appliquées
-- -----------------
--   1. Le nom technique de la plage doit être renseigné ;
--   2. L'étendue minimale ne doit pas dépasser l'étendue maximale ;
--   3. La configuration ne doit pas rendre toute plage impossible ;
--   4. La durée minimale doit être présente ;
--   5. La durée minimale ne doit pas être NULL ;
--   6. La durée minimale doit être strictement de type duration ;
--   7. La durée maximale doit être présente ;
--   8. La durée maximale ne doit pas être NULL ;
--   9. La durée maximale doit être strictement de type duration ;
--  10. La durée maximale ne doit pas être inférieure à la durée minimale ;
--  11. Une plage exacte est refusée lorsque $allow_exact vaut false ;
--  12. L'étendue entre les deux bornes est calculée ;
--  13. L'étendue minimale est contrôlée lorsqu'elle est définie ;
--  14. L'étendue maximale est contrôlée lorsqu'elle est définie ;
--  15. Un objet contenant les deux bornes et leur étendue est retourné.
--
-- Paramètres
-- ----------
-- $min_value:
--   Type : option<any>
--
--   Durée minimale obligatoire de la plage.
--
-- $max_value:
--   Type : option<any>
--
--   Durée maximale obligatoire de la plage.
--
-- $field:
--   Type : string
--
--   Nom technique de la plage utilisé pour construire les codes d'erreur.
--
--   Convention recommandée :
--
--     - BOOKING_DURATION_RANGE
--     - TIMEOUT_RANGE
--     - SESSION_DURATION_RANGE
--     - RETRY_DELAY_RANGE
--     - RETENTION_RANGE
--     - LOCK_DURATION_RANGE
--     - EXECUTION_DURATION_RANGE
--     - GRACE_PERIOD_RANGE
--
-- $allow_exact:
--   Type : bool
--
--   true :
--     Les deux bornes peuvent être identiques.
--
--   false :
--     La durée maximale doit être strictement supérieure à la durée minimale.
--
-- $min_span:
--   Type : option<duration>
--
--   Étendue minimale autorisée entre les deux bornes.
--
--   Utiliser NONE lorsqu'aucune étendue minimale n'est requise.
--
--   La limite est inclusive.
--
-- $max_span:
--   Type : option<duration>
--
--   Étendue maximale autorisée entre les deux bornes.
--
--   Utiliser NONE lorsqu'aucune étendue maximale n'est requise.
--
--   La limite est inclusive.
--
-- Valeur retournée
-- ----------------
-- Type : object
--
-- Retourne :
--
--   {
--       min_duration: duration,
--       max_duration: duration,
--       span: duration
--   }
--
-- Exemple :
--
--   fn::validation_duration_range(
--       30m,
--       8h,
--       "BOOKING_DURATION_RANGE",
--       false,
--       1h,
--       24h
--   )
--
-- retourne :
--
--   {
--       min_duration: 30m,
--       max_duration: 8h,
--       span: 7h30m
--   }
--
-- Erreurs générées
-- ----------------
-- <FIELD>_MIN_REQUIRED
--   La durée minimale est absente ou égale à NONE.
--
-- <FIELD>_MIN_NULL_NOT_ALLOWED
--   La durée minimale est explicitement égale à NULL.
--
-- <FIELD>_MIN_INVALID_TYPE
--   La durée minimale n'est pas strictement de type duration.
--
-- <FIELD>_MAX_REQUIRED
--   La durée maximale est absente ou égale à NONE.
--
-- <FIELD>_MAX_NULL_NOT_ALLOWED
--   La durée maximale est explicitement égale à NULL.
--
-- <FIELD>_MAX_INVALID_TYPE
--   La durée maximale n'est pas strictement de type duration.
--
-- <FIELD>_INVALID_ORDER
--   La durée maximale est inférieure à la durée minimale.
--
-- <FIELD>_EXACT_RANGE_NOT_ALLOWED
--   Les deux bornes sont identiques alors que les plages exactes sont
--   interdites.
--
-- <FIELD>_SPAN_TOO_SMALL
--   L'étendue calculée est inférieure à l'étendue minimale.
--
-- <FIELD>_SPAN_TOO_LARGE
--   L'étendue calculée est supérieure à l'étendue maximale.
--
-- VALIDATION_INVALID_FIELD_NAME
--   Le nom technique de la plage est vide.
--
-- VALIDATION_INVALID_DURATION_SPAN_RANGE
--   L'étendue minimale configurée est supérieure à l'étendue maximale.
--
-- VALIDATION_IMPOSSIBLE_DURATION_RANGE
--   Les plages exactes sont interdites alors que l'étendue maximale vaut zéro.
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
--   - elle ne contacte aucun service externe ;
--   - elle ne dépend pas du contexte d'authentification ;
--   - elle agit uniquement sur les paramètres transmis ;
--   - elle ne possède aucun effet secondaire.
--
-- Elle peut donc être appelée par toutes les fonctions métier autorisées.
--
-- Les règles d'utilisation des bornes restent sous la responsabilité de la
-- fonction métier appelante.
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
-- Cette fonction est autonome.
--
-- Elle est toutefois logiquement liée aux fonctions :
--
--   - fn::validation_duration()
--   - fn::validation_time_range()
--   - fn::validation_future_datetime()
--   - fn::validation_past_datetime()
--
-- Exemples d'utilisation
-- ----------------------
-- Plage de réservation :
--
-- LET $range = fn::validation_duration_range(
--     $min_booking_duration,
--     $max_booking_duration,
--     "BOOKING_DURATION_RANGE",
--     false,
--     NONE,
--     NONE
-- );
--
-- LET $booking_duration = fn::validation_duration(
--     $booking_duration,
--     "BOOKING_DURATION",
--     $range.min_duration,
--     $range.max_duration
-- );
--
-- Plage exacte autorisée :
--
-- LET $range = fn::validation_duration_range(
--     1h,
--     1h,
--     "APPOINTMENT_DURATION_RANGE",
--     true,
--     NONE,
--     NONE
-- );
--
-- Plage avec étendue limitée :
--
-- LET $range = fn::validation_duration_range(
--     15m,
--     8h,
--     "SESSION_DURATION_RANGE",
--     false,
--     1h,
--     24h
-- );
--
-- Conversion explicite avant validation :
--
-- LET $min_duration = type::duration(
--     $min_duration_string
-- );
--
-- LET $max_duration = type::duration(
--     $max_duration_string
-- );
--
-- LET $range = fn::validation_duration_range(
--     $min_duration,
--     $max_duration,
--     "DURATION_RANGE",
--     false,
--     NONE,
--     NONE
-- );
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_duration_range(
    $min_value: option<any>,
    $max_value: option<any>,
    $field: string,
    $allow_exact: bool,
    $min_span: option<duration>,
    $max_span: option<duration>
) -> object {

    -- ------------------------------------------------------------------------
    -- 1. Validation du nom technique de la plage
    -- ------------------------------------------------------------------------

    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    -- ------------------------------------------------------------------------
    -- 2. Validation de la cohérence des limites d'étendue
    -- ------------------------------------------------------------------------

    IF $min_span IS NOT NONE
        AND $max_span IS NOT NONE
        AND $min_span > $max_span
    {
        THROW "VALIDATION_INVALID_DURATION_SPAN_RANGE";
    };

    -- ------------------------------------------------------------------------
    -- 3. Validation d'une configuration impossible
    -- ------------------------------------------------------------------------
    -- Lorsque les plages exactes sont interdites, une étendue maximale égale
    -- à zéro ne permettrait de valider aucune plage.

    IF !$allow_exact
        AND $max_span IS NOT NONE
        AND $max_span = 0ns
    {
        THROW "VALIDATION_IMPOSSIBLE_DURATION_RANGE";
    };

    -- ------------------------------------------------------------------------
    -- 4. Vérification de la présence de la durée minimale
    -- ------------------------------------------------------------------------

    IF $min_value IS NONE {
        THROW string::concat(
            $clean_field,
            "_MIN_REQUIRED"
        );
    };

    -- ------------------------------------------------------------------------
    -- 5. Refus de NULL pour la durée minimale
    -- ------------------------------------------------------------------------

    IF type::is_null($min_value) {
        THROW string::concat(
            $clean_field,
            "_MIN_NULL_NOT_ALLOWED"
        );
    };

    -- ------------------------------------------------------------------------
    -- 6. Vérification stricte du type de la durée minimale
    -- ------------------------------------------------------------------------

    IF !type::is_duration($min_value) {
        THROW string::concat(
            $clean_field,
            "_MIN_INVALID_TYPE"
        );
    };

    -- ------------------------------------------------------------------------
    -- 7. Vérification de la présence de la durée maximale
    -- ------------------------------------------------------------------------

    IF $max_value IS NONE {
        THROW string::concat(
            $clean_field,
            "_MAX_REQUIRED"
        );
    };

    -- ------------------------------------------------------------------------
    -- 8. Refus de NULL pour la durée maximale
    -- ------------------------------------------------------------------------

    IF type::is_null($max_value) {
        THROW string::concat(
            $clean_field,
            "_MAX_NULL_NOT_ALLOWED"
        );
    };

    -- ------------------------------------------------------------------------
    -- 9. Vérification stricte du type de la durée maximale
    -- ------------------------------------------------------------------------

    IF !type::is_duration($max_value) {
        THROW string::concat(
            $clean_field,
            "_MAX_INVALID_TYPE"
        );
    };

    -- ------------------------------------------------------------------------
    -- 10. Vérification de l'ordre des bornes
    -- ------------------------------------------------------------------------

    IF $max_value < $min_value {
        THROW string::concat(
            $clean_field,
            "_INVALID_ORDER"
        );
    };

    -- ------------------------------------------------------------------------
    -- 11. Refus d'une plage exacte
    -- ------------------------------------------------------------------------

    IF !$allow_exact
        AND $max_value = $min_value
    {
        THROW string::concat(
            $clean_field,
            "_EXACT_RANGE_NOT_ALLOWED"
        );
    };

    -- ------------------------------------------------------------------------
    -- 12. Calcul de l'étendue de la plage
    -- ------------------------------------------------------------------------
    -- L'ordre a déjà été validé.
    --
    -- La soustraction produit donc une durée positive ou nulle.

    LET $range_span = $max_value - $min_value;

    -- ------------------------------------------------------------------------
    -- 13. Validation de l'étendue minimale
    -- ------------------------------------------------------------------------

    IF $min_span IS NOT NONE
        AND $range_span < $min_span
    {
        THROW string::concat(
            $clean_field,
            "_SPAN_TOO_SMALL"
        );
    };

    -- ------------------------------------------------------------------------
    -- 14. Validation de l'étendue maximale
    -- ------------------------------------------------------------------------

    IF $max_span IS NOT NONE
        AND $range_span > $max_span
    {
        THROW string::concat(
            $clean_field,
            "_SPAN_TOO_LARGE"
        );
    };

    -- ------------------------------------------------------------------------
    -- 15. Retour de la plage de durées validée
    -- ------------------------------------------------------------------------

    RETURN {
        min_duration: $min_value,
        max_duration: $max_value,
        span: $range_span
    };
}
COMMENT "
Valide une plage composée d'une durée minimale et d'une durée maximale.
Contrôle strictement le type duration des deux bornes, leur ordre, autorise ou
refuse les plages exactes et applique facultativement une étendue minimale et
maximale. Retourne les deux bornes et leur étendue sans transformation.
"
PERMISSIONS FULL;