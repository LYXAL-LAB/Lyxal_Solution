# 🏗️ Architecture Séparée : Infrastructure ↔ Integrations

**Date** : 2025-01-27  
**Objectif** : Séparer les responsabilités entre Infrastructure (miroirs + fonctions Lyxal) et Integrations (métadonnées API + fn::execute_tool)

---

## 🎯 Vision Architecturale

### Séparation des Responsabilités

```
┌─────────────────────────────────────────────────────────────┐
│                    INFRASTRUCTURE                            │
│  (Miroirs de données Bunny + Fonctions Lyxal spécifiques)   │
└─────────────────────────────────────────────────────────────┘
                              │
                              │ utilise
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    INTEGRATIONS                              │
│  (Métadonnées API Bunny + fn::execute_tool générique)       │
└─────────────────────────────────────────────────────────────┘
                              │
                              │ appelle
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    BUNNY API                                 │
│  (API réelle Bunny.net)                                      │
└─────────────────────────────────────────────────────────────┘
```

---

## 📋 Rôle de chaque Module

### Module Infrastructure

**Responsabilité** : Gestion des miroirs de données Bunny + logique métier Lyxal

**Contenu** :
- ✅ **Tables miroirs** (`database/`) : `bunny_cdn_zone`, `bunny_dns_zone`, etc.
- ✅ **Fonctions Lyxal spécifiques** (`functions/`) : Logique métier, sync, validation
- ✅ **Patterns Lyxal** : `identity`, `metadata`, `sync`, i18n

**Ce que fait Infrastructure** :
```surql
-- Fonction Lyxal qui gère la logique métier
DEFINE FUNCTION fn::infrastructure_cdn_zone_create(
  $zone_config: object,
  $user_id: record<identity>
) {
  -- 1. Valider la configuration
  -- 2. Appeler l'API via integrations
  LET $result = fn::execute_tool(
    tool:tool:bunny_pull_zone_create,
    $params: $zone_config,
    $user_id: $user_id
  );
  
  -- 3. Créer le miroir dans SurrealDB
  CREATE bunny_cdn_zone SET
    identity.code = $zone_config.code,
    sync.bunny_id = $result.data.id,
    sync.sync_status = "synced",
    ...
  
  -- 4. Logger dans infrastructure_logs
  CREATE infrastructure_log SET ...
  
  RETURN $result;
}
```

---

### Module Integrations

**Responsabilité** : Métadonnées API Bunny + exécution générique

**Contenu** :
- ✅ **Provider Bunny** : Métadonnées du provider Bunny
- ✅ **Services Bunny** : Services (DNS Zone, Pull Zone, Storage Zone, etc.)
- ✅ **Resources Bunny** : Resources (DNS Zone, Pull Zone, etc.)
- ✅ **Tools Bunny** : Tools pour chaque endpoint API (create, update, delete, etc.)
- ✅ **Parameters** : Paramètres de chaque tool
- ✅ **fn::execute_tool** : Fonction générique qui exécute n'importe quel tool

**Ce que fait Integrations** :
```surql
-- Provider Bunny
CREATE provider:bunny SET
  name = "bunny",
  config.base_url = "https://api.bunny.net",
  ...

-- Service DNS Zone
CREATE service:bunny_dns_zone SET
  provider_id = provider:bunny,
  name = "DNS Zone",
  config.base_url = "https://api.bunny.net",
  ...

-- Tool : Create DNS Zone
CREATE tool:bunny_dns_zone_create SET
  service_id = service:bunny_dns_zone,
  resource_id = resource:bunny_dns_zone,
  config.request = {
    method: "POST",
    endpoint: "/dnszone",
    body_template: { domain: "{{domain}}" }
  },
  ...
```

---

## 🔄 Flux de Données

### Scénario : Créer une DNS Zone

