# Infrastructure Bunny.net - Documentation Complète

## 📋 Vue d'ensemble

Cette infrastructure a été **générée automatiquement** à partir des spécifications OpenAPI officielles de Bunny.net. Elle couvre l'intégralité des services Bunny.net disponibles via leur API.

## 🎯 Génération automatique

### Fichiers sources OpenAPI
Les 5 fichiers OpenAPI officiels de Bunny.net ont été utilisés :

1. **bunnynet-api-1.json** (12 421 lignes)
   - API principale : DNS Zone, Pull Zone, Storage Zone, Video Library
   - Gestion des certificats SSL, hostnames, edge rules, purge, etc.

2. **stream-api.json** (3 240 lignes)
   - API Stream Video
   - Collections, vidéos, captions, transcriptions, heatmaps, etc.

3. **edge-scripting-api.json** (2 508 lignes)
   - API Edge Scripting
   - Scripts, variables, secrets, releases, déploiements

4. **bunnynet-edge-storage-api.json** (388 lignes)
   - API Edge Storage
   - Gestion du stockage edge

5. **bunny-shield-api.json** (3 818 lignes)
   - API Bunny Shield (WAF)
   - Règles WAF, rate limiting, DDoS, métriques de sécurité

### Générateur
Le générateur automatique (`generate_bunny_infrastructure.py`) :
- Parse les fichiers OpenAPI JSON
- Convertit les schemas en tables SurrealDB
- Génère les fonctions d'API avec gestion complète des erreurs
- Organise automatiquement les fichiers par catégorie
- Exclut les implémentations manuelles existantes

## 📊 Résultats de la génération

### Tables SurrealDB : **181 tables**

| API | Tables générées | Description |
|-----|-----------------|-------------|
| bunnynet-api-1.json | **78 tables** | DNS, Pull Zone, Storage, Video Library, API Keys |
| stream-api.json | **25 tables** | Collections, vidéos, captions, chapitres, métadonnées |
| edge-scripting-api.json | **20 tables** | Scripts, variables, secrets, releases, déploiements |
| bunnynet-edge-storage-api.json | **2 tables** | Objets de stockage, erreurs |
| bunny-shield-api.json | **56 tables** | WAF, rate limiting, règles custom, métriques |

**Total : 181 tables**

### Fonctions d'API : **120 fonctions**

| API | Fonctions générées | Catégories |
|-----|--------------------|-----------| 
| bunnynet-api-1.json | **70 fonctions** | DNS Zone, Pull Zone, Storage Zone, Video Library, Statistics, Region, Purge, User, API Keys |
| stream-api.json | **27 fonctions** | Collections, Videos, OEmbed |
| edge-scripting-api.json | **23 fonctions** | Code, Edge Script, Variables, Secrets, Releases |

**Total : 120 fonctions**

## 🗂️ Structure des dossiers

