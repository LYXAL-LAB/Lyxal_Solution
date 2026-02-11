-- ================================================================================================
-- 📊 DONNÉES DE CONFIGURATION SYSTÈME
-- ================================================================================================
-- Description : Données de référence pour toutes les configurations système
-- Tables concernées : system_identity, system_infrastructure, app_configuration, 
--                     locale_configuration, period_configuration, 
--                     notification_configuration, import_configuration
-- 
-- Date ajout MASTER: 2025-01-27T10:00:00.000Z
-- Solution commercialisable 100k€-500k€ - Modifiable à chaud
-- ================================================================================================

-- ================================================================================================
-- 🎯 DONNÉES CONFIGURATION MASTER - IDENTITÉ & INFRASTRUCTURE
-- ================================================================================================

-- Configuration identité plateforme MASTER
CREATE system_identity:master SET
    platform_name = "LYXAL",
    platform_id = "lyxal-master-001",
    environment = "production",
    platform_version = "1.0.0",
    annee_construction = "2025",
    niveau_architectural = 0,
    theme_par_defaut = "corporate",
    theme_website = "corporate",
    ultimate = false,
    createdAt = time::now(),
    updatedAt = time::now();

-- Configuration infrastructure technique MASTER
CREATE system_infrastructure:master SET
    surreal_db_url = "wss://accurate-horse-06bnu0f1k1tv1215mv54m347tc.aws-euw1.surreal.cloud/rpc",
    surreal_namespace = "lyxal_platform",
    surreal_database = "platform",
    surreal_username = "admin",
    surreal_password = "admin",
    logto_master_endpoint = "https://lyxal-master.logto.cloud",
    logto_admin_app_id = "lyxal-admin-console",
    api_base_url = "https://api.lyxal.com",
    createdAt = time::now(),
    updatedAt = time::now();

-- Vérification des données MASTER insérées
SELECT * FROM system_identity:master;
SELECT * FROM system_infrastructure:master;

-- ================================================================================================
-- 🚀 DONNÉES CONFIGURATION APPLICATION
-- ================================================================================================

