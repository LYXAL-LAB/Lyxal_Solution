-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/slug.surql
-- Fonction     : fn::validation_slug
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide et normalise une chaîne obligatoire destinée à être utilisée comme
-- slug technique.
--
-- Un slug est un identifiant textuel lisible principalement utilisé dans :
--
--   - les URL ;
--   - les identifiants fonctionnels ;
--   - les noms techniques de ressources ;
--   - les chemins d'API ;
--   - les références publiques ;
--   - les espaces de travail ;
--   - les équipes ;
--   - les événements ;
--   - les catégories.
--
-- Cette fonction applique les règles suivantes :
--
--   1. La valeur doit être présente ;
--   2. La valeur ne doit pas être vide après nettoyage ;
--   3. Les espaces périphériques sont supprimés ;
--   4. La valeur est convertie en minuscules ;
--   5. Une longueur maximale facultative peut être appliquée ;
--   6. Le slug doit commencer par un caractère alphanumérique ;
--   7. Le slug doit se terminer par un caractère alphanumérique ;
--   8. Seuls les caractères a à z, les chiffres et les tirets sont acceptés ;
--   9. Les tirets consécutifs sont interdits ;
--  10. La valeur normalisée est retournée.
--
-- Format accepté
-- --------------
-- Expression régulière :
--
--   ^[a-z0-9]+(?:-[a-z0-9]+)*$
--
-- Exemples valides :
--
--   equipe-commerciale
--   booking
--   booking-v2
--   equipe-2026
--   module-1
--   lyxal-os
--
-- Exemples invalides :
--
--   -equipe
--   equipe-
--   equipe--commerciale
--   equipe commerciale
--   équipe-commerciale
--   equipe_commerciale
--   equipe/commerciale
--   equipe.commerciale
--
-- Normalisation
-- -------------
-- La fonction convertit automatiquement les lettres majuscules en minuscules.
--
-- Exemple :
--
--   "  Equipe-Commerciale  "
--
-- devient :
--
--   "equipe-commerciale"
--
-- La fonction ne transforme toutefois pas :
--
--   - les espaces internes en tirets ;
--   - les caractères accentués ;
--   - les underscores ;
--   - les caractères spéciaux.
--
-- Ces transformations relèveront éventuellement d'une future fonction du
-- domaine core/sanitize, par exemple :
--
--   fn::sanitize_slug()
--
-- Cette fonction de validation doit uniquement vérifier et normaliser les
-- opérations simples qui ne modifient pas la signification de la valeur.
--
-- Paramètres
-- ----------
-- $value:
--   Type : option<string>
--
--   Valeur obligatoire à valider.
--
--   NONE, une chaîne vide ou une chaîne composée uniquement d'espaces
--   produisent l'erreur :
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
--     - WORKSPACE_SLUG
--     - EVENT_SLUG
--     - MODULE_SLUG
--     - CATEGORY_SLUG
--
-- $max_length:
--   Type : option<int>
--
--   Longueur maximale autorisée pour le slug.
--
--   Utiliser NONE lorsqu'aucune limite maximale particulière n'est requise.
--
--   Valeurs généralement recommandées :
--
--     - 50 caractères pour un identifiant court ;
--     - 100 caractères pour un slug métier ;
--     - 150 caractères pour une URL descriptive.
--
-- Valeur retournée
-- ----------------
-- Type : string
--
-- Retourne le slug :
--
--   - nettoyé ;
--   - converti en minuscules ;
--   - validé.
--
-- Exemple :
--
--   fn::validation_slug(
--       "  Booking-Equipe-01  ",
--       "TEAM_SLUG",
--       100
--   )
--
-- retourne :
--
--   "booking-equipe-01"
--
-- Erreurs générées
-- ----------------
-- <FIELD>_REQUIRED
--   La valeur est NONE, vide ou composée uniquement d'espaces.
--
-- <FIELD>_TOO_LONG
--   La valeur dépasse la longueur maximale configurée.
--
-- <FIELD>_INVALID_FORMAT
--   La valeur ne respecte pas le format d'un slug.
--
-- VALIDATION_INVALID_FIELD_NAME
--   Le nom technique du champ est vide.
--
-- VALIDATION_INVALID_MAX_LENGTH
--   La longueur maximale configurée est négative.
--
-- Permissions
-- -----------
-- PERMISSIONS FULL
--
-- Cette fonction peut être appelée par toutes les fonctions métier autorisées
-- parce qu'elle :
--
--   - ne consulte aucune table ;
--   - ne modifie aucune donnée ;
--   - ne dépend pas du contexte d'authentification ;
--   - ne révèle aucune information enregistrée ;
--   - agit uniquement sur les paramètres transmis ;
--   - ne possède aucun effet secondaire.
--
-- Attention :
--
-- Cette fonction vérifie uniquement le format du slug.
-- Elle ne contrôle pas son unicité dans une table.
--
-- Le contrôle d'unicité devra être réalisé séparément, par exemple avec une
-- future fonction :
--
--   fn::validation_unique()
--
-- ou directement dans la fonction métier.
--
-- Dépendances natives SurrealDB
-- -----------------------------
--   - string::lowercase()
--
-- Dépendances Lyxal
-- -----------------
--   - fn::validation_required_string
--   - fn::validation_regex
--
-- Ordre de chargement
-- -------------------
-- Cette fonction doit être importée après :
--
--   1. required_string.surql
--   2. regex.surql
--
-- Exemples d'utilisation
-- ----------------------
-- LET $slug = fn::validation_slug(
--     $slug,
--     "TEAM_SLUG",
--     100
-- );
--
-- LET $workspace_slug = fn::validation_slug(
--     $workspace_slug,
--     "WORKSPACE_SLUG",
--     50
-- );
--
-- LET $category_slug = fn::validation_slug(
--     $category_slug,
--     "CATEGORY_SLUG",
--     NONE
-- );
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_slug(
    $value: option<string>,
    $field: string,
    $max_length: option<int>
) -> string {

    -- ------------------------------------------------------------------------
    -- 1. Validation de la chaîne obligatoire
    -- ------------------------------------------------------------------------
    -- Cette étape contrôle :
    --
    --   - la présence de la valeur ;
    --   - l'absence d'une chaîne vide ;
    --   - le nettoyage des espaces périphériques ;
    --   - la longueur maximale facultative.
    --
    -- La longueur minimale est fixée à 1 caractère.

    LET $clean_value = fn::validation_required_string(
        $value,
        $field,
        1,
        $max_length
    );

    -- ------------------------------------------------------------------------
    -- 2. Normalisation de la casse
    -- ------------------------------------------------------------------------
    -- Les slugs sont toujours retournés en minuscules afin d'éviter les
    -- différences de casse dans les URL, recherches et contraintes d'unicité.

    LET $normalized_value = string::lowercase(
        $clean_value
    );

    -- ------------------------------------------------------------------------
    -- 3. Validation du format du slug
    -- ------------------------------------------------------------------------
    -- Règles imposées :
    --
    --   - lettres minuscules de a à z ;
    --   - chiffres de 0 à 9 ;
    --   - tirets simples entre les groupes ;
    --   - aucun tiret au début ;
    --   - aucun tiret à la fin ;
    --   - aucun double tiret.

    LET $validated_slug = fn::validation_regex(
        $normalized_value,
        $field,
        "^[a-z0-9]+(?:-[a-z0-9]+)*$"
    );

    -- ------------------------------------------------------------------------
    -- 4. Retour du slug normalisé et validé
    -- ------------------------------------------------------------------------

    RETURN $validated_slug;
}
COMMENT "
Valide et normalise un slug obligatoire. La valeur est nettoyée, convertie en
minuscules puis contrôlée afin de n'autoriser que les lettres de a à z, les
chiffres et les tirets simples placés entre des groupes alphanumériques.
"
PERMISSIONS FULL;