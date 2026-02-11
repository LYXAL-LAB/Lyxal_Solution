-- =====================================================================
-- FONCTIONS INTELLIGENTES DE GESTION DES MODULES
-- =====================================================================

-- Fonction pour vérifier si un module est actif
DEFINE FUNCTION fn::is_module_active($module_code: string) {
    LET $module = SELECT is_active FROM app_module WHERE code = $module_code LIMIT 1;
    RETURN $module.is_active OR false;
};

-- Fonction pour activer un module avec vérification des dépendances
DEFINE FUNCTION fn::activate_module($module_code: string) {
    LET $module = SELECT * FROM app_module WHERE code = $module_code LIMIT 1;
    
    IF !$module {
        THROW "Module non trouvé: " + $module_code;
    };
    
    IF $module.is_active {
        RETURN { success: true, message: "Module déjà actif" };
    };
    
    -- Vérifier les dépendances
    FOR $dep IN $module.dependencies {
        IF !fn::is_module_active($dep) {
            THROW "Dépendance manquante: " + $dep + " requis pour " + $module_code;
        };
    };
    
    -- Vérifier les conflits
    FOR $conflict IN $module.conflicts_with {
        IF fn::is_module_active($conflict) {
            THROW "Conflit détecté: " + $conflict + " incompatible avec " + $module_code;
        };
    };
    
    -- Activer le module
    UPDATE app_module SET 
        is_active = true,
        last_activated = time::now(),
        updated_on = time::now()
    WHERE code = $module_code;
    
    -- Exécuter le script d'installation si présent
    IF $module.install_script {
        -- Ici on pourrait exécuter le script d'installation
        -- eval($module.install_script);
    };
    
    RETURN { success: true, message: "Module activé avec succès" };
};

-- Fonction pour désactiver un module avec vérification des dépendances
DEFINE FUNCTION fn::deactivate_module($module_code: string) {
    LET $module = SELECT * FROM app_module WHERE code = $module_code LIMIT 1;
    
    IF !$module {
        THROW "Module non trouvé: " + $module_code;
    };
    
    IF $module.is_core_module {
        THROW "Impossible de désactiver un module core: " + $module_code;
    };
    
    IF !$module.is_active {
        RETURN { success: true, message: "Module déjà inactif" };
    };
    
    -- Vérifier si d'autres modules dépendent de celui-ci
    LET $dependents = SELECT code FROM app_module 
                     WHERE is_active = true 
                     AND $module_code IN dependencies;
    
    IF count($dependents) > 0 {
        THROW "Impossible de désactiver: modules dépendants actifs - " + string::join(array::map($dependents, |$d| $d.code), ", ");
    };
    
    -- Désactiver le module
    UPDATE app_module SET 
        is_active = false,
        last_deactivated = time::now(),
        updated_on = time::now()
    WHERE code = $module_code;
    
    -- Exécuter le script de désinstallation si présent
    IF $module.uninstall_script {
        -- eval($module.uninstall_script);
    };
    
    RETURN { success: true, message: "Module désactivé avec succès" };
};

-- Fonction pour obtenir la liste des modules actifs
DEFINE FUNCTION fn::get_active_modules() {
    RETURN SELECT * FROM app_module 
           WHERE is_active = true 
           ORDER BY install_order, name;
};

-- Fonction pour obtenir la configuration d'un module
DEFINE FUNCTION fn::get_module_config($module_code: string) {
    LET $module = SELECT * FROM app_module WHERE code = $module_code LIMIT 1;
    
    IF !$module OR !$module.is_active {
        RETURN {};
    };
    
    RETURN {
        code: $module.code,
        name: $module.name,
        version: $module.version,
        is_active: $module.is_active,
        config_keys: $module.config_keys,
        api_endpoints: $module.api_endpoints,
        ui_components: $module.ui_components,
        permissions: $module.permissions
    };
};

-- Fonction pour vérifier la santé des modules
DEFINE FUNCTION fn::check_modules_health() {
    LET $modules = SELECT * FROM app_module WHERE is_active = true;
    LET $health_report = [];
    
    FOR $module IN $modules {
        LET $health = {
            code: $module.code,
            name: $module.name,
            status: $module.health_status,
            performance_score: $module.performance_score,
            error_count: $module.error_count,
            last_used: $module.last_used
        };
        
        -- Vérifier si le module a été utilisé récemment
        IF $module.last_used AND $module.last_used < time::now() - 30d {
            $health.status = "WARNING";
            $health.warning = "Module non utilisé depuis 30 jours";
        };
        
        -- Vérifier les erreurs
        IF $module.error_count > 10 {
            $health.status = "ERROR";
            $health.error = "Trop d'erreurs détectées";
        };
        
        array::push($health_report, $health);
    };
    
    RETURN $health_report;
};

-- Fonction pour obtenir les modules disponibles pour installation
DEFINE FUNCTION fn::get_available_modules() {
    RETURN SELECT 
        code,
        name,
        description,
        version,
        is_active,
        dependencies,
        license_type,
        author
    FROM app_module 
    ORDER BY name;
};

-- Fonction pour vérifier les permissions d'un module
DEFINE FUNCTION fn::check_module_permissions($module_code: string, $user_permissions: array<string>) {
    LET $module = SELECT permissions FROM app_module 
                  WHERE code = $module_code AND is_active = true LIMIT 1;
    
    IF !$module {
        RETURN false;
    };
    
    FOR $required_perm IN $module.permissions {
        IF !($required_perm IN $user_permissions) {
            RETURN false;
        };
    };
    
    RETURN true;
};

-- Fonction pour mettre à jour les statistiques d'utilisation
DEFINE FUNCTION fn::update_module_usage($module_code: string) {
    UPDATE app_module SET 
        last_used = time::now(),
        updated_on = time::now()
    WHERE code = $module_code AND is_active = true;
};

-- Fonction pour obtenir les endpoints API actifs
DEFINE FUNCTION fn::get_active_api_endpoints() {
    LET $modules = SELECT code, api_endpoints FROM app_module WHERE is_active = true;
    LET $endpoints = [];
    
    FOR $module IN $modules {
        FOR $endpoint IN $module.api_endpoints {
            array::push($endpoints, {
                module: $module.code,
                endpoint: $endpoint
            });
        };
    };
    
    RETURN $endpoints;
};

-- Fonction pour obtenir les composants UI actifs
DEFINE FUNCTION fn::get_active_ui_components() {
    LET $modules = SELECT code, ui_components FROM app_module WHERE is_active = true;
    LET $components = [];
    
    FOR $module IN $modules {
        FOR $component IN $module.ui_components {
            array::push($components, {
                module: $module.code,
                component: $component
            });
        };
    };
    
    RETURN $components;
}; 