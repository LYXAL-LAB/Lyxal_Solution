-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/array_without_none.surql
-- Fonction     : fn::validation_array_without_none
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Vérifie qu'une valeur obligatoire est strictement de type array et qu'aucun
-- élément du tableau n'est égal à NONE.
--
-- NONE représente l'absence de valeur dans SurrealDB.
--
-- Cette fonction permet donc d'empêcher qu'un tableau contienne des éléments
-- non définis ou absents.
--
-- Exemple valide :
--
--   [
--       "owner",
--       "admin",
--       "member"
--   ]
--
-- Exemple invalide :
--
--   [
--       "owner",
--       NONE,
--       "member"
--   ]
--
-- Le second tableau produit :
--
--   ROLES_NONE_NOT_ALLOWED
--
-- Cas d'utilisation
-- -----------------
-- Cette fonction peut notamment être utilisée pour valider :
--
--   - une liste de rôles ;
--   - une liste de permissions ;
--   - une liste de membres ;
--   - une liste de destinataires ;
--   - une liste de Record IDs ;
--   - une liste de tags ;
--   - une liste de valeurs métier ;
--   - une liste de paramètres ;
--   - une liste de fichiers ;
--   - une liste de ressources.
--
-- Différence entre NONE et NULL
-- -----------------------------
-- NONE et NULL sont deux valeurs différentes dans SurrealDB.
--
-- NONE :
--   représente l'absence de valeur.
--
-- NULL :
--   représente une valeur explicitement vide.
--
-- Cette fonction interdit uniquement NONE à l'intérieur du tableau.
--
-- Ainsi :
--
--   [NULL]
--
-- est accepté par cette fonction.
--
-- En revanche :
--
--   [NONE]
--
-- est refusé.
--
-- Pour interdire également NULL, utiliser :
--
--   fn::validation_array_without_null()
--
-- Exemple d'enchaînement :
--
--   LET $values = fn::validation_array_without_none(
--       $values,
--       "VALUES"
--   );
--
--   LET $values = fn::validation_array_without_null(
--       $values,
--       "VALUES"
--   );
--
-- Valeur globale NONE
-- --------------------
-- Lorsque le paramètre complet vaut NONE :
--
--   fn::validation_array_without_none(
--       NONE,
--       "VALUES"
--   )
--
-- la fonction produit :
--
--   VALUES_REQUIRED
--
-- Cette erreur est différente de celle produite lorsqu'un élément interne vaut
-- NONE.
--
-- Valeur globale :
--
--   NONE
--
-- produit :
--
--   <FIELD>_REQUIRED
--
-- Élément interne :
--
--   [1, NONE, 3]
--
-- produit :
--
--   <FIELD>_NONE_NOT_ALLOWED
--
-- Valeur globale NULL
-- --------------------
-- Lorsque le paramètre complet vaut NULL, la fonction produit :
--
--   <FIELD>_NULL_NOT_ALLOWED
--
-- Cela évite de confondre :
--
--   - une valeur absente ;
--   - une valeur explicitement NULL ;
--   - un tableau contenant NULL.
--
-- Tableau vide
-- ------------
-- Un tableau vide est accepté.
--
-- En effet :
--
--   []
--
-- ne contient aucun élément NONE.
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
--   LET $values = fn::validation_array_length(
--       $values,
--       "VALUES",
--       1,
--       100
--   );
--
--   LET $values = fn::validation_array_without_none(
--       $values,
--       "VALUES"
--   );
--
-- Type des éléments
-- -----------------
-- Cette fonction ne vérifie pas le type des autres éléments.
--
-- Ainsi, le tableau suivant est valide pour cette fonction :
--
--   [
--       "texte",
--       42,
--       true,
--       NULL,
--       identity_user:user_001,
--       {
--           name: "Lyxal"
--       }
--   ]
--
-- Aucun élément n'est égal à NONE.
--
-- Pour contrôler le type des éléments, utiliser une fonction spécialisée :
--
--   fn::validation_array_of_strings()
--   fn::validation_array_of_records()
--
-- Doublons
-- --------
-- Cette fonction ne contrôle pas l'unicité.
--
-- Le tableau suivant est accepté :
--
--   ["admin", "admin"]
--
-- Pour interdire les doublons, utiliser :
--
--   fn::validation_array_unique()
--
-- Tableaux imbriqués
-- ------------------
-- La validation porte uniquement sur les éléments de premier niveau.
--
-- Exemple :
--
--   [
--       [1, NONE, 3]
--   ]
--
-- Le premier niveau contient un seul élément de type array.
-- Il ne contient donc pas directement NONE.
--
-- Cette fonction ne parcourt pas récursivement les tableaux imbriqués.
--
-- Une future fonction pourra assurer une validation récursive :
--
--   fn::validation_array_without_none_recursive()
--
-- Objets imbriqués
-- ----------------
-- Cette fonction ne vérifie pas les propriétés des objets contenus dans le
-- tableau.
--
-- Exemple :
--
--   [
--       {
--           name: NONE
--       }
--   ]
--
-- est accepté, car l'élément de premier niveau est un objet et non NONE.
--
-- Une future fonction spécialisée pourra contrôler récursivement les objets.
--
-- Limites de la validation
-- ------------------------
-- Cette fonction vérifie uniquement :
--
--   - la présence de la valeur globale ;
--   - le refus de NULL comme valeur globale ;
--   - le type array ;
--   - l'absence de NONE parmi les éléments de premier niveau.
--
-- Elle ne vérifie pas :
--
--   - que le tableau est non vide ;
--   - la longueur du tableau ;
--   - le type des éléments ;
--   - la présence de NULL dans le tableau ;
--   - les doublons ;
--   - les valeurs vides ;
--   - les tableaux ou objets imbriqués ;
--   - la validité métier des éléments ;
--   - les permissions associées aux éléments.
--
-- Règles appliquées
-- -----------------
--   1. Le nom technique du champ doit être renseigné ;
--   2. La valeur globale doit être présente ;
--   3. La valeur globale ne doit pas être NULL ;
--   4. La valeur doit être strictement de type array ;
--   5. Chaque élément de premier niveau est inspecté ;
--   6. Une erreur est levée lorsqu'au moins un élément vaut NONE ;
--   7. Le tableau d'origine est retourné lorsqu'il est valide.
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
--     - une valeur globale absente ;
--     - une valeur globale NULL ;
--     - une valeur globale d'un type incorrect ;
--     - la présence de NONE dans le tableau.
--
-- $field:
--   Type : string
--
--   Nom technique utilisé pour construire les codes d'erreur.
--
--   Convention recommandée :
--
--     - VALUES
--     - ROLES
--     - PERMISSIONS
--     - MEMBER_IDS
--     - RECIPIENTS
--     - RESOURCE_IDS
--     - ITEMS
--     - TAGS
--
-- Valeur retournée
-- ----------------
-- Type : array
--
-- Retourne le tableau d'origine sans suppression ni transformation.
--
-- Exemple :
--
--   fn::validation_array_without_none(
--       ["owner", "admin"],
--       "ROLES"
--   )
--
-- retourne :
--
--   ["owner", "admin"]
--
-- Erreurs générées
-- ----------------
-- <FIELD>_REQUIRED
--   La valeur globale est absente ou égale à NONE.
--
-- <FIELD>_NULL_NOT_ALLOWED
--   La valeur globale est explicitement égale à NULL.
--
-- <FIELD>_INVALID_TYPE
--   La valeur globale n'est pas de type array.
--
-- <FIELD>_NONE_NOT_ALLOWED
--   Au moins un élément de premier niveau du tableau est égal à NONE.
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
--   - elle ne modifie aucune donnée persistante ;
--   - elle ne supprime aucune donnée ;
--   - elle ne dépend pas du contexte d'authentification ;
--   - elle ne révèle aucune information enregistrée ;
--   - elle agit uniquement sur ses paramètres ;
--   - elle ne possède aucun effet secondaire.
--
-- Elle peut donc être appelée par toutes les fonctions métier autorisées.
--
-- Dépendances natives SurrealDB
-- -----------------------------
--   - string::trim()
--   - string::concat()
--   - type::is_null()
--   - type::is_array()
--   - type::is_none()
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
-- Il est toutefois recommandé de charger les validateurs de tableaux dans
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
-- Tableau sans éléments NONE :
--
-- LET $values = fn::validation_array_without_none(
--     $values,
--     "VALUES"
-- );
--
-- Liste de membres complète :
--
-- LET $member_ids = fn::validation_array_length(
--     $member_ids,
--     "MEMBER_IDS",
--     1,
--     100
-- );
--
-- LET $member_ids = fn::validation_array_of_records(
--     $member_ids,
--     "MEMBER_IDS",
--     "identity_user",
--     true
-- );
--
-- LET $member_ids = fn::validation_array_without_none(
--     $member_ids,
--     "MEMBER_IDS"
-- );
--
-- LET $member_ids = fn::validation_array_unique(
--     $member_ids,
--     "MEMBER_IDS"
-- );
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_array_without_none(
    $value: option<any>,
    $field: string
) -> array {

    -- ------------------------------------------------------------------------
    -- 1. Validation du nom technique du champ
    -- ------------------------------------------------------------------------

    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    -- ------------------------------------------------------------------------
    -- 2. Vérification de la présence de la valeur globale
    -- ------------------------------------------------------------------------
    -- Une valeur globale NONE signifie que le tableau n'a pas été fourni.

    IF $value IS NONE {
        THROW string::concat(
            $clean_field,
            "_REQUIRED"
        );
    };

    -- ------------------------------------------------------------------------
    -- 3. Refus explicite de NULL comme valeur globale
    -- ------------------------------------------------------------------------
    -- Un tableau peut contenir NULL, mais le paramètre complet ne peut pas être
    -- égal à NULL.

    IF type::is_null($value) {
        THROW string::concat(
            $clean_field,
            "_NULL_NOT_ALLOWED"
        );
    };

    -- ------------------------------------------------------------------------
    -- 4. Vérification stricte du type array
    -- ------------------------------------------------------------------------

    IF !type::is_array($value) {
        THROW string::concat(
            $clean_field,
            "_INVALID_TYPE"
        );
    };

    -- ------------------------------------------------------------------------
    -- 5. Recherche d'un élément NONE
    -- ------------------------------------------------------------------------
    -- array::any() retourne true lorsqu'au moins un élément satisfait la
    -- condition fournie.
    --
    -- type::is_none() permet de distinguer précisément NONE de NULL et des
    -- autres valeurs fausses comme false, 0 ou une chaîne vide.

    LET $contains_none = array::any(
        $value,
        |$item| type::is_none($item)
    );

    -- ------------------------------------------------------------------------
    -- 6. Refus du tableau lorsqu'un élément NONE est détecté
    -- ------------------------------------------------------------------------

    IF $contains_none {
        THROW string::concat(
            $clean_field,
            "_NONE_NOT_ALLOWED"
        );
    };

    -- ------------------------------------------------------------------------
    -- 7. Retour du tableau validé
    -- ------------------------------------------------------------------------
    -- Le tableau d'origine est retourné sans suppression, tri ou modification.

    RETURN $value;
}
COMMENT "
Valide qu'une valeur obligatoire est strictement de type array et qu'aucun
élément de premier niveau n'est égal à NONE. Retourne le tableau d'origine sans
suppression ni transformation lorsqu'il est valide.
"
PERMISSIONS FULL;