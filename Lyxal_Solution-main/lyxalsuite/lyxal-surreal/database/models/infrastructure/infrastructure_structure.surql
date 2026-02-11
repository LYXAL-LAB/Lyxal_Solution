-- ===================================
-- 🏗️ MODULE INFRASTRUCTURE - STRUCTURE
-- ===================================
-- Tables pour gestion domaines, hébergement, email, SMS, SSL
-- Fournisseurs : LWS (extensible à d'autres)
-- Accès : Ultimate Grade uniquement

-- 🌐 DOMAINES
DEFINE TABLE infrastructure_domains SCHEMAFULL;
DEFINE FIELD domain_name ON infrastructure_domains TYPE string ASSERT $value != NONE;
DEFINE FIELD registrar ON infrastructure_domains TYPE string DEFAULT 'lws';
DEFINE FIELD status ON infrastructure_domains TYPE string DEFAULT 'active';
DEFINE FIELD expiry_date ON infrastructure_domains TYPE datetime;
DEFINE FIELD auto_renew ON infrastructure_domains TYPE bool DEFAULT true;
DEFINE FIELD whois_privacy ON infrastructure_domains TYPE bool DEFAULT true;
DEFINE FIELD dns_managed ON infrastructure_domains TYPE bool DEFAULT true;
DEFINE FIELD owner_level ON infrastructure_domains TYPE int ASSERT $value >= 0 AND $value <= 4;
DEFINE FIELD owner_id ON infrastructure_domains TYPE string ASSERT $value != NONE;
DEFINE FIELD created_at ON infrastructure_domains TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON infrastructure_domains TYPE datetime DEFAULT time::now();

-- 🏠 HÉBERGEMENT
DEFINE TABLE infrastructure_hosting SCHEMAFULL;
DEFINE FIELD hosting_id ON infrastructure_hosting TYPE string ASSERT $value != NONE;
DEFINE FIELD domain_id ON infrastructure_hosting TYPE record(infrastructure_domains);
DEFINE FIELD plan_type ON infrastructure_hosting TYPE string; -- shared_starter, shared_pro, vps_pro, dedicated_pro
DEFINE FIELD provider ON infrastructure_hosting TYPE string DEFAULT 'lws';
DEFINE FIELD status ON infrastructure_hosting TYPE string DEFAULT 'active';
DEFINE FIELD resources ON infrastructure_hosting TYPE object VALUE {
    disk_space: 0,
    bandwidth: 0,
    databases: 0,
    email_accounts: 0,
    subdomains: 0
};
DEFINE FIELD billing ON infrastructure_hosting TYPE object VALUE {
    monthly_cost: 0.0,
    billing_cycle: 'monthly',
    next_billing: datetime
};
DEFINE FIELD owner_level ON infrastructure_hosting TYPE int ASSERT $value >= 0 AND $value <= 4;
DEFINE FIELD owner_id ON infrastructure_hosting TYPE string ASSERT $value != NONE;
DEFINE FIELD created_at ON infrastructure_hosting TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON infrastructure_hosting TYPE datetime DEFAULT time::now();

-- 📧 EMAIL
DEFINE TABLE infrastructure_email SCHEMAFULL;
DEFINE FIELD email_address ON infrastructure_email TYPE string ASSERT $value != NONE;
DEFINE FIELD domain_id ON infrastructure_email TYPE record(infrastructure_domains);
DEFINE FIELD hosting_id ON infrastructure_email TYPE record(infrastructure_hosting);
DEFINE FIELD mailbox_size ON infrastructure_email TYPE int DEFAULT 1000; -- MB
DEFINE FIELD status ON infrastructure_email TYPE string DEFAULT 'active';
DEFINE FIELD forwarding ON infrastructure_email TYPE array<string>;
DEFINE FIELD autoresponder ON infrastructure_email TYPE object VALUE {
    enabled: false,
    subject: '',
    message: '',
    start_date: datetime,
    end_date: datetime
};
DEFINE FIELD owner_level ON infrastructure_email TYPE int ASSERT $value >= 0 AND $value <= 4;
DEFINE FIELD owner_id ON infrastructure_email TYPE string ASSERT $value != NONE;
DEFINE FIELD created_at ON infrastructure_email TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON infrastructure_email TYPE datetime DEFAULT time::now();

-- 📱 SMS
DEFINE TABLE infrastructure_sms SCHEMAFULL;
DEFINE FIELD campaign_id ON infrastructure_sms TYPE string ASSERT $value != NONE;
DEFINE FIELD campaign_name ON infrastructure_sms TYPE string ASSERT $value != NONE;
DEFINE FIELD message ON infrastructure_sms TYPE string ASSERT $value != NONE;
DEFINE FIELD recipients ON infrastructure_sms TYPE array<string>;
DEFINE FIELD status ON infrastructure_sms TYPE string DEFAULT 'draft'; -- draft, scheduled, sent, failed
DEFINE FIELD scheduled_at ON infrastructure_sms TYPE datetime;
DEFINE FIELD sent_at ON infrastructure_sms TYPE datetime;
DEFINE FIELD stats ON infrastructure_sms TYPE object VALUE {
    sent_count: 0,
    delivered_count: 0,
    failed_count: 0,
    cost: 0.0
};
DEFINE FIELD owner_level ON infrastructure_sms TYPE int ASSERT $value >= 0 AND $value <= 4;
DEFINE FIELD owner_id ON infrastructure_sms TYPE string ASSERT $value != NONE;
DEFINE FIELD created_at ON infrastructure_sms TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON infrastructure_sms TYPE datetime DEFAULT time::now();

-- 🔒 SSL CERTIFICATS
DEFINE TABLE infrastructure_ssl SCHEMAFULL;
DEFINE FIELD certificate_id ON infrastructure_ssl TYPE string ASSERT $value != NONE;
DEFINE FIELD domain_id ON infrastructure_ssl TYPE record(infrastructure_domains);
DEFINE FIELD certificate_type ON infrastructure_ssl TYPE string DEFAULT 'letsencrypt'; -- letsencrypt, commercial
DEFINE FIELD status ON infrastructure_ssl TYPE string DEFAULT 'active';
DEFINE FIELD issued_at ON infrastructure_ssl TYPE datetime;
DEFINE FIELD expires_at ON infrastructure_ssl TYPE datetime;
DEFINE FIELD auto_renew ON infrastructure_ssl TYPE bool DEFAULT true;
DEFINE FIELD provider ON infrastructure_ssl TYPE string DEFAULT 'lws';
DEFINE FIELD owner_level ON infrastructure_ssl TYPE int ASSERT $value >= 0 AND $value <= 4;
DEFINE FIELD owner_id ON infrastructure_ssl TYPE string ASSERT $value != NONE;
DEFINE FIELD created_at ON infrastructure_ssl TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON infrastructure_ssl TYPE datetime DEFAULT time::now();

-- 🔧 CONFIGURATION FOURNISSEURS
DEFINE TABLE infrastructure_providers SCHEMAFULL;
DEFINE FIELD provider_name ON infrastructure_providers TYPE string ASSERT $value != NONE;
DEFINE FIELD api_config ON infrastructure_providers TYPE object VALUE {
    base_url: '',
    api_key: '',
    api_secret: '',
    hmac_enabled: false,
    rate_limit: 100
};
DEFINE FIELD services ON infrastructure_providers TYPE array<string>; -- ['domains', 'hosting', 'email', 'sms', 'ssl']
DEFINE FIELD status ON infrastructure_providers TYPE string DEFAULT 'active';
DEFINE FIELD created_at ON infrastructure_providers TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON infrastructure_providers TYPE datetime DEFAULT time::now(); 