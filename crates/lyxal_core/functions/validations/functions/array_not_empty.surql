-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/array_not_empty.surql
-- Fonction     : fn::validation_array_not_empty
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Vérifie qu'une valeur obligatoire est strictement de type array et que le
-- tableau contient au moins un élément.
--
-- Cette fonction est destinée aux champs nécessitant une collection non vide,
-- par exemple :
--
--   - une liste de membres ;
--   - une liste d'identifiants ;
--   - une liste de permissions ;
--   - une liste de destinataires ;
--   - une liste de catégories ;
--   - une liste de ressources ;
--   - une liste de créneaux ;
--   - une liste de fichiers ;
--   - une liste d'actions ;
--   - une liste de rôles.
--
-- La fonction applique une validation stricte.
--
-- Elle accepte :
--
--   ["admin"]
--   [user:one, user:two]
--   [1, 2, 3]
--   [{ name: "Test" }]
--
-- Elle refuse :
--
--   NONE
--   []
--   "admin"
--   {}
--   1
--   true
--
-- Cette fonction vérifie uniquement :
--
--   - la présence de la valeur ;
--   - le type array ;
--   - la présence d'au moins un élément.
--
-- Elle ne vérifie pas :
--
--   - le type des éléments ;
--   - l'unicité des éléments ;
--   - l'absence de valeurs NONE ou NULL ;
--   - la validité des Record IDs contenus ;
--   - une longueur maximale ;
--   - une longueur minimale supérieure à un élément.
--
-- Ces règles pourront être assurées par d'autres fonctions spécialisées,
-- par exemple :
--
--   fn::validation_array_length()
--   fn::validation_array_unique()
--   fn::validation_array_of_strings()
--   fn::validation_array_of_records()
--   fn::validation_array_without_none()
--
-- Règles appliquées
-- -----------------
--   1. Le nom technique du champ doit être renseigné ;
--   2. La valeur doit être présente ;
--   3. La valeur doit être strictement de type array ;
--   4. Le tableau doit contenir au moins un élément ;
--   5. Le tableau d'origine est retourné lorsqu'il est valide.
--
-- Paramètres
-- ----------
-- $value:
--   Type : option<any>
--
--   Valeur obligatoire à contrôler.
--
--   Le type option<any> permet à la fonction de recevoir :
--
--     - une valeur NONE ;
--     - un tableau ;
--     - une valeur d'un autre type.
--
--   Cela permet de produire des codes d'erreur métier explicites plutôt que
--   de laisser le contrôle de type interrompre l'appel avant l'exécution du
--   corps de la fonction.
--
-- $field:
--   Type : string
--
--   Nom technique du champ utilisé pour construire les codes d'erreur.
--
--   Convention recommandée :
--
--     - MEMBER_IDS
--     - RECIPIENTS
--     - PERMISSIONS
--     - CATEGORY_IDS
--     - RESOURCE_IDS
--     - ATTACHMENTS
--     - ACTIONS
--
-- Valeur retournée
-- ----------------
-- Type : array
--
-- Retourne le tableau d'origine sans modification lorsqu'il contient au moins
-- un élément.
--
-- Exemple :
--
--   fn::validation_array_not_empty(
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
--   La valeur est absente ou égale à NONE.
--
-- <FIELD>_INVALID_TYPE
--   La valeur fournie n'est pas de type array.
--
-- <FIELD>_EMPTY
--   Le tableau existe, mais ne contient aucun élément.
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
-- Les autorisations relatives aux éléments contenus dans le tableau restent
-- sous la responsabilité de la fonction métier appelante.
--
-- Par exemple, la présence d'un Record ID dans un tableau ne signifie pas que
-- l'utilisateur est autorisé à consulter ou modifier cet enregistrement.
--
-- Dépendances natives SurrealDB
-- -----------------------------
--   - string::trim()
--   - string::concat()
--   - type::is_array()
--   - array::len()
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
-- Liste de membres obligatoire :
--
-- LET $member_ids = fn::validation_array_not_empty(
--     $member_ids,
--     "MEMBER_IDS"
-- );
--
-- Liste de destinataires obligatoire :
--
-- LET $recipients = fn::validation_array_not_empty(
--     $recipients,
--     "RECIPIENTS"
-- );
--
-- Liste de permissions obligatoire :
--
-- LET $permissions = fn::validation_array_not_empty(
--     $permissions,
--     "PERMISSIONS"
-- );
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_array_not_empty(
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
    -- 2. Vérification de la présence de la valeur
    -- ------------------------------------------------------------------------

    IF $value IS NONE {
        THROW string::concat(
            $clean_field,
            "_REQUIRED"
        );
    };

    -- ------------------------------------------------------------------------
    -- 3. Vérification stricte du type array
    -- ------------------------------------------------------------------------
    -- type::is_array() garantit que la valeur reçue est réellement un tableau.
    --
    -- Une chaîne, un objet, un nombre ou un booléen sont refusés, même s'ils
    -- pourraient techniquement être convertis en tableau.

    IF !type::is_array($value) {
        THROW string::concat(
            $clean_field,
            "_INVALID_TYPE"
        );
    };

    -- ------------------------------------------------------------------------
    -- 4. Vérification du contenu du tableau
    -- ------------------------------------------------------------------------
    -- array::len() compte tous les éléments du tableau, y compris les valeurs
    -- NONE, NULL, false ou 0.
    --
    -- Cette fonction vérifie uniquement qu'un élément est présent. Une future
    -- fonction pourra contrôler la validité individuelle des éléments.

    IF array::len($value) = 0 {
        THROW string::concat(
            $clean_field,
            "_EMPTY"
        );
    };

    -- ------------------------------------------------------------------------
    -- 5. Retour du tableau validé
    -- ------------------------------------------------------------------------

    RETURN $value;
}
COMMENT "
Valide qu'une valeur obligatoire est strictement de type array et que le
tableau contient au moins un élément. Retourne le tableau d'origine lorsqu'il
est valide ou interrompt l'exécution avec un code d'erreur stable.
"
PERMISSIONS FULL;