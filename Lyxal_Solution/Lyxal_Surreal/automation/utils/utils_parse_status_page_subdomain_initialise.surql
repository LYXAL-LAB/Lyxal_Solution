-- =================================================================================================
-- DEBUT DE L'INITIALISATION DE LA FONCTION `fn::scheduler::utils::parse_status_page_subdomain`
-- =================================================================================================

DEFINE FUNCTION fn::scheduler_utils_parse_status_page_subdomain_initialise() {
    -- Définition du domaine de base pour les pages de statut
    DEFINE PARAM IF NOT EXISTS $scheduler_status_page_domain VALUE 'status.example.com';

    -- Création de la fonction
    fn::system_log_create_record_system(['scheduler_utils_parse_status_page_subdomain_initialise', 'start'], 'Initialisation de la fonction `fn::scheduler::utils::parse_status_page_subdomain`.');

    DEFINE FUNCTION fn::scheduler::utils::parse_status_page_subdomain(
        $domain: string
    ) {
        // Extrait l'identifiant unique d'un sous-domaine de page de statut.
        // ex: "my-page.status.example.com" -> "my-page"
        
        LET $base_domain_with_dot = '.' + $scheduler_status_page_domain;
        
        IF string::ends_with($domain, $base_domain_with_dot) {
            LET $len_base = string::len($base_domain_with_dot);
            LET $len_total = string::len($domain);
            
            LET $subdomain = string::slice($domain, 0, $len_total - $len_base);
            
            RETURN string::to_lower($subdomain);
        } ELSE {
            RETURN false;
        };
    };
    
    fn::system_log_create_record_system(['scheduler_utils_parse_status_page_subdomain_initialise', 'success'], 'Fonction `fn::scheduler::utils::parse_status_page_subdomain` initialisée avec succès.');

    RETURN true;
};
