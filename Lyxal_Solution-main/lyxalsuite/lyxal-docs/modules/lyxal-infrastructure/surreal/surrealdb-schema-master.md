# 🗄️ SCHÉMA SURREALDB - MODULE INFRASTRUCTURE (NIVEAU MASTER)

## 📋 Vue d'Ensemble

**Module :** `lyxal-infrastructure`  
**Niveau :** Master (ULTIMATE = TRUE)  
**Base de données :** SurrealDB  
**Namespace :** `NS master_{name}`  `DB main_{name}`  
**Scope :** Master level management

---

## 📋 **1. REGISTRE DE PROPRIÉTÉ**

### 1.1 Table `ownership_registry`
```sql
DEFINE TABLE ownership_registry SCHEMAFULL;

DEFINE FIELD master_account_id ON ownership_registry TYPE record<master_accounts> ASSERT $value != NONE;
DEFINE FIELD resource_type ON ownership_registry TYPE string ASSERT $value INSIDE ["domain", "hosting", "email", "sms", "ssl"];
DEFINE FIELD resource_id ON ownership_registry TYPE string ASSERT string::len($value) > 0;
DEFINE FIELD owner_level ON ownership_registry TYPE string ASSERT $value INSIDE ["MASTER", "INVESTOR", "BUSINESS", "DEVELOPER", "CONTRACTOR"];
DEFINE FIELD owner_account_id ON ownership_registry TYPE string ASSERT string::len($value) > 0;
DEFINE FIELD owner_namespace ON ownership_registry TYPE string ASSERT string::len($value) > 0;
DEFINE FIELD owner_database ON ownership_registry TYPE string ASSERT string::len($value) > 0;
DEFINE FIELD parent_owner_id ON ownership_registry TYPE string;
DEFINE FIELD delegation_chain ON ownership_registry TYPE array;
DEFINE FIELD permissions ON ownership_registry TYPE object;
DEFINE FIELD billing_responsibility ON ownership_registry TYPE string ASSERT $value INSIDE ["owner", "parent", "master"];
DEFINE FIELD created_at ON ownership_registry TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON ownership_registry TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_master_registry ON ownership_registry COLUMNS master_account_id;
DEFINE INDEX idx_resource_type ON ownership_registry COLUMNS resource_type;
DEFINE INDEX idx_resource_id ON ownership_registry COLUMNS resource_id UNIQUE;
DEFINE INDEX idx_owner_level ON ownership_registry COLUMNS owner_level;
DEFINE INDEX idx_owner_account ON ownership_registry COLUMNS owner_account_id;
DEFINE INDEX idx_owner_namespace ON ownership_registry COLUMNS owner_namespace;
```

### 1.2 Exemples de propriété
```sql
-- Exemple 1: Domaine appartenant directement au Master
INSERT INTO ownership_registry {
  master_account_id: master_accounts:master_john,
  resource_type: "domain",
  resource_id: "domains:example.com",
  owner_level: "MASTER",
  owner_account_id: "master_john",
  owner_namespace: "NS master_john",
  owner_database: "DB main_john",
  delegation_chain: ["MASTER"],
  billing_responsibility: "owner"
};

-- Exemple 2: Domaine délégué à un Investor
INSERT INTO ownership_registry {
  master_account_id: master_accounts:master_john,
  resource_type: "domain",
  resource_id: "domains:client-website.com",
  owner_level: "INVESTOR",
  owner_account_id: "investor_alice",
  owner_namespace: "NS investor_alice",
  owner_database: "DB main_alice",
  parent_owner_id: "master_john",
  delegation_chain: ["MASTER", "INVESTOR"],
  billing_responsibility: "master"
};

-- Exemple 3: Hébergement délégué à un Developer via Business
INSERT INTO ownership_registry {
  master_account_id: master_accounts:master_john,
  resource_type: "hosting",
  resource_id: "hosting_accounts:dev_project_hosting",
  owner_level: "DEVELOPER",
  owner_account_id: "developer_bob",
  owner_namespace: "NS developer_bob",
  owner_database: "DB main_bob",
  parent_owner_id: "business_carol",
  delegation_chain: ["MASTER", "INVESTOR", "BUSINESS", "DEVELOPER"],
  billing_responsibility: "master"
};
```

### 1.3 Fonctions de recherche propriétaire
```sql
-- Fonction: Trouver le propriétaire d'une ressource
DEFINE FUNCTION fn::get_resource_owner($resource_id: string) {
  RETURN SELECT * FROM ownership_registry WHERE resource_id = $resource_id;
};

-- Fonction: Lister toutes les ressources d'un propriétaire
DEFINE FUNCTION fn::get_owner_resources($owner_account_id: string) {
  RETURN SELECT * FROM ownership_registry WHERE owner_account_id = $owner_account_id;
};

-- Fonction: Vérifier les permissions d'accès
DEFINE FUNCTION fn::check_resource_access($resource_id: string, $user_account_id: string) {
  LET $ownership = SELECT * FROM ownership_registry WHERE resource_id = $resource_id;
  RETURN $ownership.owner_account_id = $user_account_id OR $user_account_id IN $ownership.delegation_chain;
};

-- Fonction: Tracer la chaîne de propriété complète
DEFINE FUNCTION fn::get_ownership_chain($resource_id: string) {
  LET $ownership = SELECT * FROM ownership_registry WHERE resource_id = $resource_id;
  RETURN {
    resource: $ownership,
    master: $ownership.master_account_id,
    chain: $ownership.delegation_chain,
    billing: $ownership.billing_responsibility
  };
};
```

