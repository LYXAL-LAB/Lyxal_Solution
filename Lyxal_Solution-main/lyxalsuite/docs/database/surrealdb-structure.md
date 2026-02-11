# 🗄️ Structure SurrealDB - LyxalSuite

## 🎯 Vue d'ensemble

LyxalSuite utilise **SurrealDB** avec une architecture basée sur les **namespaces** pour garantir l'isolation complète des données entre tenants, SaaS et workspaces.

## 🏗️ Architecture namespaces

### Structure globale
```
SurrealDB Instance unique (Multi-tenant)
├── 🏛️ NS system (Configuration globale)
├── 🏢 NS tenant_{tenant_id} (Données tenant)
├── 🏪 NS saas_{saas_id} (Données SaaS)
└── 🏢 NS ws_{workspace_id} (Données métier)
```

## 🏛️ Namespace `system`

### Tables système globales
```sql
-- Configuration globale LyxalSuite
USE NS system;

-- Tenants (freelances/agences)
DEFINE TABLE tenants SCHEMAFULL;
DEFINE FIELD id ON tenants TYPE string ASSERT $value != NONE;
DEFINE FIELD email ON tenants TYPE string ASSERT is::email($value);
DEFINE FIELD name ON tenants TYPE string;
DEFINE FIELD type ON tenants TYPE string ASSERT $value IN ['freelance', 'agency'];
DEFINE FIELD plan ON tenants TYPE string ASSERT $value IN ['starter', 'pro', 'enterprise'];
DEFINE FIELD created_at ON tenants TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON tenants TYPE datetime DEFAULT time::now();

-- Instances SaaS créées
DEFINE TABLE saas_instances SCHEMAFULL;
DEFINE FIELD id ON saas_instances TYPE string ASSERT $value != NONE;
DEFINE FIELD tenant_id ON saas_instances TYPE string;
DEFINE FIELD name ON saas_instances TYPE string;
DEFINE FIELD domain ON saas_instances TYPE string;
DEFINE FIELD industry ON saas_instances TYPE string;
DEFINE FIELD status ON saas_instances TYPE string ASSERT $value IN ['active', 'suspended', 'deleted'];
DEFINE FIELD created_at ON saas_instances TYPE datetime DEFAULT time::now();

-- Configuration globale (plans, pricing, etc.)
DEFINE TABLE global_config SCHEMAFULL;
DEFINE FIELD key ON global_config TYPE string ASSERT $value != NONE;
DEFINE FIELD value ON global_config TYPE string;
DEFINE FIELD updated_at ON global_config TYPE datetime DEFAULT time::now();

-- Logs système
DEFINE TABLE system_logs SCHEMAFULL;
DEFINE FIELD id ON system_logs TYPE string ASSERT $value != NONE;
DEFINE FIELD level ON system_logs TYPE string ASSERT $value IN ['info', 'warn', 'error'];
DEFINE FIELD message ON system_logs TYPE string;
DEFINE FIELD context ON system_logs TYPE object;
DEFINE FIELD created_at ON system_logs TYPE datetime DEFAULT time::now();
```

### Exemples de données système
```sql
-- Tenant example
INSERT INTO tenants {
    id: 'tenant_12345',
    email: 'contact@freelancea.com',
    name: 'FreelanceA Solutions',
    type: 'freelance',
    plan: 'pro'
};

-- SaaS instance example
INSERT INTO saas_instances {
    id: 'saas_67890',
    tenant_id: 'tenant_12345',
    name: 'Bistro Paris',
    domain: 'restaurant-bistro-paris.com',
    industry: 'restaurant',
    status: 'active'
};

-- Configuration globale
INSERT INTO global_config [
    { key: 'plans.starter.price', value: '29' },
    { key: 'plans.pro.price', value: '99' },
    { key: 'plans.enterprise.price', value: '299' }
];
```

## 🏢 Namespace `tenant_{id}`

