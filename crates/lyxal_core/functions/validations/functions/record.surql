-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/record.surql
-- Fonction     : fn::validation_record
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Valide et normalise un identifiant d'enregistrement SurrealDB.
--
-- Cette fonction accepte :
--
--   - un identifiant simple, par exemple "team_001" ;
--   - un identifiant complet, par exemple "booking_team:team_001".
--
-- Lorsque seul l'identifiant est fourni, la fonction construit automatiquement
-- le Record ID à partir de la table attendue.
--
-- Exemple :
--
--   valeur reçue   : "team_001"
--   table attendue : "booking_team"
--
--   résultat :
--
--   booking_team:team_001
--
-- Lorsque la valeur contient déjà un nom de table, la fonction vérifie que
-- cette table correspond exactement à la table attendue.
--
-- Exemple valide :
--
--   booking_team:team_001
--
-- Exemple invalide :
--
--   booking_account:team_001
--
-- Cette fonction valide uniquement la forme du Record ID et la table associée.
-- Elle ne vérifie pas que l'enregistrement existe réellement en base.
--
-- Le contrôle d'existence sera réalisé par une fonction distincte :
--
--   fn::validation_record_exists
--
-- Règles appliquées
-- -----------------
--   1. Le nom technique du champ doit être renseigné ;
--   2. Le nom de la table attendue doit être renseigné ;
--   3. La valeur doit être présente ;
--   4. La valeur ne doit pas être vide après nettoyage ;
--   5. Un identifiant simple est converti en Record ID ;
--   6. Un Record ID complet doit appartenir à la table attendue ;
--   7. L'identifiant situé après les deux-points ne doit pas être vide ;
--   8. Le Record ID normalisé est retourné.
--
-- Paramètres
-- ----------
-- $value:
--   Type : option<string>
--
--   Identifiant obligatoire à valider.
--
--   Formats acceptés :
--
--     "team_001"
--     "booking_team:team_001"
--
-- $field:
--   Type : string
--
--   Nom technique du champ utilisé pour construire les codes d'erreur.
--
--   Exemples :
--
--     TEAM_ID
--     USER_ID
--     WORKSPACE_ID
--     BOOKING_ID
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
--
-- Valeur retournée
-- ----------------
-- Type : record
--
-- Retourne un Record ID SurrealDB normalisé.
--
-- Exemples :
--
--   "team_001"
--
-- devient :
--
--   booking_team:team_001
--
--   "booking_team:team_001"
--
-- reste :
--
--   booking_team:team_001
--
-- Erreurs générées
-- ----------------
-- <FIELD>_REQUIRED
--   La valeur est NONE ou vide.
--
-- <FIELD>_INVALID
--   L'identifiant est incomplet ou ne peut pas être transformé.
--
-- <FIELD>_INVALID_TABLE
--   Le Record ID appartient à une autre table.
--
-- VALIDATION_INVALID_FIELD_NAME
--   Le nom technique du champ est vide.
--
-- VALIDATION_INVALID_TABLE_NAME
--   Le nom de la table attendue est vide.
--
-- Permissions
-- -----------
-- PERMISSIONS FULL
--
-- Cette fonction :
--
--   - ne lit aucune donnée ;
--   - ne vérifie pas l'existence d'un enregistrement ;
--   - n'écrit aucune donnée ;
--   - ne dépend pas du contexte d'authentification ;
--   - agit uniquement sur les paramètres transmis.
--
-- Elle peut donc être appelée par toutes les fonctions métier autorisées.
--
-- Dépendances natives SurrealDB
-- -----------------------------
--   - string::trim()
--   - string::split()
--   - array::len()
--   - type::record()
--   - string::concat()
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.
--
-- Exemples d'utilisation
-- ----------------------
-- LET $team_id = fn::validation_record(
--     $team_id,
--     "TEAM_ID",
--     "booking_team"
-- );
--
-- LET $user_id = fn::validation_record(
--     $user_id,
--     "USER_ID",
--     "identity_user"
-- );
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_record(
    $value: option<string>,
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

    LET $clean_value = string::trim($value);

    IF $clean_value = "" {
        THROW string::concat(
            $clean_field,
            "_REQUIRED"
        );
    };

    -- ------------------------------------------------------------------------
    -- 4. Découpage de la valeur
    -- ------------------------------------------------------------------------

    LET $parts = string::split(
        $clean_value,
        ":"
    );

    LET $parts_count = array::len($parts);

    -- ------------------------------------------------------------------------
    -- 5. Traitement d'un identifiant simple
    -- ------------------------------------------------------------------------
    -- Exemple :
    --
    --   team_001
    --
    -- devient :
    --
    --   booking_team:team_001

    IF $parts_count = 1 {

        LET $record_id = string::trim($parts[0]);

        IF $record_id = "" {
            THROW string::concat(
                $clean_field,
                "_INVALID"
            );
        };

        RETURN type::record(
            $clean_table,
            $record_id
        );
    };

    -- ------------------------------------------------------------------------
    -- 6. Validation d'un Record ID complet
    -- ------------------------------------------------------------------------
    -- Un Record ID textuel simple doit contenir exactement :
    --
    --   table:id
    --
    -- Toute valeur contenant plusieurs séparateurs est refusée ici afin
    -- d'éviter une interprétation ambiguë.

    IF $parts_count != 2 {
        THROW string::concat(
            $clean_field,
            "_INVALID"
        );
    };

    LET $received_table = string::trim($parts[0]);
    LET $record_id = string::trim($parts[1]);

    -- ------------------------------------------------------------------------
    -- 7. Vérification de la table
    -- ------------------------------------------------------------------------

    IF $received_table != $clean_table {
        THROW string::concat(
            $clean_field,
            "_INVALID_TABLE"
        );
    };

    -- ------------------------------------------------------------------------
    -- 8. Vérification de l'identifiant
    -- ------------------------------------------------------------------------

    IF $record_id = "" {
        THROW string::concat(
            $clean_field,
            "_INVALID"
        );
    };

    -- ------------------------------------------------------------------------
    -- 9. Retour du Record ID normalisé
    -- ------------------------------------------------------------------------

    RETURN type::record(
        $clean_table,
        $record_id
    );
}
COMMENT "
Valide un identifiant d'enregistrement SurrealDB. Accepte un identifiant simple
ou un identifiant complet au format table:id, vérifie la table attendue et
retourne un Record ID normalisé. Ne contrôle pas l'existence de l'enregistrement.
"
PERMISSIONS FULL;