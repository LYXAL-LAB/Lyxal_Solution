-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/min_length.surql
-- Fonction     : fn::validation_min_length
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Vérifie qu'une chaîne de caractères contient au minimum le nombre de
-- caractères demandé.
--
-- Cette fonction est une primitive de validation spécialisée. Elle est conçue
-- pour être utilisée lorsqu'une chaîne a déjà été contrôlée ou normalisée par
-- une fonction précédente.
--
-- Elle ne vérifie pas :
--
--   - si le champ est obligatoire ;
--   - si la valeur est NONE ;
--   - si la chaîne doit être nettoyée ;
--   - si une longueur maximale doit être appliquée ;
--   - si le contenu respecte un format particulier.
--
-- Ces responsabilités appartiennent à d'autres fonctions :
--
--   - fn::validation_required_string
--   - fn::validation_optional_string
--   - fn::validation_max_length
--   - fn::validation_regex
--
-- La fonction applique les règles suivantes :
--
--   1. Le nom technique du champ ne doit pas être vide ;
--   2. La longueur minimale ne doit pas être négative ;
--   3. La longueur de la chaîne est calculée ;
--   4. Une erreur est levée lorsque la chaîne est trop courte ;
--   5. La chaîne d'origine est retournée lorsqu'elle est valide.
--
-- La valeur n'est volontairement pas modifiée.
--
-- Paramètres
-- ----------
-- $value:
--   Type : string
--
--   Chaîne dont la longueur doit être contrôlée.
--
--   La valeur doit déjà être une chaîne valide. Cette fonction n'accepte pas
--   NONE, car elle ne gère pas le caractère obligatoire ou facultatif du
--   champ.
--
-- $field:
--   Type : string
--
--   Nom technique du champ utilisé pour construire le code d'erreur.
--
--   Convention recommandée :
--
--     - PASSWORD
--     - USERNAME
--     - TEAM_NAME
--     - EVENT_TITLE
--     - SEARCH_QUERY
--
-- $min_length:
--   Type : int
--
--   Nombre minimal de caractères autorisé.
--
--   La valeur doit être supérieure ou égale à zéro.
--
-- Valeur retournée
-- ----------------
-- Type : string
--
-- Retourne la chaîne d'origine sans modification lorsque sa longueur respecte
-- la limite minimale.
--
-- Exemple :
--
--   fn::validation_min_length(
--       "Administrateur",
--       "ROLE_LABEL",
--       3
--   )
--
-- retourne :
--
--   "Administrateur"
--
-- Erreurs générées
-- ----------------
-- <FIELD>_TOO_SHORT
--   La chaîne contient moins de caractères que la longueur minimale.
--
-- VALIDATION_INVALID_FIELD_NAME
--   Le nom technique du champ est vide ou composé uniquement d'espaces.
--
-- VALIDATION_INVALID_MIN_LENGTH
--   La longueur minimale fournie est négative.
--
-- Permissions
-- -----------
-- PERMISSIONS FULL
--
-- Cette fonction est une primitive pure :
--
--   - elle ne lit aucune table ;
--   - elle n'écrit aucune donnée ;
--   - elle ne consulte pas le contexte d'authentification ;
--   - elle ne révèle aucune information enregistrée ;
--   - elle agit uniquement sur ses paramètres ;
--   - elle ne possède aucun effet secondaire.
--
-- Elle peut donc être appelée par toutes les fonctions métier autorisées.
--
-- Les permissions concernant la lecture ou la modification du champ validé
-- doivent être appliquées dans la fonction métier appelante.
--
-- Dépendances
-- -----------
-- Fonctions natives SurrealDB :
--
--   - string::trim()
--   - string::len()
--   - string::concat()
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.
--
-- Exemples d'utilisation
-- ----------------------
-- LET $password = fn::validation_min_length(
--     $password,
--     "PASSWORD",
--     12
-- );
--
-- LET $username = fn::validation_min_length(
--     $username,
--     "USERNAME",
--     3
-- );
--
-- Utilisation avec validation_required_string :
--
-- LET $password = fn::validation_required_string(
--     $password,
--     "PASSWORD",
--     NONE,
--     128
-- );
--
-- LET $password = fn::validation_min_length(
--     $password,
--     "PASSWORD",
--     12
-- );
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_min_length(
    $value: string,
    $field: string,
    $min_length: int
) -> string {

    -- ------------------------------------------------------------------------
    -- 1. Validation du nom technique du champ
    -- ------------------------------------------------------------------------

    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    -- ------------------------------------------------------------------------
    -- 2. Validation de la configuration
    -- ------------------------------------------------------------------------

    IF $min_length < 0 {
        THROW "VALIDATION_INVALID_MIN_LENGTH";
    };

    -- ------------------------------------------------------------------------
    -- 3. Calcul de la longueur de la chaîne
    -- ------------------------------------------------------------------------

    LET $value_length = string::len($value);

    -- ------------------------------------------------------------------------
    -- 4. Contrôle de la longueur minimale
    -- ------------------------------------------------------------------------

    IF $value_length < $min_length {
        THROW string::concat(
            $clean_field,
            "_TOO_SHORT"
        );
    };

    -- ------------------------------------------------------------------------
    -- 5. Retour de la valeur validée
    -- ------------------------------------------------------------------------

    RETURN $value;
}
COMMENT "
Vérifie qu'une chaîne contient au minimum le nombre de caractères demandé.
Retourne la chaîne d'origine lorsqu'elle est valide ou interrompt l'exécution
avec un code d'erreur stable construit à partir du nom technique du champ.
"
PERMISSIONS FULL;