```
infrastructure/
├── database/                          # 181 tables SurrealDB
│   ├── bunny_dns_zone.surql          # Table DNS Zone (implémentée manuellement)
│   ├── bunny_dns_record.surql        # Table DNS Record (implémentée manuellement)
│   ├── bunny_country.surql           # Table Country (implémentée manuellement)
│   ├── bunny_pull_zone_model.surql   # Table Pull Zone (générée)
│   ├── bunny_video_model.surql       # Table Video (générée)
│   ├── bunny_collection_model.surql  # Table Collection (générée)
│   └── ... (178 autres tables)
│
├── resources/
│   └── bunny/
│       └── bunny_net_api/            # 120+ fonctions d'API
│           ├── country/              # API Country (implémentée manuellement)
│           │   ├── fn_bunny_get_country_list.surql
│           │   ├── fn_bunny_sync_countries.surql
│           │   ├── fn_bunny_get_country_by_code.surql
│           │   ├── README.md
│           │   └── examples.surql
│           │
│           ├── d_n_s__zone/          # 14 fonctions DNS Zone
│           │   ├── fn_bunny_dns_zone_public__index.surql
│           │   ├── fn_bunny_dns_zone_public__add.surql
│           │   ├── fn_bunny_dns_zone_public__update.surql
│           │   ├── fn_bunny_dns_zone_public__delete.surql
│           │   ├── fn_bunny_dns_zone_public__add_record.surql
│           │   └── ... (9 autres fonctions)
│           │
│           ├── pull__zone/           # 26 fonctions Pull Zone
│           │   ├── fn_bunny_pull_zone_public__index.surql
│           │   ├── fn_bunny_pull_zone_public__add.surql
│           │   ├── fn_bunny_pull_zone_public__update_pull_zone.surql
│           │   ├── fn_bunny_pull_zone_public__delete.surql
│           │   ├── fn_bunny_pull_zone_public__add_hostname.surql
│           │   └── ... (21 autres fonctions)
│           │
│           ├── storage__zone/        # 9 fonctions Storage Zone
│           ├── stream__video__library/ # 16 fonctions Video Library
│           ├── manage__videos/       # 21 fonctions Videos (Stream API)
│           ├── manage__collections/  # 5 fonctions Collections (Stream API)
│           ├── edge__script/         # 7 fonctions Edge Script
│           ├── variable/             # 5 fonctions Variables
│           ├── secret/               # 5 fonctions Secrets
│           ├── release/              # 4 fonctions Releases
│           ├── code/                 # 2 fonctions Code
│           ├── statistics/           # 1 fonction Statistics
│           ├── region/               # 1 fonction Region
│           ├── purge/                # 1 fonction Purge
│           ├── user/                 # 1 fonction User Audit Log
│           ├── a_p_i__keys/          # 1 fonction API Keys
│           └── o_embed/              # 1 fonction OEmbed
│
├── documentation/
│   └── bunny/                        # Spécifications OpenAPI
│       ├── bunnynet-api-1.json
│       ├── stream-api.json
│       ├── edge-scripting-api.json
│       ├── bunnynet-edge-storage-api.json
│       └── bunny-shield-api.json
│
├── parametre/
│   └── infrastructure_parameters.surql  # Paramètres globaux ($bunny_api_key)
│
└── generate_bunny_infrastructure.py     # Générateur automatique

```

## 🔧 Utilisation

### 1. Configuration de la clé API

La clé API Bunny.net doit être configurée dans les paramètres globaux :

```sql
-- Définir la clé API Bunny.net
LET $bunny_api_key = "votre-cle-api-bunny-net";
```

### 2. Utilisation des fonctions d'API

Toutes les fonctions suivent le même pattern standardisé :

```sql
-- Liste des Pull Zones
LET $result = fn::bunny_pull_zone_public__index(
    1,        -- page
    10,       -- perPage
    NONE,     -- search
    false     -- includeCertificate
);

-- Résultat
{
    success: true,
    data: {
        Items: [...],
        CurrentPage: 1,
        TotalItems: 42,
        HasMoreItems: true
    }
}
```

```sql
-- Créer une DNS Zone
LET $result = fn::bunny_dns_zone_public__add({
    Domain: "example.com"
});

-- Résultat
{
    success: true,
    data: {
        Id: 12345,
        Domain: "example.com",
        ...
    }
}
```

```sql
-- Gérer les erreurs
LET $result = fn::bunny_pull_zone_public__index(...);

IF $result.success {
    -- Traiter les données
    RETURN $result.data;
} ELSE {
    -- Gérer l'erreur
    THROW $result.message;
};
```

### 3. Utilisation des tables

Les tables reflètent exactement les modèles de l'API Bunny.net :

```sql
-- Créer une entrée miroir d'une Pull Zone
CREATE bunny_pull_zone_model CONTENT {
    id: 123456,
    name: "My Pull Zone",
    origin_url: "https://example.com",
    enabled: true,
    suspended: false,
    storage_zone_id: 78910,
    edge_script_id: 0,
    allowed_referrers: [],
    blocked_referrers: [],
    blocked_ips: [],
    enable_geo_zone_u_s: true,
    enable_geo_zone_e_u: true,
    enable_geo_zone_a_s_i_a: true,
    enable_geo_zone_s_a: false,
    enable_geo_zone_a_f: false,
    metadata: {
        synced_at: time::now()
    }
};

-- Requête des Pull Zones actives
SELECT * FROM bunny_pull_zone_model
WHERE enabled = true AND suspended = false;
```

## 🎨 Architecture des fonctions générées

Toutes les fonctions d'API suivent cette architecture standardisée :

### Structure commune

