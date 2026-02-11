-- ===================================
-- 🔗 MODULE INFRASTRUCTURE - RELATIONS
-- ===================================
-- Relations entre domaines, hébergement, email, SMS, SSL

-- 🌐→🏠 DOMAINE vers HÉBERGEMENT
DEFINE TABLE domain_hosting SCHEMAFULL;
DEFINE FIELD in ON domain_hosting TYPE record(infrastructure_domains);
DEFINE FIELD out ON domain_hosting TYPE record(infrastructure_hosting);
DEFINE FIELD relationship_type ON domain_hosting TYPE string DEFAULT 'hosts';
DEFINE FIELD created_at ON domain_hosting TYPE datetime DEFAULT time::now();

-- 🏠→📧 HÉBERGEMENT vers EMAIL
DEFINE TABLE hosting_email SCHEMAFULL;
DEFINE FIELD in ON hosting_email TYPE record(infrastructure_hosting);
DEFINE FIELD out ON hosting_email TYPE record(infrastructure_email);
DEFINE FIELD relationship_type ON hosting_email TYPE string DEFAULT 'provides';
DEFINE FIELD created_at ON hosting_email TYPE datetime DEFAULT time::now();

-- 🌐→🔒 DOMAINE vers SSL
DEFINE TABLE domain_ssl SCHEMAFULL;
DEFINE FIELD in ON domain_ssl TYPE record(infrastructure_domains);
DEFINE FIELD out ON domain_ssl TYPE record(infrastructure_ssl);
DEFINE FIELD relationship_type ON domain_ssl TYPE string DEFAULT 'secures';
DEFINE FIELD created_at ON domain_ssl TYPE datetime DEFAULT time::now();

-- 🔧→🌐 FOURNISSEUR vers SERVICES
DEFINE TABLE provider_services SCHEMAFULL;
DEFINE FIELD in ON provider_services TYPE record(infrastructure_providers);
DEFINE FIELD out ON provider_services TYPE string; -- domain_id, hosting_id, email_id, etc.
DEFINE FIELD service_type ON provider_services TYPE string; -- 'domain', 'hosting', 'email', 'sms', 'ssl'
DEFINE FIELD relationship_type ON provider_services TYPE string DEFAULT 'manages';
DEFINE FIELD created_at ON provider_services TYPE datetime DEFAULT time::now(); 