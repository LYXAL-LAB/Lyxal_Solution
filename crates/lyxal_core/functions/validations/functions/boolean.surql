-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/boolean.surql
-- Fonction     : fn::validation_boolean
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Vérifie qu'une valeur obligatoire est strictement de type booléen.
--
-- Cette fonction accepte uniquement les deux valeurs booléennes natives :
--
--   - true
--   - false
--
-- Elle refuse toute autre représentation, notamment :
--
--   - "true"
--   - "false"
--   - 1
--   - 0
--   - "1"
--   - "0"
--   - NONE
--
-- Cette validation stricte évite les conversions implicites et garantit que
-- la fonction métier reçoit une véritable valeur booléenne SurrealDB.
--
-- Cette fonction est adaptée aux champs comme :
--
--   - enabled ;
--   - active ;
--   - visible ;
--   - archived ;
--   - deleted ;
--   - confirmed ;
--   - public ;
--   - required ;
--   - allow_guests ;
--   - send_notification.
--
-- Validation stricte
-- ------------------
-- La fonction ne tente jamais de convertir la valeur reçue.
--
-- Ainsi :
--
--   true
--     est accepté.
--
--   false
--     est accepté.
--
--   "true"
--     est refusé, car il s'agit d'une chaîne.
--
--   1
--     est refusé, car il s'agit d'un entier.
--
-- Une éventuelle conversion de chaînes ou d'entiers en booléens devra être
-- réalisée par une future fonction distincte du domaine core/sanitize ou
-- core/conversion.
--
-- Règles appliquées
-- -----------------
--   1. Le nom technique du champ doit être renseigné ;
--   2. La valeur doit être présente ;
--   3. La valeur doit être strictement de type bool ;
--   4. La valeur booléenne d'origine est retournée lorsqu'elle est valide.
--
-- Paramètres
-- ----------
-- $value:
--   Type : option<any>
--
--   Valeur obligatoire à contrôler.
--
--   Le type option<any> permet :
--
--     - de détecter explicitement une valeur NONE ;
--     - de détecter les types incorrects ;
--     - de retourner des codes d'erreur métier stables.
--
-- $field:
--   Type : string
--
--   Nom technique du champ utilisé pour construire les codes d'erreur.
--
--   Convention recommandée :
--
--     - ENABLED
--     - ACTIVE
--     - VISIBLE
--     - ARCHIVED
--     - IS_PUBLIC
--     - ALLOW_GUESTS
--     - SEND_NOTIFICATION
--
-- Valeur retournée
-- ----------------
-- Type : bool
--
-- Retourne la valeur booléenne d'origine sans modification.
--
-- Exemples :
--
--   fn::validation_boolean(
--       true,
--       "ENABLED"
--   )
--
-- retourne :
--
--   true
--
-- Erreurs générées
-- ----------------
-- <FIELD>_REQUIRED
--   La valeur est absente ou égale à NONE.
--
-- <FIELD>_INVALID_TYPE
--   La valeur fournie n'est pas de type bool.
--
-- VALIDATION_INVALID_FIELD_NAME
--   Le nom technique du champ est vide ou composé uniquement d'espaces.
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
-- Les autorisations relatives au champ validé restent sous la responsabilité
-- de la fonction métier appelante.
--
-- Dépendances natives SurrealDB
-- -----------------------------
--   - string::trim()
--   - string::concat()
--   - type::is_bool()
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
-- LET $enabled = fn::validation_boolean(
--     $enabled,
--     "ENABLED"
-- );
--
-- LET $allow_guests = fn::validation_boolean(
--     $allow_guests,
--     "ALLOW_GUESTS"
-- );
--
-- LET $send_notification = fn::validation_boolean(
--     $send_notification,
--     "SEND_NOTIFICATION"
-- );
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_boolean(
    $value: option<any>,
    $field: string
) -> bool {

    -- ------------------------------------------------------------------------
    -- 1. Validation du nom technique du champ
    -- ------------------------------------------------------------------------

    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    -- ------------------------------------------------------------------------
    -- 2. Vérification de la présence de la valeur
    -- ------------------------------------------------------------------------

    IF $value IS NONE {
        THROW string::concat(
            $clean_field,
            "_REQUIRED"
        );
    };

    -- ------------------------------------------------------------------------
    -- 3. Vérification stricte du type booléen
    -- ------------------------------------------------------------------------

    IF !type::is_bool($value) {
        THROW string::concat(
            $clean_field,
            "_INVALID_TYPE"
        );
    };

    -- ------------------------------------------------------------------------
    -- 4. Retour de la valeur booléenne validée
    -- ------------------------------------------------------------------------

    RETURN $value;
}
COMMENT "
Valide qu'une valeur obligatoire est strictement de type bool. Retourne la
valeur booléenne d'origine lorsqu'elle est valide ou interrompt l'exécution
avec un code d'erreur stable construit à partir du nom technique du champ.
"
PERMISSIONS FULL;