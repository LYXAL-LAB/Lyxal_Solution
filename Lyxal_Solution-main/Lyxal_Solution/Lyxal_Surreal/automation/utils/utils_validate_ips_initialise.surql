-- =================================================================================================
-- DEBUT DE L'INITIALISATION DE LA FONCTION `fn::scheduler::utils::validate_ips`
-- =================================================================================================

DEFINE FUNCTION fn::scheduler_utils_validate_ips_initialise() {
    -- Création de la fonction
    fn::system_log_create_record_system(['scheduler_utils_validate_ips_initialise', 'start'], 'Initialisation de la fonction `fn::scheduler::utils::validate_ips`.');

    DEFINE FUNCTION fn::scheduler::utils::validate_ips(
        $ips: option<array>
    ) {
        RETURN function($ips) {
            if (!Array.isArray($ips)) {
                return [];
            }

            const ipRegex = /^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$/;
            
            const sanitizedIps = $ips.filter(ip => {
                if (typeof ip !== 'string') {
                    return false;
                }
                return ipRegex.test(ip.trim());
            });

            return sanitizedIps;
        }($ips);
    };
    
    fn::system_log_create_record_system(['scheduler_utils_validate_ips_initialise', 'success'], 'Fonction `fn::scheduler::utils::validate_ips` initialisée avec succès.');

    RETURN true;
};