### Tables spécifiques tenant
```sql
-- Configuration tenant
USE NS tenant_12345;

-- Configuration du tenant
DEFINE TABLE tenant_config SCHEMAFULL;
DEFINE FIELD id ON tenant_config TYPE string ASSERT $value != NONE;
DEFINE FIELD company ON tenant_config TYPE object;
DEFINE FIELD branding ON tenant_config TYPE object;
DEFINE FIELD settings ON tenant_config TYPE object;
DEFINE FIELD updated_at ON tenant_config TYPE datetime DEFAULT time::now();

-- SaaS instances du tenant
DEFINE TABLE saas_instances SCHEMAFULL;
DEFINE FIELD id ON saas_instances TYPE string ASSERT $value != NONE;
DEFINE FIELD config ON saas_instances TYPE object;
DEFINE FIELD modules ON saas_instances TYPE object;
DEFINE FIELD deployment ON saas_instances TYPE object;
DEFINE FIELD created_at ON saas_instances TYPE datetime DEFAULT time::now();

-- Facturation tenant
DEFINE TABLE billing_data SCHEMAFULL;
DEFINE FIELD id ON billing_data TYPE string ASSERT $value != NONE;
DEFINE FIELD period ON billing_data TYPE string;
DEFINE FIELD saas_count ON billing_data TYPE number;
DEFINE FIELD amount ON billing_data TYPE number;
DEFINE FIELD status ON billing_data TYPE string;
DEFINE FIELD created_at ON billing_data TYPE datetime DEFAULT time::now();

-- Support tickets
DEFINE TABLE support_tickets SCHEMAFULL;
DEFINE FIELD id ON support_tickets TYPE string ASSERT $value != NONE;
DEFINE FIELD subject ON support_tickets TYPE string;
DEFINE FIELD content ON support_tickets TYPE string;
DEFINE FIELD status ON support_tickets TYPE string;
DEFINE FIELD priority ON support_tickets TYPE string;
DEFINE FIELD created_at ON support_tickets TYPE datetime DEFAULT time::now();
```

### Exemple configuration tenant
```sql
-- Configuration tenant
INSERT INTO tenant_config {
    id: 'config_main',
    company: {
        name: 'FreelanceA Solutions',
        address: '123 rue de la République, Paris',
        phone: '+33 1 23 45 67 89',
        website: 'https://freelancea.com'
    },
    branding: {
        logo: 'https://cdn.freelancea.com/logo.png',
        colors: {
            primary: '#3B82F6',
            secondary: '#1E40AF'
        }
    },
    settings: {
        timezone: 'Europe/Paris',
        currency: 'EUR',
        language: 'fr'
    }
};

-- Instance SaaS du tenant
INSERT INTO saas_instances {
    id: 'saas_67890',
    config: {
        name: 'Bistro Paris',
        domain: 'restaurant-bistro-paris.com',
        industry: 'restaurant',
        template: 'restaurant_v2'
    },
    modules: {
        enabled: ['auth', 'crm', 'ecommerce', 'analytics'],
        config: {
            crm: { features: ['customers', 'reservations'] },
            ecommerce: { payment_gateways: ['stripe'] }
        }
    },
    deployment: {
        status: 'deployed',
        url: 'https://restaurant-bistro-paris.com',
        build_version: '1.2.3'
    }
};
```

## 🏪 Namespace `saas_{id}`

