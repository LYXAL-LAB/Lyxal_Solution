-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/time_range.surql
-- Fonction     : fn::validation_time_range
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Vérifie qu'une plage temporelle obligatoire est composée de deux valeurs
-- datetime cohérentes :
--
--   - une date et heure de début ;
--   - une date et heure de fin.
--
-- Cette fonction permet également :
--
--   - d'autoriser ou de refuser une plage de durée nulle ;
--   - d'imposer une durée minimale ;
--   - d'imposer une durée maximale ;
--   - de retourner les deux datetimes validés ainsi que la durée calculée.
--
-- Elle est destinée aux plages temporelles telles que :
--
--   - une réservation ;
--   - un rendez-vous ;
--   - une intervention ;
--   - un créneau de disponibilité ;
--   - une période d'exécution ;
--   - une session ;
--   - une location ;
--   - une période de maintenance ;
--   - une fenêtre de livraison ;
--   - une période de validité.
--
-- Exemple simple
-- --------------
-- Début :
--
--   d"2026-08-03T08:00:00Z"
--
-- Fin :
--
--   d"2026-08-03T10:30:00Z"
--
-- Durée calculée :
--
--   2h30m
--
-- Exemple d'appel :
--
--   fn::validation_time_range(
--       d"2026-08-03T08:00:00Z",
--       d"2026-08-03T10:30:00Z",
--       "BOOKING_RANGE",
--       false,
--       30m,
--       8h
--   )
--
-- retourne :
--
--   {
--       start_at: d"2026-08-03T08:00:00Z",
--       end_at: d"2026-08-03T10:30:00Z",
--       duration: 2h30m
--   }
--
-- Validation stricte
-- ------------------
-- Les deux valeurs doivent être de véritables datetimes SurrealDB.
--
-- Exemples acceptés :
--
--   d"2026-08-03T08:00:00Z"
--   d"2026-08-03T10:30:00Z"
--
-- Exemples refusés :
--
--   "2026-08-03T08:00:00Z"
--     chaîne non convertie.
--
--   1754208000
--     timestamp numérique.
--
--   2h
--     durée et non datetime.
--
--   NONE
--     absence de valeur.
--
--   NULL
--     valeur explicitement vide.
--
-- La fonction n'effectue aucune conversion automatique.
--
-- Pour convertir explicitement une chaîne en datetime, utiliser :
--
--   type::datetime($value)
--
-- Exemple :
--
--   LET $start_at = type::datetime(
--       "2026-08-03T08:00:00Z"
--   );
--
--   LET $end_at = type::datetime(
--       "2026-08-03T10:00:00Z"
--   );
--
--   RETURN fn::validation_time_range(
--       $start_at,
--       $end_at,
--       "BOOKING_RANGE",
--       false,
--       NONE,
--       NONE
--   );
--
-- Ordre temporel
-- ---------------
-- La date de fin ne peut jamais être antérieure à la date de début.
--
-- Exemple invalide :
--
--   début :
--     d"2026-08-03T10:00:00Z"
--
--   fin :
--     d"2026-08-03T08:00:00Z"
--
-- produit :
--
--   <FIELD>_INVALID_ORDER
--
-- Cette erreur est produite indépendamment de la valeur du paramètre
-- $allow_zero_duration.
--
-- Durée nulle
-- -----------
-- Une durée nulle apparaît lorsque :
--
--   $start_value = $end_value
--
-- Exemple :
--
--   début :
--     d"2026-08-03T10:00:00Z"
--
--   fin :
--     d"2026-08-03T10:00:00Z"
--
-- Durée :
--
--   0ns
--
-- Lorsque $allow_zero_duration vaut true, cette plage est acceptée sous réserve
-- de la durée minimale configurée.
--
-- Lorsque $allow_zero_duration vaut false, elle produit :
--
--   <FIELD>_ZERO_DURATION_NOT_ALLOWED
--
-- Attention :
--
-- Si $allow_zero_duration vaut true mais que $min_duration est supérieure à
-- zéro, la plage nulle reste refusée avec :
--
--   <FIELD>_DURATION_TOO_SHORT
--
-- Durée calculée
-- ---------------
-- La durée est obtenue par soustraction :
--
--   $end_value - $start_value
--
-- Exemple :
--
--   d"2026-08-03T10:30:00Z"
--   -
--   d"2026-08-03T08:00:00Z"
--
-- produit :
--
--   2h30m
--
-- Le résultat est une valeur de type duration.
--
-- La comparaison porte sur les instants UTC réels.
--
-- Deux valeurs exprimées avec des décalages horaires différents peuvent donc
-- représenter le même instant.
--
-- Exemple :
--
--   d"2026-08-03T10:00:00+02:00"
--
-- représente le même instant que :
--
--   d"2026-08-03T08:00:00Z"
--
-- Durée minimale
-- ---------------
-- Le paramètre $min_duration permet d'imposer une durée minimale inclusive.
--
-- Exemple :
--
--   $min_duration = 30m
--
-- Une plage de exactement trente minutes est acceptée.
--
-- Une plage de vingt-neuf minutes produit :
--
--   <FIELD>_DURATION_TOO_SHORT
--
-- Durée maximale
-- ---------------
-- Le paramètre $max_duration permet d'imposer une durée maximale inclusive.
--
-- Exemple :
--
--   $max_duration = 8h
--
-- Une plage de exactement huit heures est acceptée.
--
-- Une plage de huit heures et une seconde produit :
--
--   <FIELD>_DURATION_TOO_LONG
--
-- Durée exacte
-- -------------
-- Pour exiger une durée exacte, utiliser la même valeur pour les deux limites.
--
-- Exemple :
--
--   $min_duration = 1h
--   $max_duration = 1h
--
-- Seule une plage d'une heure exacte est acceptée.
--
-- Cohérence des limites
-- ----------------------
-- Lorsque les deux limites sont définies, la durée minimale ne peut pas être
-- supérieure à la durée maximale.
--
-- Exemple invalide :
--
--   min = 8h
--   max = 1h
--
-- produit :
--
--   VALIDATION_INVALID_TIME_RANGE_DURATION
--
-- Si $allow_zero_duration vaut false et que $max_duration vaut 0ns, aucune
-- plage ne pourrait être valide.
--
-- Cette configuration produit :
--
--   VALIDATION_IMPOSSIBLE_TIME_RANGE
--
-- Cela permet de détecter une configuration incohérente avant de valider les
-- valeurs reçues.
--
-- Plage traversant plusieurs jours
-- ---------------------------------
-- La fonction autorise une plage traversant :
--
--   - minuit ;
--   - plusieurs jours ;
--   - plusieurs semaines ;
--   - plusieurs mois calendaires ;
--   - plusieurs années.
--
-- Exemple :
--
--   début :
--     d"2026-08-03T22:00:00Z"
--
--   fin :
--     d"2026-08-04T02:00:00Z"
--
-- durée :
--
--   4h
--
-- La fonction travaille sur une durée absolue et non sur des heures affichées
-- dans un fuseau local.
--
-- Changement d'heure et fuseaux horaires
-- ---------------------------------------
-- Les datetimes SurrealDB sont comparés comme des instants.
--
-- Une plage créée avec des décalages horaires différents doit donc être
-- évaluée selon sa durée UTC réelle.
--
-- Cette fonction ne calcule pas :
--
--   - une durée d'horloge locale ;
--   - une durée de journée ouvrée ;
--   - une durée excluant les pauses ;
--   - une durée excluant les nuits ;
--   - une durée excluant les week-ends ;
--   - une durée excluant les jours fériés.
--
-- Ces règles appartiennent aux fonctions métier ou au moteur de calendrier.
--
-- Retour sous forme d'objet
-- --------------------------
-- Cette fonction reçoit deux valeurs et retourne donc un objet contenant :
--
--   start_at
--     datetime de début validé.
--
--   end_at
--     datetime de fin validé.
--
--   duration
--     durée calculée entre le début et la fin.
--
-- Exemple d'utilisation :
--
--   LET $range = fn::validation_time_range(...);
--
--   RETURN $range.start_at;
--
--   RETURN $range.end_at;
--
--   RETURN $range.duration;
--
-- Cette structure évite de recalculer la durée dans la fonction métier.
--
-- Conservation des valeurs
-- -------------------------
-- Les valeurs start_at et end_at sont retournées sans transformation.
--
-- La fonction ne réalise :
--
--   - aucune conversion de fuseau horaire ;
--   - aucun arrondi ;
--   - aucun changement de précision ;
--   - aucun déplacement temporel ;
--   - aucune normalisation à la minute ;
--   - aucun découpage en créneaux ;
--   - aucune lecture de calendrier.
--
-- Limites de la validation
-- ------------------------
-- Cette fonction vérifie uniquement :
--
--   - la présence du début ;
--   - la présence de la fin ;
--   - le refus de NULL ;
--   - le type datetime des deux valeurs ;
--   - l'ordre temporel ;
--   - l'autorisation d'une durée nulle ;
--   - la durée minimale ;
--   - la durée maximale.
--
-- Elle ne vérifie pas :
--
--   - la disponibilité d'une ressource ;
--   - les chevauchements avec d'autres plages ;
--   - les horaires d'ouverture ;
--   - les jours ouvrés ;
--   - les pauses obligatoires ;
--   - le fuseau horaire métier ;
--   - les permissions de réservation ;
--   - la capacité d'une équipe ;
--   - la présence d'un événement existant ;
--   - les récurrences ;
--   - les contraintes liées au calendrier.
--
-- Ces contrôles devront être effectués dans les fonctions métier ou dans les
-- modules Scheduler, Booking ou Calendar.
--
-- Règles appliquées
-- -----------------
--   1. Le nom technique de la plage doit être renseigné ;
--   2. La durée minimale ne doit pas être supérieure à la durée maximale ;
--   3. La configuration ne doit pas rendre toute plage impossible ;
--   4. La valeur de début doit être présente ;
--   5. La valeur de début ne doit pas être NULL ;
--   6. La valeur de début doit être strictement de type datetime ;
--   7. La valeur de fin doit être présente ;
--   8. La valeur de fin ne doit pas être NULL ;
--   9. La valeur de fin doit être strictement de type datetime ;
--  10. La fin ne doit pas être antérieure au début ;
--  11. Une durée nulle est refusée lorsque $allow_zero_duration vaut false ;
--  12. La durée réelle est calculée ;
--  13. La durée minimale est contrôlée lorsqu'elle est définie ;
--  14. La durée maximale est contrôlée lorsqu'elle est définie ;
--  15. Un objet contenant le début, la fin et la durée est retourné.
--
-- Paramètres
-- ----------
-- $start_value:
--   Type : option<any>
--
--   Datetime obligatoire représentant le début de la plage.
--
-- $end_value:
--   Type : option<any>
--
--   Datetime obligatoire représentant la fin de la plage.
--
-- $field:
--   Type : string
--
--   Nom technique de la plage utilisé pour construire les codes d'erreur.
--
--   Convention recommandée :
--
--     - BOOKING_RANGE
--     - AVAILABILITY_RANGE
--     - SESSION_RANGE
--     - EXECUTION_RANGE
--     - MAINTENANCE_RANGE
--     - DELIVERY_RANGE
--     - CONTRACT_RANGE
--     - EVENT_RANGE
--
-- $allow_zero_duration:
--   Type : bool
--
--   true :
--     Une plage dont le début et la fin sont identiques est autorisée, sous
--     réserve de la durée minimale.
--
--   false :
--     Une plage nulle produit <FIELD>_ZERO_DURATION_NOT_ALLOWED.
--
-- $min_duration:
--   Type : option<duration>
--
--   Durée minimale autorisée.
--
--   Utiliser NONE lorsqu'aucune durée minimale n'est requise.
--
--   La limite est inclusive.
--
-- $max_duration:
--   Type : option<duration>
--
--   Durée maximale autorisée.
--
--   Utiliser NONE lorsqu'aucune durée maximale n'est requise.
--
--   La limite est inclusive.
--
-- Valeur retournée
-- ----------------
-- Type : object
--
-- Retourne un objet contenant :
--
--   {
--       start_at: datetime,
--       end_at: datetime,
--       duration: duration
--   }
--
-- Exemple :
--
--   fn::validation_time_range(
--       d"2026-08-03T08:00:00Z",
--       d"2026-08-03T10:30:00Z",
--       "BOOKING_RANGE",
--       false,
--       30m,
--       8h
--   )
--
-- retourne :
--
--   {
--       start_at: d"2026-08-03T08:00:00Z",
--       end_at: d"2026-08-03T10:30:00Z",
--       duration: 2h30m
--   }
--
-- Erreurs générées
-- ----------------
-- <FIELD>_START_REQUIRED
--   La valeur de début est absente ou égale à NONE.
--
-- <FIELD>_START_NULL_NOT_ALLOWED
--   La valeur de début est explicitement égale à NULL.
--
-- <FIELD>_START_INVALID_TYPE
--   La valeur de début n'est pas de type datetime.
--
-- <FIELD>_END_REQUIRED
--   La valeur de fin est absente ou égale à NONE.
--
-- <FIELD>_END_NULL_NOT_ALLOWED
--   La valeur de fin est explicitement égale à NULL.
--
-- <FIELD>_END_INVALID_TYPE
--   La valeur de fin n'est pas de type datetime.
--
-- <FIELD>_INVALID_ORDER
--   La date de fin est antérieure à la date de début.
--
-- <FIELD>_ZERO_DURATION_NOT_ALLOWED
--   Le début et la fin sont identiques alors que les plages nulles sont
--   interdites.
--
-- <FIELD>_DURATION_TOO_SHORT
--   La durée calculée est inférieure à la durée minimale.
--
-- <FIELD>_DURATION_TOO_LONG
--   La durée calculée est supérieure à la durée maximale.
--
-- VALIDATION_INVALID_FIELD_NAME
--   Le nom technique de la plage est vide ou composé uniquement d'espaces.
--
-- VALIDATION_INVALID_TIME_RANGE_DURATION
--   La durée minimale configurée est supérieure à la durée maximale.
--
-- VALIDATION_IMPOSSIBLE_TIME_RANGE
--   La configuration interdit les durées nulles, mais la durée maximale vaut
--   zéro.
--
-- Permissions
-- -----------
-- PERMISSIONS FULL
--
-- Cette fonction est une primitive pure :
--
--   - elle ne consulte aucune table ;
--   - elle ne recherche aucun événement ;
--   - elle ne crée aucune donnée ;
--   - elle ne modifie aucune donnée ;
--   - elle ne supprime aucune donnée ;
--   - elle ne dépend pas du contexte d'authentification ;
--   - elle ne contacte aucun service externe ;
--   - elle agit uniquement sur les paramètres transmis ;
--   - elle ne possède aucun effet secondaire.
--
-- Elle peut donc être appelée par toutes les fonctions métier autorisées.
--
-- Les permissions et les règles de disponibilité restent sous la
-- responsabilité de la fonction métier appelante.
--
-- Dépendances natives SurrealDB
-- -----------------------------
--   - string::trim()
--   - string::concat()
--   - type::is_null()
--   - type::is_datetime()
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
--   - fn::validation_datetime()
--   - fn::validation_duration()
--   - fn::validation_future_datetime()
--   - fn::validation_past_datetime()
--   - fn::validation_date()
--
-- Exemples d'utilisation
-- ----------------------
-- Réservation comprise entre trente minutes et huit heures :
--
-- LET $booking_range = fn::validation_time_range(
--     $start_at,
--     $end_at,
--     "BOOKING_RANGE",
--     false,
--     30m,
--     8h
-- );
--
-- RETURN CREATE booking_event CONTENT {
--     start_at: $booking_range.start_at,
--     end_at: $booking_range.end_at,
--     duration: $booking_range.duration
-- };
--
-- Créneau pouvant avoir une durée nulle :
--
-- LET $range = fn::validation_time_range(
--     $start_at,
--     $end_at,
--     "MARKER_RANGE",
--     true,
--     NONE,
--     NONE
-- );
--
-- Plage sans limites de durée :
--
-- LET $range = fn::validation_time_range(
--     $start_at,
--     $end_at,
--     "EVENT_RANGE",
--     false,
--     NONE,
--     NONE
-- );
--
-- Plage d'une durée exacte :
--
-- LET $range = fn::validation_time_range(
--     $start_at,
--     $end_at,
--     "APPOINTMENT_RANGE",
--     false,
--     1h,
--     1h
-- );
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_time_range(
    $start_value: option<any>,
    $end_value: option<any>,
    $field: string,
    $allow_zero_duration: bool,
    $min_duration: option<duration>,
    $max_duration: option<duration>
) -> object {

    -- ------------------------------------------------------------------------
    -- 1. Validation du nom technique de la plage
    -- ------------------------------------------------------------------------

    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    -- ------------------------------------------------------------------------
    -- 2. Validation de la cohérence des limites de durée
    -- ------------------------------------------------------------------------

    IF $min_duration IS NOT NONE
        AND $max_duration IS NOT NONE
        AND $min_duration > $max_duration
    {
        THROW "VALIDATION_INVALID_TIME_RANGE_DURATION";
    };

    -- ------------------------------------------------------------------------
    -- 3. Validation d'une configuration impossible
    -- ------------------------------------------------------------------------
    -- Lorsque les durées nulles sont interdites, une durée maximale égale à
    -- zéro rend toute plage impossible.
    --
    -- Une durée négative n'existe pas dans le type duration.

    IF !$allow_zero_duration
        AND $max_duration IS NOT NONE
        AND $max_duration = 0ns
    {
        THROW "VALIDATION_IMPOSSIBLE_TIME_RANGE";
    };

    -- ------------------------------------------------------------------------
    -- 4. Vérification de la présence du début
    -- ------------------------------------------------------------------------

    IF $start_value IS NONE {
        THROW string::concat(
            $clean_field,
            "_START_REQUIRED"
        );
    };

    -- ------------------------------------------------------------------------
    -- 5. Refus de NULL pour le début
    -- ------------------------------------------------------------------------

    IF type::is_null($start_value) {
        THROW string::concat(
            $clean_field,
            "_START_NULL_NOT_ALLOWED"
        );
    };

    -- ------------------------------------------------------------------------
    -- 6. Vérification stricte du type datetime pour le début
    -- ------------------------------------------------------------------------

    IF !type::is_datetime($start_value) {
        THROW string::concat(
            $clean_field,
            "_START_INVALID_TYPE"
        );
    };

    -- ------------------------------------------------------------------------
    -- 7. Vérification de la présence de la fin
    -- ------------------------------------------------------------------------

    IF $end_value IS NONE {
        THROW string::concat(
            $clean_field,
            "_END_REQUIRED"
        );
    };

    -- ------------------------------------------------------------------------
    -- 8. Refus de NULL pour la fin
    -- ------------------------------------------------------------------------

    IF type::is_null($end_value) {
        THROW string::concat(
            $clean_field,
            "_END_NULL_NOT_ALLOWED"
        );
    };

    -- ------------------------------------------------------------------------
    -- 9. Vérification stricte du type datetime pour la fin
    -- ------------------------------------------------------------------------

    IF !type::is_datetime($end_value) {
        THROW string::concat(
            $clean_field,
            "_END_INVALID_TYPE"
        );
    };

    -- ------------------------------------------------------------------------
    -- 10. Vérification de l'ordre temporel
    -- ------------------------------------------------------------------------
    -- La fin ne peut jamais être antérieure au début.
    --
    -- Cette règle est indépendante de l'autorisation d'une durée nulle.

    IF $end_value < $start_value {
        THROW string::concat(
            $clean_field,
            "_INVALID_ORDER"
        );
    };

    -- ------------------------------------------------------------------------
    -- 11. Vérification de la durée nulle
    -- ------------------------------------------------------------------------

    IF !$allow_zero_duration
        AND $end_value = $start_value
    {
        THROW string::concat(
            $clean_field,
            "_ZERO_DURATION_NOT_ALLOWED"
        );
    };

    -- ------------------------------------------------------------------------
    -- 12. Calcul de la durée réelle
    -- ------------------------------------------------------------------------
    -- La soustraction de deux datetimes produit une valeur duration.
    --
    -- L'ordre a déjà été validé, la durée obtenue est donc positive ou nulle.

    LET $range_duration = $end_value - $start_value;

    -- ------------------------------------------------------------------------
    -- 13. Validation de la durée minimale
    -- ------------------------------------------------------------------------

    IF $min_duration IS NOT NONE
        AND $range_duration < $min_duration
    {
        THROW string::concat(
            $clean_field,
            "_DURATION_TOO_SHORT"
        );
    };

    -- ------------------------------------------------------------------------
    -- 14. Validation de la durée maximale
    -- ------------------------------------------------------------------------

    IF $max_duration IS NOT NONE
        AND $range_duration > $max_duration
    {
        THROW string::concat(
            $clean_field,
            "_DURATION_TOO_LONG"
        );
    };

    -- ------------------------------------------------------------------------
    -- 15. Retour de la plage validée
    -- ------------------------------------------------------------------------

    RETURN {
        start_at: $start_value,
        end_at: $end_value,
        duration: $range_duration
    };
}
COMMENT "
Valide une plage temporelle composée d'un datetime de début et d'un datetime
de fin. Contrôle l'ordre chronologique, permet d'autoriser ou de refuser une
durée nulle et applique facultativement une durée minimale et maximale. Retourne
un objet contenant start_at, end_at et la durée calculée.
"
PERMISSIONS FULL;