```
1. APPEL UTILISATEUR
   ↓
   fn::infrastructure_dns_zone_create($config, $user_id)

2. VALIDATION LYXAL (Infrastructure)
   ↓
   - Vérifier que le domaine n'existe pas déjà
   - Valider la configuration selon patterns Lyxal
   - Préparer les paramètres

3. APPEL API VIA INTEGRATIONS
   ↓
   fn::execute_tool(
     tool:tool:bunny_dns_zone_create,
     $params: { domain: "example.com" },
     $user_id: $user_id
   )

4. EXÉCUTION GÉNÉRIQUE (Integrations)
   ↓
   - Lire config depuis tool
   - Récupérer credentials depuis user_service_credential
   - Construire URL, headers, body
   - Appeler API Bunny
   - Gérer erreurs via error_mapping

5. RETOUR À INFRASTRUCTURE
   ↓
   - Créer miroir bunny_dns_zone dans SurrealDB
   - Mettre à jour sync.bunny_id
   - Logger dans infrastructure_logs
   - Retourner résultat
```

---

## 📁 Structure Cible

### Infrastructure (`infrastructure/`)

```
infrastructure/
├── database/                      (Tables miroirs)
│   ├── cdn/
│   │   └── bunny_cdn_zone.surql   (Miroir avec patterns Lyxal)
│   ├── dns/
│   │   └── bunny_dns_zone.surql   (Miroir avec patterns Lyxal)
│   └── ...
├── functions/                     (Fonctions Lyxal spécifiques)
│   ├── fn_infrastructure_dns_zone_create.surql
│   ├── fn_infrastructure_dns_zone_sync.surql
│   ├── fn_infrastructure_cdn_zone_create.surql
│   └── ...
└── resources/                    (SUPPRIMÉ - Déplacé vers integrations)
```

**Note** : `infrastructure/resources/bunny/bunny_net_api/` sera **déplacé** vers `integrations/`

---

### Integrations (`integrations/`)

```
integrations/
├── database/                      (Tables métadonnées)
│   ├── provider/
│   ├── service/
│   ├── resource/
│   ├── tool/
│   └── parameter/
├── reference/                     (Seeds)
│   ├── provider/
│   │   └── provider_bunny_*.surql
│   ├── service/
│   │   └── service_bunny_*.surql
│   ├── resource/
│   │   └── resource_bunny_*.surql
│   ├── tool/
│   │   ├── tool_bunny_dns_zone_*.surql
│   │   ├── tool_bunny_pull_zone_*.surql
│   │   ├── tool_bunny_storage_zone_*.surql
│   │   ├── tool_bunny_waf_*.surql
│   │   ├── tool_bunny_edge_storage_*.surql
│   │   └── ...
│   └── parameter/
│       └── parameter_bunny_*.surql
└── resources/                    (NOUVEAU - Depuis infrastructure)
    └── fn_execute_tool.surql     (Fonction générique existante)
```

---

## 🔧 Migration depuis Infrastructure

### Étape 1 : Créer Provider Bunny dans Integrations

```surql
-- integrations/reference/provider/provider_bunny_seeds.surql
CREATE provider:bunny SET
  identity = {
    name: "bunny",
    slug: "bunny",
    display_name_i18n: i18n_key:provider_bunny_name,
    description_i18n: i18n_key:provider_bunny_description
  },
  config = {
    base_url: "https://api.bunny.net",
    auth_type: "api_key",
    supports_oauth2: false,
    supports_api_key: true
  },
  ...
```

### Étape 2 : Créer Services Bunny

```surql
-- integrations/reference/service/service_bunny_dns_zone.surql
CREATE service:bunny_dns_zone SET
  provider_id = provider:bunny,
  identity = {
    name: "bunny_dns_zone",
    slug: "bunny-dns-zone",
    display_name_i18n: i18n_key:service_bunny_dns_zone_name
  },
  config = {
    base_url: "https://api.bunny.net",
    api_version: NONE
  },
  ...
```

### Étape 3 : Créer Resources Bunny

