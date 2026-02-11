--
-- @name automation_credential_create_table_initialise
-- @description Initialise la table `automation_credential` pour stocker les credentials.
--
-- @related
--   - function:fn::automation_deploy_initialise
--
DEFINE FUNCTION fn::automation_credential_create_table_initialise(
    $parent_run_id: option<string>
) {
    -- Paramètres
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_automation'];
    LET $run_id = rand::uuid();

    -- Création du log de début
    fn::system_log_create_record_system(['automation_credential_create_table_initialise', 'start'],
    'Initialisation de la table `automation_credential`.',
    { log_extra_tags: $log_extra_tags, run_id: $run_id, parent_run_id: $parent_run_id });

    --
    -- Initialise la table `automation_credential`.
    -- Cette table stocke les informations d'authentification (clés API, tokens OAuth, etc.)
    -- de manière sécurisée. Les données sensibles dans le champ `data` sont destinées
    -- à être chiffrées avant d'être stockées.
    --
    DEFINE TABLE IF NOT EXISTS automation_credential SCHEMAFULL TYPE NORMAL
        COMMENT "Stocke les credentials (jetons, clés API) utilisés par les jobs d'automatisation.";

    -- == Champs principaux
    DEFINE FIELD IF NOT EXISTS name ON TABLE automation_credential TYPE string
        COMMENT "Nom unique et descriptif du credential (ex: 'Mon compte OpenAI')."
        ASSERT string::len($value) > 0 AND string::len($value) <= 128;

    DEFINE FIELD IF NOT EXISTS service ON TABLE automation_credential TYPE record<automation_service>
        COMMENT "Lien vers le service (ex: Google Sheets) auquel ce credential est associé."
        ASSERT $value != NONE;

    DEFINE FIELD IF NOT EXISTS data ON TABLE automation_credential FLEXIBLE TYPE object
        COMMENT "Objet contenant les données d'authentification, chiffrées.";

    -- == Timestamps
    DEFINE FIELD IF NOT EXISTS created_at ON TABLE automation_credential TYPE datetime
        COMMENT "Date et heure de création du credential."
        VALUE $value OR time::now();
    DEFINE FIELD IF NOT EXISTS updated_at ON TABLE automation_credential TYPE datetime
        COMMENT "Date et heure de la dernière mise à jour du credential."
        VALUE $value OR time::now();

    -- == Index
    -- Assure que le nom d'un credential est unique.
    DEFINE INDEX IF NOT EXISTS credential_name_unique ON TABLE automation_credential 
    FIELDS name UNIQUE
    COMMENT "Index sur le nom d'un credential.";

    -- Création du log de succès
    fn::system_log_create_record_system(['automation_credential_create_table_initialise', 'success'],
    'Table `automation_credential` initialisée avec succès.',
    { log_extra_tags: $log_extra_tags, run_id: $run_id, parent_run_id: $parent_run_id });

    RETURN {
        success: true,
        run_id: $run_id,
        parent_run_id: $parent_run_id
    };
}
