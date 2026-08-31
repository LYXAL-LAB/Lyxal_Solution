-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/exists.surql
-- Fonction     : fn::validation_exists
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Vérifie qu'au moins un enregistrement d'une table possède une valeur
-- déterminée dans un champ donné.
--
-- Cette fonction constitue le complément logique de :
--
--   fn::validation_unique()
--
-- fn::validation_unique() :
--
--   refuse la valeur lorsqu'un enregistrement correspondant existe déjà.
--
-- fn::validation_exists() :
--
--   refuse la valeur lorsqu'aucun enregistrement correspondant n'existe.
--
-- Cette fonction peut notamment être utilisée pour contrôler :
--
--   - un code d'invitation ;
--   - une adresse e-mail associée à un compte ;
--   - une référence commerciale ;
--   - un slug public ;
--   - un identifiant externe ;
--   - un token métier stocké en base ;
--   - une clé de configuration ;
--   - un code de vérification ;
--   - une valeur de relation indirecte.
--
-- Exemple
-- -------
-- Vérification de l'existence d'une adresse e-mail :
--
--   LET $email = fn::validation_exists(
--       $email,
--       "USER_EMAIL",
--       "identity_user",
--       "email"
--   );
--
-- Si un enregistrement possède cette adresse, la fonction retourne la valeur.
--
-- Si aucun enregistrement ne la possède, elle produit :
--
--   USER_EMAIL_NOT_FOUND
--
-- Fonctionnement
-- --------------
-- La table est ciblée dynamiquement avec :
--
--   type::table($target_table)
--
-- Le champ est ciblé dynamiquement avec :
--
--   type::field($target_field)
--
-- La recherche logique correspond à :
--
--   SELECT VALUE id
--   FROM type::table($target_table)
--   WHERE type::field($target_field) = $value
--   LIMIT 1;
--
-- Un seul résultat est recherché, car la présence d'un enregistrement suffit
-- pour valider l'existence de la valeur.
--
-- Différence avec validation_record_exists
-- ----------------------------------------
-- fn::validation_record_exists() reçoit directement un Record ID :
--
--   identity_user:user_001
--
-- puis vérifie que cet enregistrement existe.
--
-- fn::validation_exists() reçoit une valeur quelconque et recherche cette
-- valeur dans un champ :
--
--   valeur :
--     "contact@example.com"
--
--   table :
--     identity_user
--
--   champ :
--     email
--
-- Utiliser validation_record_exists lorsqu'un Record ID est déjà disponible.
--
-- Utiliser validation_exists lorsqu'une ressource doit être retrouvée par une
-- valeur métier.
--
-- Comparaison exacte
-- ------------------
-- La comparaison utilise l'égalité SurrealQL :
--
--   type::field($target_field) = $value
--
-- Pour les chaînes, la comparaison peut être sensible :
--
--   - à la casse ;
--   - aux espaces ;
--   - aux accents ;
--   - à la représentation exacte de la valeur.
--
-- Exemple :
--
--   "Contact@example.com"
--
-- peut être différent de :
--
--   "contact@example.com"
--
-- Il est donc recommandé de normaliser la valeur avant l'appel lorsque le
-- domaine métier exige une comparaison normalisée.
--
-- Exemple futur :
--
--   LET $email = fn::sanitize_email($email);
--
--   LET $email = fn::validation_email(
--       $email,
--       "USER_EMAIL",
--       254
--   );
--
--   LET $email = fn::validation_exists(
--       $email,
--       "USER_EMAIL",
--       "identity_user",
--       "email"
--   );
--
-- Champ imbriqué
-- --------------
-- Le champ cible peut représenter un chemin imbriqué.
--
-- Exemple :
--
--   "profile.username"
--
-- La fonction utilisera :
--
--   type::field("profile.username")
--
-- Valeurs NONE et NULL
-- --------------------
-- La valeur recherchée ne peut pas être NONE.
--
-- NONE produit :
--
--   <FIELD>_REQUIRED
--
-- NULL est également refusé :
--
--   <FIELD>_NULL_NOT_ALLOWED
--
-- Cette décision évite les recherches ambiguës portant sur des valeurs
-- absentes ou explicitement nulles.
--
-- Sécurité des paramètres dynamiques
-- ----------------------------------
-- Les noms de table et de champ doivent être définis par une fonction métier.
--
-- Exemple correct :
--
--   fn::identity_request_password_reset()
--
-- appelle :
--
--   fn::validation_exists(
--       $email,
--       "USER_EMAIL",
--       "identity_user",
--       "email"
--   );
--
-- Il est déconseillé d'exposer directement une API générique permettant au
-- client de choisir librement :
--
--   - la table ;
--   - le champ ;
--   - la valeur recherchée.
--
-- Même si type::table() et type::field() évitent de construire une requête
-- SurrealQL par concaténation, une fonction générique pourrait révéler
-- indirectement l'existence de données sensibles.
--
-- Informations retournées
-- ------------------------
-- Cette fonction ne retourne pas :
--
--   - le Record ID trouvé ;
--   - le contenu de l'enregistrement ;
--   - la valeur stockée ;
--   - le nombre total de correspondances.
--
-- Elle retourne uniquement la valeur reçue lorsqu'une correspondance existe.
--
-- Cela permet de l'intégrer naturellement dans une chaîne de validation :
--
--   LET $email = fn::validation_email(...);
--   LET $email = fn::validation_exists(...);
--
--   RETURN $email;
--
-- Limites de la validation
-- ------------------------
-- Cette fonction ne vérifie pas :
--
--   - le format métier de la valeur ;
--   - la normalisation de la valeur ;
--   - que la table existe dans le schéma ;
--   - que le champ existe dans le schéma ;
--   - l'unicité de la valeur ;
--   - les permissions métier de l'utilisateur ;
--   - que l'enregistrement trouvé est actif ;
--   - que l'enregistrement n'est pas archivé ;
--   - que l'enregistrement appartient au workspace courant ;
--   - l'existence selon plusieurs champs simultanément.
--
-- Pour une recherche contextualisée, une fonction métier spécialisée devra
-- être utilisée.
--
-- Exemples :
--
--   fn::validation_exists_in_workspace()
--   fn::validation_exists_for_owner()
--   fn::validation_exists_compound()
--
-- Règles appliquées
-- -----------------
--   1. Le nom technique du champ d'erreur doit être renseigné ;
--   2. Le nom de la table cible doit être renseigné ;
--   3. Le nom ou chemin du champ cible doit être renseigné ;
--   4. La valeur recherchée doit être présente ;
--   5. La valeur recherchée ne doit pas être NULL ;
--   6. La fonction recherche une correspondance dans la table cible ;
--   7. Une erreur est levée lorsqu'aucune correspondance n'est trouvée ;
--   8. La valeur d'origine est retournée lorsqu'elle existe.
--
-- Paramètres
-- ----------
-- $value:
--   Type : option<any>
--
--   Valeur obligatoire à rechercher.
--
--   Tous les types comparables par SurrealQL peuvent théoriquement être
--   utilisés, notamment :
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
--   Ce nom n'est pas nécessairement identique au nom du champ en base.
--
--   Convention recommandée :
--
--     - USER_EMAIL
--     - INVITATION_CODE
--     - PRODUCT_REFERENCE
--     - TEAM_SLUG
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
--     - invitation
--
-- $target_field:
--   Type : string
--
--   Nom ou chemin du champ contenant la valeur recherchée.
--
--   Exemples :
--
--     - email
--     - slug
--     - code
--     - reference
--     - profile.username
--
-- Valeur retournée
-- ----------------
-- Type : any
--
-- Retourne la valeur d'origine sans transformation lorsqu'au moins un
-- enregistrement correspondant existe.
--
-- Exemple :
--
--   fn::validation_exists(
--       "contact@example.com",
--       "USER_EMAIL",
--       "identity_user",
--       "email"
--   )
--
-- retourne :
--
--   "contact@example.com"
--
-- lorsqu'un utilisateur possède cette adresse.
--
-- Erreurs générées
-- ----------------
-- <FIELD>_REQUIRED
--   La valeur recherchée est absente ou égale à NONE.
--
-- <FIELD>_NULL_NOT_ALLOWED
--   La valeur recherchée est explicitement égale à NULL.
--
-- <FIELD>_NOT_FOUND
--   Aucun enregistrement ne possède la valeur recherchée.
--
-- VALIDATION_INVALID_FIELD_NAME
--   Le nom technique utilisé pour les erreurs est vide.
--
-- VALIDATION_INVALID_TABLE_NAME
--   Le nom de la table cible est vide.
--
-- VALIDATION_INVALID_TARGET_FIELD
--   Le nom ou chemin du champ cible est vide.
--
-- Permissions
-- -----------
-- PERMISSIONS FULL
--
-- Cette fonction effectue une lecture dans la table cible.
--
-- Elle ne retourne aucune donnée provenant de la table.
--
-- Elle révèle néanmoins indirectement qu'une valeur existe ou n'existe pas.
--
-- Cette information peut être sensible dans certains contextes, notamment :
--
--   - la recherche de comptes par adresse e-mail ;
--   - la vérification de numéros de téléphone ;
--   - l'existence de ressources privées ;
--   - l'existence d'identifiants externes.
--
-- Les fonctions métier doivent donc éviter les attaques d'énumération.
--
-- Selon le contexte, il peut être préférable de retourner un message générique
-- au client, même lorsque cette fonction produit en interne un code précis.
--
-- Dépendances natives SurrealDB
-- -----------------------------
--   - string::trim()
--   - string::concat()
--   - type::is_null()
--   - type::table()
--   - type::field()
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
-- Elle doit toutefois être utilisée après la normalisation et la validation du
-- format de la valeur recherchée.
--
-- Ordre recommandé :
--
--   1. normaliser la valeur ;
--   2. valider son type et son format ;
--   3. vérifier son existence ;
--   4. appliquer les règles métier et de sécurité.
--
-- Exemples d'utilisation
-- ----------------------
-- Vérification d'une adresse e-mail :
--
-- LET $email = fn::validation_email(
--     $email,
--     "USER_EMAIL",
--     254
-- );
--
-- LET $email = fn::validation_exists(
--     $email,
--     "USER_EMAIL",
--     "identity_user",
--     "email"
-- );
--
-- Vérification d'un code d'invitation :
--
-- LET $code = fn::validation_required_string(
--     $code,
--     "INVITATION_CODE",
--     1,
--     100
-- );
--
-- LET $code = fn::validation_exists(
--     $code,
--     "INVITATION_CODE",
--     "invitation",
--     "code"
-- );
--
-- Vérification d'un slug :
--
-- LET $slug = fn::validation_slug(
--     $slug,
--     "TEAM_SLUG",
--     100
-- );
--
-- LET $slug = fn::validation_exists(
--     $slug,
--     "TEAM_SLUG",
--     "booking_team",
--     "slug"
-- );
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_exists(
    $value: option<any>,
    $field: string,
    $target_table: string,
    $target_field: string
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
    -- 3. Validation du nom ou chemin du champ cible
    -- ------------------------------------------------------------------------

    LET $clean_target_field = string::trim($target_field);

    IF $clean_target_field = "" {
        THROW "VALIDATION_INVALID_TARGET_FIELD";
    };

    -- ------------------------------------------------------------------------
    -- 4. Vérification de la présence de la valeur recherchée
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
    -- 6. Recherche d'une correspondance
    -- ------------------------------------------------------------------------
    -- type::table() transforme la chaîne en cible de table.
    --
    -- type::field() transforme la chaîne en référence de champ ou de chemin.
    --
    -- LIMIT 1 évite de charger tous les résultats, car une seule
    -- correspondance suffit à valider l'existence.

    LET $matches = SELECT VALUE id
        FROM type::table($clean_table)
        WHERE type::field($clean_target_field) = $value
        LIMIT 1;

    -- ------------------------------------------------------------------------
    -- 7. Refus lorsque la valeur n'existe pas
    -- ------------------------------------------------------------------------

    IF array::len($matches) = 0 {
        THROW string::concat(
            $clean_field,
            "_NOT_FOUND"
        );
    };

    -- ------------------------------------------------------------------------
    -- 8. Retour de la valeur validée
    -- ------------------------------------------------------------------------

    RETURN $value;
}
COMMENT "
Vérifie qu'au moins un enregistrement d'une table possède une valeur donnée
dans un champ déterminé. Retourne la valeur d'origine lorsqu'une correspondance
existe ou interrompt l'exécution avec un code d'erreur stable. Ne retourne
aucune donnée provenant de l'enregistrement trouvé.
"
PERMISSIONS FULL;