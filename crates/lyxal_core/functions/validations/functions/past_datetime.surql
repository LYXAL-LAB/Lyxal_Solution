-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/past_datetime.surql
-- Fonction     : fn::validation_past_datetime
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Vérifie qu'une valeur obligatoire est strictement de type datetime et
-- représente un instant passé par rapport à un instant de référence.
--
-- Cette fonction permet également :
--
--   - d'utiliser automatiquement l'instant courant avec time::now() ;
--   - de fournir un instant de référence explicite ;
--   - d'autoriser ou de refuser une valeur égale à la référence ;
--   - d'imposer une ancienneté minimale ;
--   - d'imposer une ancienneté maximale ;
--   - de retourner le datetime d'origine sans transformation.
--
-- Elle peut notamment être utilisée pour valider :
--
--   - une date de naissance avec heure ;
--   - une date d'exécution passée ;
--   - une date de dernière connexion ;
--   - une date de paiement ;
--   - une date de réception ;
--   - une date de clôture ;
--   - une date de signature ;
--   - une date d'import ;
--   - une date d'événement passé ;
--   - une date de synchronisation.
--
-- Exemple simple
-- --------------
-- Validation par rapport à l'instant courant :
--
--   fn::validation_past_datetime(
--       $executed_at,
--       "EXECUTED_AT",
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
--   fn::validation_past_datetime(
--       d"2026-08-03T08:00:00Z",
--       "EXECUTED_AT",
--       d"2026-08-03T10:00:00Z",
--       false,
--       30m,
--       24h
--   )
--
-- La valeur se trouve deux heures avant la référence.
--
-- Son ancienneté est donc :
--
--   2h
--
-- Validation stricte
-- ------------------
-- La valeur doit être un véritable datetime SurrealDB.
--
-- Exemple accepté :
--
--   d"2026-08-03T08:00:00Z"
--
-- Exemples refusés :
--
--   "2026-08-03T08:00:00Z"
--     chaîne non convertie.
--
--   1785744000
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
--   LET $executed_at = type::datetime(
--       "2026-08-03T08:00:00Z"
--   );
--
--   RETURN fn::validation_past_datetime(
--       $executed_at,
--       "EXECUTED_AT",
--       NONE,
--       false,
--       NONE,
--       NONE
--   );
--
-- Instant de référence
-- --------------------
-- Le paramètre $reference_value détermine l'instant à partir duquel le passé
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
--     d"2026-08-03T08:00:00Z"
--
--   ancienneté :
--     2h
--
-- Une référence explicite est particulièrement utile pour :
--
--   - les tests automatisés ;
--   - les imports ;
--   - les migrations ;
--   - les traitements transactionnels ;
--   - les calculs fondés sur une date métier ;
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
--   <FIELD>_NOT_IN_PAST
--
-- Lorsque $allow_equal vaut true :
--
--   valeur = référence
--
-- est acceptée, sous réserve de l'ancienneté minimale configurée.
--
-- Attention :
--
-- Si $allow_equal vaut true mais que $min_age est supérieure à zéro, l'égalité
-- reste refusée avec :
--
--   <FIELD>_TOO_RECENT
--
-- Ancienneté calculée
-- -------------------
-- Une fois l'ordre temporel validé, l'ancienneté est calculée ainsi :
--
--   $reference - $value
--
-- Exemple :
--
--   d"2026-08-03T10:00:00Z"
--   -
--   d"2026-08-03T07:30:00Z"
--
-- produit :
--
--   2h30m
--
-- Le résultat est une valeur de type duration.
--
-- La soustraction est volontairement effectuée dans cet ordre afin d'obtenir
-- une durée positive ou nulle :
--
--   référence - valeur passée
--
-- Ancienneté minimale
-- -------------------
-- Le paramètre $min_age permet d'imposer une distance temporelle minimale entre
-- la valeur et la référence.
--
-- Exemple :
--
--   $min_age = 18y
--
-- ne doit pas être utilisé directement pour calculer un âge civil, car une
-- année civile n'est pas une durée fixe disponible sous cette forme.
--
-- Pour les âges légaux et calendaires, une validation métier spécialisée sera
-- nécessaire.
--
-- En revanche, une durée fixe comme :
--
--   30m
--   24h
--   7d
--
-- peut être utilisée.
--
-- Exemple :
--
--   $min_age = 30m
--
-- Une valeur située exactement trente minutes avant la référence est acceptée.
--
-- Une valeur située seulement vingt-neuf minutes auparavant produit :
--
--   <FIELD>_TOO_RECENT
--
-- Cette règle peut servir à :
--
--   - imposer qu'une opération soit terminée depuis un certain délai ;
--   - attendre avant une nouvelle tentative ;
--   - vérifier une période minimale de conservation ;
--   - appliquer un délai de sécurité ;
--   - imposer une ancienneté minimale à une donnée technique.
--
-- Ancienneté maximale
-- -------------------
-- Le paramètre $max_age permet de refuser une valeur trop ancienne.
--
-- Exemple :
--
--   $max_age = 30d
--
-- Une valeur située exactement trente jours avant la référence est acceptée.
--
-- Une valeur plus ancienne produit :
--
--   <FIELD>_TOO_OLD
--
-- Cette règle peut servir à :
--
--   - limiter la validité d'un événement passé ;
--   - accepter uniquement un document récent ;
--   - limiter la période d'import ;
--   - vérifier la fraîcheur d'une synchronisation ;
--   - imposer une fenêtre de récupération.
--
-- Ancienneté exacte
-- -----------------
-- Pour exiger une ancienneté exacte, utiliser la même durée pour les deux
-- limites.
--
-- Exemple :
--
--   $min_age = 24h
--   $max_age = 24h
--
-- Seule une valeur située exactement vingt-quatre heures avant la référence
-- sera acceptée.
--
-- Cohérence des limites
-- ----------------------
-- Lorsque les deux limites sont définies, l'ancienneté minimale ne peut pas
-- être supérieure à l'ancienneté maximale.
--
-- Exemple invalide :
--
--   min = 30d
--   max = 7d
--
-- produit :
--
--   VALIDATION_INVALID_PAST_RANGE
--
-- Configuration impossible
-- -------------------------
-- Lorsque $allow_equal vaut false, une ancienneté maximale égale à zéro rend
-- toute valeur impossible :
--
--   - la valeur doit être strictement antérieure à la référence ;
--   - mais son ancienneté ne peut pas dépasser zéro.
--
-- Cette configuration produit :
--
--   VALIDATION_IMPOSSIBLE_PAST_RANGE
--
-- Fuseaux horaires
-- ----------------
-- Les datetimes sont comparés comme des instants réels.
--
-- Une valeur exprimée avec un décalage horaire est comparée selon son instant
-- UTC.
--
-- Exemple :
--
--   d"2026-08-03T10:00:00+02:00"
--
-- représente le même instant que :
--
--   d"2026-08-03T08:00:00Z"
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
--     d"2026-08-03T10:00:00.000000001Z"
--
--   valeur :
--     d"2026-08-03T10:00:00.000000000Z"
--
-- La valeur se trouve une nanoseconde dans le passé.
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
--   LET $started_at = fn::validation_past_datetime(
--       $started_at,
--       "STARTED_AT",
--       $reference_time,
--       false,
--       NONE,
--       NONE
--   );
--
--   LET $completed_at = fn::validation_past_datetime(
--       $completed_at,
--       "COMPLETED_AT",
--       $reference_time,
--       false,
--       NONE,
--       NONE
--   );
--
-- Les deux validations utilisent alors exactement la même référence.
--
-- Différence avec validation_datetime
-- -----------------------------------
-- fn::validation_datetime() vérifie principalement :
--
--   - le type datetime ;
--   - des limites absolues facultatives.
--
-- fn::validation_past_datetime() vérifie :
--
--   - le type datetime ;
--   - la position passée relative à une référence ;
--   - une ancienneté minimale ;
--   - une ancienneté maximale.
--
-- Différence avec validation_date
-- -------------------------------
-- fn::validation_date() représente un jour civil à minuit UTC.
--
-- fn::validation_past_datetime() représente un instant précis qui doit être
-- situé dans le passé.
--
-- Différence avec validation_future_datetime
-- -------------------------------------------
-- fn::validation_future_datetime() impose :
--
--   valeur >= référence
--
-- ou :
--
--   valeur > référence
--
-- fn::validation_past_datetime() impose :
--
--   valeur <= référence
--
-- ou :
--
--   valeur < référence
--
-- Différence avec validation_time_range
-- -------------------------------------
-- fn::validation_time_range() valide deux datetimes formant une plage.
--
-- fn::validation_past_datetime() valide un datetime unique par rapport à une
-- référence.
--
-- Retour de la fonction
-- ----------------------
-- La fonction retourne uniquement le datetime validé.
--
-- Elle ne retourne pas l'ancienneté calculée afin de conserver une primitive
-- facile à chaîner :
--
--   LET $executed_at = fn::validation_past_datetime(...);
--
-- Lorsque l'ancienneté est nécessaire, la fonction métier peut la recalculer :
--
--   LET $age = $reference_time - $executed_at;
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
--   - l'âge civil d'une personne ;
--   - les années calendaires ;
--   - les mois calendaires ;
--   - les jours ouvrés ;
--   - les jours fériés ;
--   - le fuseau horaire métier ;
--   - la cohérence avec une autre date ;
--   - la présence d'un enregistrement ;
--   - l'état d'un événement ;
--   - les permissions liées à la donnée ;
--   - la fiabilité de l'horloge du client.
--
-- Pour une date fournie par un client, l'instant de référence doit provenir du
-- serveur ou de SurrealDB, et non d'une valeur librement contrôlée par ce
-- client.
--
-- Règles appliquées
-- -----------------
--   1. Le nom technique du champ doit être renseigné ;
--   2. L'ancienneté minimale ne doit pas dépasser l'ancienneté maximale ;
--   3. La configuration ne doit pas rendre toute valeur impossible ;
--   4. La valeur doit être présente ;
--   5. La valeur ne doit pas être NULL ;
--   6. La valeur doit être strictement de type datetime ;
--   7. La référence effective est déterminée ;
--   8. La valeur doit être antérieure ou égale à la référence selon la règle ;
--   9. L'ancienneté est calculée ;
--  10. L'ancienneté minimale est contrôlée lorsqu'elle est définie ;
--  11. L'ancienneté maximale est contrôlée lorsqu'elle est définie ;
--  12. Le datetime d'origine est retourné lorsqu'il est valide.
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
--     - EXECUTED_AT
--     - STARTED_AT
--     - COMPLETED_AT
--     - PAID_AT
--     - RECEIVED_AT
--     - SIGNED_AT
--     - LAST_LOGIN_AT
--     - SYNCHRONIZED_AT
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
--     La valeur doit être strictement antérieure à la référence.
--
--   true :
--     La valeur peut être égale à la référence.
--
-- $min_age:
--   Type : option<duration>
--
--   Ancienneté minimale autorisée par rapport à la référence.
--
--   Utiliser NONE lorsqu'aucune ancienneté minimale n'est requise.
--
--   La limite est inclusive.
--
-- $max_age:
--   Type : option<duration>
--
--   Ancienneté maximale autorisée par rapport à la référence.
--
--   Utiliser NONE lorsqu'aucune ancienneté maximale n'est requise.
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
--   fn::validation_past_datetime(
--       d"2026-08-03T08:00:00Z",
--       "EXECUTED_AT",
--       d"2026-08-03T10:00:00Z",
--       false,
--       30m,
--       24h
--   )
--
-- retourne :
--
--   d"2026-08-03T08:00:00Z"
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
-- <FIELD>_NOT_IN_PAST
--   La valeur est postérieure à la référence, ou elle lui est égale alors que
--   l'égalité est interdite.
--
-- <FIELD>_TOO_RECENT
--   La valeur est passée, mais son ancienneté est inférieure au minimum.
--
-- <FIELD>_TOO_OLD
--   La valeur est plus ancienne que la limite maximale.
--
-- VALIDATION_INVALID_FIELD_NAME
--   Le nom technique du champ est vide.
--
-- VALIDATION_INVALID_PAST_RANGE
--   L'ancienneté minimale est supérieure à l'ancienneté maximale.
--
-- VALIDATION_IMPOSSIBLE_PAST_RANGE
--   L'égalité est interdite alors que l'ancienneté maximale vaut zéro.
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
--   - fn::validation_future_datetime()
--   - fn::validation_time_range()
--   - fn::validation_duration()
--
-- Exemples d'utilisation
-- ----------------------
-- Date strictement passée par rapport à maintenant :
--
-- LET $executed_at = fn::validation_past_datetime(
--     $executed_at,
--     "EXECUTED_AT",
--     NONE,
--     false,
--     NONE,
--     NONE
-- );
--
-- Dernière synchronisation datant d'au maximum une heure :
--
-- LET $synchronized_at = fn::validation_past_datetime(
--     $synchronized_at,
--     "SYNCHRONIZED_AT",
--     NONE,
--     true,
--     NONE,
--     1h
-- );
--
-- Événement passé depuis au moins trente minutes :
--
-- LET $completed_at = fn::validation_past_datetime(
--     $completed_at,
--     "COMPLETED_AT",
--     NONE,
--     false,
--     30m,
--     NONE
-- );
--
-- Validation déterministe :
--
-- LET $reference_time = time::now();
--
-- LET $paid_at = fn::validation_past_datetime(
--     $paid_at,
--     "PAID_AT",
--     $reference_time,
--     false,
--     NONE,
--     365d
-- );
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_past_datetime(
    $value: option<any>,
    $field: string,
    $reference_value: option<datetime>,
    $allow_equal: bool,
    $min_age: option<duration>,
    $max_age: option<duration>
) -> datetime {

    -- ------------------------------------------------------------------------
    -- 1. Validation du nom technique du champ
    -- ------------------------------------------------------------------------

    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    -- ------------------------------------------------------------------------
    -- 2. Validation de la cohérence des limites d'ancienneté
    -- ------------------------------------------------------------------------

    IF $min_age IS NOT NONE
        AND $max_age IS NOT NONE
        AND $min_age > $max_age
    {
        THROW "VALIDATION_INVALID_PAST_RANGE";
    };

    -- ------------------------------------------------------------------------
    -- 3. Validation d'une configuration impossible
    -- ------------------------------------------------------------------------
    -- Lorsque l'égalité est interdite, une ancienneté maximale égale à zéro
    -- ne permettrait de valider aucun datetime.

    IF !$allow_equal
        AND $max_age IS NOT NONE
        AND $max_age = 0ns
    {
        THROW "VALIDATION_IMPOSSIBLE_PAST_RANGE";
    };

    -- ------------------------------------------------------------------------
    -- 4. Vérification de la présence de la valeur
    -- ------------------------------------------------------------------------

    IF $value IS NONE {
        THROW string::concat(
            $clean_field,
            "_REQUIRED"
        );
    };

    -- ------------------------------------------------------------------------
    -- 5. Refus explicite de NULL
    -- ------------------------------------------------------------------------

    IF type::is_null($value) {
        THROW string::concat(
            $clean_field,
            "_NULL_NOT_ALLOWED"
        );
    };

    -- ------------------------------------------------------------------------
    -- 6. Vérification stricte du type datetime
    -- ------------------------------------------------------------------------

    IF !type::is_datetime($value) {
        THROW string::concat(
            $clean_field,
            "_INVALID_TYPE"
        );
    };

    -- ------------------------------------------------------------------------
    -- 7. Détermination de l'instant de référence effectif
    -- ------------------------------------------------------------------------
    -- Une référence explicite garantit des validations déterministes.
    --
    -- Lorsqu'elle n'est pas fournie, l'instant courant est utilisé.

    LET $effective_reference = IF $reference_value IS NONE {
        time::now()
    } ELSE {
        $reference_value
    };

    -- ------------------------------------------------------------------------
    -- 8. Vérification de la position passée
    -- ------------------------------------------------------------------------

    IF $allow_equal {

        IF $value > $effective_reference {
            THROW string::concat(
                $clean_field,
                "_NOT_IN_PAST"
            );
        };

    } ELSE {

        IF $value >= $effective_reference {
            THROW string::concat(
                $clean_field,
                "_NOT_IN_PAST"
            );
        };
    };

    -- ------------------------------------------------------------------------
    -- 9. Calcul de l'ancienneté
    -- ------------------------------------------------------------------------
    -- La position temporelle a déjà été validée.
    --
    -- La soustraction produit donc une durée positive ou nulle.

    LET $age = $effective_reference - $value;

    -- ------------------------------------------------------------------------
    -- 10. Validation de l'ancienneté minimale
    -- ------------------------------------------------------------------------

    IF $min_age IS NOT NONE
        AND $age < $min_age
    {
        THROW string::concat(
            $clean_field,
            "_TOO_RECENT"
        );
    };

    -- ------------------------------------------------------------------------
    -- 11. Validation de l'ancienneté maximale
    -- ------------------------------------------------------------------------

    IF $max_age IS NOT NONE
        AND $age > $max_age
    {
        THROW string::concat(
            $clean_field,
            "_TOO_OLD"
        );
    };

    -- ------------------------------------------------------------------------
    -- 12. Retour du datetime validé
    -- ------------------------------------------------------------------------

    RETURN $value;
}
COMMENT "
Valide qu'une valeur obligatoire est strictement de type datetime et se situe
dans le passé par rapport à une référence explicite ou à time::now(). Permet
d'autoriser l'égalité et de contrôler facultativement une ancienneté minimale
et maximale. Retourne le datetime d'origine sans transformation.
"
PERMISSIONS FULL;