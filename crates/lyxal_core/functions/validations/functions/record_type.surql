-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/record_type.surql
-- Fonction     : fn::validation_record_type
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Vérifie qu'une valeur obligatoire est strictement un Record ID natif
-- SurrealDB et qu'elle appartient à la table attendue.
--
-- Cette fonction est destinée aux valeurs déjà typées comme record.
--
-- Exemple accepté :
--
--   booking_team:team_001
--
-- Exemple refusé :
--
--   "booking_team:team_001"
--
-- La chaîne possède visuellement le même contenu, mais elle reste de type
-- string. Cette fonction n'effectue volontairement aucune conversion.
--
-- Pour convertir une chaîne ou un identifiant simple en Record ID, utiliser :
--
--   fn::validation_record()
--
-- Différence avec validation_record
-- ----------------------------------
-- fn::validation_record() :
--
--   - accepte une chaîne ;
--   - accepte un identifiant simple ;
--   - accepte une chaîne table:id ;
--   - construit un Record ID normalisé.
--
-- fn::validation_record_type() :
--
--   - accepte uniquement un Record ID natif ;
--   - refuse les chaînes ;
--   - vérifie que le Record ID appartient à la table attendue ;
--   - retourne le Record ID d'origine.
--
-- Exemple :
--
--   fn::validation_record(
--       "team_001",
--       "TEAM_ID",
--       "booking_team"
--   )
--
-- retourne :
--
--   booking_team:team_001
--
-- Puis :
--
--   fn::validation_record_type(
--       booking_team:team_001,
--       "TEAM_ID",
--       "booking_team"
--   )
--
-- confirme que la valeur est bien un Record ID de la table booking_team.
--
-- Cas d'utilisation
-- -----------------
-- Cette fonction est adaptée aux paramètres internes déjà typés :
--
--   - identifiant d'équipe ;
--   - identifiant utilisateur ;
--   - identifiant d'espace de travail ;
--   - identifiant de réservation ;
--   - identifiant d'événement ;
--   - identifiant de document ;
--   - identifiant de ressource ;
--   - relation entre enregistrements.
--
-- Elle est particulièrement utile après :
--
--   - une lecture SurrealDB ;
--   - une relation ;
--   - une fonction retournant un record ;
--   - une extraction depuis un objet déjà typé ;
--   - une conversion explicite avec type::record().
--
-- Validation stricte
-- ------------------
-- La fonction accepte uniquement une valeur de type record.
--
-- Exemples acceptés :
--
--   booking_team:team_001
--   identity_user:user_001
--   core_workspace:workspace_001
--
-- Exemples refusés :
--
--   "booking_team:team_001"
--   "team_001"
--   NONE
--   NULL
--   42
--   true
--   {}
--   []
--
-- Vérification de la table
-- ------------------------
-- La fonction vérifie également que le Record ID appartient exactement à la
-- table attendue.
--
-- Exemple :
--
--   valeur reçue :
--     identity_user:user_001
--
--   table attendue :
--     booking_team
--
-- produit :
--
--   TEAM_ID_INVALID_TABLE
--
-- Cette vérification évite notamment qu'un identifiant d'un autre domaine soit
-- utilisé accidentellement dans une fonction métier.
--
-- Contrôle d'existence
-- --------------------
-- Cette fonction ne vérifie pas que l'enregistrement existe réellement.
--
-- Un Record ID peut être syntaxiquement et typologiquement valide sans qu'un
-- enregistrement correspondant soit présent dans la base.
--
-- Pour contrôler l'existence, utiliser ensuite :
--
--   fn::validation_record_exists()
--
-- Enchaînement recommandé :
--
--   LET $team_id = fn::validation_record_type(
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
-- Règles appliquées
-- -----------------
--   1. Le nom technique du champ doit être renseigné ;
--   2. Le nom de la table attendue doit être renseigné ;
--   3. La valeur doit être présente ;
--   4. La valeur ne doit pas être NULL ;
--   5. La valeur doit être strictement de type record ;
--   6. Le Record ID doit appartenir à la table attendue ;
--   7. Le Record ID d'origine est retourné lorsqu'il est valide.
--
-- Paramètres
-- ----------
-- $value:
--   Type : option<any>
--
--   Valeur obligatoire à contrôler.
--
--   Le type option<any> permet de produire des erreurs métier explicites pour :
--
--     - une valeur absente ;
--     - une valeur NULL ;
--     - un type incorrect ;
--     - un Record ID appartenant à une autre table.
--
-- $field:
--   Type : string
--
--   Nom technique du champ utilisé pour construire les codes d'erreur.
--
--   Convention recommandée :
--
--     - TEAM_ID
--     - USER_ID
--     - WORKSPACE_ID
--     - BOOKING_ID
--     - EVENT_ID
--     - DOCUMENT_ID
--
-- $expected_table:
--   Type : string
--
--   Nom exact de la table SurrealDB attendue.
--
--   Exemples :
--
--     booking_team
--     identity_user
--     core_workspace
--     booking_event
--
-- Valeur retournée
-- ----------------
-- Type : record
--
-- Retourne le Record ID d'origine sans conversion ni modification.
--
-- Exemple :
--
--   fn::validation_record_type(
--       booking_team:team_001,
--       "TEAM_ID",
--       "booking_team"
--   )
--
-- retourne :
--
--   booking_team:team_001
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
--   La valeur fournie n'est pas de type record.
--
-- <FIELD>_INVALID_TABLE
--   Le Record ID appartient à une table différente de la table attendue.
--
-- VALIDATION_INVALID_FIELD_NAME
--   Le nom technique du champ est vide ou composé uniquement d'espaces.
--
-- VALIDATION_INVALID_TABLE_NAME
--   Le nom de la table attendue est vide ou composé uniquement d'espaces.
--
-- Permissions
-- -----------
-- PERMISSIONS FULL
--
-- Cette fonction est une primitive pure :
--
--   - elle ne lit aucune table ;
--   - elle ne vérifie pas l'existence de l'enregistrement ;
--   - elle ne crée aucune donnée ;
--   - elle ne modifie aucune donnée ;
--   - elle ne supprime aucune donnée ;
--   - elle ne dépend pas du contexte d'authentification ;
--   - elle agit uniquement sur ses paramètres ;
--   - elle ne possède aucun effet secondaire.
--
-- Elle peut donc être appelée par toutes les fonctions métier autorisées.
--
-- Le fait qu'un Record ID soit valide et appartienne à la bonne table ne
-- signifie pas que l'utilisateur est autorisé à accéder à l'enregistrement.
--
-- Les contrôles d'autorisation restent sous la responsabilité :
--
--   - des permissions de table ;
--   - des fonctions métier ;
--   - des fonctions core/security.
--
-- Dépendances natives SurrealDB
-- -----------------------------
--   - string::trim()
--   - string::concat()
--   - type::is_null()
--   - type::is_record()
--   - record::tb()
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.
--
-- Ordre de chargement
-- -------------------
-- Cette fonction est autonome et peut être importée indépendamment.
--
-- Il est toutefois recommandé de charger les fonctions liées aux Record IDs
-- dans l'ordre logique suivant :
--
--   1. record.surql
--   2. record_type.surql
--   3. record_exists.surql
--
-- Exemples d'utilisation
-- ----------------------
-- Validation d'un Record ID d'équipe :
--
-- LET $team_id = fn::validation_record_type(
--     $team_id,
--     "TEAM_ID",
--     "booking_team"
-- );
--
-- Validation puis contrôle d'existence :
--
-- LET $user_id = fn::validation_record_type(
--     $user_id,
--     "USER_ID",
--     "identity_user"
-- );
--
-- LET $user_id = fn::validation_record_exists(
--     $user_id,
--     "USER_ID"
-- );
--
-- Validation après conversion explicite :
--
-- LET $team_id = type::record(
--     "booking_team",
--     "team_001"
-- );
--
-- LET $team_id = fn::validation_record_type(
--     $team_id,
--     "TEAM_ID",
--     "booking_team"
-- );
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_record_type(
    $value: option<any>,
    $field: string,
    $expected_table: string
) -> record {

    -- ------------------------------------------------------------------------
    -- 1. Validation du nom technique du champ
    -- ------------------------------------------------------------------------

    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    -- ------------------------------------------------------------------------
    -- 2. Validation du nom de la table attendue
    -- ------------------------------------------------------------------------

    LET $clean_table = string::trim($expected_table);

    IF $clean_table = "" {
        THROW "VALIDATION_INVALID_TABLE_NAME";
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
    -- 5. Vérification stricte du type record
    -- ------------------------------------------------------------------------
    -- Cette première vérification permet de distinguer clairement :
    --
    --   - un Record ID natif ;
    --   - une chaîne ayant la forme table:id ;
    --   - tout autre type SurrealDB.

    IF !type::is_record($value) {
        THROW string::concat(
            $clean_field,
            "_INVALID_TYPE"
        );
    };

    -- ------------------------------------------------------------------------
    -- 6. Vérification de la table du Record ID
    -- ------------------------------------------------------------------------
    -- record::tb() extrait le nom de table du Record ID.
    --
    -- Exemple :
    --
    --   record::tb(booking_team:team_001)
    --
    -- retourne :
    --
    --   "booking_team"

    LET $received_table = record::tb($value);

    IF $received_table != $clean_table {
        THROW string::concat(
            $clean_field,
            "_INVALID_TABLE"
        );
    };

    -- ------------------------------------------------------------------------
    -- 7. Vérification défensive avec type::is_record et table attendue
    -- ------------------------------------------------------------------------
    -- SurrealDB permet également de vérifier directement qu'une valeur est un
    -- Record ID appartenant à une table déterminée.
    --
    -- Cette vérification complète celle réalisée avec record::tb().

    IF !type::is_record(
        $value,
        $clean_table
    ) {
        THROW string::concat(
            $clean_field,
            "_INVALID_TABLE"
        );
    };

    -- ------------------------------------------------------------------------
    -- 8. Retour du Record ID validé
    -- ------------------------------------------------------------------------

    RETURN $value;
}
COMMENT "
Valide qu'une valeur obligatoire est strictement un Record ID natif SurrealDB
et qu'elle appartient à la table attendue. Refuse les chaînes, NONE, NULL et
les Record IDs provenant d'une autre table. Ne contrôle pas l'existence réelle
de l'enregistrement.
"
PERMISSIONS FULL;