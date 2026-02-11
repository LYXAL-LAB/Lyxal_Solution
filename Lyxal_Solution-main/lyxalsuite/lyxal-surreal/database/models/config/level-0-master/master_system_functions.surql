-- ================================================================================================
-- 🔧 FONCTIONS SYSTÈME - CONFIGURATION MASTER
-- ================================================================================================
-- 
-- Fonctions SurrealDB pour la gestion dynamique des plateformes MASTER
-- Solution commercialisable 100k€-500k€ - Création via formulaires
-- 
-- Fonctions incluses:
-- - fn::create_master_platform: Création complète d'une plateforme MASTER
-- - fn::update_master_config: Mise à jour configuration avec historique
-- - fn::validate_master_data: Validation des données MASTER
-- 
-- Date de création: 2025-01-27T10:00:00.000Z
-- ================================================================================================

-- ================================================================================
-- FONCTION: VALIDATION DES DONNÉES MASTER
-- ================================================================================

DEFINE FUNCTION fn::validate_master_data($data: object) {
    -- Validation du nom de plateforme
    IF !$data.platform_name OR string::len($data.platform_name) < 2 {
        THROW "Le nom de la plateforme doit contenir au moins 2 caractères";
    };
    
    -- Validation de l'ID plateforme
    IF !$data.platform_id OR string::len($data.platform_id) < 5 {
        THROW "L'ID de la plateforme doit contenir au moins 5 caractères";
    };
    
    -- Validation de l'environnement
    IF $data.environment AND !($data.environment INSIDE ["dev", "staging", "production"]) {
        THROW "L'environnement doit être: dev, staging ou production";
    };
    
    -- Validation de l'URL SurrealDB
    IF !$data.surreal_db_url OR !(string::starts_with($data.surreal_db_url, "ws://") OR string::starts_with($data.surreal_db_url, "wss://")) {
        THROW "L'URL SurrealDB doit commencer par ws:// ou wss://";
    };
    
    -- Validation du namespace
    IF !$data.surreal_namespace OR string::len($data.surreal_namespace) < 3 {
        THROW "Le namespace SurrealDB doit contenir au moins 3 caractères";
    };
    
    -- Validation de la database
    IF !$data.surreal_database OR string::len($data.surreal_database) < 3 {
        THROW "La database SurrealDB doit contenir au moins 3 caractères";
    };
    
    -- Validation des identifiants
    IF !$data.surreal_username OR string::len($data.surreal_username) < 3 {
        THROW "Le nom d'utilisateur SurrealDB doit contenir au moins 3 caractères";
    };
    
    IF !$data.surreal_password OR string::len($data.surreal_password) < 6 {
        THROW "Le mot de passe SurrealDB doit contenir au moins 6 caractères";
    };
    
    -- Validation endpoint Logto
    IF !$data.logto_master_endpoint OR !string::starts_with($data.logto_master_endpoint, "https://") {
        THROW "L'endpoint Logto doit commencer par https://";
    };
    
    -- Validation App ID Logto
    IF !$data.logto_admin_app_id OR string::len($data.logto_admin_app_id) < 5 {
        THROW "L'App ID Logto doit contenir au moins 5 caractères";
    };
    
    -- Validation API Base URL
    IF !$data.api_base_url OR !string::starts_with($data.api_base_url, "https://") {
        THROW "L'URL de l'API doit commencer par https://";
    };
    
    RETURN true;
};

-- ================================================================================
-- FONCTION: CRÉATION PLATEFORME MASTER COMPLÈTE
-- ================================================================================

