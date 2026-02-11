-- =================================================================================================
-- DEBUT DE L'INITIALISATION DE LA FONCTION `fn::scheduler::tasks::process_user_group_changes`
-- =================================================================================================

DEFINE FUNCTION fn::scheduler_tasks_process_user_group_changes_initialise() {
    -- Création de la fonction
    fn::system_log_create_record_system(['scheduler_tasks_process_user_group_changes_initialise', 'start'], 'Initialisation de la fonction `fn::scheduler::tasks::process_user_group_changes`.');

    DEFINE FUNCTION fn::scheduler::tasks::process_user_group_changes() {
        // Cette fonction traite les changements de groupe d'utilisateurs en attente.
        // Elle simule la logique du script PHP `ProcessUserGroupChanges.php`.
        
        LET $changes = SELECT * FROM scheduler_usergroupchange WHERE processed_at IS NONE ORDER BY created_at ASC;
        
        LET $failed_user_ids = [];
        
        FOR $change IN $changes {
            // Si une mise à jour a déjà échoué pour cet utilisateur, on ignore les suivantes pour ne pas les traiter dans le désordre.
            IF $change.userid IN $failed_user_ids {
                CONTINUE;
            }
            
            BEGIN TRANSACTION;
            
            // --- Logique de propagation vers les noeuds (simulée) ---
            // Dans l'architecture originale, il y a ici un appel RPC vers chaque noeud où l'utilisateur a des jobs.
            // LET $nodes = fn::scheduler::resources::node::get_user_job_nodes($change.userid);
            // FOR $node IN $nodes {
            //     // Appel RPC : $node->client->updateUserGroupId(...)
            // }
            // Cette logique est pour l'instant un placeholder. Nous supposons que la propagation réussit toujours.
            // Un point sera ajouté au fichier A_FAIRE.md.
            
            LET $propagation_succeeded = true;
            
            IF $propagation_succeeded {
                // Mettre à jour le groupe de l'utilisateur dans la table principale.
                UPDATE $change.userid SET usergroupid = $change.new_usergroup_id;
                
                // Marquer le changement comme traité.
                UPDATE $change.id SET processed_at = time::now();
            } ELSE {
                // Si la propagation échoue, on ajoute l'utilisateur à la liste des échecs.
                $failed_user_ids = array::push($failed_user_ids, $change.userid);
            }
            
            COMMIT TRANSACTION;
        }
        
        RETURN {
            processed: count($changes),
            failures: count($failed_user_ids)
        };
    };
    
    fn::system_log_create_record_system(['scheduler_tasks_process_user_group_changes_initialise', 'success'], 'Fonction `fn::scheduler::tasks::process_user_group_changes` initialisée avec succès.');

    RETURN true;
};