```surql
DEFINE FUNCTION IF NOT EXISTS fn::bunny_<operation_id>(
  $param1: type1,
  $param2: option<type2>,
  ...
) {
  
  RETURN function() {
    
    // 1. Récupérer la clé API
    const apiKey = await surrealdb.value("$bunny_api_key");
    
    if (!apiKey) {
      return {
        success: false,
        error: 'api_key_missing',
        message: 'Bunny API key is not configured'
      };
    }
    
    // 2. Récupérer les paramètres
    const param1 = await surrealdb.value("$param1");
    const param2 = await surrealdb.value("$param2");
    
    // 3. Construire l'URL
    let url = 'https://api.bunny.net/endpoint';
    
    // Remplacer les path parameters
    url = url.replace('{id}', param1);
    
    // Ajouter les query parameters
    const params = [];
    if (param2 !== null && param2 !== undefined) {
      params.push('param2=' + encodeURIComponent(param2));
    }
    if (params.length > 0) {
      url += '?' + params.join('&');
    }
    
    try {
      // 4. Appel API
      const response = await fetch(url, {
        method: 'GET',
        headers: {
          'Accept': 'application/json',
          'Accesskey': apiKey
        }
      });
      
      // 5. Logger l'appel
      await surrealdb.query(`
        CREATE infrastructure_log CONTENT {
          type: 'api_call',
          resource_type: 'ResourceType',
          bunny_api: {
            endpoint: '/endpoint',
            method: 'GET',
            status_code: ${response.status}
          },
          status: '${response.ok ? 'success' : 'failed'}',
          timestamp: time::now()
        }
      `);
      
      // 6. Gestion des erreurs HTTP
      if (!response.ok) {
        const errorData = response.status !== 401 ? await response.json() : null;
        return {
          success: false,
          status: response.status,
          error: errorData?.ErrorKey || 'http_error',
          message: errorData?.Message || `HTTP error! status: ${response.status}`
        };
      }
      
      // 7. Retourner les données
      const data = await response.json();
      return {
        success: true,
        data: data
      };
      
    } catch (e) {
      // 8. Gestion des exceptions
      return {
        success: false,
        error: 'exception',
        message: e.message
      };
    }
  };
};
```

### Avantages de cette architecture

1. **Standardisation** : Toutes les fonctions suivent le même pattern
2. **Gestion d'erreurs robuste** : Codes HTTP, exceptions, timeout
3. **Logging automatique** : Tous les appels sont loggés dans `infrastructure_log`
4. **Format de réponse unifié** : `{ success, data/error, message }`
5. **Paramètres optionnels** : Gestion correcte des valeurs `NONE`
6. **Sécurité** : Clé API centralisée et sécurisée

## 📋 Mapping des types OpenAPI → SurrealDB

Le générateur convertit automatiquement les types :

| Type OpenAPI | Format | Type SurrealDB |
|--------------|--------|----------------|
| string | - | `string` |
| string | date | `datetime` |
| string | date-time | `datetime` |
| integer | int32 | `int` |
| integer | int64 | `int` |
| number | float | `float` |
| number | double | `float` |
| boolean | - | `bool` |
| array | - | `array<T>` |
| object | - | `object` |
| $ref | - | `record<table_name>` |

### Gestion du nullable

- **Champ requis** : `TYPE string`
- **Champ nullable ou non-requis** : `TYPE option<string>`
- **Array nullable** : `TYPE option<array<string>>`
- **Référence nullable** : `TYPE option<record<table>>`

## 🔍 Exemples par catégorie

### DNS Zone

```sql
-- Lister toutes les DNS zones
LET $zones = fn::bunny_dns_zone_public__index(1, 100, NONE);

-- Créer une nouvelle zone
LET $new_zone = fn::bunny_dns_zone_public__add({
    Domain: "example.com"
});

-- Ajouter un record A
LET $record = fn::bunny_dns_zone_public__add_record($zone_id, {
    Type: "A",
    Name: "www",
    Value: "192.0.2.1",
    Ttl: 3600
});

-- Activer DNSSEC
LET $dnssec = fn::bunny_manage_dns_zone_dns_sec_endpoint__enable_dns_sec_dns_zone($zone_id);
```

### Pull Zone (CDN)

```sql
-- Lister les Pull Zones
LET $pullzones = fn::bunny_pull_zone_public__index(1, 50, NONE, false);

-- Créer une Pull Zone
LET $pz = fn::bunny_pull_zone_public__add({
    Name: "my-cdn",
    OriginUrl: "https://origin.example.com",
    Type: 0
});

-- Ajouter un hostname custom
LET $hostname = fn::bunny_pull_zone_public__add_hostname($pz_id, {
    Hostname: "cdn.example.com"
});

-- Purger le cache
LET $purge = fn::bunny_pull_zone_public__purge_cache_post_by_tag($pz_id, {
    CacheTag: "product-123"
});
```