### Tables spécifiques SaaS
```sql
-- Configuration SaaS
USE NS saas_67890;

-- Configuration du SaaS
DEFINE TABLE saas_config SCHEMAFULL;
DEFINE FIELD id ON saas_config TYPE string ASSERT $value != NONE;
DEFINE FIELD branding ON saas_config TYPE object;
DEFINE FIELD modules ON saas_config TYPE object;
DEFINE FIELD permissions ON saas_config TYPE object;
DEFINE FIELD updated_at ON saas_config TYPE datetime DEFAULT time::now();

-- Accounts clients finaux
DEFINE TABLE accounts SCHEMAFULL;
DEFINE FIELD id ON accounts TYPE string ASSERT $value != NONE;
DEFINE FIELD name ON accounts TYPE string;
DEFINE FIELD owner ON accounts TYPE string;
DEFINE FIELD email ON accounts TYPE string ASSERT is::email($value);
DEFINE FIELD phone ON accounts TYPE string;
DEFINE FIELD address ON accounts TYPE object;
DEFINE FIELD subscription ON accounts TYPE object;
DEFINE FIELD created_at ON accounts TYPE datetime DEFAULT time::now();

-- Utilisateurs du SaaS
DEFINE TABLE users SCHEMAFULL;
DEFINE FIELD id ON users TYPE string ASSERT $value != NONE;
DEFINE FIELD account_id ON users TYPE string;
DEFINE FIELD email ON users TYPE string ASSERT is::email($value);
DEFINE FIELD first_name ON users TYPE string;
DEFINE FIELD last_name ON users TYPE string;
DEFINE FIELD role ON users TYPE string;
DEFINE FIELD permissions ON users TYPE object;
DEFINE FIELD logto_user_id ON users TYPE string;
DEFINE FIELD created_at ON users TYPE datetime DEFAULT time::now();

-- Workspaces par account
DEFINE TABLE workspaces SCHEMAFULL;
DEFINE FIELD id ON workspaces TYPE string ASSERT $value != NONE;
DEFINE FIELD account_id ON workspaces TYPE string;
DEFINE FIELD name ON workspaces TYPE string;
DEFINE FIELD type ON workspaces TYPE string;
DEFINE FIELD config ON workspaces TYPE object;
DEFINE FIELD created_at ON workspaces TYPE datetime DEFAULT time::now();

-- Sessions utilisateurs
DEFINE TABLE user_sessions SCHEMAFULL;
DEFINE FIELD id ON user_sessions TYPE string ASSERT $value != NONE;
DEFINE FIELD user_id ON user_sessions TYPE string;
DEFINE FIELD token ON user_sessions TYPE string;
DEFINE FIELD expires_at ON user_sessions TYPE datetime;
DEFINE FIELD created_at ON user_sessions TYPE datetime DEFAULT time::now();
```

### Exemple données SaaS
```sql
-- Account client final
INSERT INTO accounts {
    id: 'account_abc123',
    name: 'Restaurant Bistro Paris',
    owner: 'Jean Dupont',
    email: 'jean@bistro-paris.com',
    phone: '+33 1 23 45 67 89',
    address: {
        street: '15 rue de Rivoli',
        city: 'Paris',
        postal_code: '75001',
        country: 'France'
    },
    subscription: {
        plan: 'premium',
        features: ['reservations', 'delivery', 'loyalty']
    }
};

-- Utilisateur du SaaS
INSERT INTO users {
    id: 'user_xyz789',
    account_id: 'account_abc123',
    email: 'manager@bistro-paris.com',
    first_name: 'Marie',
    last_name: 'Martin',
    role: 'manager',
    permissions: {
        modules: {
            crm: ['read', 'write'],
            analytics: ['read'],
            ecommerce: ['read', 'write']
        }
    },
    logto_user_id: 'logto_user_456'
};

-- Workspace principal
INSERT INTO workspaces {
    id: 'ws_main',
    account_id: 'account_abc123',
    name: 'Restaurant Principal',
    type: 'production',
    config: {
        timezone: 'Europe/Paris',
        currency: 'EUR',
        language: 'fr'
    }
};
```

## 🏢 Namespace `ws_{workspace_id}`