---

## 🌐 **2. GESTION DOMAINES**

### 1.1 Table `domains`
```sql
DEFINE TABLE domains SCHEMAFULL;

DEFINE FIELD master_account_id ON domains TYPE record<master_accounts> ASSERT $value != NONE;
DEFINE FIELD domain_name ON domains TYPE string ASSERT string::len($value) > 0;
DEFINE FIELD registrar ON domains TYPE string DEFAULT "lws";
DEFINE FIELD status ON domains TYPE string ASSERT $value INSIDE ["active", "pending", "expired", "suspended", "transferred"];
DEFINE FIELD registration_date ON domains TYPE datetime;
DEFINE FIELD expiration_date ON domains TYPE datetime;
DEFINE FIELD auto_renew ON domains TYPE bool DEFAULT true;
DEFINE FIELD whois_privacy ON domains TYPE bool DEFAULT true;
DEFINE FIELD dns_managed ON domains TYPE bool DEFAULT true;
DEFINE FIELD registrar_domain_id ON domains TYPE string;
DEFINE FIELD contact_info ON domains TYPE object;
DEFINE FIELD pricing ON domains TYPE object;
DEFINE FIELD created_at ON domains TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON domains TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_domain_name ON domains COLUMNS domain_name UNIQUE;
DEFINE INDEX idx_master_account ON domains COLUMNS master_account_id;
DEFINE INDEX idx_expiration_date ON domains COLUMNS expiration_date;
DEFINE INDEX idx_status ON domains COLUMNS status;
```

### 1.2 Table `dns_records`
```sql
DEFINE TABLE dns_records SCHEMAFULL;

DEFINE FIELD domain_id ON dns_records TYPE record<domains> ASSERT $value != NONE;
DEFINE FIELD record_type ON dns_records TYPE string ASSERT $value INSIDE ["A", "AAAA", "CNAME", "MX", "TXT", "SRV", "NS", "CAA"];
DEFINE FIELD name ON dns_records TYPE string;
DEFINE FIELD value ON dns_records TYPE string ASSERT string::len($value) > 0;
DEFINE FIELD ttl ON dns_records TYPE int DEFAULT 3600;
DEFINE FIELD priority ON dns_records TYPE int;
DEFINE FIELD weight ON dns_records TYPE int;
DEFINE FIELD port ON dns_records TYPE int;
DEFINE FIELD is_active ON dns_records TYPE bool DEFAULT true;
DEFINE FIELD registrar_record_id ON dns_records TYPE string;
DEFINE FIELD created_at ON dns_records TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON dns_records TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_domain_records ON dns_records COLUMNS domain_id;
DEFINE INDEX idx_record_type ON dns_records COLUMNS record_type;
DEFINE INDEX idx_record_name ON dns_records COLUMNS name;
```

### 1.3 Table `domain_monitoring`
```sql
DEFINE TABLE domain_monitoring SCHEMAFULL;

DEFINE FIELD domain_id ON domain_monitoring TYPE record<domains> ASSERT $value != NONE;
DEFINE FIELD check_type ON domain_monitoring TYPE string ASSERT $value INSIDE ["expiration", "dns_propagation", "availability", "ssl_status"];
DEFINE FIELD status ON domain_monitoring TYPE string ASSERT $value INSIDE ["ok", "warning", "critical", "unknown"];
DEFINE FIELD last_check ON domain_monitoring TYPE datetime;
DEFINE FIELD next_check ON domain_monitoring TYPE datetime;
DEFINE FIELD alert_thresholds ON domain_monitoring TYPE object;
DEFINE FIELD check_results ON domain_monitoring TYPE object;
DEFINE FIELD notifications_sent ON domain_monitoring TYPE array;
DEFINE FIELD created_at ON domain_monitoring TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON domain_monitoring TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_domain_monitoring ON domain_monitoring COLUMNS domain_id;
DEFINE INDEX idx_check_type ON domain_monitoring COLUMNS check_type;
DEFINE INDEX idx_status ON domain_monitoring COLUMNS status;
DEFINE INDEX idx_next_check ON domain_monitoring COLUMNS next_check;
```

---

## 🏠 **2. GESTION HÉBERGEMENT**