INSERT INTO app_configuration [
    {
        id: app_configuration:LYXAL_DEFAULT,
        code: "LYXAL_DEFAULT",
        name: "Configuration LYXAL par Défaut",
        version: "1.0.0",
        isDefault: true,
        isActive: true,
        systemParameters: {
            maxUsers: 1000,
            sessionTimeout: 3600,
            backupFrequency: 24,
            logRetention: 90,
            cacheSize: 512,
            performanceMode: "OPTIMIZED"
        },
        systemAI: {
            performanceOptimization: {
                "auto_scaling": true,
                "cache_optimization": true,
                "query_optimization": true
            },
            resourceUtilization: {
                "cpu_threshold": 80.0,
                "memory_threshold": 85.0,
                "disk_threshold": 90.0
            },
            predictionModels: {
                "user_behavior": "advanced",
                "system_load": "predictive",
                "maintenance": "proactive"
            },
            autoTuning: true,
            healthMetrics: {
                "availability_target": 99.9,
                "response_time_target": 200,
                "error_rate_threshold": 0.1
            },
            alertRules: [
                {
                    "metric": "response_time",
                    "threshold": 500,
                    "action": "scale_up"
                },
                {
                    "metric": "error_rate",
                    "threshold": 1.0,
                    "action": "investigate"
                }
            ]
        },
        systemAnalytics: {
            uptime: 99.95,
            responseTime: 150.0,
            throughput: 1500.0,
            errorRate: 0.05,
            resourceUsage: {
                "cpu": 65.0,
                "memory": 72.0,
                "disk": 45.0,
                "network": 35.0
            },
            userActivity: {
                "active_sessions": 250,
                "daily_users": 800,
                "peak_concurrent": 150
            }
        },
        createdAt: time::now(),
        updatedAt: time::now()
    },
    {
        id: app_configuration:LYXAL_MASTER,
        code: "LYXAL_MASTER_CONFIG",
        name: "Configuration Master Console LYXAL",
        version: "1.0.0",
        isDefault: false,
        isActive: true,
        systemParameters: {
            // === IDENTITÉ PLATEFORME ===
            platformName: "LYXAL",
            anneeConstruction: "2025",
            
            // === INFRASTRUCTURE TECHNIQUE ===
            surrealDbUrl: "wss://accurate-horse-06bnu0f1k1tv1215mv54m347tc.aws-euw1.surreal.cloud/rpc",
            surrealNamespace: "lyxal_master",
            surrealDatabase: "platform_control",
            surrealUsername: "admin",
            surrealPassword: "admin",
            
            // === AUTHENTIFICATION ===
            logtoMasterEndpoint: "https://lyxal-master.logto.cloud",
            logtoAdminAppId: "lyxal-admin-console",
            
            // === LIMITES PLATEFORME ===
            maxInvestors: 100,
            maxTotalTenants: 10000,
            maxConcurrentUsers: 50000,
            
            // === THÈMES ===
            themeParDefaut: "corporate",
            themeWebsite: "corporate",
            
            // === PARAMÈTRES SYSTÈME EXISTANTS ===
            maxUsers: 1000,
            sessionTimeout: 3600,
            backupFrequency: 24,
            logRetention: 90,
            cacheSize: 512,
            performanceMode: "OPTIMIZED"
        },
        systemAI: {
            performanceOptimization: {
                "auto_scaling": true,
                "cache_optimization": true,
                "query_optimization": true
            },
            resourceUtilization: {
                "cpu_threshold": 80.0,
                "memory_threshold": 85.0,
                "disk_threshold": 90.0
            },
            predictionModels: {
                "user_behavior": "advanced",
                "system_load": "predictive",
                "maintenance": "proactive"
            },
            autoTuning: true,
            healthMetrics: {
                "availability_target": 99.9,
                "response_time_target": 200,
                "error_rate_threshold": 0.1
            },
            alertRules: [
                {
                    "metric": "response_time",
                    "threshold": 500,
                    "action": "scale_up"
                },
                {
                    "metric": "error_rate",
                    "threshold": 1.0,
                    "action": "investigate"
                }
            ]
        },
        systemAnalytics: {
            uptime: 99.95,
            responseTime: 150.0,
            throughput: 1500.0,
            errorRate: 0.05,
            resourceUsage: {
                "cpu": 65.0,
                "memory": 72.0,
                "disk": 45.0,
                "network": 35.0
            },
            userActivity: {
                "active_sessions": 250,
                "daily_users": 800,
                "peak_concurrent": 150
            }
        },
        createdAt: time::now(),
        updatedAt: time::now()
    }
];

-- ================================================================================================
-- 🌐 DONNÉES CONFIGURATION LOCALE
-- ================================================================================================

INSERT INTO locale_configuration [
    {
        id: locale_configuration:fr_FR,
        code: "fr_FR",
        name: "Français (France)",
        language: "fr",
        country: "FR",
        isDefault: true,
        isActive: true,
        culturalSettings: {
            dateFormat: "dd/MM/yyyy",
            timeFormat: "HH:mm:ss",
            numberFormat: "1 234,56",
            currency: "EUR",
            currencySymbol: "€",
            firstDayOfWeek: 1,
            workingDays: [1, 2, 3, 4, 5],
            timezone: "Europe/Paris"
        },
        businessIntelligence: {
            culturalInsights: {
                "business_hours": "09:00-18:00",
                "lunch_break": "12:00-14:00",
                "vacation_period": "July-August",
                "business_culture": "formal"
            },
            behavioralAnalytics: {
                "preferred_communication": "email",
                "decision_making": "consensus",
                "meeting_style": "structured",
                "work_life_balance": "high_priority"
            }
        },
        createdAt: time::now(),
        updatedAt: time::now()
    },
    {
        id: locale_configuration:en_US,
        code: "en_US",
        name: "English (United States)",
        language: "en",
        country: "US",
        isDefault: false,
        isActive: true,
        culturalSettings: {
            dateFormat: "MM/dd/yyyy",
            timeFormat: "hh:mm:ss a",
            numberFormat: "1,234.56",
            currency: "USD",
            currencySymbol: "$",
            firstDayOfWeek: 0,
            workingDays: [1, 2, 3, 4, 5],
            timezone: "America/New_York"
        },
        businessIntelligence: {
            culturalInsights: {
                "business_hours": "09:00-17:00",
                "lunch_break": "12:00-13:00",
                "vacation_period": "June-August",
                "business_culture": "direct"
            },
            behavioralAnalytics: {
                "preferred_communication": "phone",
                "decision_making": "individual",
                "meeting_style": "dynamic",
                "work_life_balance": "moderate_priority"
            }
        },
        createdAt: time::now(),
        updatedAt: time::now()
    }
];

