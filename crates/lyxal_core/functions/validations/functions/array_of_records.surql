-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/array_of_records.surql
-- Fonction     : fn::validation_array_of_records
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Vérifie qu'une valeur obligatoire est strictement de type array et que tous
-- les éléments du tableau sont des Record IDs natifs SurrealDB.
--
-- Cette fonction permet également :
--
--   - d'imposer une table précise à tous les Record IDs ;
--   - de vérifier facultativement l'existence réelle de chaque enregistrement ;
--   - de retourner le tableau d'origine sans conversion ni modification.
--
-- Elle est destinée aux collections de références telles que :
--
--   - une liste de membres ;
--   - une liste d'utilisateurs ;
--   - une liste d'équipes ;
--   - une liste de ressources ;
--   - une liste de documents ;
--   - une liste de catégories ;
--   - une liste de destinataires ;
--   - une liste d'événements ;
--   - une liste de relations métier.
--
-- Exemple simple
-- --------------
-- Tableau accepté :
--
--   [
--       identity_user:user_001,
--       identity_user:user_002
--   ]
--
-- Tableau refusé :
--
--   [
--       "identity_user:user_001",
--       "identity_user:user_002"
--   ]
--
-- Les valeurs du second tableau sont des chaînes et non des Record IDs natifs.
--
-- Validation stricte
-- ------------------
-- Cette fonction n'effectue aucune conversion automatique.
--
-- Exemple accepté :
--
--   identity_user:user_001
--
-- Exemple refusé :
--
--   "identity_user:user_001"
--
-- Pour convertir des chaînes en Record IDs avant cette validation, utiliser :
--
--   fn::validation_record()
--
-- ou :
--
--   type::record()
--
-- Table attendue
-- ---------------
-- Le paramètre $expected_table permet d'imposer une table précise à tous les
-- éléments.
--
-- Exemple :
--
--   $expected_table = "identity_user"
--
-- oblige chaque Record ID à appartenir à la table identity_user.
--
-- Tableau valide :
--
--   [
--       identity_user:user_001,
--       identity_user:user_002
--   ]
--
-- Tableau invalide :
--
--   [
--       identity_user:user_001,
--       booking_team:team_001
--   ]
--
-- Lorsque $expected_table vaut NONE, les Record IDs peuvent appartenir à des
-- tables différentes.
--
-- Exemple accepté sans table imposée :
--
--   [
--       identity_user:user_001,
--       booking_team:team_001
--   ]
--
-- Contrôle d'existence
-- --------------------
-- Le paramètre $require_exists permet de vérifier que tous les enregistrements
-- existent réellement.
--
-- Lorsque $require_exists vaut false :
--
--   - seul le type record est contrôlé ;
--   - la table est contrôlée lorsqu'elle est configurée ;
--   - un Record ID inexistant peut être accepté.
--
-- Lorsque $require_exists vaut true :
--
--   - chaque Record ID est contrôlé avec record::exists() ;
--   - la fonction échoue dès qu'au moins un enregistrement est absent.
--
-- Exemple :
--
--   [
--       identity_user:user_existing,
--       identity_user:user_missing
--   ]
--
-- produit :
--
--   MEMBER_IDS_ITEM_NOT_FOUND
--
-- lorsque $require_exists vaut true.
--
-- Tableau vide
-- ------------
-- Un tableau vide est accepté par cette fonction.
--
-- En effet, aucun élément présent ne viole la règle de type record.
--
-- Pour exiger au moins un élément, utiliser auparavant :
--
--   fn::validation_array_not_empty()
--
-- ou :
--
--   fn::validation_array_length()
--
-- Exemple :
--
--   LET $member_ids = fn::validation_array_length(
--       $member_ids,
--       "MEMBER_IDS",
--       1,
--       100
--   );
--
--   LET $member_ids = fn::validation_array_of_records(
--       $member_ids,
--       "MEMBER_IDS",
--       "identity_user",
--       true
--   );
--
-- Doublons
-- --------
-- Cette fonction n'interdit pas les doublons.
--
-- Ainsi :
--
--   [
--       identity_user:user_001,
--       identity_user:user_001
--   ]
--
-- est valide au regard du type des éléments.
--
-- Pour interdire les doublons, utiliser :
--
--   fn::validation_array_unique()
--
-- Exemple complet :
--
--   LET $member_ids = fn::validation_array_length(
--       $member_ids,
--       "MEMBER_IDS",
--       1,
--       100
--   );
--
--   LET $member_ids = fn::validation_array_of_records(
--       $member_ids,
--       "MEMBER_IDS",
--       "identity_user",
--       true
--   );
--
--   LET $member_ids = fn::validation_array_unique(
--       $member_ids,
--       "MEMBER_IDS"
--   );
--
-- Valeurs NONE et NULL
-- --------------------
-- NONE et NULL sont refusés comme éléments du tableau, car ils ne sont pas de
-- type record.
--
-- Exemples refusés :
--
--   [identity_user:user_001, NONE]
--   [identity_user:user_001, NULL]
--
-- Ils produisent :
--
--   <FIELD>_ITEM_INVALID_TYPE
--
-- Limites de la validation
-- ------------------------
-- Cette fonction vérifie uniquement :
--
--   - la présence du tableau ;
--   - le refus de NULL comme valeur globale ;
--   - le type array ;
--   - le type record de chaque élément ;
--   - la table de chaque Record ID lorsqu'elle est imposée ;
--   - l'existence de chaque enregistrement lorsqu'elle est demandée.
--
-- Elle ne vérifie pas :
--
--   - que le tableau est non vide ;
--   - la longueur minimale du tableau ;
--   - la longueur maximale du tableau ;
--   - l'unicité des Record IDs ;
--   - les permissions d'accès aux enregistrements ;
--   - l'appartenance des enregistrements à un utilisateur ou workspace ;
--   - la cohérence métier entre les enregistrements ;
--   - l'état actif, supprimé ou archivé des enregistrements.
--
-- Les autorisations et règles métier doivent être appliquées séparément.
--
-- Règles appliquées
-- -----------------
--   1. Le nom technique du champ doit être renseigné ;
--   2. La table attendue est nettoyée lorsqu'elle est fournie ;
--   3. Une table attendue vide est refusée ;
--   4. La valeur doit être présente ;
--   5. La valeur globale ne doit pas être NULL ;
--   6. La valeur doit être strictement de type array ;
--   7. Tous les éléments doivent être strictement de type record ;
--   8. Tous les Record IDs doivent appartenir à la table attendue lorsqu'elle
--      est fournie ;
--   9. Tous les enregistrements doivent exister lorsque $require_exists vaut
--      true ;
--  10. Le tableau d'origine est retourné lorsqu'il est valide.
--
-- Paramètres
-- ----------
-- $value:
--   Type : option<any>
--
--   Tableau obligatoire à contrôler.
--
--   Le type option<any> permet de produire des erreurs explicites pour :
--
--     - une valeur absente ;
--     - une valeur NULL ;
--     - une valeur globale d'un type incorrect ;
--     - un élément d'un type incorrect ;
--     - un Record ID appartenant à une mauvaise table ;
--     - un enregistrement inexistant.
--
-- $field:
--   Type : string
--
--   Nom technique utilisé pour construire les codes d'erreur.
--
--   Convention recommandée :
--
--     - MEMBER_IDS
--     - USER_IDS
--     - TEAM_IDS
--     - RESOURCE_IDS
--     - DOCUMENT_IDS
--     - EVENT_IDS
--     - RECIPIENT_IDS
--
-- $expected_table:
--   Type : option<string>
--
--   Nom de la table attendue pour tous les Record IDs.
--
--   Utiliser NONE pour autoriser des Record IDs provenant de tables
--   différentes.
--
--   Exemples :
--
--     "identity_user"
--     "booking_team"
--     "core_workspace"
--
-- $require_exists:
--   Type : bool
--
--   false :
--     Ne contrôle pas l'existence des enregistrements.
--
--   true :
--     Vérifie chaque Record ID avec record::exists().
--
-- Valeur retournée
-- ----------------
-- Type : array
--
-- Retourne le tableau d'origine sans conversion ni modification.
--
-- Exemple :
--
--   fn::validation_array_of_records(
--       [
--           identity_user:user_001,
--           identity_user:user_002
--       ],
--       "MEMBER_IDS",
--       "identity_user",
--       true
--   )
--
-- retourne :
--
--   [
--       identity_user:user_001,
--       identity_user:user_002
--   ]
--
-- lorsque les deux enregistrements existent.
--
-- Erreurs générées
-- ----------------
-- <FIELD>_REQUIRED
--   La valeur est absente ou égale à NONE.
--
-- <FIELD>_NULL_NOT_ALLOWED
--   La valeur globale est explicitement égale à NULL.
--
-- <FIELD>_INVALID_TYPE
--   La valeur globale n'est pas de type array.
--
-- <FIELD>_ITEM_INVALID_TYPE
--   Au moins un élément n'est pas un Record ID natif.
--
-- <FIELD>_ITEM_INVALID_TABLE
--   Au moins un Record ID appartient à une table différente de la table
--   attendue.
--
-- <FIELD>_ITEM_NOT_FOUND
--   Au moins un Record ID ne correspond à aucun enregistrement existant alors
--   que $require_exists vaut true.
--
-- VALIDATION_INVALID_FIELD_NAME
--   Le nom technique du champ est vide ou composé uniquement d'espaces.
--
-- VALIDATION_INVALID_TABLE_NAME
--   La table attendue est fournie, mais elle est vide après nettoyage.
--
-- Permissions
-- -----------
-- PERMISSIONS FULL
--
-- Cette fonction ne crée, ne modifie et ne supprime aucune donnée.
--
-- Lorsque $require_exists vaut false :
--
--   - elle ne lit aucune donnée persistante ;
--   - elle inspecte uniquement le type et la table des Record IDs.
--
-- Lorsque $require_exists vaut true :
--
--   - elle vérifie indirectement la présence des enregistrements ;
--   - elle ne retourne toutefois aucun contenu enregistré ;
--   - elle retourne uniquement le tableau de Record IDs reçu.
--
-- Attention :
--
-- L'existence d'un Record ID ne signifie pas que l'utilisateur est autorisé à
-- lire, modifier ou supprimer l'enregistrement correspondant.
--
-- Les contrôles d'autorisation restent sous la responsabilité :
--
--   - des permissions de table ;
--   - des fonctions métier ;
--   - des fonctions du domaine core/security.
--
-- Dépendances natives SurrealDB
-- -----------------------------
--   - string::trim()
--   - string::concat()
--   - type::is_null()
--   - type::is_array()
--   - type::is_record()
--   - record::tb()
--   - record::exists()
--   - array::all()
--   - array::any()
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.
--
-- Ordre de chargement
-- -------------------
-- Cette fonction est autonome.
--
-- Il est toutefois recommandé de charger les validateurs de tableau dans
-- l'ordre logique suivant :
--
--   1. array_not_empty.surql
--   2. array_length.surql
--   3. array_unique.surql
--   4. array_of_strings.surql
--   5. array_of_records.surql
--   6. array_without_none.surql
--   7. array_without_null.surql
--
-- Exemples d'utilisation
-- ----------------------
-- Record IDs d'une même table sans contrôle d'existence :
--
-- LET $member_ids = fn::validation_array_of_records(
--     $member_ids,
--     "MEMBER_IDS",
--     "identity_user",
--     false
-- );
--
-- Record IDs d'une même table avec contrôle d'existence :
--
-- LET $member_ids = fn::validation_array_of_records(
--     $member_ids,
--     "MEMBER_IDS",
--     "identity_user",
--     true
-- );
--
-- Record IDs provenant de plusieurs tables :
--
-- LET $resource_ids = fn::validation_array_of_records(
--     $resource_ids,
--     "RESOURCE_IDS",
--     NONE,
--     false
-- );
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_array_of_records(
    $value: option<any>,
    $field: string,
    $expected_table: option<string>,
    $require_exists: bool
) -> array {

    -- ------------------------------------------------------------------------
    -- 1. Validation du nom technique du champ
    -- ------------------------------------------------------------------------

    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    -- ------------------------------------------------------------------------
    -- 2. Préparation de la table attendue
    -- ------------------------------------------------------------------------

    LET $clean_table = IF $expected_table IS NONE {
        NONE
    } ELSE {
        string::trim($expected_table)
    };

    -- ------------------------------------------------------------------------
    -- 3. Validation de la table attendue
    -- ------------------------------------------------------------------------

    IF $clean_table IS NOT NONE
        AND $clean_table = ""
    {
        THROW "VALIDATION_INVALID_TABLE_NAME";
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
    -- 5. Refus explicite de NULL comme valeur globale
    -- ------------------------------------------------------------------------

    IF type::is_null($value) {
        THROW string::concat(
            $clean_field,
            "_NULL_NOT_ALLOWED"
        );
    };

    -- ------------------------------------------------------------------------
    -- 6. Vérification stricte du type array
    -- ------------------------------------------------------------------------

    IF !type::is_array($value) {
        THROW string::concat(
            $clean_field,
            "_INVALID_TYPE"
        );
    };

    -- ------------------------------------------------------------------------
    -- 7. Vérification du type de tous les éléments
    -- ------------------------------------------------------------------------
    -- Tous les éléments doivent être des Record IDs natifs.
    --
    -- Un tableau vide est accepté, car aucun élément ne viole la règle.

    LET $all_items_are_records = array::all(
        $value,
        |$item| type::is_record($item)
    );

    IF !$all_items_are_records {
        THROW string::concat(
            $clean_field,
            "_ITEM_INVALID_TYPE"
        );
    };

    -- ------------------------------------------------------------------------
    -- 8. Vérification de la table de tous les Record IDs
    -- ------------------------------------------------------------------------
    -- Cette étape est ignorée lorsque $expected_table vaut NONE.

    IF $clean_table IS NOT NONE {

        LET $contains_record_from_invalid_table = array::any(
            $value,
            |$item| record::tb($item) != $clean_table
        );

        IF $contains_record_from_invalid_table {
            THROW string::concat(
                $clean_field,
                "_ITEM_INVALID_TABLE"
            );
        };
    };

    -- ------------------------------------------------------------------------
    -- 9. Vérification de l'existence des enregistrements
    -- ------------------------------------------------------------------------
    -- Cette étape est exécutée uniquement lorsque $require_exists vaut true.

    IF $require_exists {

        LET $contains_missing_record = array::any(
            $value,
            |$item| !record::exists($item)
        );

        IF $contains_missing_record {
            THROW string::concat(
                $clean_field,
                "_ITEM_NOT_FOUND"
            );
        };
    };

    -- ------------------------------------------------------------------------
    -- 10. Retour du tableau validé
    -- ------------------------------------------------------------------------
    -- Le tableau est retourné sans conversion, tri ou suppression de doublons.

    RETURN $value;
}
COMMENT "
Valide qu'une valeur obligatoire est un tableau contenant uniquement des
Record IDs natifs SurrealDB. Permet d'imposer une table commune à tous les
éléments et de vérifier facultativement l'existence réelle de chaque
enregistrement. Retourne le tableau d'origine sans transformation.
"
PERMISSIONS FULL;