### 2.1 Table `hosting_accounts`
```sql
DEFINE TABLE hosting_accounts SCHEMAFULL;

DEFINE FIELD master_account_id ON hosting_accounts TYPE record<master_accounts> ASSERT $value != NONE;
DEFINE FIELD account_name ON hosting_accounts TYPE string ASSERT string::len($value) > 0;
DEFINE FIELD provider ON hosting_accounts TYPE string DEFAULT "lws";
DEFINE FIELD plan_id ON hosting_accounts TYPE record<hosting_plans>;
DEFINE FIELD status ON hosting_accounts TYPE string ASSERT $value INSIDE ["active", "suspended", "pending", "cancelled"];
DEFINE FIELD server_info ON hosting_accounts TYPE object;
DEFINE FIELD access_credentials ON hosting_accounts TYPE object;
DEFINE FIELD domain_id ON hosting_accounts TYPE record<domains>;
DEFINE FIELD provider_account_id ON hosting_accounts TYPE string;
DEFINE FIELD billing_cycle ON hosting_accounts TYPE string ASSERT $value INSIDE ["monthly", "yearly"];
DEFINE FIELD next_billing_date ON hosting_accounts TYPE datetime;
DEFINE FIELD created_at ON hosting_accounts TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON hosting_accounts TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_master_hosting ON hosting_accounts COLUMNS master_account_id;
DEFINE INDEX idx_hosting_status ON hosting_accounts COLUMNS status;
DEFINE INDEX idx_provider_account ON hosting_accounts COLUMNS provider_account_id;
DEFINE INDEX idx_billing_date ON hosting_accounts COLUMNS next_billing_date;
```

### 2.2 Table `hosting_plans`
```sql
DEFINE TABLE hosting_plans SCHEMAFULL;

DEFINE FIELD plan_name ON hosting_plans TYPE string ASSERT string::len($value) > 0;
DEFINE FIELD provider ON hosting_plans TYPE string DEFAULT "lws";
DEFINE FIELD plan_type ON hosting_plans TYPE string ASSERT $value INSIDE ["shared", "vps", "dedicated", "cloud"];
DEFINE FIELD specifications ON hosting_plans TYPE object;
DEFINE FIELD pricing ON hosting_plans TYPE object;
DEFINE FIELD features ON hosting_plans TYPE array;
DEFINE FIELD limits ON hosting_plans TYPE object;
DEFINE FIELD is_active ON hosting_plans TYPE bool DEFAULT true;
DEFINE FIELD provider_plan_id ON hosting_plans TYPE string;
DEFINE FIELD created_at ON hosting_plans TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON hosting_plans TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_plan_provider ON hosting_plans COLUMNS provider;
DEFINE INDEX idx_plan_type ON hosting_plans COLUMNS plan_type;
DEFINE INDEX idx_plan_active ON hosting_plans COLUMNS is_active;
```

### 2.3 Table `hosting_monitoring`
```sql
DEFINE TABLE hosting_monitoring SCHEMAFULL;

DEFINE FIELD hosting_account_id ON hosting_monitoring TYPE record<hosting_accounts> ASSERT $value != NONE;
DEFINE FIELD metric_type ON hosting_monitoring TYPE string ASSERT $value INSIDE ["cpu", "memory", "disk", "bandwidth", "uptime"];
DEFINE FIELD current_value ON hosting_monitoring TYPE float;
DEFINE FIELD max_value ON hosting_monitoring TYPE float;
DEFINE FIELD usage_percentage ON hosting_monitoring TYPE float;
DEFINE FIELD alert_threshold ON hosting_monitoring TYPE float DEFAULT 80.0;
DEFINE FIELD status ON hosting_monitoring TYPE string ASSERT $value INSIDE ["normal", "warning", "critical"];
DEFINE FIELD measurement_time ON hosting_monitoring TYPE datetime DEFAULT time::now();
DEFINE FIELD historical_data ON hosting_monitoring TYPE array;

DEFINE INDEX idx_hosting_metrics ON hosting_monitoring COLUMNS hosting_account_id;
DEFINE INDEX idx_metric_type ON hosting_monitoring COLUMNS metric_type;
DEFINE INDEX idx_measurement_time ON hosting_monitoring COLUMNS measurement_time;
DEFINE INDEX idx_status_monitoring ON hosting_monitoring COLUMNS status;
```

---

## 📧 **3. GESTION EMAIL**