### Tables données métier
```sql
-- Données métier workspace
USE NS ws_main;

-- Clients/Customers (CRM)
DEFINE TABLE customers SCHEMAFULL;
DEFINE FIELD id ON customers TYPE string ASSERT $value != NONE;
DEFINE FIELD first_name ON customers TYPE string;
DEFINE FIELD last_name ON customers TYPE string;
DEFINE FIELD email ON customers TYPE string;
DEFINE FIELD phone ON customers TYPE string;
DEFINE FIELD address ON customers TYPE object;
DEFINE FIELD tags ON customers TYPE array;
DEFINE FIELD created_at ON customers TYPE datetime DEFAULT time::now();

-- Produits (E-commerce)
DEFINE TABLE products SCHEMAFULL;
DEFINE FIELD id ON products TYPE string ASSERT $value != NONE;
DEFINE FIELD name ON products TYPE string;
DEFINE FIELD description ON products TYPE string;
DEFINE FIELD price ON products TYPE number;
DEFINE FIELD category ON products TYPE string;
DEFINE FIELD image ON products TYPE string;
DEFINE FIELD available ON products TYPE bool DEFAULT true;
DEFINE FIELD created_at ON products TYPE datetime DEFAULT time::now();

-- Commandes
DEFINE TABLE orders SCHEMAFULL;
DEFINE FIELD id ON orders TYPE string ASSERT $value != NONE;
DEFINE FIELD customer_id ON orders TYPE string;
DEFINE FIELD items ON orders TYPE array;
DEFINE FIELD total ON orders TYPE number;
DEFINE FIELD status ON orders TYPE string;
DEFINE FIELD payment_status ON orders TYPE string;
DEFINE FIELD delivery_address ON orders TYPE object;
DEFINE FIELD created_at ON orders TYPE datetime DEFAULT time::now();

-- Analytics données
DEFINE TABLE analytics_events SCHEMAFULL;
DEFINE FIELD id ON analytics_events TYPE string ASSERT $value != NONE;
DEFINE FIELD event_type ON analytics_events TYPE string;
DEFINE FIELD event_data ON analytics_events TYPE object;
DEFINE FIELD user_id ON analytics_events TYPE string;
DEFINE FIELD session_id ON analytics_events TYPE string;
DEFINE FIELD created_at ON analytics_events TYPE datetime DEFAULT time::now();

-- Fichiers stockés
DEFINE TABLE files SCHEMAFULL;
DEFINE FIELD id ON files TYPE string ASSERT $value != NONE;
DEFINE FIELD name ON files TYPE string;
DEFINE FIELD type ON files TYPE string;
DEFINE FIELD size ON files TYPE number;
DEFINE FIELD url ON files TYPE string;
DEFINE FIELD uploaded_by ON files TYPE string;
DEFINE FIELD created_at ON files TYPE datetime DEFAULT time::now();
```

### Données spécifiques industrie
```sql
-- Restaurant: Tables spécifiques
DEFINE TABLE menu_items SCHEMAFULL;
DEFINE FIELD id ON menu_items TYPE string ASSERT $value != NONE;
DEFINE FIELD name ON menu_items TYPE string;
DEFINE FIELD category ON menu_items TYPE string;
DEFINE FIELD price ON menu_items TYPE number;
DEFINE FIELD ingredients ON menu_items TYPE array;
DEFINE FIELD allergens ON menu_items TYPE array;
DEFINE FIELD available ON menu_items TYPE bool DEFAULT true;

DEFINE TABLE reservations SCHEMAFULL;
DEFINE FIELD id ON reservations TYPE string ASSERT $value != NONE;
DEFINE FIELD customer_id ON reservations TYPE string;
DEFINE FIELD table_number ON reservations TYPE number;
DEFINE FIELD party_size ON reservations TYPE number;
DEFINE FIELD reservation_date ON reservations TYPE datetime;
DEFINE FIELD status ON reservations TYPE string;
DEFINE FIELD notes ON reservations TYPE string;

-- Finance: Tables spécifiques
DEFINE TABLE portfolios SCHEMAFULL;
DEFINE FIELD id ON portfolios TYPE string ASSERT $value != NONE;
DEFINE FIELD client_id ON portfolios TYPE string;
DEFINE FIELD assets ON portfolios TYPE array;
DEFINE FIELD total_value ON portfolios TYPE number;
DEFINE FIELD risk_profile ON portfolios TYPE string;
DEFINE FIELD last_rebalance ON portfolios TYPE datetime;

DEFINE TABLE transactions SCHEMAFULL;
DEFINE FIELD id ON transactions TYPE string ASSERT $value != NONE;
DEFINE FIELD portfolio_id ON transactions TYPE string;
DEFINE FIELD asset_symbol ON transactions TYPE string;
DEFINE FIELD type ON transactions TYPE string;
DEFINE FIELD quantity ON transactions TYPE number;
DEFINE FIELD price ON transactions TYPE number;
DEFINE FIELD fees ON transactions TYPE number;
DEFINE FIELD executed_at ON transactions TYPE datetime;
```