-- ================================================================================================
-- 📅 DONNÉES CONFIGURATION PÉRIODE
-- ================================================================================================

INSERT INTO period_configuration [
    {
        id: period_configuration:FISCAL_2025,
        code: "FISCAL_2025",
        name: "Exercice Fiscal 2025",
        type: "FISCAL_YEAR",
        startDate: "2025-01-01",
        endDate: "2025-12-31",
        isDefault: true,
        isActive: true,
        fiscalSettings: {
            quarters: [
                { "name": "Q1", "start": "2025-01-01", "end": "2025-03-31" },
                { "name": "Q2", "start": "2025-04-01", "end": "2025-06-30" },
                { "name": "Q3", "start": "2025-07-01", "end": "2025-09-30" },
                { "name": "Q4", "start": "2025-10-01", "end": "2025-12-31" }
            ],
            reportingFrequency: "MONTHLY",
            closingDay: 31
        },
        createdAt: time::now(),
        updatedAt: time::now()
    }
];

-- ================================================================================================
-- 📧 DONNÉES CONFIGURATION NOTIFICATION
-- ================================================================================================

INSERT INTO notification_configuration [
    {
        id: notification_configuration:DEFAULT_NOTIFICATIONS,
        code: "DEFAULT_NOTIFICATIONS",
        name: "Configuration Notifications par Défaut",
        isDefault: true,
        isActive: true,
        emailSettings: {
            smtpServer: "smtp.lyxal.com",
            smtpPort: 587,
            enableSSL: true,
            fromAddress: "noreply@lyxal.com",
            fromName: "LYXAL Platform"
        },
        notificationRules: {
            systemAlerts: true,
            userNotifications: true,
            businessAlerts: true,
            technicalAlerts: true,
            batchFrequency: "IMMEDIATE"
        },
        createdAt: time::now(),
        updatedAt: time::now()
    }
];

-- ================================================================================================
-- 📥 DONNÉES CONFIGURATION IMPORT
-- ================================================================================================

INSERT INTO import_configuration [
    {
        id: import_configuration:DEFAULT_IMPORT,
        code: "DEFAULT_IMPORT",
        name: "Configuration Import par Défaut",
        isDefault: true,
        isActive: true,
        importSettings: {
            maxFileSize: 10485760, // 10MB
            allowedFormats: ["CSV", "XLSX", "JSON", "XML"],
            batchSize: 1000,
            validationLevel: "STRICT",
            errorHandling: "STOP_ON_ERROR"
        },
        mappingRules: {
            autoMapping: true,
            fieldValidation: true,
            duplicateHandling: "SKIP",
            emptyFieldHandling: "NULL"
        },
        createdAt: time::now(),
        updatedAt: time::now()
    }
];

-- ================================================================================================
-- 🎯 DONNÉES DE CONFIGURATION SYSTÈME TERMINÉES
-- ================================================================================================
-- Toutes les configurations système sont maintenant disponibles :
-- - 2 configurations app : LYXAL_DEFAULT + LYXAL_MASTER_CONFIG
-- - 2 configurations locale : fr_FR + en_US  
-- - 1 configuration période : FISCAL_2025
-- - 1 configuration notification : DEFAULT_NOTIFICATIONS
-- - 1 configuration import : DEFAULT_IMPORT
-- ================================================================================================ 