### 3.1 Table `email_accounts`
```sql
DEFINE TABLE email_accounts SCHEMAFULL;

DEFINE FIELD domain_id ON email_accounts TYPE record<domains> ASSERT $value != NONE;
DEFINE FIELD email_address ON email_accounts TYPE string ASSERT string::is::email($value);
DEFINE FIELD account_type ON email_accounts TYPE string ASSERT $value INSIDE ["mailbox", "alias", "forwarder"];
DEFINE FIELD password_hash ON email_accounts TYPE string;
DEFINE FIELD quota_mb ON email_accounts TYPE int DEFAULT 1000;
DEFINE FIELD used_quota_mb ON email_accounts TYPE int DEFAULT 0;
DEFINE FIELD status ON email_accounts TYPE string ASSERT $value INSIDE ["active", "suspended", "disabled"];
DEFINE FIELD forwarding_addresses ON email_accounts TYPE array;
DEFINE FIELD autoresponder ON email_accounts TYPE object;
DEFINE FIELD security_settings ON email_accounts TYPE object;
DEFINE FIELD provider_account_id ON email_accounts TYPE string;
DEFINE FIELD created_at ON email_accounts TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON email_accounts TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_email_address ON email_accounts COLUMNS email_address UNIQUE;
DEFINE INDEX idx_domain_emails ON email_accounts COLUMNS domain_id;
DEFINE INDEX idx_email_status ON email_accounts COLUMNS status;
DEFINE INDEX idx_account_type ON email_accounts COLUMNS account_type;
```

### 3.2 Table `email_rules`
```sql
DEFINE TABLE email_rules SCHEMAFULL;

DEFINE FIELD email_account_id ON email_rules TYPE record<email_accounts> ASSERT $value != NONE;
DEFINE FIELD rule_name ON email_rules TYPE string ASSERT string::len($value) > 0;
DEFINE FIELD rule_type ON email_rules TYPE string ASSERT $value INSIDE ["filter", "forward", "autoresponder", "block"];
DEFINE FIELD conditions ON email_rules TYPE object;
DEFINE FIELD actions ON email_rules TYPE object;
DEFINE FIELD priority ON email_rules TYPE int DEFAULT 100;
DEFINE FIELD is_active ON email_rules TYPE bool DEFAULT true;
DEFINE FIELD created_at ON email_rules TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON email_rules TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_email_rules ON email_rules COLUMNS email_account_id;
DEFINE INDEX idx_rule_type ON email_rules COLUMNS rule_type;
DEFINE INDEX idx_rule_priority ON email_rules COLUMNS priority;
```

### 3.3 Table `email_security`
```sql
DEFINE TABLE email_security SCHEMAFULL;

DEFINE FIELD domain_id ON email_security TYPE record<domains> ASSERT $value != NONE;
DEFINE FIELD security_type ON email_security TYPE string ASSERT $value INSIDE ["spf", "dkim", "dmarc", "antispam"];
DEFINE FIELD configuration ON email_security TYPE object;
DEFINE FIELD status ON email_security TYPE string ASSERT $value INSIDE ["enabled", "disabled", "pending"];
DEFINE FIELD last_check ON email_security TYPE datetime;
DEFINE FIELD check_results ON email_security TYPE object;
DEFINE FIELD created_at ON email_security TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON email_security TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_domain_security ON email_security COLUMNS domain_id;
DEFINE INDEX idx_security_type ON email_security COLUMNS security_type;
DEFINE INDEX idx_security_status ON email_security COLUMNS status;
```

---

## 📱 **4. GESTION SMS**

### 4.1 Table `sms_campaigns`
```sql
DEFINE TABLE sms_campaigns SCHEMAFULL;

DEFINE FIELD master_account_id ON sms_campaigns TYPE record<master_accounts> ASSERT $value != NONE;
DEFINE FIELD campaign_name ON sms_campaigns TYPE string ASSERT string::len($value) > 0;
DEFINE FIELD message_content ON sms_campaigns TYPE string ASSERT string::len($value) <= 160;
DEFINE FIELD sender_id ON sms_campaigns TYPE string;
DEFINE FIELD status ON sms_campaigns TYPE string ASSERT $value INSIDE ["draft", "scheduled", "sending", "sent", "failed"];
DEFINE FIELD scheduled_at ON sms_campaigns TYPE datetime;
DEFINE FIELD sent_at ON sms_campaigns TYPE datetime;
DEFINE FIELD recipient_count ON sms_campaigns TYPE int DEFAULT 0;
DEFINE FIELD sent_count ON sms_campaigns TYPE int DEFAULT 0;
DEFINE FIELD failed_count ON sms_campaigns TYPE int DEFAULT 0;
DEFINE FIELD cost_estimate ON sms_campaigns TYPE float;
DEFINE FIELD actual_cost ON sms_campaigns TYPE float;
DEFINE FIELD created_at ON sms_campaigns TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON sms_campaigns TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_master_campaigns ON sms_campaigns COLUMNS master_account_id;
DEFINE INDEX idx_campaign_status ON sms_campaigns COLUMNS status;
DEFINE INDEX idx_scheduled_at ON sms_campaigns COLUMNS scheduled_at;
```

