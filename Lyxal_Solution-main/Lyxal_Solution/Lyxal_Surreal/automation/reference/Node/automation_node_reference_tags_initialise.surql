-- Initialisation de la fonction pour les tags de référence des nodes d'automatisation
DEFINE FUNCTION IF NOT EXISTS fn::automation_node_reference_tags_initialise(
  $parent_run_id: option<string>
) {
    -- Paramètres
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_automation'];
    LET $run_id = rand::uuid();

    -- Journalisation du début
    fn::system_log_helper_initialise(
        'data_reference', 'start', 'automation_node_reference_tags',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );
    
    -- Création individuelle des tags sans liste intermédiaire et sans utilisateur
    fn::automation_tag_resources_create('Ventes', true, true, 'error', NONE);
    fn::automation_tag_resources_create('Marketing', true, true, 'warning', NONE);
    fn::automation_tag_resources_create('Productivité', true, true, 'success', NONE);
    fn::automation_tag_resources_create('Données & Stockage', true, true, 'info', NONE);
    fn::automation_tag_resources_create('Développement', true, true, 'neutral', NONE);
    fn::automation_tag_resources_create('Nœuds Principaux', true, true, 'neutral', NONE);
    fn::automation_tag_resources_create('Communication', true, true, 'primary', NONE);
    fn::automation_tag_resources_create('Divers', true, true, 'accent', NONE);
    fn::automation_tag_resources_create('Utilitaire', true, true, 'warning', NONE);
    fn::automation_tag_resources_create('Finance & Comptabilité', true, true, 'success', NONE);
    fn::automation_tag_resources_create('Analyse', true, true, 'warning', NONE);
    fn::automation_tag_resources_create('Intervention Humaine', true, true, 'error', NONE);
    fn::automation_tag_resources_create('Outils Développeur', true, true, 'neutral', NONE);
    
    -- Journalisation de la fin
    fn::system_log_helper_initialise(
        'data_reference', 'done', 'automation_node_reference_tags',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    -- Retour
    RETURN {
        success: true,
        run_id: $run_id,
        parent_run_id: $parent_run_id
    };
}
COMMENT 'Initialise la fonction de création des tags de référence pour les catégories de nodes.'
PERMISSIONS FULL;