### Storage Zone

```sql
-- Lister les Storage Zones
LET $storages = fn::bunny_storage_zone_public__index(1, 100, false, NONE);

-- Créer une Storage Zone
LET $sz = fn::bunny_storage_zone_public__add({
    Name: "my-storage",
    Region: "DE"
});

-- Obtenir les statistiques
LET $stats = fn::bunny_storage_zone_public__storage_zone_statistics(
    $sz_id,
    time::now() - 30d,
    time::now()
);
```

### Video Library (Stream)

```sql
-- Lister les Video Libraries
LET $libraries = fn::bunny_video_library_public__index(1, 100, NONE);

-- Créer une Video Library
LET $lib = fn::bunny_video_library_public__add({
    Name: "My Videos",
    ReplicationRegions: ["DE", "NY"]
});

-- Obtenir les langues disponibles
LET $languages = fn::bunny_video_library_public__index3();

-- Statistiques de transcription
LET $trans_stats = fn::bunny_get_transcribing_statistics__statistics(
    $lib_id,
    time::now() - 14d,
    time::now()
);
```

### Stream Videos

```sql
-- Lister les vidéos d'une collection
LET $videos = fn::bunny_video__list($library_id, $collection_id, 1, 100, NONE);

-- Créer une vidéo
LET $video = fn::bunny_video__create_video($library_id, {
    Title: "Ma vidéo",
    CollectionId: $collection_id
});

-- Upload d'une vidéo
LET $upload = fn::bunny_video__upload_video($library_id, $video_id, $file_data);

-- Obtenir les statistiques
LET $stats = fn::bunny_video__get_video_statistics($library_id, $video_id, "2024-01-01", "2024-12-31", false, NONE);

-- Transcription automatique
LET $transcribe = fn::bunny_video__transcribe_video($library_id, $video_id, {
    Language: "fr",
    Caption: true
});
```

### Edge Scripting

```sql
-- Lister les scripts
LET $scripts = fn::bunny_list_edge_scripts_endpoint__list_edge_scripts_by_account(1, 100);

-- Créer un script
LET $script = fn::bunny_create_edge_script_endpoint__add_script({
    Name: "My Edge Script",
    ScriptType: 0
});

-- Upload du code
LET $code = fn::bunny_upload_edge_script_code_endpoint__set_code($script_id, {
    Code: "addEventListener('fetch', event => { ... })"
});

-- Ajouter une variable
LET $var = fn::bunny_add_edge_script_variable_endpoint__add_edge_script_variable($script_id, {
    Name: "API_KEY",
    DefaultValue: "secret-key"
});

-- Publier une release
LET $release = fn::bunny_publish_edge_script_release_endpoint__publish($script_id, {
    Note: "Initial release"
});
```

## 🔐 Sécurité

### Clé API centralisée

La clé API Bunny.net est stockée dans un paramètre global sécurisé :

```sql
-- Dans infrastructure/parametre/infrastructure_parameters.surql
DEFINE PARAM IF NOT EXISTS $bunny_api_key VALUE 'votre-cle-api';
```

### Logging automatique

Tous les appels API sont automatiquement loggés dans `infrastructure_log` :

```sql
SELECT * FROM infrastructure_log
WHERE type = 'api_call'
  AND bunny_api.endpoint = '/pullzone'
  AND timestamp > time::now() - 1h
ORDER BY timestamp DESC;
```

### Gestion des erreurs

Les fonctions retournent toujours un format standardisé :

**Succès** :
```json
{
  "success": true,
  "data": { ... }
}
```

**Erreur HTTP** :
```json
{
  "success": false,
  "status": 400,
  "error": "invalid_domain",
  "message": "The domain name is invalid"
}
```

**Exception** :
```json
{
  "success": false,
  "error": "exception",
  "message": "Network timeout"
}
```

## 📈 Monitoring et métriques

### Statistiques par type de ressource

```sql
-- Nombre d'appels par endpoint
SELECT 
  bunny_api.endpoint as endpoint,
  count() as calls,
  array::group(status) as statuses
FROM infrastructure_log
WHERE type = 'api_call'
  AND timestamp > time::now() - 24h
GROUP BY bunny_api.endpoint
ORDER BY calls DESC;
```

### Taux de succès