### 4.2 Table `sms_contacts`
```sql
DEFINE TABLE sms_contacts SCHEMAFULL;

DEFINE FIELD master_account_id ON sms_contacts TYPE record<master_accounts> ASSERT $value != NONE;
DEFINE FIELD phone_number ON sms_contacts TYPE string ASSERT string::len($value) > 0;
DEFINE FIELD contact_name ON sms_contacts TYPE string;
DEFINE FIELD groups ON sms_contacts TYPE array;
DEFINE FIELD status ON sms_contacts TYPE string ASSERT $value INSIDE ["active", "opt_out", "invalid"];
DEFINE FIELD opt_out_date ON sms_contacts TYPE datetime;
DEFINE FIELD custom_fields ON sms_contacts TYPE object;
DEFINE FIELD created_at ON sms_contacts TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON sms_contacts TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_master_contacts ON sms_contacts COLUMNS master_account_id;
DEFINE INDEX idx_phone_number ON sms_contacts COLUMNS phone_number;
DEFINE INDEX idx_contact_status ON sms_contacts COLUMNS status;
```

### 4.3 Table `sms_logs`
```sql
DEFINE TABLE sms_logs SCHEMAFULL;

DEFINE FIELD campaign_id ON sms_logs TYPE record<sms_campaigns>;
DEFINE FIELD contact_id ON sms_logs TYPE record<sms_contacts>;
DEFINE FIELD phone_number ON sms_logs TYPE string ASSERT string::len($value) > 0;
DEFINE FIELD message_content ON sms_logs TYPE string;
DEFINE FIELD status ON sms_logs TYPE string ASSERT $value INSIDE ["sent", "delivered", "failed", "pending"];
DEFINE FIELD provider_message_id ON sms_logs TYPE string;
DEFINE FIELD error_message ON sms_logs TYPE string;
DEFINE FIELD cost ON sms_logs TYPE float;
DEFINE FIELD sent_at ON sms_logs TYPE datetime;
DEFINE FIELD delivered_at ON sms_logs TYPE datetime;

DEFINE INDEX idx_campaign_logs ON sms_logs COLUMNS campaign_id;
DEFINE INDEX idx_contact_logs ON sms_logs COLUMNS contact_id;
DEFINE INDEX idx_sms_status ON sms_logs COLUMNS status;
DEFINE INDEX idx_sent_at ON sms_logs COLUMNS sent_at;
```

---

## 🔒 **5. GESTION SSL**

### 5.1 Table `ssl_certificates`
```sql
DEFINE TABLE ssl_certificates SCHEMAFULL;

DEFINE FIELD domain_id ON ssl_certificates TYPE record<domains> ASSERT $value != NONE;
DEFINE FIELD certificate_type ON ssl_certificates TYPE string ASSERT $value INSIDE ["letsencrypt", "commercial", "wildcard"];
DEFINE FIELD issuer ON ssl_certificates TYPE string;
DEFINE FIELD status ON ssl_certificates TYPE string ASSERT $value INSIDE ["active", "expired", "revoked", "pending"];
DEFINE FIELD issue_date ON ssl_certificates TYPE datetime;
DEFINE FIELD expiration_date ON ssl_certificates TYPE datetime;
DEFINE FIELD auto_renew ON ssl_certificates TYPE bool DEFAULT true;
DEFINE FIELD certificate_data ON ssl_certificates TYPE object;
DEFINE FIELD private_key_hash ON ssl_certificates TYPE string;
DEFINE FIELD provider_cert_id ON ssl_certificates TYPE string;
DEFINE FIELD san_domains ON ssl_certificates TYPE array;
DEFINE FIELD created_at ON ssl_certificates TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON ssl_certificates TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_domain_ssl ON ssl_certificates COLUMNS domain_id;
DEFINE INDEX idx_cert_type ON ssl_certificates COLUMNS certificate_type;
DEFINE INDEX idx_expiration_date_ssl ON ssl_certificates COLUMNS expiration_date;
DEFINE INDEX idx_ssl_status ON ssl_certificates COLUMNS status;
```

### 5.2 Table `ssl_monitoring`
```sql
DEFINE TABLE ssl_monitoring SCHEMAFULL;

DEFINE FIELD certificate_id ON ssl_monitoring TYPE record<ssl_certificates> ASSERT $value != NONE;
DEFINE FIELD check_type ON ssl_monitoring TYPE string ASSERT $value INSIDE ["expiration", "validity", "chain", "configuration"];
DEFINE FIELD status ON ssl_monitoring TYPE string ASSERT $value INSIDE ["valid", "warning", "invalid", "expired"];
DEFINE FIELD last_check ON ssl_monitoring TYPE datetime;
DEFINE FIELD next_check ON ssl_monitoring TYPE datetime;
DEFINE FIELD check_results ON ssl_monitoring TYPE object;
DEFINE FIELD ssl_grade ON ssl_monitoring TYPE string;
DEFINE FIELD warnings ON ssl_monitoring TYPE array;
DEFINE FIELD created_at ON ssl_monitoring TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_cert_monitoring ON ssl_monitoring COLUMNS certificate_id;
DEFINE INDEX idx_ssl_check_type ON ssl_monitoring COLUMNS check_type;
DEFINE INDEX idx_ssl_monitor_status ON ssl_monitoring COLUMNS status;
DEFINE INDEX idx_next_ssl_check ON ssl_monitoring COLUMNS next_check;
```

