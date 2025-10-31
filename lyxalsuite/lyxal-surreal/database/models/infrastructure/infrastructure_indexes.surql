-- ===================================
-- 📊 MODULE INFRASTRUCTURE - INDEX
-- ===================================
-- Index de performance pour requêtes optimisées

-- 🌐 INDEX DOMAINES
DEFINE INDEX idx_domains_name ON infrastructure_domains COLUMNS domain_name UNIQUE;
DEFINE INDEX idx_domains_owner ON infrastructure_domains COLUMNS owner_level, owner_id;
DEFINE INDEX idx_domains_registrar ON infrastructure_domains COLUMNS registrar;
DEFINE INDEX idx_domains_status ON infrastructure_domains COLUMNS status;
DEFINE INDEX idx_domains_expiry ON infrastructure_domains COLUMNS expiry_date;

-- 🏠 INDEX HÉBERGEMENT
DEFINE INDEX idx_hosting_id ON infrastructure_hosting COLUMNS hosting_id UNIQUE;
DEFINE INDEX idx_hosting_domain ON infrastructure_hosting COLUMNS domain_id;
DEFINE INDEX idx_hosting_owner ON infrastructure_hosting COLUMNS owner_level, owner_id;
DEFINE INDEX idx_hosting_provider ON infrastructure_hosting COLUMNS provider;
DEFINE INDEX idx_hosting_plan ON infrastructure_hosting COLUMNS plan_type;
DEFINE INDEX idx_hosting_status ON infrastructure_hosting COLUMNS status;

-- 📧 INDEX EMAIL
DEFINE INDEX idx_email_address ON infrastructure_email COLUMNS email_address UNIQUE;
DEFINE INDEX idx_email_domain ON infrastructure_email COLUMNS domain_id;
DEFINE INDEX idx_email_hosting ON infrastructure_email COLUMNS hosting_id;
DEFINE INDEX idx_email_owner ON infrastructure_email COLUMNS owner_level, owner_id;
DEFINE INDEX idx_email_status ON infrastructure_email COLUMNS status;

-- 📱 INDEX SMS
DEFINE INDEX idx_sms_campaign ON infrastructure_sms COLUMNS campaign_id UNIQUE;
DEFINE INDEX idx_sms_owner ON infrastructure_sms COLUMNS owner_level, owner_id;
DEFINE INDEX idx_sms_status ON infrastructure_sms COLUMNS status;
DEFINE INDEX idx_sms_scheduled ON infrastructure_sms COLUMNS scheduled_at;

-- 🔒 INDEX SSL
DEFINE INDEX idx_ssl_certificate ON infrastructure_ssl COLUMNS certificate_id UNIQUE;
DEFINE INDEX idx_ssl_domain ON infrastructure_ssl COLUMNS domain_id;
DEFINE INDEX idx_ssl_owner ON infrastructure_ssl COLUMNS owner_level, owner_id;
DEFINE INDEX idx_ssl_expires ON infrastructure_ssl COLUMNS expires_at;
DEFINE INDEX idx_ssl_status ON infrastructure_ssl COLUMNS status;

-- 🔧 INDEX FOURNISSEURS
DEFINE INDEX idx_providers_name ON infrastructure_providers COLUMNS provider_name UNIQUE;
DEFINE INDEX idx_providers_status ON infrastructure_providers COLUMNS status; 