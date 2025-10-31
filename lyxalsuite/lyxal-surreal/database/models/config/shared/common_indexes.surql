-- ================================================================================================
-- 📊 INDEX DE CONFIGURATION SYSTÈME - LYXAL SURREAL
-- ================================================================================================
-- 
-- Index optimisés pour les tables de configuration système
-- Déplacées depuis lyxal-base pour une meilleure séparation des responsabilités
-- 
-- ================================================================================================

-- Index pour app_configuration
DEFINE INDEX idx_app_config_code ON app_configuration COLUMNS code UNIQUE;
DEFINE INDEX idx_app_config_name ON app_configuration COLUMNS name;
DEFINE INDEX idx_app_config_active ON app_configuration COLUMNS isActive;
DEFINE INDEX idx_app_config_default ON app_configuration COLUMNS isDefault;
DEFINE INDEX idx_app_config_version ON app_configuration COLUMNS version;

-- Index pour locale_configuration
DEFINE INDEX idx_locale_config_code ON locale_configuration COLUMNS code UNIQUE;
DEFINE INDEX idx_locale_config_language ON locale_configuration COLUMNS language;
DEFINE INDEX idx_locale_config_country ON locale_configuration COLUMNS country;
DEFINE INDEX idx_locale_config_default ON locale_configuration COLUMNS isDefault;
DEFINE INDEX idx_locale_config_active ON locale_configuration COLUMNS isActive;

-- Index pour period_configuration
DEFINE INDEX idx_period_config_code ON period_configuration COLUMNS code UNIQUE;
DEFINE INDEX idx_period_config_type ON period_configuration COLUMNS periodType;
DEFINE INDEX idx_period_config_dates ON period_configuration COLUMNS startDate, endDate;
DEFINE INDEX idx_period_config_active ON period_configuration COLUMNS isActive;
DEFINE INDEX idx_period_config_default ON period_configuration COLUMNS isDefault;

-- Index pour notification_configuration
DEFINE INDEX idx_notification_config_code ON notification_configuration COLUMNS code UNIQUE;
DEFINE INDEX idx_notification_config_event ON notification_configuration COLUMNS eventType;
DEFINE INDEX idx_notification_config_channel ON notification_configuration COLUMNS channelType;
DEFINE INDEX idx_notification_config_priority ON notification_configuration COLUMNS priority;
DEFINE INDEX idx_notification_config_active ON notification_configuration COLUMNS isActive;

-- Index pour import_configuration
DEFINE INDEX idx_import_config_code ON import_configuration COLUMNS code UNIQUE;
DEFINE INDEX idx_import_config_source ON import_configuration COLUMNS sourceType;
DEFINE INDEX idx_import_config_target ON import_configuration COLUMNS targetEntity;
DEFINE INDEX idx_import_config_active ON import_configuration COLUMNS isActive;

-- Index composites pour performance
DEFINE INDEX idx_config_active_default ON app_configuration COLUMNS isActive, isDefault;
DEFINE INDEX idx_locale_lang_country ON locale_configuration COLUMNS language, country;
DEFINE INDEX idx_period_type_active ON period_configuration COLUMNS periodType, isActive;
DEFINE INDEX idx_notification_event_channel ON notification_configuration COLUMNS eventType, channelType;
DEFINE INDEX idx_import_source_target ON import_configuration COLUMNS sourceType, targetEntity;

-- ================================================================================================
-- 🎯 FIN INDEX CONFIGURATION SYSTÈME
-- ================================================================================================ 