```surql
-- integrations/reference/resource/resource_bunny_dns_zone.surql
CREATE resource:bunny_dns_zone SET
  service_id = service:bunny_dns_zone,
  identity = {
    name: "dns_zone",
    slug: "dns-zone",
    display_name_i18n: i18n_key:resource_bunny_dns_zone_name
  },
  config = {
    operation_types = {
      supports_create: true,
      supports_read: true,
      supports_update: true,
      supports_delete: true,
      supports_list: true
    }
  },
  ...
```

### Étape 4 : Créer Tools depuis les JSON API

Pour chaque endpoint dans les JSON, créer un tool :

```surql
-- integrations/reference/tool/tool_bunny_dns_zone_create.surql
CREATE tool:bunny_dns_zone_create SET
  service_id = service:bunny_dns_zone,
  resource_id = resource:bunny_dns_zone,
  identity = {
    name: "bunny_dns_zone_create",
    slug: "bunny-dns-zone-create",
    display_name_i18n: i18n_key:tool_bunny_dns_zone_create_name
  },
  config = {
    request = {
      method: "POST",
      endpoint: "/dnszone",
      body_template: {
        domain: "{{domain}}"
      }
    },
    response = {
      success_codes: [200, 201],
      data_path: "",
      pagination: NONE
    }
  },
  ...
```

### Étape 5 : Créer Fonctions Infrastructure qui utilisent fn::execute_tool

```surql
-- infrastructure/functions/fn_infrastructure_dns_zone_create.surql
DEFINE FUNCTION fn::infrastructure_dns_zone_create(
  $domain: string,
  $user_id: record<identity>
) {
  -- 1. Valider que le domaine n'existe pas déjà
  LET $existing = SELECT * FROM bunny_dns_zone 
    WHERE identity.slug = string::lowercase($domain)
    LIMIT 1;
  
  IF array::len($existing) > 0 THEN
    RETURN {
      success: false,
      error: 'domain_already_exists',
      message: 'DNS Zone already exists'
    };
  END;
  
  -- 2. Appeler l'API via integrations
  LET $api_result = fn::execute_tool(
    tool:tool:bunny_dns_zone_create,
    $params: { domain: $domain },
    $user_id: $user_id
  );
  
  IF !$api_result.success THEN
    RETURN $api_result;
  END;
  
  -- 3. Créer le miroir dans SurrealDB
  CREATE bunny_dns_zone SET
    identity.code = string::uppercase(string::replace($domain, '.', '_')),
    identity.slug = string::lowercase($domain),
    sync.bunny_id = $api_result.data.id,
    sync.sync_status = "synced",
    sync.last_sync_at = time::now(),
    metadata.created_by = $user_id,
    metadata.created_at = time::now(),
    ...
  
  -- 4. Logger
  CREATE infrastructure_log SET
    resource_type: "bunny_dns_zone",
    action: "create",
    user: $user_id,
    status: "success",
    ...
  
  RETURN {
    success: true,
    data: $api_result.data,
    dns_zone: bunny_dns_zone:...
  };
}
```

---

## ✅ Avantages de cette Architecture

### Pour Infrastructure

✅ **Focus sur la logique métier** : Validation, sync, logging  
✅ **Miroirs propres** : Tables avec patterns Lyxal complets  
✅ **Pas de duplication** : Pas besoin de recréer les appels API  
✅ **Maintenabilité** : Logique métier séparée des appels API  

### Pour Integrations

✅ **Centralisation** : Tous les appels API au même endroit  
✅ **Réutilisabilité** : Même tool peut être utilisé par plusieurs modules  
✅ **Extensibilité** : Facile d'ajouter de nouveaux endpoints  
✅ **AI-Ready** : Métadonnées complètes pour l'IA  

---

## 📊 Mapping : Ancien → Nouveau

