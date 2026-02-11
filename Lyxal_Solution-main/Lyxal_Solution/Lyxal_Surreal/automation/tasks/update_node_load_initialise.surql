-- =================================================================================================
-- DEBUT DE L'INITIALISATION DE LA FONCTION `fn::scheduler::tasks::update_node_load`
-- =================================================================================================

DEFINE FUNCTION fn::scheduler_tasks_update_node_load_initialise() {
    -- Création de la fonction
    fn::system_log_create_record_system(['scheduler_tasks_update_node_load_initialise', 'start'], 'Initialisation de la fonction `fn::scheduler::tasks::update_node_load`.');

    DEFINE FUNCTION fn::scheduler::tasks::update_node_load() {
        // Cette fonction calcule la charge de chaque noeud sur les dernières 24 heures
        // et met à jour le champ `load_24h` de chaque noeud.
        // La charge est le pourcentage de jobs qu'un noeud a traité par rapport au total.
        
        LET $start_time = time::now() - 24h;
        
        // Étape 1: Agréger le nombre de jobs par noeud sur les dernières 24h.
        LET $stats_by_node = (
            SELECT 
                nodeid, 
                math::sum(jobs) AS job_count
            FROM scheduler_nodestats 
            WHERE created > $start_time 
            GROUP BY nodeid
        );
        
        // Étape 2: Calculer le nombre total de jobs sur tous les noeuds.
        // Si aucun job n'a été exécuté, on arrête pour éviter une division par zéro.
        LET $total_jobs = math::sum($stats_by_node.job_count);
        IF $total_jobs == 0 OR $total_jobs == NONE {
            RETURN {
                message: "Aucun job traité dans les dernières 24 heures. Aucune mise à jour de la charge n'est nécessaire.",
                updated_nodes: 0
            };
        }
        
        // Étape 3: Mettre à jour la charge de chaque noeud.
        FOR $node_stat IN $stats_by_node {
            LET $load = math::round(($node_stat.job_count / $total_jobs) * 100);
            UPDATE $node_stat.nodeid SET load_24h = $load;
        }
        
        RETURN {
            message: "Mise à jour de la charge des noeuds terminée.",
            updated_nodes: count($stats_by_node)
        };
    };
    
    fn::system_log_create_record_system(['scheduler_tasks_update_node_load_initialise', 'success'], 'Fonction `fn::scheduler::tasks::update_node_load` initialisée avec succès.');

    RETURN true;
};
