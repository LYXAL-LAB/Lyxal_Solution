-- ===================================
-- 📋 MODULE INFRASTRUCTURE - DONNÉES
-- ===================================
-- Données de référence et configuration LWS

-- 🔧 CONFIGURATION FOURNISSEUR LWS
INSERT INTO infrastructure_providers {
    provider_name: 'lws',
    api_config: {
        base_url: 'https://api.lws.fr/v1',
        api_key: '',  -- À configurer via variables d'environnement
        api_secret: '',  -- À configurer via variables d'environnement
        hmac_enabled: true,
        rate_limit: 100
    },
    services: ['domains', 'hosting', 'email', 'sms', 'ssl'],
    status: 'active',
    created_at: time::now(),
    updated_at: time::now()
};

-- 🏠 PLANS D'HÉBERGEMENT LWS DE RÉFÉRENCE
-- Plans recommandés selon la hiérarchie LyxalSuite

-- Plan MASTER (Niveau 0)
INSERT INTO infrastructure_hosting {
    hosting_id: 'lws_dedicated_pro_template',
    plan_type: 'dedicated_pro',
    provider: 'lws',
    status: 'template',
    resources: {
        disk_space: 2000000,  -- 2TB
        bandwidth: 0,  -- Illimité
        databases: 0,  -- Illimité
        email_accounts: 0,  -- Illimité
        subdomains: 0  -- Illimité
    },
    billing: {
        monthly_cost: 199.00,
        billing_cycle: 'monthly',
        next_billing: time::now() + 1mo
    },
    owner_level: 0,
    owner_id: 'template',
    created_at: time::now(),
    updated_at: time::now()
};

-- Plan INVESTOR (Niveau 1)
INSERT INTO infrastructure_hosting {
    hosting_id: 'lws_vps_pro_template',
    plan_type: 'vps_pro',
    provider: 'lws',
    status: 'template',
    resources: {
        disk_space: 200000,  -- 200GB
        bandwidth: 0,  -- Illimité
        databases: 50,
        email_accounts: 100,
        subdomains: 50
    },
    billing: {
        monthly_cost: 49.00,
        billing_cycle: 'monthly',
        next_billing: time::now() + 1mo
    },
    owner_level: 1,
    owner_id: 'template',
    created_at: time::now(),
    updated_at: time::now()
};

-- Plan BUSINESS (Niveau 2)
INSERT INTO infrastructure_hosting {
    hosting_id: 'lws_shared_premium_template',
    plan_type: 'shared_premium',
    provider: 'lws',
    status: 'template',
    resources: {
        disk_space: 50000,  -- 50GB
        bandwidth: 0,  -- Illimité
        databases: 10,
        email_accounts: 50,
        subdomains: 20
    },
    billing: {
        monthly_cost: 19.00,
        billing_cycle: 'monthly',
        next_billing: time::now() + 1mo
    },
    owner_level: 2,
    owner_id: 'template',
    created_at: time::now(),
    updated_at: time::now()
};

-- Plan DEVELOPER (Niveau 3)
INSERT INTO infrastructure_hosting {
    hosting_id: 'lws_shared_pro_template',
    plan_type: 'shared_pro',
    provider: 'lws',
    status: 'template',
    resources: {
        disk_space: 20000,  -- 20GB
        bandwidth: 0,  -- Illimité
        databases: 5,
        email_accounts: 20,
        subdomains: 10
    },
    billing: {
        monthly_cost: 9.00,
        billing_cycle: 'monthly',
        next_billing: time::now() + 1mo
    },
    owner_level: 3,
    owner_id: 'template',
    created_at: time::now(),
    updated_at: time::now()
};

-- Plan CONTRACTOR (Niveau 4)
INSERT INTO infrastructure_hosting {
    hosting_id: 'lws_shared_starter_template',
    plan_type: 'shared_starter',
    provider: 'lws',
    status: 'template',
    resources: {
        disk_space: 5000,  -- 5GB
        bandwidth: 0,  -- Illimité
        databases: 2,
        email_accounts: 5,
        subdomains: 5
    },
    billing: {
        monthly_cost: 4.00,
        billing_cycle: 'monthly',
        next_billing: time::now() + 1mo
    },
    owner_level: 4,
    owner_id: 'template',
    created_at: time::now(),
    updated_at: time::now()
}; 