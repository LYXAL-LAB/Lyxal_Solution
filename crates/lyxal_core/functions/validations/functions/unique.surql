-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/unique.surql
-- Fonction     : fn::validation_unique
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Vérifie qu'une valeur n'existe pas déjà dans un champ déterminé d'une table
-- SurrealDB.
--
-- Cette fonction constitue une validation générique d'unicité applicative.
--
-- Elle peut notamment être utilisée pour contrôler :
--
--   - une adresse e-mail ;
--   - un slug ;
--   - un nom d'utilisateur ;
--   - une référence commerciale ;
--   - un identifiant externe ;
--   - un numéro de téléphone ;
--   - un code métier ;
--   - une clé d'idempotence ;
--   - un identifiant public.
--
-- Exemple de création
-- -------------------
-- Lors de la création d'un enregistrement, aucun Record ID n'est exclu :
--
--   LET $email = fn::validation_unique(
--       $email,
--       "USER_EMAIL",
--       "identity_user",
--       "email",
--       NONE
--   );
--
-- La fonction recherche alors tout enregistrement dont le champ email possède
-- déjà la valeur reçue.
--
-- Exemple de mise à jour
-- ----------------------
-- Lors de la modification d'un enregistrement, celui-ci doit être exclu de la
-- recherche.
--
-- Exemple :
--
--   LET $email = fn::validation_unique(
--       $email,
--       "USER_EMAIL",
--       "identity_user",
--       "email",
--       identity_user:user_001
--   );
--
-- Si identity_user:user_001 possède déjà cette adresse, aucune erreur n'est
-- produite.
--
-- En revanche, si un autre enregistrement possède la même adresse, la fonction
-- produit :
--
--   USER_EMAIL_ALREADY_EXISTS
--
-- Fonctionnement de la recherche
-- ------------------------------
-- La table est ciblée dynamiquement avec :
--
--   type::table($table)
--
-- Le champ est ciblé dynamiquement avec :
--
--   type::field($field)
--
-- La recherche logique correspond à :
--
--   SELECT VALUE id
--   FROM type::table($table)
--   WHERE type::field($field) = $value
--   LIMIT 1;
--
-- Lorsqu'un Record ID est exclu, la condition devient :
--
--   WHERE type::field($field) = $value
--     AND id != $exclude_record
--
-- La fonction recherche uniquement un enregistrement correspondant, car la
-- présence d'un seul résultat suffit à prouver que la valeur n'est pas unique.
--
-- Validation applicative et index unique
-- --------------------------------------
-- Cette fonction améliore la qualité des erreurs retournées au client, mais
-- elle ne remplace pas un index UNIQUE défini au niveau du schéma.
--
-- Exemple recommandé :
--
--   DEFINE INDEX user_email_unique
--   ON TABLE identity_user
--   FIELDS email
--   UNIQUE;
--
-- Pourquoi conserver les deux :
--
--   fn::validation_unique()
--     fournit une erreur métier claire avant l'écriture.
--
--   INDEX UNIQUE
--     garantit l'intégrité réelle de la base, y compris en cas d'accès
--     concurrent.
--
-- Deux requêtes concurrentes peuvent théoriquement réussir leur validation
-- applicative avant que l'une d'elles n'écrive la valeur. L'index UNIQUE reste
-- donc la protection définitive contre les doublons.
--
-- Comparaison exacte
-- ------------------
-- La fonction compare la valeur reçue avec la valeur enregistrée en utilisant
-- l'égalité SurrealQL.
--
-- Pour les chaînes, la comparaison est sensible :
--
--   - à la casse ;
--   - aux espaces ;
--   - aux accents ;
--   - à la représentation exacte.
--
-- Ainsi :
--
--   "Admin@example.com"
--
-- et :
--
--   "admin@example.com"
--
-- peuvent être considérés comme différents si les données ne sont pas
-- normalisées auparavant.
--
-- Il est donc recommandé de normaliser les données avant cette validation.
--
-- Exemple futur :
--
--   LET $email = fn::sanitize_email($email);
--   LET $email = fn::validation_email($email, "USER_EMAIL", 254);
--   LET $email = fn::validation_unique(
--       $email,
--       "USER_EMAIL",
--       "identity_user",
--       "email",
--       NONE
--   );
--
-- Valeurs NONE et NULL
-- --------------------
-- La valeur à vérifier ne peut pas être NONE.
--
-- NONE représente l'absence de valeur et produit :
--
--   <FIELD>_REQUIRED
--
-- La valeur NULL est également refusée :
--
--   <FIELD>_NULL_NOT_ALLOWED
--
-- Cette décision évite une interprétation ambiguë de l'unicité des valeurs
-- absentes ou explicitement nulles.
--
-- Champ imbriqué
-- --------------
-- Le paramètre $target_field peut représenter un chemin de champ imbriqué.
--
-- Exemple :
--
--   "profile.username"
--
-- La fonction utilisera alors :
--
--   type::field("profile.username")
--
-- Table dynamique
-- ----------------
-- Le nom de table est converti avec type::table().
--
-- Cette approche doit être préférée à la génération d'une requête sous forme
-- de chaîne.
--
-- La fonction ne vérifie toutefois pas que la table ou le champ appartiennent
-- à une liste métier autorisée.
--
-- Les fonctions exposées directement à un client ne doivent donc pas accepter
-- librement les noms de table et de champ fournis par ce client.
--
-- Ces paramètres doivent être définis par la fonction métier :
--
--   fn::booking_create_team()
--   fn::identity_create_user()
--   fn::crm_create_contact()
--
-- et non transmis directement depuis le corps d'une requête HTTP non fiable.
--
-- Enregistrement exclu
-- --------------------
-- Le paramètre $exclude_record est facultatif.
--
-- NONE :
--   aucun enregistrement n'est exclu.
--
-- Record ID :
--   l'enregistrement correspondant est ignoré pendant la recherche.
--
-- Lorsqu'un Record ID est fourni :
--
--   - il doit être de type record ;
--   - il doit appartenir à la table ciblée.
--
-- L'existence de cet enregistrement n'est pas exigée. Son rôle est uniquement
-- d'exclure cet identifiant de la recherche.
--
-- Limites de la validation
-- ------------------------
-- Cette fonction ne vérifie pas :
--
--   - le format métier de la valeur ;
--   - la normalisation de la valeur ;
--   - que le champ existe dans le schéma ;
--   - que la table existe dans le schéma ;
--   - que le champ possède un index UNIQUE ;
--   - les permissions métier de l'utilisateur ;
--   - l'unicité composée de plusieurs champs ;
--   - l'unicité limitée à un workspace ou à un tenant ;
--   - les conflits produits entre la validation et l'écriture.
--
-- Pour une unicité composée ou contextualisée, une fonction spécialisée sera
-- préférable.
--
-- Exemples futurs :
--
--   fn::validation_unique_in_workspace()
--   fn::validation_unique_compound()
--   fn::validation_unique_for_owner()
--
-- Règles appliquées
-- -----------------
--   1. Le nom technique du champ d'erreur doit être renseigné ;
--   2. Le nom de la table cible doit être renseigné ;
--   3. Le nom du champ cible doit être renseigné ;
--   4. La valeur à vérifier doit être présente ;
--   5. La valeur à vérifier ne doit pas être NULL ;
--   6. L'enregistrement exclu doit être un Record ID lorsqu'il est fourni ;
--   7. L'enregistrement exclu doit appartenir à la table cible ;
--   8. La fonction recherche un enregistrement possédant la même valeur ;
--   9. L'enregistrement exclu est ignoré lorsqu'il est fourni ;
--  10. Une erreur est levée lorsqu'un doublon est trouvé ;
--  11. La valeur d'origine est retournée lorsqu'elle est unique.
--
-- Paramètres
-- ----------
-- $value:
--   Type : option<any>
--
--   Valeur obligatoire dont l'unicité doit être vérifiée.
--
--   Tous les types comparables par SurrealQL peuvent théoriquement être
--   utilisés, mais cette fonction est principalement destinée aux valeurs
--   scalaires :
--
--     - string ;
--     - int ;
--     - number ;
--     - uuid ;
--     - datetime ;
--     - record.
--
-- $field:
--   Type : string
--
--   Nom technique utilisé pour construire les codes d'erreur.
--
--   Ce nom n'est pas obligatoirement identique au champ de base de données.
--
--   Convention recommandée :
--
--     - USER_EMAIL
--     - TEAM_SLUG
--     - USERNAME
--     - PRODUCT_REFERENCE
--     - EXTERNAL_ID
--
-- $target_table:
--   Type : string
--
--   Nom de la table dans laquelle rechercher la valeur.
--
--   Exemples :
--
--     - identity_user
--     - booking_team
--     - crm_contact
--     - core_workspace
--
-- $target_field:
--   Type : string
--
--   Nom ou chemin du champ contenant la valeur.
--
--   Exemples :
--
--     - email
--     - slug
--     - username
--     - profile.username
--     - external_id
--
-- $exclude_record:
--   Type : option<any>
--
--   Record ID à exclure de la recherche.
--
--   Utiliser NONE lors d'une création.
--
--   Fournir le Record ID actuel lors d'une mise à jour.
--
-- Valeur retournée
-- ----------------
-- Type : any
--
-- Retourne la valeur d'origine sans transformation lorsqu'aucun doublon n'est
-- trouvé.
--
-- Exemple :
--
--   fn::validation_unique(
--       "contact@example.com",
--       "USER_EMAIL",
--       "identity_user",
--       "email",
--       NONE
--   )
--
-- retourne :
--
--   "contact@example.com"
--
-- lorsqu'aucun enregistrement ne possède cette adresse.
--
-- Erreurs générées
-- ----------------
-- <FIELD>_REQUIRED
--   La valeur à vérifier est absente ou égale à NONE.
--
-- <FIELD>_NULL_NOT_ALLOWED
--   La valeur à vérifier est explicitement égale à NULL.
--
-- <FIELD>_ALREADY_EXISTS
--   Un autre enregistrement possède déjà la même valeur.
--
-- VALIDATION_INVALID_FIELD_NAME
--   Le nom technique utilisé pour les erreurs est vide.
--
-- VALIDATION_INVALID_TABLE_NAME
--   Le nom de la table cible est vide.
--
-- VALIDATION_INVALID_TARGET_FIELD
--   Le nom du champ cible est vide.
--
-- VALIDATION_INVALID_EXCLUDE_RECORD
--   La valeur d'exclusion fournie n'est pas un Record ID.
--
-- VALIDATION_INVALID_EXCLUDE_TABLE
--   Le Record ID exclu appartient à une autre table.
--
-- Permissions
-- -----------
-- PERMISSIONS FULL
--
-- Cette fonction effectue une lecture dans la table cible.
--
-- Elle ne retourne :
--
--   - aucun contenu d'enregistrement ;
--   - aucune valeur enregistrée ;
--   - aucun Record ID trouvé.
--
-- Elle retourne uniquement la valeur reçue ou une erreur d'unicité.
--
-- Néanmoins, elle révèle indirectement qu'une valeur existe déjà.
--
-- Pour cette raison :
--
--   - les noms de table et de champ doivent être imposés par les fonctions
--     métier ;
--   - cette fonction ne doit pas être exposée comme endpoint générique ;
--   - les permissions des tables doivent rester correctement configurées ;
--   - les messages d'erreur sensibles peuvent être généralisés selon le
--     contexte métier.
--
-- Dépendances natives SurrealDB
-- -----------------------------
--   - string::trim()
--   - string::concat()
--   - type::is_null()
--   - type::is_record()
--   - type::table()
--   - type::field()
--   - record::tb()
--   - array::len()
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.
--
-- Ordre de chargement
-- -------------------
-- Cette fonction est autonome.
--
-- Elle doit cependant être utilisée après les fonctions qui normalisent et
-- valident le format de la valeur.
--
-- Exemple recommandé :
--
--   1. sanitize ;
--   2. validation du format ;
--   3. validation d'unicité ;
--   4. écriture protégée par un index UNIQUE.
--
-- Exemples d'utilisation
-- ----------------------
-- Création d'un utilisateur :
--
-- LET $email = fn::validation_email(
--     $email,
--     "USER_EMAIL",
--     254
-- );
--
-- LET $email = fn::validation_unique(
--     $email,
--     "USER_EMAIL",
--     "identity_user",
--     "email",
--     NONE
-- );
--
-- Mise à jour d'un utilisateur :
--
-- LET $email = fn::validation_email(
--     $email,
--     "USER_EMAIL",
--     254
-- );
--
-- LET $email = fn::validation_unique(
--     $email,
--     "USER_EMAIL",
--     "identity_user",
--     "email",
--     $user_id
-- );
--
-- Validation d'un slug :
--
-- LET $slug = fn::validation_slug(
--     $slug,
--     "TEAM_SLUG",
--     100
-- );
--
-- LET $slug = fn::validation_unique(
--     $slug,
--     "TEAM_SLUG",
--     "booking_team",
--     "slug",
--     NONE
-- );
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_unique(
    $value: option<any>,
    $field: string,
    $target_table: string,
    $target_field: string,
    $exclude_record: option<any>
) -> any {

    -- ------------------------------------------------------------------------
    -- 1. Validation du nom technique utilisé pour les erreurs
    -- ------------------------------------------------------------------------

    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    -- ------------------------------------------------------------------------
    -- 2. Validation du nom de la table cible
    -- ------------------------------------------------------------------------

    LET $clean_table = string::trim($target_table);

    IF $clean_table = "" {
        THROW "VALIDATION_INVALID_TABLE_NAME";
    };

    -- ------------------------------------------------------------------------
    -- 3. Validation du nom ou du chemin du champ cible
    -- ------------------------------------------------------------------------

    LET $clean_target_field = string::trim($target_field);

    IF $clean_target_field = "" {
        THROW "VALIDATION_INVALID_TARGET_FIELD";
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
    -- 6. Validation de l'enregistrement exclu
    -- ------------------------------------------------------------------------
    -- Lorsqu'une valeur d'exclusion est fournie, elle doit être un Record ID
    -- appartenant à la table dans laquelle la recherche est effectuée.

    IF $exclude_record IS NOT NONE {

        IF !type::is_record($exclude_record) {
            THROW "VALIDATION_INVALID_EXCLUDE_RECORD";
        };

        IF record::tb($exclude_record) != $clean_table {
            THROW "VALIDATION_INVALID_EXCLUDE_TABLE";
        };
    };

    -- ------------------------------------------------------------------------
    -- 7. Recherche d'un doublon
    -- ------------------------------------------------------------------------
    -- type::table() transforme le nom reçu en cible de table.
    --
    -- type::field() transforme le nom ou chemin reçu en référence de champ.
    --
    -- LIMIT 1 évite de charger tous les doublons éventuels, car un seul
    -- résultat suffit pour invalider l'unicité.

    LET $duplicates = SELECT VALUE id
        FROM type::table($clean_table)
        WHERE type::field($clean_target_field) = $value
          AND (
              $exclude_record IS NONE
              OR id != $exclude_record
          )
        LIMIT 1;

    -- ------------------------------------------------------------------------
    -- 8. Refus de la valeur lorsqu'un doublon existe
    -- ------------------------------------------------------------------------

    IF array::len($duplicates) > 0 {
        THROW string::concat(
            $clean_field,
            "_ALREADY_EXISTS"
        );
    };

    -- ------------------------------------------------------------------------
    -- 9. Retour de la valeur validée
    -- ------------------------------------------------------------------------

    RETURN $value;
}
COMMENT "
Vérifie qu'une valeur n'existe pas déjà dans un champ donné d'une table.
Permet d'exclure un Record ID lors d'une mise à jour. Retourne la valeur
d'origine lorsqu'elle est unique ou interrompt l'exécution avec un code
d'erreur stable. Cette validation applicative doit être complétée par un index
UNIQUE afin de garantir l'intégrité en cas d'écritures concurrentes.
"
PERMISSIONS FULL;