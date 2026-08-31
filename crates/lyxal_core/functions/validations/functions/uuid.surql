-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/uuid.surql
-- Fonction     : fn::validation_uuid
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Vérifie qu'une valeur obligatoire est strictement de type uuid SurrealDB.
--
-- Cette fonction accepte uniquement une véritable valeur UUID native :
--
--   u"018a6680-bef9-701b-9025-e1754f296a0f"
--
-- Elle refuse notamment :
--
--   - une chaîne contenant un UUID ;
--   - un Record ID ;
--   - un entier ;
--   - un objet ;
--   - un tableau ;
--   - une valeur NONE ;
--   - une valeur NULL.
--
-- Cette fonction est destinée aux champs utilisant un UUID comme identifiant
-- technique indépendant d'un Record ID SurrealDB.
--
-- Exemples de champs concernés :
--
--   - identifiant public ;
--   - identifiant de corrélation ;
--   - identifiant de requête ;
--   - identifiant de trace ;
--   - identifiant d'idempotence ;
--   - identifiant d'import ;
--   - identifiant d'exécution ;
--   - identifiant d'événement ;
--   - identifiant provenant d'un système externe.
--
-- Validation stricte
-- ------------------
-- Cette fonction ne convertit jamais une chaîne en UUID.
--
-- Exemple accepté :
--
--   u"018a6680-bef9-701b-9025-e1754f296a0f"
--
-- Exemple refusé :
--
--   "018a6680-bef9-701b-9025-e1754f296a0f"
--
-- Cette séparation est volontaire.
--
-- Une conversion explicite pourra être réalisée auparavant par :
--
--   type::uuid($value)
--
-- ou par une future fonction du domaine :
--
--   core/conversion
--
-- La présente fonction doit uniquement vérifier qu'une valeur est déjà
-- correctement typée.
--
-- Différence entre UUID et Record ID
-- ----------------------------------
-- Un UUID est une valeur autonome :
--
--   u"018a6680-bef9-701b-9025-e1754f296a0f"
--
-- Un Record ID identifie un enregistrement dans une table :
--
--   booking_team:team_001
--
-- Pour contrôler un Record ID, utiliser :
--
--   fn::validation_record()
--
-- Pour vérifier qu'un Record ID existe, utiliser :
--
--   fn::validation_record_exists()
--
-- Cette fonction ne vérifie pas :
--
--   - l'existence d'un enregistrement ;
--   - l'unicité de l'UUID dans une table ;
--   - une version particulière d'UUID ;
--   - l'origine ou la sécurité de génération de l'UUID ;
--   - l'association de l'UUID à une ressource.
--
-- Règles appliquées
-- -----------------
--   1. Le nom technique du champ doit être renseigné ;
--   2. La valeur doit être présente ;
--   3. La valeur ne doit pas être NULL ;
--   4. La valeur doit être strictement de type uuid ;
--   5. La valeur UUID d'origine est retournée lorsqu'elle est valide.
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
--     - de détecter une valeur NONE ;
--     - de détecter une valeur NULL ;
--     - de détecter une valeur d'un type incorrect ;
--     - de retourner des codes d'erreur métier stables.
--
-- $field:
--   Type : string
--
--   Nom technique du champ utilisé pour construire les codes d'erreur.
--
--   Convention recommandée :
--
--     - PUBLIC_ID
--     - REQUEST_ID
--     - CORRELATION_ID
--     - TRACE_ID
--     - IDEMPOTENCY_KEY
--     - EXECUTION_ID
--     - EXTERNAL_ID
--
-- Valeur retournée
-- ----------------
-- Type : uuid
--
-- Retourne la valeur UUID d'origine sans conversion ni modification.
--
-- Exemple :
--
--   fn::validation_uuid(
--       u"018a6680-bef9-701b-9025-e1754f296a0f",
--       "PUBLIC_ID"
--   )
--
-- retourne :
--
--   u"018a6680-bef9-701b-9025-e1754f296a0f"
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
--   La valeur fournie n'est pas de type uuid.
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
-- Les autorisations relatives à l'utilisation du champ validé restent sous la
-- responsabilité de la fonction métier appelante.
--
-- Dépendances natives SurrealDB
-- -----------------------------
--   - string::trim()
--   - string::concat()
--   - type::is_null()
--   - type::is_uuid()
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
-- Validation d'un identifiant public :
--
-- LET $public_id = fn::validation_uuid(
--     $public_id,
--     "PUBLIC_ID"
-- );
--
-- Validation d'un identifiant de corrélation :
--
-- LET $correlation_id = fn::validation_uuid(
--     $correlation_id,
--     "CORRELATION_ID"
-- );
--
-- Validation après conversion explicite :
--
-- LET $converted_uuid = type::uuid($uuid_string);
--
-- LET $validated_uuid = fn::validation_uuid(
--     $converted_uuid,
--     "EXTERNAL_ID"
-- );
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_uuid(
    $value: option<any>,
    $field: string
) -> uuid {

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
    -- 3. Refus explicite de NULL
    -- ------------------------------------------------------------------------
    -- NONE représente l'absence de valeur.
    -- NULL représente une valeur explicitement vide.
    --
    -- Les deux états sont distingués afin de fournir un code d'erreur précis.

    IF type::is_null($value) {
        THROW string::concat(
            $clean_field,
            "_NULL_NOT_ALLOWED"
        );
    };

    -- ------------------------------------------------------------------------
    -- 4. Vérification stricte du type uuid
    -- ------------------------------------------------------------------------
    -- type::is_uuid() accepte uniquement une véritable valeur uuid.
    --
    -- Une chaîne ayant la forme d'un UUID reste une chaîne et est refusée.

    IF !type::is_uuid($value) {
        THROW string::concat(
            $clean_field,
            "_INVALID_TYPE"
        );
    };

    -- ------------------------------------------------------------------------
    -- 5. Retour de la valeur UUID validée
    -- ------------------------------------------------------------------------

    RETURN $value;
}
COMMENT "
Valide qu'une valeur obligatoire est strictement de type uuid SurrealDB.
Refuse NONE, NULL et toute autre représentation, notamment les chaînes
contenant un UUID. Retourne la valeur UUID d'origine lorsqu'elle est valide.
"
PERMISSIONS FULL;