DEFINE FUNCTION fn::create_master_platform($data: object) {
    -- Étape 1: Validation complète des données
    LET $validation = fn::validate_master_data($data);
    
    -- Étape 2: Vérifications d'unicité
    LET $existing_id = SELECT * FROM system_identity WHERE platform_id = $data.platform_id;
    IF array::len($existing_id) > 0 {
        THROW "Une plateforme avec cet ID existe déjà: " + $data.platform_id;
    };
    
    LET $existing_name = SELECT * FROM system_identity WHERE platform_name = $data.platform_name;
    IF array::len($existing_name) > 0 {
        THROW "Une plateforme avec ce nom existe déjà: " + $data.platform_name;
    };
    
    LET $existing_namespace = SELECT * FROM system_infrastructure WHERE surreal_namespace = $data.surreal_namespace;
    IF array::len($existing_namespace) > 0 {
        THROW "Ce namespace SurrealDB est déjà utilisé: " + $data.surreal_namespace;
    };
    
    -- Étape 3: Génération d'un ID unique si nécessaire
    LET $final_platform_id = $data.platform_id OR ("master-" + string::slice(rand::uuid::v4(), 0, 8));
    
    -- Étape 4: Transaction de création
    BEGIN TRANSACTION;
    
    -- Création de l'identité plateforme
    LET $identity = CREATE system_identity SET
        platform_name = $data.platform_name,
        platform_id = $final_platform_id,
        environment = $data.environment OR "production",
        platform_version = $data.platform_version OR "1.0.0",
        annee_construction = $data.annee_construction OR string::slice(time::now(), 0, 4),
        niveau_architectural = 0,
        theme_par_defaut = $data.theme_par_defaut OR "corporate",
        theme_website = $data.theme_website OR "corporate",
        ultimate = $data.ultimate OR false,
        createdAt = time::now(),
        updatedAt = time::now(),
        createdBy = $data.created_by;
    
    -- Création de l'infrastructure technique
    LET $infrastructure = CREATE system_infrastructure SET
        surreal_db_url = $data.surreal_db_url,
        surreal_namespace = $data.surreal_namespace,
        surreal_database = $data.surreal_database,
        surreal_username = $data.surreal_username,
        surreal_password = $data.surreal_password,
        logto_master_endpoint = $data.logto_master_endpoint,
        logto_admin_app_id = $data.logto_admin_app_id,
        api_base_url = $data.api_base_url,
        createdAt = time::now(),
        updatedAt = time::now(),
        createdBy = $data.created_by;
    
    -- Enregistrement dans l'historique - Identité
    CREATE system_config_metadata SET
        table_name = "system_identity",
        field_name = "platform_creation",
        old_value = "",
        new_value = $data.platform_name,
        changed_by = $data.created_by OR "system",
        change_reason = "Création plateforme MASTER via formulaire",
        changed_at = time::now();
    
    -- Enregistrement dans l'historique - Infrastructure
    CREATE system_config_metadata SET
        table_name = "system_infrastructure",
        field_name = "infrastructure_creation",
        old_value = "",
        new_value = $data.surreal_namespace,
        changed_by = $data.created_by OR "system",
        change_reason = "Création infrastructure MASTER via formulaire",
        changed_at = time::now();
    
    COMMIT TRANSACTION;
    
    -- Étape 5: Retour des données créées
    RETURN {
        success: true,
        message: "Plateforme MASTER créée avec succès",
        data: {
            identity: $identity,
            infrastructure: $infrastructure,
            platform_id: $final_platform_id,
            created_at: time::now()
        },
        metadata: {
            total_platforms: (SELECT COUNT() FROM system_identity)[0],
            environment: $data.environment OR "production",
            created_by: $data.created_by OR "system"
        }
    };
};

-- ================================================================================
-- FONCTION: MISE À JOUR CONFIGURATION AVEC HISTORIQUE
-- ================================================================================

DEFINE FUNCTION fn::update_master_config($table_name: string, $field_name: string, $new_value: string, $platform_id: string, $changed_by: string, $reason: string) {
    -- Validation des paramètres
    IF !$table_name OR !($table_name INSIDE ["system_identity", "system_infrastructure"]) {
        THROW "Table invalide. Doit être: system_identity ou system_infrastructure";
    };
    
    IF !$field_name OR !$new_value {
        THROW "Le nom du champ et la nouvelle valeur sont requis";
    };
    
    BEGIN TRANSACTION;
    
    -- Récupérer l'ancienne valeur
    LET $old_record = IF $table_name = "system_identity" THEN
        (SELECT * FROM system_identity WHERE platform_id = $platform_id)[0]
    ELSE
        (SELECT * FROM system_infrastructure WHERE platform_id = $platform_id)[0]
    END;
    
    IF !$old_record {
        THROW "Plateforme non trouvée avec l'ID: " + $platform_id;
    };
    
    LET $old_value = $old_record[$field_name];
    
    -- Mettre à jour le champ
    IF $table_name = "system_identity" THEN
        UPDATE system_identity SET 
            [$field_name] = $new_value,
            updatedAt = time::now()
        WHERE platform_id = $platform_id
    ELSE
        UPDATE system_infrastructure SET 
            [$field_name] = $new_value,
            updatedAt = time::now()
        WHERE platform_id = $platform_id
    END;
    
    -- Enregistrer dans l'historique
    CREATE system_config_metadata SET
        table_name = $table_name,
        field_name = $field_name,
        old_value = $old_value,
        new_value = $new_value,
        changed_by = $changed_by,
        change_reason = $reason OR "Mise à jour configuration",
        changed_at = time::now();
    
    COMMIT TRANSACTION;
    
    RETURN {
        success: true,
        message: "Configuration mise à jour avec succès",
        field_updated: $field_name,
        old_value: $old_value,
        new_value: $new_value,
        updated_at: time::now()
    };
};