---

## 🔧 **6. INTÉGRATION ET CONFIGURATION**

### 6.1 Table `api_credentials`
```sql
DEFINE TABLE api_credentials SCHEMAFULL;

DEFINE FIELD master_account_id ON api_credentials TYPE record<master_accounts> ASSERT $value != NONE;
DEFINE FIELD provider ON api_credentials TYPE string ASSERT string::len($value) > 0;
DEFINE FIELD credential_type ON api_credentials TYPE string ASSERT $value INSIDE ["api_key", "oauth", "hmac"];
DEFINE FIELD encrypted_credentials ON api_credentials TYPE string;
DEFINE FIELD environment ON api_credentials TYPE string ASSERT $value INSIDE ["production", "sandbox", "test"];
DEFINE FIELD status ON api_credentials TYPE string ASSERT $value INSIDE ["active", "expired", "disabled"];
DEFINE FIELD permissions ON api_credentials TYPE array;
DEFINE FIELD rate_limits ON api_credentials TYPE object;
DEFINE FIELD last_used ON api_credentials TYPE datetime;
DEFINE FIELD expires_at ON api_credentials TYPE datetime;
DEFINE FIELD created_at ON api_credentials TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON api_credentials TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_master_credentials ON api_credentials COLUMNS master_account_id;
DEFINE INDEX idx_provider_creds ON api_credentials COLUMNS provider;
DEFINE INDEX idx_creds_status ON api_credentials COLUMNS status;
```

### 6.2 Table `webhooks`
```sql
DEFINE TABLE webhooks SCHEMAFULL;

DEFINE FIELD provider ON webhooks TYPE string ASSERT string::len($value) > 0;
DEFINE FIELD event_type ON webhooks TYPE string ASSERT string::len($value) > 0;
DEFINE FIELD webhook_url ON webhooks TYPE string;
DEFINE FIELD secret_key ON webhooks TYPE string;
DEFINE FIELD is_active ON webhooks TYPE bool DEFAULT true;
DEFINE FIELD retry_count ON webhooks TYPE int DEFAULT 3;
DEFINE FIELD timeout_seconds ON webhooks TYPE int DEFAULT 30;
DEFINE FIELD last_triggered ON webhooks TYPE datetime;
DEFINE FIELD success_count ON webhooks TYPE int DEFAULT 0;
DEFINE FIELD failure_count ON webhooks TYPE int DEFAULT 0;
DEFINE FIELD created_at ON webhooks TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON webhooks TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_provider_webhooks ON webhooks COLUMNS provider;
DEFINE INDEX idx_event_type ON webhooks COLUMNS event_type;
DEFINE INDEX idx_webhook_active ON webhooks COLUMNS is_active;
```

### 6.3 Table `providers`
```sql
DEFINE TABLE providers SCHEMAFULL;

DEFINE FIELD provider_name ON providers TYPE string ASSERT string::len($value) > 0;
DEFINE FIELD provider_type ON providers TYPE string ASSERT $value INSIDE ["hosting", "domain", "email", "sms", "ssl"];
DEFINE FIELD api_base_url ON providers TYPE string;
DEFINE FIELD api_version ON providers TYPE string;
DEFINE FIELD supported_features ON providers TYPE array;
DEFINE FIELD rate_limits ON providers TYPE object;
DEFINE FIELD documentation_url ON providers TYPE string;
DEFINE FIELD status ON providers TYPE string ASSERT $value INSIDE ["active", "maintenance", "deprecated"];
DEFINE FIELD health_check_url ON providers TYPE string;
DEFINE FIELD last_health_check ON providers TYPE datetime;
DEFINE FIELD created_at ON providers TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON providers TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_provider_name ON providers COLUMNS provider_name UNIQUE;
DEFINE INDEX idx_provider_type ON providers COLUMNS provider_type;
DEFINE INDEX idx_provider_status ON providers COLUMNS status;
```

---

## 📊 **7. MONITORING ET ANALYTICS**

### 7.1 Table `infrastructure_metrics`
```sql
DEFINE TABLE infrastructure_metrics SCHEMAFULL;

DEFINE FIELD master_account_id ON infrastructure_metrics TYPE record<master_accounts> ASSERT $value != NONE;
DEFINE FIELD metric_category ON infrastructure_metrics TYPE string ASSERT $value INSIDE ["domains", "hosting", "email", "sms", "ssl"];
DEFINE FIELD metric_name ON infrastructure_metrics TYPE string ASSERT string::len($value) > 0;
DEFINE FIELD metric_value ON infrastructure_metrics TYPE float;
DEFINE FIELD metric_unit ON infrastructure_metrics TYPE string;
DEFINE FIELD resource_id ON infrastructure_metrics TYPE string;
DEFINE FIELD timestamp ON infrastructure_metrics TYPE datetime DEFAULT time::now();
DEFINE FIELD metadata ON infrastructure_metrics TYPE object;

DEFINE INDEX idx_master_metrics ON infrastructure_metrics COLUMNS master_account_id;
DEFINE INDEX idx_metric_category ON infrastructure_metrics COLUMNS metric_category;
DEFINE INDEX idx_metric_timestamp ON infrastructure_metrics COLUMNS timestamp;
DEFINE INDEX idx_resource_metrics ON infrastructure_metrics COLUMNS resource_id;
```