| Ancien (Infrastructure) | Nouveau (Integrations) |
|------------------------|------------------------|
| `resources/bunny/bunny_net_api/dns_zone/fn_bunny_add_dns_zone.surql` | `reference/tool/tool_bunny_dns_zone_create.surql` |
| `resources/bunny/bunny_net_api/dns_zone/fn_bunny_get_dns_zone.surql` | `reference/tool/tool_bunny_dns_zone_get.surql` |
| `resources/bunny/bunny_net_api/pull__zone/fn_bunny_*.surql` | `reference/tool/tool_bunny_pull_zone_*.surql` |

**Fonctions Infrastructure** :
- `functions/fn_infrastructure_dns_zone_create.surql` → Utilise `tool:bunny_dns_zone_create`
- `functions/fn_infrastructure_dns_zone_sync.surql` → Utilise `tool:bunny_dns_zone_get`

---

## 🎯 Plan d'Action

### Phase 1 : Préparer Integrations
1. ✅ Créer Provider Bunny dans integrations
2. ✅ Créer Services Bunny (DNS Zone, Pull Zone, Storage Zone, etc.)
3. ✅ Créer Resources Bunny
4. ✅ Créer Tools depuis les JSON API (migration depuis `infrastructure/resources/bunny/bunny_net_api/`)

### Phase 2 : Migrer Infrastructure
1. ✅ Créer fonctions Infrastructure qui utilisent `fn::execute_tool`
2. ✅ Migrer la logique métier depuis les anciennes fonctions
3. ✅ Supprimer `infrastructure/resources/bunny/bunny_net_api/`

### Phase 3 : Harmoniser
1. ✅ Vérifier que tous les endpoints sont couverts
2. ✅ Ajouter les APIs manquantes (Shield, Edge Storage)
3. ✅ Documenter l'architecture finale

---

## 📝 Exemple Complet

### Tool dans Integrations

```surql
-- integrations/reference/tool/tool_bunny_dns_zone_create.surql
CREATE tool:bunny_dns_zone_create SET
  service_id = service:bunny_dns_zone,
  resource_id = resource:bunny_dns_zone,
  identity = {
    name: "bunny_dns_zone_create",
    slug: "bunny-dns-zone-create",
    display_name_i18n: i18n_key:tool_bunny_dns_zone_create_name,
    description_i18n: i18n_key:tool_bunny_dns_zone_create_description
  },
  config = {
    request = {
      method: "POST",
      endpoint: "/dnszone",
      body_template: {
        domain: "{{domain}}"
      }
    },
    response = {
      success_codes: [200, 201],
      data_path: "",
      pagination: NONE
    }
  },
  ...
```

### Fonction Infrastructure qui l'utilise

```surql
-- infrastructure/functions/fn_infrastructure_dns_zone_create.surql
DEFINE FUNCTION fn::infrastructure_dns_zone_create(
  $domain: string,
  $user_id: record<identity>
) {
  -- Validation Lyxal
  IF string::len($domain) < 3 THEN
    RETURN { success: false, error: 'invalid_domain' };
  END;
  
  -- Appel API via integrations
  LET $result = fn::execute_tool(
    tool:tool:bunny_dns_zone_create,
    $params: { domain: $domain },
    $user_id: $user_id
  );
  
  IF !$result.success THEN
    RETURN $result;
  END;
  
  -- Créer miroir
  CREATE bunny_dns_zone SET
    identity.code = string::uppercase(string::replace($domain, '.', '_')),
    identity.slug = string::lowercase($domain),
    sync.bunny_id = $result.data.id,
    sync.sync_status = "synced",
    ...
  
  RETURN { success: true, dns_zone: bunny_dns_zone:... };
}
```

---

## 🎯 Prochaines Étapes

1. **Créer Provider Bunny** dans integrations
2. **Extraire les endpoints** des JSON API vers Tools
3. **Créer les fonctions Infrastructure** qui utilisent fn::execute_tool
4. **Migrer progressivement** depuis l'ancienne structure

---

**Architecture séparée : Infrastructure ↔ Integrations** 🏗️✨