-- ================================================================================================
-- 📊 DONNÉES INITIALES - CONFIGURATION SYSTÈME MASTER
-- ================================================================================================
-- 
-- Ce fichier contient les données par défaut pour les tables de configuration MASTER
-- À exécuter après system_configuration_structure.surql
-- 
-- Tables peuplées:
-- - system_identity:master (Configuration identité plateforme)
-- - system_infrastructure:master (Configuration infrastructure technique)
-- 
-- Date de création: 2025-01-27T10:00:00.000Z
-- Solution commercialisable 100k€-500k€ - Modifiable à chaud
-- ================================================================================================

-- ================================================================================
-- CONFIGURATION IDENTITÉ PLATEFORME MASTER
-- ================================================================================

-- Insertion de la configuration identité par défaut
CREATE system_identity:master SET
    platform_name = "LYXAL",
    platform_id = "lyxal-master-001",
    environment = "production",
    platform_version = "1.0.0",
    annee_construction = "2025",
    niveau_architectural = 0,
    theme_par_defaut = "corporate",
    theme_website = "corporate",
    ultimate = false,
    createdAt = time::now(),
    updatedAt = time::now();

-- ================================================================================
-- CONFIGURATION INFRASTRUCTURE TECHNIQUE MASTER
-- ================================================================================

-- Insertion de la configuration infrastructure par défaut
CREATE system_infrastructure:master SET
    surreal_db_url = "wss://accurate-horse-06bnu0f1k1tv1215mv54m347tc.aws-euw1.surreal.cloud/rpc",
    surreal_namespace = "lyxal_platform",
    surreal_database = "platform",
    surreal_username = "admin",
    surreal_password = "admin",
    logto_master_endpoint = "https://lyxal-master.logto.cloud",
    logto_admin_app_id = "lyxal-admin-console",
    api_base_url = "https://api.lyxal.com",
    createdAt = time::now(),
    updatedAt = time::now();

-- ================================================================================
-- VÉRIFICATION DES DONNÉES INSÉRÉES
-- ================================================================================

-- Vérifier que la configuration identité a été créée
SELECT * FROM system_identity:master;

-- Vérifier que la configuration infrastructure a été créée
SELECT * FROM system_infrastructure:master;

-- Vérifier le nombre total d'enregistrements
SELECT 
    (SELECT COUNT() FROM system_identity)[0] as identity_count,
    (SELECT COUNT() FROM system_infrastructure)[0] as infrastructure_count;

-- ================================================================================================
-- 🎯 REQUÊTES UTILES POUR LA GESTION
-- ================================================================================================

-- Récupérer toute la configuration système
-- SELECT * FROM system_identity:master, system_infrastructure:master;

-- Mettre à jour le nom de la plateforme (exemple)
-- UPDATE system_identity:master SET platform_name = "LYXAL_CUSTOM", updatedAt = time::now();

-- Mettre à jour l'URL SurrealDB (exemple)
-- UPDATE system_infrastructure:master SET surreal_db_url = "wss://nouvelle-instance.surreal.cloud/rpc", updatedAt = time::now();

-- Changer le thème par défaut (exemple)
-- UPDATE system_identity:master SET theme_par_defaut = "dark", updatedAt = time::now();

-- Historique des modifications (après avoir configuré les triggers)
-- SELECT * FROM system_config_metadata ORDER BY changed_at DESC LIMIT 10;

-- ================================================================================================
-- 💡 NOTES IMPORTANTES
-- ================================================================================================

-- 1. Ces données sont modifiables à chaud sans redéploiement
-- 2. Chaque modification peut être tracée via system_config_metadata
-- 3. Les contraintes SurrealDB valident automatiquement les données
-- 4. Solution commercialisable avec personnalisation totale
-- 5. Architecture bicéphale : .env minimal + SurrealDB dynamique

-- ================================================================================================ 