-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/enum.surql
-- Fonction     : fn::validation_enum
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Vérifie qu'une chaîne de caractères appartient à une liste de valeurs
-- autorisées.
--
-- Cette fonction constitue une primitive générique pour valider les champs
-- dont la valeur doit être choisie dans un ensemble fermé.
--
-- Exemples de champs concernés :
--
--   - rôle d'un utilisateur ;
--   - statut d'une réservation ;
--   - niveau de priorité ;
--   - mode de visibilité ;
--   - type d'événement ;
--   - état d'une tâche ;
--   - catégorie technique ;
--   - stratégie d'exécution.
--
-- La fonction applique les règles suivantes :
--
--   1. Le nom technique du champ ne doit pas être vide ;
--   2. La liste des valeurs autorisées ne doit pas être vide ;
--   3. La valeur doit être présente et non vide ;
--   4. La valeur est nettoyée avec string::trim() ;
--   5. La comparaison peut être sensible ou insensible à la casse ;
--   6. Une erreur est levée si la valeur n'appartient pas à la liste ;
--   7. La valeur validée et normalisée est retournée.
--
-- Lorsque $case_sensitive vaut false, la fonction :
--
--   - convertit la valeur reçue en minuscules ;
--   - convertit chaque valeur autorisée en minuscules ;
--   - retourne la valeur normalisée en minuscules.
--
-- Lorsque $case_sensitive vaut true, la comparaison respecte exactement la
-- casse des caractères et la valeur nettoyée est retournée sans conversion.
--
-- Paramètres
-- ----------
-- $value:
--   Type : option<string>
--
--   Valeur à vérifier.
--
--   La valeur est considérée comme obligatoire par cette fonction.
--   NONE ou une chaîne vide produisent une erreur <FIELD>_REQUIRED.
--
-- $field:
--   Type : string
--
--   Nom technique du champ utilisé pour construire les codes d'erreur.
--
--   Convention recommandée :
--
--     - TEAM_ROLE
--     - BOOKING_STATUS
--     - EVENT_VISIBILITY
--     - TASK_PRIORITY
--     - JOB_STATE
--
-- $allowed:
--   Type : array<string>
--
--   Liste exhaustive des valeurs autorisées.
--
--   Exemple :
--
--     ["owner", "admin", "member"]
--
--   La liste ne doit pas être vide.
--
-- $case_sensitive:
--   Type : bool
--
--   Définit le comportement de comparaison.
--
--   false :
--     La comparaison est insensible à la casse.
--     "ADMIN", "Admin" et "admin" sont considérés comme équivalents.
--
--   true :
--     La comparaison est sensible à la casse.
--     "Admin" et "admin" sont considérés comme différents.
--
-- Valeur retournée
-- ----------------
-- Type : string
--
-- Si $case_sensitive vaut false :
--   retourne la valeur nettoyée et convertie en minuscules.
--
-- Si $case_sensitive vaut true :
--   retourne la valeur nettoyée sans modification de casse.
--
-- Exemples
-- --------
-- Entrée :
--   value          = " ADMIN "
--   allowed        = ["owner", "admin", "member"]
--   case_sensitive = false
--
-- Retour :
--   "admin"
--
-- Entrée :
--   value          = "Admin"
--   allowed        = ["Admin", "Member"]
--   case_sensitive = true
--
-- Retour :
--   "Admin"
--
-- Erreurs générées
-- ----------------
-- <FIELD>_REQUIRED
--   La valeur est NONE, vide ou composée uniquement d'espaces.
--
-- <FIELD>_INVALID
--   La valeur n'appartient pas à la liste autorisée.
--
-- VALIDATION_INVALID_FIELD_NAME
--   Le nom technique du champ est vide ou composé uniquement d'espaces.
--
-- VALIDATION_EMPTY_ALLOWED_VALUES
--   La liste des valeurs autorisées est vide.
--
-- VALIDATION_INVALID_ALLOWED_VALUE
--   Une valeur de la liste autorisée est vide après nettoyage.
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
--   - elle agit uniquement sur les paramètres transmis ;
--   - elle ne possède aucun effet secondaire.
--
-- Elle peut donc être utilisée par toutes les fonctions métier autorisées.
--
-- Les règles déterminant la liste des valeurs autorisées doivent être définies
-- par la fonction métier appelante ou par un validateur spécialisé du module.
--
-- Dépendances
-- -----------
-- Fonctions natives SurrealDB :
--
--   - string::trim()
--   - string::lowercase()
--   - string::concat()
--   - array::len()
--   - array::map()
--   - array::any()
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.
--
-- Exemples d'utilisation
-- ----------------------
-- LET $role = fn::validation_enum(
--     $role,
--     "TEAM_ROLE",
--     ["owner", "admin", "member"],
--     false
-- );
--
-- LET $visibility = fn::validation_enum(
--     $visibility,
--     "EVENT_VISIBILITY",
--     ["PUBLIC", "PRIVATE", "INTERNAL"],
--     true
-- );
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_enum(
    $value: option<string>,
    $field: string,
    $allowed: array<string>,
    $case_sensitive: bool
) -> string {

    -- ------------------------------------------------------------------------
    -- 1. Validation du nom technique du champ
    -- ------------------------------------------------------------------------

    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    -- ------------------------------------------------------------------------
    -- 2. Validation de la liste des valeurs autorisées
    -- ------------------------------------------------------------------------

    IF array::len($allowed) = 0 {
        THROW "VALIDATION_EMPTY_ALLOWED_VALUES";
    };

    -- Chaque valeur autorisée doit elle-même être exploitable.

    LET $contains_invalid_allowed_value = array::any(
        $allowed,
        |$allowed_value| string::trim($allowed_value) = ""
    );

    IF $contains_invalid_allowed_value {
        THROW "VALIDATION_INVALID_ALLOWED_VALUE";
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

    LET $clean_value = string::trim($value);

    IF $clean_value = "" {
        THROW string::concat(
            $clean_field,
            "_REQUIRED"
        );
    };

    -- ------------------------------------------------------------------------
    -- 4. Comparaison sensible à la casse
    -- ------------------------------------------------------------------------

    IF $case_sensitive {

        LET $clean_allowed = array::map(
            $allowed,
            |$allowed_value| string::trim($allowed_value)
        );

        IF $clean_value NOT IN $clean_allowed {
            THROW string::concat(
                $clean_field,
                "_INVALID"
            );
        };

        RETURN $clean_value;
    };

    -- ------------------------------------------------------------------------
    -- 5. Comparaison insensible à la casse
    -- ------------------------------------------------------------------------

    LET $normalized_value = string::lowercase($clean_value);

    LET $normalized_allowed = array::map(
        $allowed,
        |$allowed_value|
            string::lowercase(
                string::trim($allowed_value)
            )
    );

    IF $normalized_value NOT IN $normalized_allowed {
        THROW string::concat(
            $clean_field,
            "_INVALID"
        );
    };

    -- ------------------------------------------------------------------------
    -- 6. Retour de la valeur validée et normalisée
    -- ------------------------------------------------------------------------

    RETURN $normalized_value;
}
COMMENT "
Vérifie qu'une chaîne obligatoire appartient à une liste fermée de valeurs
autorisées. La comparaison peut être sensible ou insensible à la casse.
Retourne la valeur validée et normalisée ou interrompt l'exécution avec un code
d'erreur stable construit à partir du nom technique du champ.
"
PERMISSIONS FULL;