### 7.2 Table `alerts`
```sql
DEFINE TABLE alerts SCHEMAFULL;

DEFINE FIELD master_account_id ON alerts TYPE record<master_accounts> ASSERT $value != NONE;
DEFINE FIELD alert_type ON alerts TYPE string ASSERT $value INSIDE ["domain_expiry", "ssl_expiry", "quota_exceeded", "service_down", "security_issue"];
DEFINE FIELD severity ON alerts TYPE string ASSERT $value INSIDE ["info", "warning", "critical"];
DEFINE FIELD title ON alerts TYPE string ASSERT string::len($value) > 0;
DEFINE FIELD description ON alerts TYPE string;
DEFINE FIELD resource_type ON alerts TYPE string;
DEFINE FIELD resource_id ON alerts TYPE string;
DEFINE FIELD status ON alerts TYPE string ASSERT $value INSIDE ["active", "acknowledged", "resolved"];
DEFINE FIELD triggered_at ON alerts TYPE datetime DEFAULT time::now();
DEFINE FIELD acknowledged_at ON alerts TYPE datetime;
DEFINE FIELD resolved_at ON alerts TYPE datetime;
DEFINE FIELD notification_sent ON alerts TYPE bool DEFAULT false;

DEFINE INDEX idx_master_alerts ON alerts COLUMNS master_account_id;
DEFINE INDEX idx_alert_type ON alerts COLUMNS alert_type;
DEFINE INDEX idx_alert_severity ON alerts COLUMNS severity;
DEFINE INDEX idx_alert_status ON alerts COLUMNS status;
DEFINE INDEX idx_triggered_at ON alerts COLUMNS triggered_at;
```

### 7.3 Table `audit_logs`
```sql
DEFINE TABLE audit_logs SCHEMAFULL;

DEFINE FIELD master_account_id ON audit_logs TYPE record<master_accounts> ASSERT $value != NONE;
DEFINE FIELD action_type ON audit_logs TYPE string ASSERT string::len($value) > 0;
DEFINE FIELD resource_type ON audit_logs TYPE string;
DEFINE FIELD resource_id ON audit_logs TYPE string;
DEFINE FIELD user_id ON audit_logs TYPE string;
DEFINE FIELD action_details ON audit_logs TYPE object;
DEFINE FIELD ip_address ON audit_logs TYPE string;
DEFINE FIELD user_agent ON audit_logs TYPE string;
DEFINE FIELD timestamp ON audit_logs TYPE datetime DEFAULT time::now();
DEFINE FIELD success ON audit_logs TYPE bool;
DEFINE FIELD error_message ON audit_logs TYPE string;

DEFINE INDEX idx_master_audit ON audit_logs COLUMNS master_account_id;
DEFINE INDEX idx_action_type ON audit_logs COLUMNS action_type;
DEFINE INDEX idx_resource_type ON audit_logs COLUMNS resource_type;
DEFINE INDEX idx_audit_timestamp ON audit_logs COLUMNS timestamp;
DEFINE INDEX idx_user_audit ON audit_logs COLUMNS user_id;
```

---

## 💰 **8. FACTURATION ET COÛTS**

### 8.1 Table `billing_records`
```sql
DEFINE TABLE billing_records SCHEMAFULL;

DEFINE FIELD master_account_id ON billing_records TYPE record<master_accounts> ASSERT $value != NONE;
DEFINE FIELD service_type ON billing_records TYPE string ASSERT $value INSIDE ["domain", "hosting", "email", "sms", "ssl"];
DEFINE FIELD resource_id ON billing_records TYPE string;
DEFINE FIELD billing_period_start ON billing_records TYPE datetime;
DEFINE FIELD billing_period_end ON billing_records TYPE datetime;
DEFINE FIELD amount ON billing_records TYPE float;
DEFINE FIELD currency ON billing_records TYPE string DEFAULT "EUR";
DEFINE FIELD provider_invoice_id ON billing_records TYPE string;
DEFINE FIELD status ON billing_records TYPE string ASSERT $value INSIDE ["pending", "paid", "overdue", "cancelled"];
DEFINE FIELD invoice_date ON billing_records TYPE datetime;
DEFINE FIELD due_date ON billing_records TYPE datetime;
DEFINE FIELD paid_date ON billing_records TYPE datetime;
DEFINE FIELD created_at ON billing_records TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_master_billing ON billing_records COLUMNS master_account_id;
DEFINE INDEX idx_service_billing ON billing_records COLUMNS service_type;
DEFINE INDEX idx_billing_status ON billing_records COLUMNS status;
DEFINE INDEX idx_due_date ON billing_records COLUMNS due_date;
```

