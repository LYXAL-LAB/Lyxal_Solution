-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/datetime.surql
-- Fonction     : fn::validation_datetime
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Vérifie qu'une valeur obligatoire est strictement de type datetime.
--
-- Cette fonction permet également d'appliquer facultativement :
--
--   - une date et heure minimale ;
--   - une date et heure maximale ;
--   - une plage comprise entre deux valeurs datetime.
--
-- Elle est destinée aux champs temporels tels que :
--
--   - une date de début ;
--   - une date de fin ;
--   - une date de réservation ;
--   - une date d'expiration ;
--   - une date de publication ;
--   - une échéance ;
--   - une date d'exécution ;
--   - une date de rappel ;
--   - une date d'activation ;
--   - une date d'archivage.
--
-- Validation stricte
-- ------------------
-- Cette fonction n'effectue aucune conversion automatique.
--
-- Exemples :
--
--   d"2026-08-01T10:00:00Z"
--     accepté, car la valeur est de type datetime.
--
--   "2026-08-01T10:00:00Z"
--     refusé, car la valeur est une chaîne.
--
--   1754042400
--     refusé, car la valeur est un entier.
--
--   NONE
--     refusé, car cette fonction valide un champ obligatoire.
--
-- Une éventuelle conversion depuis une chaîne, un timestamp ou un autre
-- format devra être réalisée par une fonction distincte du domaine
-- core/sanitize ou core/conversion.
--
-- Cette fonction doit uniquement valider une valeur datetime déjà construite.
--
-- Comparaison temporelle
-- ----------------------
-- Les limites minimale et maximale sont inclusives.
--
-- Ainsi :
--
--   - une valeur égale à $min_value est acceptée ;
--   - une valeur égale à $max_value est acceptée ;
--   - une valeur antérieure à $min_value est refusée ;
--   - une valeur postérieure à $max_value est refusée.
--
-- Les valeurs datetime SurrealDB sont comparées chronologiquement.
--
-- Règles appliquées
-- -----------------
--   1. Le nom technique du champ doit être renseigné ;
--   2. La limite minimale doit être un datetime lorsqu'elle est définie ;
--   3. La limite maximale doit être un datetime lorsqu'elle est définie ;
--   4. La limite minimale ne doit pas être postérieure à la limite maximale ;
--   5. La valeur doit être présente ;
--   6. La valeur doit être strictement de type datetime ;
--   7. La valeur doit respecter la limite minimale lorsqu'elle est définie ;
--   8. La valeur doit respecter la limite maximale lorsqu'elle est définie ;
--   9. La valeur datetime d'origine est retournée lorsqu'elle est valide.
--
-- Paramètres
-- ----------
-- $value:
--   Type : option<any>
--
--   Valeur obligatoire à contrôler.
--
--   Le type option<any> permet à la fonction :
--
--     - de détecter explicitement une valeur NONE ;
--     - de détecter une valeur d'un type incorrect ;
--     - de retourner des codes d'erreur métier stables.
--
--   La fonction attend une véritable valeur datetime SurrealDB :
--
--     d"2026-08-01T10:00:00Z"
--
-- $field:
--   Type : string
--
--   Nom technique du champ utilisé pour construire les codes d'erreur.
--
--   Convention recommandée :
--
--     - START_AT
--     - END_AT
--     - EXPIRES_AT
--     - PUBLISHED_AT
--     - SCHEDULED_AT
--     - REMINDER_AT
--     - DEADLINE_AT
--
-- $min_value:
--   Type : option<datetime>
--
--   Date et heure minimale autorisée.
--
--   Utiliser NONE lorsqu'aucune limite minimale n'est requise.
--
--   La limite est inclusive.
--
-- $max_value:
--   Type : option<datetime>
--
--   Date et heure maximale autorisée.
--
--   Utiliser NONE lorsqu'aucune limite maximale n'est requise.
--
--   La limite est inclusive.
--
-- Valeur retournée
-- ----------------
-- Type : datetime
--
-- Retourne la valeur datetime d'origine sans conversion ni modification.
--
-- Exemple :
--
--   fn::validation_datetime(
--       d"2026-08-10T14:00:00Z",
--       "START_AT",
--       d"2026-08-01T00:00:00Z",
--       d"2026-08-31T23:59:59Z"
--   )
--
-- retourne :
--
--   d"2026-08-10T14:00:00Z"
--
-- Erreurs générées
-- ----------------
-- <FIELD>_REQUIRED
--   La valeur est absente ou égale à NONE.
--
-- <FIELD>_INVALID_TYPE
--   La valeur fournie n'est pas de type datetime.
--
-- <FIELD>_TOO_EARLY
--   La valeur est antérieure à la limite minimale.
--
-- <FIELD>_TOO_LATE
--   La valeur est postérieure à la limite maximale.
--
-- VALIDATION_INVALID_FIELD_NAME
--   Le nom technique du champ est vide ou composé uniquement d'espaces.
--
-- VALIDATION_INVALID_DATETIME_RANGE
--   La limite minimale est postérieure à la limite maximale.
--
-- Permissions
-- -----------
-- PERMISSIONS FULL
--
-- Cette fonction est une primitive pure :
--
--   - elle ne lit aucune table ;
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
-- Les autorisations relatives au champ temporel validé restent sous la
-- responsabilité de la fonction métier appelante.
--
-- Dépendances natives SurrealDB
-- -----------------------------
--   - string::trim()
--   - string::concat()
--   - type::is_datetime()
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
-- Date sans limites :
--
-- LET $published_at = fn::validation_datetime(
--     $published_at,
--     "PUBLISHED_AT",
--     NONE,
--     NONE
-- );
--
-- Date ne pouvant pas être antérieure à maintenant :
--
-- LET $scheduled_at = fn::validation_datetime(
--     $scheduled_at,
--     "SCHEDULED_AT",
--     time::now(),
--     NONE
-- );
--
-- Date comprise dans une période :
--
-- LET $start_at = fn::validation_datetime(
--     $start_at,
--     "START_AT",
--     d"2026-08-01T00:00:00Z",
--     d"2026-08-31T23:59:59Z"
-- );
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_datetime(
    $value: option<any>,
    $field: string,
    $min_value: option<datetime>,
    $max_value: option<datetime>
) -> datetime {

    -- ------------------------------------------------------------------------
    -- 1. Validation du nom technique du champ
    -- ------------------------------------------------------------------------

    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    -- ------------------------------------------------------------------------
    -- 2. Validation de la cohérence de la plage temporelle
    -- ------------------------------------------------------------------------
    -- Lorsque les deux limites sont définies, la borne minimale ne peut pas
    -- être postérieure à la borne maximale.

    IF $min_value IS NOT NONE
        AND $max_value IS NOT NONE
        AND $min_value > $max_value
    {
        THROW "VALIDATION_INVALID_DATETIME_RANGE";
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
    -- 4. Vérification stricte du type datetime
    -- ------------------------------------------------------------------------
    -- La fonction refuse notamment :
    --
    --   - les chaînes ISO 8601 ;
    --   - les timestamps numériques ;
    --   - les durées ;
    --   - les objets ;
    --   - toute valeur qui n'est pas déjà un datetime SurrealDB.

    IF !type::is_datetime($value) {
        THROW string::concat(
            $clean_field,
            "_INVALID_TYPE"
        );
    };

    -- ------------------------------------------------------------------------
    -- 5. Validation de la limite minimale
    -- ------------------------------------------------------------------------

    IF $min_value IS NOT NONE
        AND $value < $min_value
    {
        THROW string::concat(
            $clean_field,
            "_TOO_EARLY"
        );
    };

    -- ------------------------------------------------------------------------
    -- 6. Validation de la limite maximale
    -- ------------------------------------------------------------------------

    IF $max_value IS NOT NONE
        AND $value > $max_value
    {
        THROW string::concat(
            $clean_field,
            "_TOO_LATE"
        );
    };

    -- ------------------------------------------------------------------------
    -- 7. Retour de la valeur datetime validée
    -- ------------------------------------------------------------------------

    RETURN $value;
}
COMMENT "
Valide qu'une valeur obligatoire est strictement de type datetime. Contrôle
facultativement ses limites temporelles minimale et maximale et retourne la
valeur datetime d'origine lorsqu'elle est valide.
"
PERMISSIONS FULL;