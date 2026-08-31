-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/record_exists.surql
-- Fonction     : fn::validation_record_exists
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Vérifie qu'un identifiant d'enregistrement SurrealDB correspond à un
-- enregistrement existant dans la base de données.
--
-- Cette fonction doit être utilisée après la validation et la normalisation
-- du Record ID par :
--
--   fn::validation_record()
--
-- Exemple d'enchaînement :
--
--   LET $team_id = fn::validation_record(
--       $team_id,
--       "TEAM_ID",
--       "booking_team"
--   );
--
--   LET $team_id = fn::validation_record_exists(
--       $team_id,
--       "TEAM_ID"
--   );
--
-- La première fonction vérifie :
--
--   - la présence de l'identifiant ;
--   - son format ;
--   - la table attendue ;
--   - sa conversion en type record.
--
-- La présente fonction vérifie ensuite :
--
--   - l'existence réelle de l'enregistrement.
--
-- La fonction ne retourne pas le contenu de l'enregistrement. Elle retourne
-- uniquement le Record ID reçu lorsqu'il existe.
--
-- Cette séparation permet à la fonction appelante d'utiliser ensuite le
-- Record ID dans une lecture, une relation, une mise à jour ou une suppression.
--
-- Règles appliquées
-- -----------------
--   1. Le nom technique du champ doit être renseigné ;
--   2. Le Record ID reçu doit être valide selon son type ;
--   3. record::exists() vérifie la présence de l'enregistrement ;
--   4. Une erreur est levée lorsque l'enregistrement n'existe pas ;
--   5. Le Record ID d'origine est retourné lorsqu'il existe.
--
-- Paramètres
-- ----------
-- $value:
--   Type : record
--
--   Record ID SurrealDB dont l'existence doit être vérifiée.
--
--   Exemples :
--
--     booking_team:team_001
--     identity_user:user_001
--     core_workspace:workspace_001
--
--   La fonction attend déjà une valeur de type record et non une chaîne.
--
--   Pour une valeur reçue sous forme de chaîne, utiliser préalablement :
--
--     fn::validation_record()
--
-- $field:
--   Type : string
--
--   Nom technique du champ utilisé pour construire le code d'erreur.
--
--   Convention recommandée :
--
--     - TEAM_ID
--     - USER_ID
--     - WORKSPACE_ID
--     - BOOKING_ID
--     - EVENT_ID
--
-- Valeur retournée
-- ----------------
-- Type : record
--
-- Retourne le Record ID d'origine lorsque l'enregistrement existe.
--
-- Exemple :
--
--   fn::validation_record_exists(
--       booking_team:team_001,
--       "TEAM_ID"
--   )
--
-- retourne :
--
--   booking_team:team_001
--
-- Erreurs générées
-- ----------------
-- <FIELD>_NOT_FOUND
--   Aucun enregistrement correspondant au Record ID n'existe.
--
-- VALIDATION_INVALID_FIELD_NAME
--   Le nom technique du champ est vide ou composé uniquement d'espaces.
--
-- Permissions
-- -----------
-- PERMISSIONS FULL
--
-- Cette fonction doit être accessible aux fonctions métier qui valident les
-- références reçues dans leurs paramètres.
--
-- Elle :
--
--   - ne crée aucun enregistrement ;
--   - ne modifie aucune donnée ;
--   - ne supprime aucune donnée ;
--   - ne retourne pas le contenu de l'enregistrement ;
--   - retourne uniquement le Record ID reçu lorsqu'il existe.
--
-- Attention :
--
-- La fonction révèle indirectement si un Record ID existe. Les fonctions
-- métier appelantes doivent donc vérifier les autorisations de l'utilisateur
-- avant d'exposer une opération portant sur une ressource sensible.
--
-- La présence d'un enregistrement ne signifie pas que l'utilisateur est
-- autorisé à le consulter, le modifier ou le supprimer.
--
-- Les contrôles d'autorisation restent sous la responsabilité :
--
--   - des permissions de table ;
--   - des fonctions métier ;
--   - des futures fonctions core/security.
--
-- Dépendances natives SurrealDB
-- -----------------------------
--   - string::trim()
--   - string::concat()
--   - record::exists()
--
-- Dépendances Lyxal
-- -----------------
-- Aucune dépendance technique obligatoire.
--
-- Dans l'utilisation normale, cette fonction est appelée après :
--
--   fn::validation_record()
--
-- Ordre de chargement
-- -------------------
-- Cette fonction peut être chargée indépendamment.
--
-- Il est toutefois recommandé de respecter l'ordre logique suivant :
--
--   1. record.surql
--   2. record_exists.surql
--
-- Exemples d'utilisation
-- ----------------------
-- LET $team_id = fn::validation_record(
--     $team_id,
--     "TEAM_ID",
--     "booking_team"
-- );
--
-- LET $team_id = fn::validation_record_exists(
--     $team_id,
--     "TEAM_ID"
-- );
--
-- RETURN $team_id;
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_record_exists(
    $value: record,
    $field: string
) -> record {

    -- ------------------------------------------------------------------------
    -- 1. Validation du nom technique du champ
    -- ------------------------------------------------------------------------

    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    -- ------------------------------------------------------------------------
    -- 2. Vérification de l'existence de l'enregistrement
    -- ------------------------------------------------------------------------
    -- record::exists() retourne :
    --
    --   true  lorsque l'enregistrement existe ;
    --   false lorsqu'aucun enregistrement ne correspond au Record ID.

    LET $record_exists = record::exists($value);

    IF !$record_exists {
        THROW string::concat(
            $clean_field,
            "_NOT_FOUND"
        );
    };

    -- ------------------------------------------------------------------------
    -- 3. Retour du Record ID validé
    -- ------------------------------------------------------------------------

    RETURN $value;
}
COMMENT "
Vérifie qu'un Record ID SurrealDB correspond à un enregistrement existant.
Retourne le Record ID reçu lorsqu'il existe ou interrompt l'exécution avec un
code d'erreur stable construit à partir du nom technique du champ.
"
PERMISSIONS FULL;