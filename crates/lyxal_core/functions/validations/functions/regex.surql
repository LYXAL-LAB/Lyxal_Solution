-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/regex.surql
-- Fonction     : fn::validation_regex
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Vérifie qu'une chaîne de caractères respecte une expression régulière.
--
-- Cette fonction constitue une primitive générique destinée à valider les
-- formats textuels qui ne peuvent pas être contrôlés uniquement par une
-- longueur minimale, une longueur maximale ou une liste de valeurs.
--
-- Exemples de formats concernés :
--
--   - slug ;
--   - nom d'utilisateur ;
--   - code interne ;
--   - référence commerciale ;
--   - identifiant technique ;
--   - numéro de version ;
--   - code postal ;
--   - format métier spécifique ;
--   - caractères autorisés dans un champ.
--
-- La fonction applique les règles suivantes :
--
--   1. Le nom technique du champ ne doit pas être vide ;
--   2. Le motif de validation ne doit pas être vide ;
--   3. La valeur doit être présente ;
--   4. La valeur ne doit pas être vide après suppression des espaces
--      périphériques ;
--   5. La valeur est comparée au motif avec string::matches() ;
--   6. Une erreur est levée si le motif ne correspond pas ;
--   7. La chaîne nettoyée est retournée lorsqu'elle est valide.
--
-- La fonction considère la valeur comme obligatoire.
--
-- Pour un champ facultatif, la fonction métier appelante doit d'abord utiliser
-- fn::validation_optional_string(), puis appeler ce validateur uniquement
-- lorsqu'une valeur différente de NONE est retournée.
--
-- Important
-- ---------
-- Cette fonction utilise string::matches(), qui recherche une correspondance
-- avec l'expression régulière fournie.
--
-- Pour imposer la correspondance de la chaîne entière, il est recommandé
-- d'utiliser les ancres :
--
--   ^  début de chaîne
--   $  fin de chaîne
--
-- Exemple :
--
--   ^[a-z0-9]+(?:-[a-z0-9]+)*$
--
-- Sans ces ancres, un motif peut seulement correspondre à une partie de la
-- chaîne.
--
-- Paramètres
-- ----------
-- $value:
--   Type : option<string>
--
--   Chaîne obligatoire à contrôler.
--
--   NONE ou une chaîne vide après nettoyage produisent l'erreur :
--
--     <FIELD>_REQUIRED
--
-- $field:
--   Type : string
--
--   Nom technique du champ utilisé pour construire les codes d'erreur.
--
--   Convention recommandée :
--
--     - TEAM_SLUG
--     - USERNAME
--     - PRODUCT_REFERENCE
--     - POSTAL_CODE
--     - VERSION_NUMBER
--
-- $pattern:
--   Type : string
--
--   Expression régulière utilisée pour valider la valeur.
--
--   Exemples :
--
--     Slug :
--       ^[a-z0-9]+(?:-[a-z0-9]+)*$
--
--     Nom d'utilisateur :
--       ^[a-zA-Z0-9_-]{3,50}$
--
--     Code postal français :
--       ^[0-9]{5}$
--
--     Version simple :
--       ^[0-9]+\.[0-9]+\.[0-9]+$
--
--   Le motif ne doit pas être vide ou composé uniquement d'espaces.
--
-- Valeur retournée
-- ----------------
-- Type : string
--
-- Retourne la chaîne nettoyée avec string::trim() lorsqu'elle respecte
-- l'expression régulière.
--
-- Exemple :
--
--   fn::validation_regex(
--       "  mon-equipe  ",
--       "TEAM_SLUG",
--       "^[a-z0-9]+(?:-[a-z0-9]+)*$"
--   )
--
-- retourne :
--
--   "mon-equipe"
--
-- Erreurs générées
-- ----------------
-- <FIELD>_REQUIRED
--   La valeur est NONE, vide ou composée uniquement d'espaces.
--
-- <FIELD>_INVALID_FORMAT
--   La valeur ne respecte pas l'expression régulière fournie.
--
-- VALIDATION_INVALID_FIELD_NAME
--   Le nom technique du champ est vide ou composé uniquement d'espaces.
--
-- VALIDATION_EMPTY_REGEX_PATTERN
--   Le motif est vide ou composé uniquement d'espaces.
--
-- Erreur native SurrealDB
--   Si le motif fourni n'est pas une expression régulière valide, le moteur
--   peut interrompre l'exécution avec une erreur native de compilation ou
--   d'évaluation du motif.
--
-- Permissions
-- -----------
-- PERMISSIONS FULL
--
-- Cette fonction peut être appelée par tous les utilisateurs autorisés à
-- exécuter les fonctions métier qui l'utilisent, car :
--
--   - elle ne consulte aucune table ;
--   - elle n'écrit aucune donnée ;
--   - elle ne dépend pas du contexte d'authentification ;
--   - elle ne révèle aucune donnée enregistrée ;
--   - elle agit uniquement sur ses paramètres ;
--   - elle ne possède aucun effet secondaire.
--
-- Les autorisations concernant la lecture ou la modification du champ validé
-- restent sous la responsabilité de la fonction métier appelante.
--
-- Dépendances
-- -----------
-- Fonctions natives SurrealDB :
--
--   - string::trim()
--   - string::matches()
--   - string::concat()
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.
--
-- Exemples d'utilisation
-- ----------------------
-- LET $slug = fn::validation_regex(
--     $slug,
--     "TEAM_SLUG",
--     "^[a-z0-9]+(?:-[a-z0-9]+)*$"
-- );
--
-- LET $postal_code = fn::validation_regex(
--     $postal_code,
--     "POSTAL_CODE",
--     "^[0-9]{5}$"
-- );
--
-- LET $username = fn::validation_regex(
--     $username,
--     "USERNAME",
--     "^[a-zA-Z0-9_-]{3,50}$"
-- );
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_regex(
    $value: option<string>,
    $field: string,
    $pattern: string
) -> string {

    -- ------------------------------------------------------------------------
    -- 1. Validation du nom technique du champ
    -- ------------------------------------------------------------------------

    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    -- ------------------------------------------------------------------------
    -- 2. Validation de l'expression régulière
    -- ------------------------------------------------------------------------
    -- Le motif ne doit pas être vide.
    -- Les espaces internes ne sont pas supprimés, car ils peuvent faire partie
    -- volontairement de l'expression régulière.

    IF string::trim($pattern) = "" {
        THROW "VALIDATION_EMPTY_REGEX_PATTERN";
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
    -- 4. Nettoyage de la valeur
    -- ------------------------------------------------------------------------

    LET $clean_value = string::trim($value);

    IF $clean_value = "" {
        THROW string::concat(
            $clean_field,
            "_REQUIRED"
        );
    };

    -- ------------------------------------------------------------------------
    -- 5. Vérification du format
    -- ------------------------------------------------------------------------

    LET $matches_pattern = string::matches(
        $clean_value,
        $pattern
    );

    IF !$matches_pattern {
        THROW string::concat(
            $clean_field,
            "_INVALID_FORMAT"
        );
    };

    -- ------------------------------------------------------------------------
    -- 6. Retour de la valeur validée et nettoyée
    -- ------------------------------------------------------------------------

    RETURN $clean_value;
}
COMMENT "
Vérifie qu'une chaîne obligatoire respecte une expression régulière fournie.
La valeur est nettoyée avec string::trim() puis contrôlée avec
string::matches(). Retourne la chaîne nettoyée lorsqu'elle est valide ou
interrompt l'exécution avec un code d'erreur stable.
"
PERMISSIONS FULL;