## 🔒 Sécurité et isolation

### Règles d'accès par namespace
```sql
-- Isolation complète des namespaces
-- Un tenant ne peut accéder qu'à ses namespaces
DEFINE ACCESS tenant_{tenant_id}_access ON NAMESPACE tenant_{tenant_id} 
  TYPE JWT KEY 'tenant_secret_{tenant_id}';

-- Un SaaS ne peut accéder qu'à ses données
DEFINE ACCESS saas_{saas_id}_access ON NAMESPACE saas_{saas_id}
  TYPE JWT WHERE saas_id = '{saas_id}';

-- Un workspace isolé par permissions utilisateur  
DEFINE ACCESS workspace_access ON NAMESPACE ws_{workspace_id}
  TYPE JWT WHERE workspace_id IN user_workspaces;
```

### Index pour performances
```sql
-- Index globaux système
USE NS system;
DEFINE INDEX tenant_email ON tenants FIELDS email UNIQUE;
DEFINE INDEX saas_domain ON saas_instances FIELDS domain UNIQUE;
DEFINE INDEX saas_tenant ON saas_instances FIELDS tenant_id;

-- Index tenant
USE NS tenant_{tenant_id};
DEFINE INDEX saas_status ON saas_instances FIELDS status;
DEFINE INDEX billing_period ON billing_data FIELDS period;

-- Index SaaS
USE NS saas_{saas_id};
DEFINE INDEX user_email ON users FIELDS email UNIQUE;
DEFINE INDEX user_account ON users FIELDS account_id;
DEFINE INDEX workspace_account ON workspaces FIELDS account_id;

-- Index workspace
USE NS ws_{workspace_id};
DEFINE INDEX customer_email ON customers FIELDS email;
DEFINE INDEX order_customer ON orders FIELDS customer_id;
DEFINE INDEX order_status ON orders FIELDS status;
DEFINE INDEX analytics_event ON analytics_events FIELDS event_type;
DEFINE INDEX analytics_date ON analytics_events FIELDS created_at;
```

## 🔄 Requêtes cross-namespace

### Exemple: Statistiques tenant
```sql
-- Compter les SaaS actifs d'un tenant (depuis NS system)
USE NS system;
SELECT count() FROM saas_instances 
WHERE tenant_id = 'tenant_12345' AND status = 'active';

-- Récupérer config SaaS (depuis NS tenant)
USE NS tenant_12345;
SELECT * FROM saas_instances WHERE id = 'saas_67890';

-- Statistiques clients d'un workspace (depuis NS workspace)
USE NS ws_main;
SELECT count() as total_customers,
       count(WHERE created_at >= time::now() - 30d) as new_customers_30d
FROM customers;
```

### Exemple: Dashboard multi-niveau
```sql
-- Dashboard tenant: vue d'ensemble de tous ses SaaS
USE NS tenant_12345;
LET $saas_list = (SELECT id, name, domain FROM saas_instances WHERE status = 'active');

FOR $saas IN $saas_list {
    USE NS saas_{{ $saas.id }};
    LET $accounts = (SELECT count() FROM accounts);
    LET $users = (SELECT count() FROM users);
    
    RETURN {
        saas: $saas,
        accounts: $accounts,
        users: $users
    };
};
```

---

**🗄️ SurrealDB : Isolation totale + Performance + Flexibilité multi-tenant** 