-- ================================================================================
-- FONCTION: RÉCUPÉRATION CONFIGURATION COMPLÈTE
-- ================================================================================

DEFINE FUNCTION fn::get_master_platform($platform_id: string) {
    LET $identity = (SELECT * FROM system_identity WHERE platform_id = $platform_id)[0];
    LET $infrastructure = (SELECT * FROM system_infrastructure WHERE platform_id = $platform_id)[0];
    
    IF !$identity OR !$infrastructure {
        THROW "Plateforme non trouvée avec l'ID: " + $platform_id;
    };
    
    RETURN {
        success: true,
        data: {
            identity: $identity,
            infrastructure: $infrastructure
        },
        metadata: {
            retrieved_at: time::now(),
            platform_id: $platform_id
        }
    };
};

-- ================================================================================
-- FONCTION: SUPPRESSION PLATEFORME (AVEC SÉCURITÉ)
-- ================================================================================

DEFINE FUNCTION fn::delete_master_platform($platform_id: string, $confirmation: string, $deleted_by: string) {
    -- Sécurité: confirmation requise
    IF $confirmation != "DELETE_CONFIRMED" {
        THROW "Suppression annulée: confirmation requise avec 'DELETE_CONFIRMED'";
    };
    
    -- Vérifier l'existence
    LET $identity = (SELECT * FROM system_identity WHERE platform_id = $platform_id)[0];
    IF !$identity {
        THROW "Plateforme non trouvée avec l'ID: " + $platform_id;
    };
    
    BEGIN TRANSACTION;
    
    -- Enregistrer la suppression dans l'historique
    CREATE system_config_metadata SET
        table_name = "system_identity",
        field_name = "platform_deletion",
        old_value = $identity.platform_name,
        new_value = "DELETED",
        changed_by = $deleted_by,
        change_reason = "Suppression plateforme MASTER",
        changed_at = time::now();
    
    -- Supprimer les enregistrements
    DELETE system_identity WHERE platform_id = $platform_id;
    DELETE system_infrastructure WHERE platform_id = $platform_id;
    
    COMMIT TRANSACTION;
    
    RETURN {
        success: true,
        message: "Plateforme MASTER supprimée avec succès",
        deleted_platform: $identity.platform_name,
        deleted_at: time::now(),
        deleted_by: $deleted_by
    };
};

-- ================================================================================================
-- 🎯 EXEMPLES D'UTILISATION
-- ================================================================================================

-- Créer une plateforme MASTER
-- RETURN fn::create_master_platform({
--     platform_name: "LYXAL_CLIENT_001",
--     platform_id: "client-001-master",
--     environment: "production",
--     surreal_db_url: "wss://client-001.surreal.cloud/rpc",
--     surreal_namespace: "client_001_master",
--     surreal_database: "platform_control",
--     surreal_username: "admin_client_001",
--     surreal_password: "secure_password_2025",
--     logto_master_endpoint: "https://client-001-master.logto.cloud",
--     logto_admin_app_id: "client-001-admin-console",
--     api_base_url: "https://api.client-001.com",
--     theme_par_defaut: "dark",
--     created_by: "admin_user"
-- });

-- Mettre à jour une configuration
-- RETURN fn::update_master_config(
--     "system_identity", 
--     "platform_name", 
--     "NOUVEAU_NOM", 
--     "client-001-master", 
--     "admin_user", 
--     "Changement de nom commercial"
-- );

-- Récupérer une plateforme
-- RETURN fn::get_master_platform("client-001-master");

-- ================================================================================================ 