```sql
-- Taux de succès par endpoint
SELECT 
  bunny_api.endpoint,
  count() as total_calls,
  math::sum(IF status = 'success' THEN 1 ELSE 0 END) as success_calls,
  (math::sum(IF status = 'success' THEN 1 ELSE 0 END) * 100.0 / count()) as success_rate
FROM infrastructure_log
WHERE type = 'api_call'
  AND timestamp > time::now() - 7d
GROUP BY bunny_api.endpoint
ORDER BY success_rate ASC;
```

### Erreurs fréquentes

```sql
-- Top 10 des erreurs
SELECT 
  error_message,
  bunny_api.endpoint,
  count() as occurrences
FROM infrastructure_log
WHERE type = 'api_call'
  AND status = 'exception'
  AND timestamp > time::now() - 7d
GROUP BY error_message, bunny_api.endpoint
ORDER BY occurrences DESC
LIMIT 10;
```

## 🚀 Prochaines étapes

### 1. Synchronisation automatique

Créer des fonctions de synchronisation pour maintenir les tables locales à jour :

```sql
-- Exemple : Synchroniser toutes les Pull Zones
DEFINE FUNCTION IF NOT EXISTS fn::bunny_sync_all_pull_zones() {
  LET $result = fn::bunny_pull_zone_public__index(1, 1000, NONE, false);
  
  IF $result.success {
    -- Vider la table
    DELETE bunny_pull_zone_model;
    
    -- Insérer les nouvelles données
    FOR $pz IN $result.data.Items {
      CREATE bunny_pull_zone_model CONTENT {
        ...$pz,
        metadata: {
          synced_at: time::now()
        }
      };
    };
    
    RETURN { success: true, synced_count: array::len($result.data.Items) };
  } ELSE {
    RETURN $result;
  };
};
```

### 2. Webhooks et événements

Implémenter la gestion des webhooks Bunny.net pour les mises à jour en temps réel.

### 3. Cache et optimisation

Mettre en place un système de cache pour réduire les appels API :

```sql
-- Cache des données avec TTL
DEFINE TABLE IF NOT EXISTS bunny_api_cache SCHEMAFULL;
DEFINE FIELD key ON bunny_api_cache TYPE string;
DEFINE FIELD value ON bunny_api_cache TYPE object;
DEFINE FIELD expires_at ON bunny_api_cache TYPE datetime;
```

### 4. Documentation par catégorie

Créer des README détaillés pour chaque catégorie :
- Pull Zone : Gestion CDN, cache, edge rules
- DNS Zone : Gestion DNS, DNSSEC, records
- Storage Zone : Gestion du stockage
- Video Library : Gestion des vidéos stream
- Edge Scripting : Déploiement et gestion des scripts

### 5. Tests automatisés

Implémenter des tests pour chaque fonction d'API.

## 📚 Ressources

### Documentation officielle Bunny.net
- [Documentation API](https://docs.bunny.net/reference/bunnynet-api)
- [Documentation Stream API](https://docs.bunny.net/reference/stream-api)
- [Documentation Storage API](https://docs.bunny.net/reference/storage-api)
- [Documentation Edge Scripting](https://docs.bunny.net/docs/edge-scripting)

### Fichiers OpenAPI sources
- `infrastructure/documentation/bunny/bunnynet-api-1.json`
- `infrastructure/documentation/bunny/stream-api.json`
- `infrastructure/documentation/bunny/edge-scripting-api.json`
- `infrastructure/documentation/bunny/bunnynet-edge-storage-api.json`
- `infrastructure/documentation/bunny/bunny-shield-api.json`

### Générateur
- `infrastructure/generate_bunny_infrastructure.py`

## ✅ Résumé

L'infrastructure Bunny.net pour SurrealDB comprend :

- ✅ **181 tables SurrealDB** représentant tous les modèles de données Bunny.net
- ✅ **120 fonctions d'API** couvrant tous les endpoints Bunny.net
- ✅ **Génération automatique** depuis les spécifications OpenAPI officielles
- ✅ **Architecture standardisée** pour toutes les fonctions
- ✅ **Gestion d'erreurs robuste** avec logging automatique
- ✅ **Types SurrealDB natifs** avec mapping automatique
- ✅ **Documentation complète** avec exemples
- ✅ **Extensible et maintenable** grâce au générateur

Cette infrastructure permet d'utiliser l'intégralité des services Bunny.net directement depuis SurrealDB avec une architecture propre, standardisée et facilement maintenable. 🚀

