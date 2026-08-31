-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/future_datetime.surql
-- Fonction     : fn::validation_future_datetime
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Vérifie qu'une valeur obligatoire est strictement de type datetime et
-- représente un instant futur par rapport à un instant de référence.
--
-- Cette fonction permet également :
--
--   - d'utiliser automatiquement l'instant courant avec time::now() ;
--   - de fournir un instant de référence explicite ;
--   - d'autoriser ou de refuser une valeur égale à la référence ;
--   - d'imposer une avance minimale ;
--   - d'imposer une avance maximale ;
--   - de retourner le datetime d'origine sans transformation.
--
-- Elle peut notamment être utilisée pour valider :
--
--   - une date de réservation ;
--   - une date de rendez-vous ;
--   - une date d'expiration future ;
--   - une date de livraison prévue ;
--   - une date de planification ;
--   - une date de démarrage différé ;
--   - une date d'exécution programmée ;
--   - une date de rappel ;
--   - une date de publication ;
--   - une échéance future.
--
-- Exemple simple
-- --------------
-- Validation par rapport à l'instant courant :
--
--   fn::validation_future_datetime(
--       $scheduled_at,
--       "SCHEDULED_AT",
--       NONE,
--       false,
--       NONE,
--       NONE
--   )
--
-- Lorsque $reference_value vaut NONE, la fonction utilise :
--
--   time::now()
--
-- Exemple déterministe :
--
--   fn::validation_future_datetime(
--       d"2026-08-03T12:00:00Z",
--       "SCHEDULED_AT",
--       d"2026-08-03T10:00:00Z",
--       false,
--       30m,
--       24h
--   )
--
-- La valeur se trouve deux heures après la référence. Elle est donc valide.
--
-- Validation stricte
-- ------------------
-- La valeur doit être un véritable datetime SurrealDB.
--
-- Exemple accepté :
--
--   d"2026-08-03T12:00:00Z"
--
-- Exemples refusés :
--
--   "2026-08-03T12:00:00Z"
--     chaîne non convertie.
--
--   1785758400
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
-- Une chaîne peut être convertie explicitement avant validation :
--
--   LET $scheduled_at = type::datetime(
--       "2026-08-03T12:00:00Z"
--   );
--
--   RETURN fn::validation_future_datetime(
--       $scheduled_at,
--       "SCHEDULED_AT",
--       NONE,
--       false,
--       NONE,
--       NONE
--   );
--
-- Instant de référence
-- --------------------
-- Le paramètre $reference_value détermine l'instant à partir duquel le futur
-- est évalué.
--
-- Lorsque $reference_value vaut NONE :
--
--   time::now()
--
-- est utilisé au moment de l'exécution de la fonction.
--
-- Lorsqu'un datetime est fourni, celui-ci devient la référence.
--
-- Exemple :
--
--   référence :
--     d"2026-08-03T10:00:00Z"
--
--   valeur :
--     d"2026-08-03T12:00:00Z"
--
--   avance :
--     2h
--
-- Une référence explicite est particulièrement utile pour :
--
--   - les tests automatisés ;
--   - les imports ;
--   - les migrations ;
--   - les traitements transactionnels ;
--   - les calculs basés sur une date métier ;
--   - la reproductibilité des résultats.
--
-- Autorisation de l'égalité
-- --------------------------
-- Le paramètre $allow_equal définit si la valeur peut être exactement égale à
-- l'instant de référence.
--
-- Lorsque $allow_equal vaut false :
--
--   valeur = référence
--
-- produit :
--
--   <FIELD>_NOT_IN_FUTURE
--
-- Lorsque $allow_equal vaut true :
--
--   valeur = référence
--
-- est acceptée, sous réserve de la durée minimale configurée.
--
-- Attention :
--
-- Si $allow_equal vaut true mais que $min_advance est supérieure à zéro,
-- l'égalité reste refusée avec :
--
--   <FIELD>_TOO_SOON
--
-- Avance calculée
-- ----------------
-- Une fois l'ordre temporel validé, l'avance est calculée ainsi :
--
--   $value - $reference
--
-- Exemple :
--
--   d"2026-08-03T12:30:00Z"
--   -
--   d"2026-08-03T10:00:00Z"
--
-- produit :
--
--   2h30m
--
-- Le résultat de cette soustraction est une valeur de type duration.
--
-- Avance minimale
-- ----------------
-- Le paramètre $min_advance permet d'imposer un délai minimal entre la
-- référence et le datetime validé.
--
-- Exemple :
--
--   $min_advance = 30m
--
-- Une valeur exactement trente minutes après la référence est acceptée.
--
-- Une valeur vingt-neuf minutes après la référence produit :
--
--   <FIELD>_TOO_SOON
--
-- Cette règle est utile pour :
--
--   - imposer un délai de réservation ;
--   - empêcher une planification trop proche ;
--   - respecter un préavis ;
--   - laisser un temps de préparation ;
--   - imposer un délai de traitement.
--
-- Avance maximale
-- ----------------
-- Le paramètre $max_advance permet d'interdire une date située trop loin dans
-- le futur.
--
-- Exemple :
--
--   $max_advance = 365d
--
-- Une valeur exactement 365 jours après la référence est acceptée.
--
-- Une valeur située plus loin produit :
--
--   <FIELD>_TOO_FAR
--
-- Cette règle est utile pour :
--
--   - limiter l'horizon de réservation ;
--   - limiter la durée de validité ;
--   - empêcher une programmation excessive ;
--   - limiter une date d'expiration ;
--   - encadrer une prévision.
--
-- Avance exacte
-- --------------
-- Pour exiger une avance exacte, utiliser la même durée pour les deux limites.
--
-- Exemple :
--
--   $min_advance = 24h
--   $max_advance = 24h
--
-- Seule une valeur située exactement vingt-quatre heures après la référence
-- sera acceptée.
--
-- Cohérence des limites
-- ----------------------
-- Lorsque les deux limites sont définies, l'avance minimale ne peut pas être
-- supérieure à l'avance maximale.
--
-- Exemple invalide :
--
--   min = 30d
--   max = 7d
--
-- produit :
--
--   VALIDATION_INVALID_FUTURE_RANGE
--
-- Configuration impossible
-- -------------------------
-- Lorsque $allow_equal vaut false, une avance maximale égale à zéro rend toute
-- valeur impossible :
--
--   la valeur doit être strictement future ;
--   mais elle ne peut pas être située après la référence.
--
-- Cette configuration produit :
--
--   VALIDATION_IMPOSSIBLE_FUTURE_RANGE
--
-- Fuseaux horaires
-- ----------------
-- Les datetimes sont comparés comme des instants réels.
--
-- Une valeur exprimée avec un décalage horaire est convertie selon son instant
-- UTC avant comparaison.
--
-- Exemple :
--
--   d"2026-08-03T12:00:00+02:00"
--
-- représente le même instant que :
--
--   d"2026-08-03T10:00:00Z"
--
-- Si la seconde valeur est utilisée comme référence, les deux datetimes sont
-- égaux et non séparés de deux heures.
--
-- Précision
-- ---------
-- Les comparaisons prennent en compte la précision du datetime, y compris les
-- fractions de seconde.
--
-- Exemple :
--
--   référence :
--     d"2026-08-03T10:00:00.000000000Z"
--
--   valeur :
--     d"2026-08-03T10:00:00.000000001Z"
--
-- La valeur se trouve une nanoseconde dans le futur.
--
-- Utilisation de time::now()
-- --------------------------
-- Lorsque la référence vaut NONE, time::now() est évalué dans la fonction.
--
-- Pour éviter de prendre plusieurs instants légèrement différents dans une
-- même fonction métier, il est recommandé de capturer une référence unique :
--
--   LET $reference_time = time::now();
--
--   LET $start_at = fn::validation_future_datetime(
--       $start_at,
--       "START_AT",
--       $reference_time,
--       false,
--       NONE,
--       NONE
--   );
--
--   LET $end_at = fn::validation_future_datetime(
--       $end_at,
--       "END_AT",
--       $reference_time,
--       false,
--       NONE,
--       NONE
--   );
--
-- Les deux validations utilisent alors exactement le même instant de
-- référence.
--
-- Différence avec validation_datetime
-- -----------------------------------
-- fn::validation_datetime() vérifie principalement :
--
--   - le type datetime ;
--   - les limites absolues facultatives.
--
-- fn::validation_future_datetime() vérifie :
--
--   - le type datetime ;
--   - la position future relative à une référence ;
--   - une avance minimale ;
--   - une avance maximale.
--
-- Différence avec validation_date
-- -------------------------------
-- fn::validation_date() représente un jour civil à minuit UTC.
--
-- fn::validation_future_datetime() représente un instant précis qui doit être
-- situé dans le futur.
--
-- Différence avec validation_time_range
-- -------------------------------------
-- fn::validation_time_range() valide deux datetimes formant une plage.
--
-- fn::validation_future_datetime() valide un datetime unique par rapport à une
-- référence.
--
-- Retour de la fonction
-- ----------------------
-- La fonction retourne uniquement le datetime validé.
--
-- Elle ne retourne pas l'avance calculée afin de conserver une primitive facile
-- à chaîner :
--
--   LET $scheduled_at = fn::validation_future_datetime(...);
--
-- Lorsque l'avance est nécessaire, la fonction métier peut la recalculer à
-- partir de la même référence :
--
--   LET $advance = $scheduled_at - $reference_time;
--
-- Conservation de la valeur
-- --------------------------
-- La fonction retourne le datetime d'origine sans :
--
--   - conversion de fuseau ;
--   - arrondi ;
--   - troncature ;
--   - modification de précision ;
--   - déplacement temporel ;
--   - formatage ;
--   - conversion en chaîne.
--
-- Limites de la validation
-- ------------------------
-- Cette fonction ne vérifie pas :
--
--   - la disponibilité d'une ressource ;
--   - les horaires d'ouverture ;
--   - les jours ouvrés ;
--   - les jours fériés ;
--   - les chevauchements ;
--   - le fuseau horaire métier ;
--   - la capacité d'une équipe ;
--   - les permissions de réservation ;
--   - la validité d'un calendrier ;
--   - la cohérence avec une date de fin ;
--   - l'état d'un événement.
--
-- Ces contrôles appartiennent aux fonctions métier ou aux modules Calendar,
-- Scheduler et Booking.
--
-- Règles appliquées
-- -----------------
--   1. Le nom technique du champ doit être renseigné ;
--   2. L'avance minimale ne doit pas dépasser l'avance maximale ;
--   3. La configuration ne doit pas rendre toute valeur impossible ;
--   4. La référence explicite doit être de type datetime lorsqu'elle existe ;
--   5. La valeur doit être présente ;
--   6. La valeur ne doit pas être NULL ;
--   7. La valeur doit être strictement de type datetime ;
--   8. La référence effective est déterminée ;
--   9. La valeur doit être postérieure ou égale à la référence selon la règle ;
--  10. L'avance est calculée ;
--  11. L'avance minimale est contrôlée lorsqu'elle est définie ;
--  12. L'avance maximale est contrôlée lorsqu'elle est définie ;
--  13. Le datetime d'origine est retourné lorsqu'il est valide.
--
-- Paramètres
-- ----------
-- $value:
--   Type : option<any>
--
--   Datetime obligatoire à valider.
--
-- $field:
--   Type : string
--
--   Nom technique utilisé pour construire les codes d'erreur.
--
--   Convention recommandée :
--
--     - SCHEDULED_AT
--     - START_AT
--     - EXPIRES_AT
--     - DELIVERY_AT
--     - PUBLISH_AT
--     - REMINDER_AT
--     - EXECUTE_AT
--     - BOOKING_AT
--
-- $reference_value:
--   Type : option<datetime>
--
--   Instant de référence.
--
--   Utiliser NONE pour employer time::now().
--
--   Fournir un datetime explicite pour obtenir un résultat déterministe.
--
-- $allow_equal:
--   Type : bool
--
--   false :
--     La valeur doit être strictement postérieure à la référence.
--
--   true :
--     La valeur peut être égale à la référence.
--
-- $min_advance:
--   Type : option<duration>
--
--   Avance minimale autorisée par rapport à la référence.
--
--   Utiliser NONE lorsqu'aucune avance minimale n'est requise.
--
--   La limite est inclusive.
--
-- $max_advance:
--   Type : option<duration>
--
--   Avance maximale autorisée par rapport à la référence.
--
--   Utiliser NONE lorsqu'aucune avance maximale n'est requise.
--
--   La limite est inclusive.
--
-- Valeur retournée
-- ----------------
-- Type : datetime
--
-- Retourne le datetime d'origine sans transformation.
--
-- Exemple :
--
--   fn::validation_future_datetime(
--       d"2026-08-03T12:00:00Z",
--       "SCHEDULED_AT",
--       d"2026-08-03T10:00:00Z",
--       false,
--       30m,
--       24h
--   )
--
-- retourne :
--
--   d"2026-08-03T12:00:00Z"
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
--   La valeur n'est pas strictement de type datetime.
--
-- <FIELD>_NOT_IN_FUTURE
--   La valeur est antérieure à la référence, ou elle lui est égale alors que
--   l'égalité est interdite.
--
-- <FIELD>_TOO_SOON
--   La valeur est future, mais son avance est inférieure au minimum.
--
-- <FIELD>_TOO_FAR
--   La valeur est située au-delà de l'avance maximale.
--
-- VALIDATION_INVALID_FIELD_NAME
--   Le nom technique du champ est vide.
--
-- VALIDATION_INVALID_REFERENCE_DATETIME
--   La référence fournie n'est pas de type datetime.
--
-- VALIDATION_INVALID_FUTURE_RANGE
--   L'avance minimale est supérieure à l'avance maximale.
--
-- VALIDATION_IMPOSSIBLE_FUTURE_RANGE
--   L'égalité est interdite alors que l'avance maximale vaut zéro.
--
-- Permissions
-- -----------
-- PERMISSIONS FULL
--
-- Cette fonction est une primitive sans accès aux données persistantes :
--
--   - elle ne consulte aucune table ;
--   - elle ne crée aucune donnée ;
--   - elle ne modifie aucune donnée ;
--   - elle ne supprime aucune donnée ;
--   - elle ne contacte aucun service externe ;
--   - elle ne dépend pas du contexte d'authentification ;
--   - elle agit uniquement sur ses paramètres et éventuellement time::now() ;
--   - elle ne possède aucun effet secondaire.
--
-- Elle peut donc être appelée par toutes les fonctions métier autorisées.
--
-- Dépendances natives SurrealDB
-- -----------------------------
--   - string::trim()
--   - string::concat()
--   - type::is_null()
--   - type::is_datetime()
--   - time::now()
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
--   - fn::validation_past_datetime()
--   - fn::validation_time_range()
--   - fn::validation_duration()
--
-- Exemples d'utilisation
-- ----------------------
-- Date strictement future par rapport à maintenant :
--
-- LET $scheduled_at = fn::validation_future_datetime(
--     $scheduled_at,
--     "SCHEDULED_AT",
--     NONE,
--     false,
--     NONE,
--     NONE
-- );
--
-- Réservation au moins trente minutes à l'avance :
--
-- LET $start_at = fn::validation_future_datetime(
--     $start_at,
--     "START_AT",
--     NONE,
--     false,
--     30m,
--     NONE
-- );
--
-- Réservation entre trente minutes et trois mois :
--
-- LET $start_at = fn::validation_future_datetime(
--     $start_at,
--     "START_AT",
--     NONE,
--     false,
--     30m,
--     90d
-- );
--
-- Validation déterministe :
--
-- LET $reference_time = time::now();
--
-- LET $expires_at = fn::validation_future_datetime(
--     $expires_at,
--     "EXPIRES_AT",
--     $reference_time,
--     false,
--     1m,
--     30d
-- );
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_future_datetime(
    $value: option<any>,
    $field: string,
    $reference_value: option<datetime>,
    $allow_equal: bool,
    $min_advance: option<duration>,
    $max_advance: option<duration>
) -> datetime {

    -- ------------------------------------------------------------------------
    -- 1. Validation du nom technique du champ
    -- ------------------------------------------------------------------------

    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    -- ------------------------------------------------------------------------
    -- 2. Validation de la cohérence des limites d'avance
    -- ------------------------------------------------------------------------

    IF $min_advance IS NOT NONE
        AND $max_advance IS NOT NONE
        AND $min_advance > $max_advance
    {
        THROW "VALIDATION_INVALID_FUTURE_RANGE";
    };

    -- ------------------------------------------------------------------------
    -- 3. Validation d'une configuration impossible
    -- ------------------------------------------------------------------------
    -- Lorsque l'égalité est interdite, une avance maximale égale à zéro ne
    -- permettrait de valider aucun datetime.

    IF !$allow_equal
        AND $max_advance IS NOT NONE
        AND $max_advance = 0ns
    {
        THROW "VALIDATION_IMPOSSIBLE_FUTURE_RANGE";
    };

    -- ------------------------------------------------------------------------
    -- 4. Validation défensive de la référence explicite
    -- ------------------------------------------------------------------------
    -- Le type du paramètre est option<datetime>, mais ce contrôle documente
    -- explicitement l'invariant et protège la fonction si sa signature évolue.

    IF $reference_value IS NOT NONE
        AND !type::is_datetime($reference_value)
    {
        THROW "VALIDATION_INVALID_REFERENCE_DATETIME";
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
    -- 6. Refus explicite de NULL
    -- ------------------------------------------------------------------------

    IF type::is_null($value) {
        THROW string::concat(
            $clean_field,
            "_NULL_NOT_ALLOWED"
        );
    };

    -- ------------------------------------------------------------------------
    -- 7. Vérification stricte du type datetime
    -- ------------------------------------------------------------------------

    IF !type::is_datetime($value) {
        THROW string::concat(
            $clean_field,
            "_INVALID_TYPE"
        );
    };

    -- ------------------------------------------------------------------------
    -- 8. Détermination de l'instant de référence effectif
    -- ------------------------------------------------------------------------
    -- Une référence explicite garantit des validations déterministes.
    --
    -- Lorsque celle-ci n'est pas fournie, l'instant courant est utilisé.

    LET $effective_reference = IF $reference_value IS NONE {
        time::now()
    } ELSE {
        $reference_value
    };

    -- ------------------------------------------------------------------------
    -- 9. Vérification de la position future
    -- ------------------------------------------------------------------------

    IF $allow_equal {

        IF $value < $effective_reference {
            THROW string::concat(
                $clean_field,
                "_NOT_IN_FUTURE"
            );
        };

    } ELSE {

        IF $value <= $effective_reference {
            THROW string::concat(
                $clean_field,
                "_NOT_IN_FUTURE"
            );
        };
    };

    -- ------------------------------------------------------------------------
    -- 10. Calcul de l'avance
    -- ------------------------------------------------------------------------
    -- La position temporelle a déjà été validée.
    --
    -- La soustraction produit donc une durée positive ou nulle.

    LET $advance = $value - $effective_reference;

    -- ------------------------------------------------------------------------
    -- 11. Validation de l'avance minimale
    -- ------------------------------------------------------------------------

    IF $min_advance IS NOT NONE
        AND $advance < $min_advance
    {
        THROW string::concat(
            $clean_field,
            "_TOO_SOON"
        );
    };

    -- ------------------------------------------------------------------------
    -- 12. Validation de l'avance maximale
    -- ------------------------------------------------------------------------

    IF $max_advance IS NOT NONE
        AND $advance > $max_advance
    {
        THROW string::concat(
            $clean_field,
            "_TOO_FAR"
        );
    };

    -- ------------------------------------------------------------------------
    -- 13. Retour du datetime validé
    -- ------------------------------------------------------------------------

    RETURN $value;
}
COMMENT "
Valide qu'une valeur obligatoire est strictement de type datetime et se situe
dans le futur par rapport à une référence explicite ou à time::now(). Permet
d'autoriser l'égalité et de contrôler facultativement une avance minimale et
maximale. Retourne le datetime d'origine sans transformation.
"
PERMISSIONS FULL;