### 8.2 Table `cost_tracking`
```sql
DEFINE TABLE cost_tracking SCHEMAFULL;

DEFINE FIELD master_account_id ON cost_tracking TYPE record<master_accounts> ASSERT $value != NONE;
DEFINE FIELD cost_category ON cost_tracking TYPE string ASSERT $value INSIDE ["domains", "hosting", "email", "sms", "ssl", "api_calls"];
DEFINE FIELD resource_id ON cost_tracking TYPE string;
DEFINE FIELD cost_amount ON cost_tracking TYPE float;
DEFINE FIELD currency ON cost_tracking TYPE string DEFAULT "EUR";
DEFINE FIELD usage_quantity ON cost_tracking TYPE float;
DEFINE FIELD usage_unit ON cost_tracking TYPE string;
DEFINE FIELD cost_date ON cost_tracking TYPE datetime DEFAULT time::now();
DEFINE FIELD provider ON cost_tracking TYPE string;
DEFINE FIELD notes ON cost_tracking TYPE string;

DEFINE INDEX idx_master_costs ON cost_tracking COLUMNS master_account_id;
DEFINE INDEX idx_cost_category ON cost_tracking COLUMNS cost_category;
DEFINE INDEX idx_cost_date ON cost_tracking COLUMNS cost_date;
DEFINE INDEX idx_provider_costs ON cost_tracking COLUMNS provider;
```

---

## 🔗 **RELATIONS ENTRE TABLES**

### **Relations Principales**
```sql
-- Domaine vers DNS
RELATE domains->has_dns_records->dns_records;

-- Domaine vers Monitoring
RELATE domains->monitored_by->domain_monitoring;

-- Domaine vers SSL
RELATE domains->secured_by->ssl_certificates;

-- Domaine vers Email
RELATE domains->provides_email->email_accounts;

-- Hébergement vers Monitoring
RELATE hosting_accounts->monitored_by->hosting_monitoring;

-- SSL vers Monitoring
RELATE ssl_certificates->monitored_by->ssl_monitoring;

-- Email vers Règles
RELATE email_accounts->has_rules->email_rules;

-- Master vers toutes les ressources
RELATE master_accounts->owns->domains;
RELATE master_accounts->owns->hosting_accounts;
RELATE master_accounts->owns->sms_campaigns;
RELATE master_accounts->has_credentials->api_credentials;
```

---

## 🚀 **INITIALISATION ET CONFIGURATION**

### **Script d'initialisation**
```sql
-- Création du namespace et database
DEFINE NAMESPACE lyxal_infrastructure;
USE NS lyxal_infrastructure;
DEFINE DATABASE infrastructure;
USE DB infrastructure;

-- Configuration sécurité
DEFINE SCOPE master_access
  SESSION 24h
  SIGNIN (
    SELECT * FROM master_accounts WHERE email = $email AND crypto::argon2::compare(password, $password)
  );

-- Données de référence LWS
INSERT INTO providers {
  provider_name: "lws",
  provider_type: "hosting",
  api_base_url: "https://api.lws.fr/v1",
  api_version: "1.0",
  supported_features: ["domains", "hosting", "email", "ssl"],
  status: "active"
};

-- Configuration webhooks par défaut
INSERT INTO webhooks {
  provider: "lws",
  event_type: "domain.expired",
  webhook_url: "https://api.lyxalsuite.com/webhooks/lws/domain-expired",
  is_active: true
};
```

---

## 📋 **CHECKLIST IMPLÉMENTATION**

### **Phase 1 : Tables Core**
- [ ] Création tables `domains`, `dns_records`, `domain_monitoring`
- [ ] Création tables `hosting_accounts`, `hosting_plans`, `hosting_monitoring`
- [ ] Tests CRUD operations

### **Phase 2 : Communication**
- [ ] Création tables `email_accounts`, `email_rules`, `email_security`
- [ ] Création tables `sms_campaigns`, `sms_contacts`, `sms_logs`
- [ ] Tests intégrations

### **Phase 3 : Sécurité et Monitoring**
- [ ] Création tables `ssl_certificates`, `ssl_monitoring`
- [ ] Création tables `alerts`, `audit_logs`, `infrastructure_metrics`
- [ ] Tests alertes

### **Phase 4 : Intégration et Facturation**
- [ ] Création tables `api_credentials`, `webhooks`, `providers`
- [ ] Création tables `billing_records`, `cost_tracking`
- [ ] Tests end-to-end

---

**Version :** 1.0  
**Dernière mise à jour :** Décembre 2024  
**Statut :** Schéma complet pour niveau Master 