# Module ERROR_MAPPING

## 📋 Vue d'ensemble

Le module **error_mapping** fournit un système de mapping des codes d'erreur HTTP/API vers des messages utilisateur internationalisés, des actions suggérées et des stratégies de retry.

## 🎯 Objectif

- Transformer les erreurs techniques (codes HTTP, erreurs API) en messages utilisateur compréhensibles
- Fournir des actions suggérées pour résoudre les erreurs
- Définir des stratégies de retry automatiques pour les erreurs temporaires
- Supporter l'internationalisation complète des messages d'erreur
- Permettre aux IA de comprendre et gérer intelligemment les erreurs

## 📊 Statistiques

- **Total error mappings** : 683 (extraits depuis n8n)
  - Services couverts : 190 (45% des 419 services)
  - Types d'erreurs extraites :
    - Erreurs de validation (errorMessage dans Description.ts)
    - Erreurs d'opération (NodeOperationError dans .node.ts)
    - Erreurs d'API (NodeApiError avec messages personnalisés)
    - Erreurs d'application (ApplicationError)
    - Erreurs de constants (ERROR_MESSAGES dans constants.ts)
    - Erreurs HTTP (errorMapping dans GenericFunctions.ts)
  - Méthode d'extraction :
    - Scan récursif complet de TOUS les fichiers .ts
    - Extraction multipattern exhaustive (6 types de patterns)
    - Déduplication automatique des messages identiques
    - Extraction 1:1 sans invention de données
- **Clés i18n** : 2 049 (3 par error mapping)
- **Traductions** : 10 245 (5 langues)

## 🏗️ Structure

### Fichiers principaux

```
error_mapping/
├── generate_error_mappings.py        # Générateur de mappings
├── generate_seeds.py                 # Générateur de seeds
├── error_mappings_flat.json          # Données JSON
├── error_mapping_seeds.surql         # Seeds
├── error_mapping_i18n_keys.surql     # Clés i18n
├── error_mapping_i18n_translations.surql  # Traductions
└── README.md                         # Documentation
```

## 🔑 Codes HTTP couverts

### Erreurs client (4xx)

| Code | Catégorie | Description | Retryable |
|------|-----------|-------------|-----------|
| 400 | validation | Bad Request - Invalid input | ❌ |
| 401 | auth | Unauthorized - Invalid credentials | ❌ |
| 403 | permission | Forbidden - Access denied | ❌ |
| 404 | not_found | Not Found - Resource not found | ❌ |
| 409 | conflict | Conflict - Resource already exists | ❌ |
| 429 | rate_limit | Too Many Requests | ✅ (60s) |

### Erreurs serveur (5xx)

| Code | Catégorie | Description | Retryable |
|------|-----------|-------------|-----------|
| 500 | server | Internal Server Error | ✅ (exponential) |
| 502 | server | Bad Gateway | ✅ (exponential) |
| 503 | server | Service Unavailable | ✅ (linear, 300s) |
| 504 | server | Gateway Timeout | ✅ (exponential) |

## 📝 Schéma SurrealDB

Voir le fichier `../../database/error_mapping/error_mapping.surql` pour la définition complète.

### Structure principale

```surql
error_mapping:{slug}
├── identity
│   ├── http_code               (int 100-599)
│   ├── error_code              (option<string>) "INVALID_TOKEN"
│   ├── error_category          (string) auth|validation|rate_limit|...
│   ├── service_id              (option<record<service>>)
│   └── tool_id                 (option<record<tool>>)
├── presentation
│   ├── user_message_i18n       (record<i18n_key>)
│   ├── technical_message_i18n  (option<record<i18n_key>>)
│   ├── severity                (string) info|warning|error|critical
│   ├── icon                    (option<string>)
│   └── color                   (option<string>)
├── config
│   ├── is_retryable            (bool)
│   ├── retry_after_seconds     (option<int>)
│   ├── max_retries             (int)
│   ├── backoff_strategy        (option<string>) none|linear|exponential
│   ├── should_log              (bool)
│   └── should_notify_admin     (bool)
├── suggested_action
│   ├── action_message_i18n     (option<record<i18n_key>>)
│   ├── action_type             (option<string>)
│   ├── help_url                (option<string>)
│   └── support_contact         (option<string>)
├── documentation               (option<object>)
├── metadata                    (...)
└── is_active                   (bool)
```

## 🎨 Catégories d'erreurs

- **auth** : Erreurs d'authentification/autorisation (401, 403)
- **validation** : Erreurs de validation d'entrée (400)
- **rate_limit** : Dépassement de limite de taux (429)
- **not_found** : Ressource introuvable (404)
- **server** : Erreurs serveur (500, 502, 503, 504)
- **network** : Erreurs réseau (timeout, connection refused)
- **permission** : Permissions insuffisantes (403 avec contexte)
- **conflict** : Conflit de données (409)
- **other** : Autres erreurs

## 🔄 Stratégies de retry

### Exponential Backoff
Utilisé pour : 500, 502, 504
```
Retry 1: immédiat
Retry 2: 2 secondes
Retry 3: 4 secondes
Retry 4: 8 secondes
```

### Linear Backoff
Utilisé pour : 503
```
Retry 1: 300 secondes
Retry 2: 600 secondes
Retry 3: 900 secondes
```

### Rate Limit (429)
```
Retry après le délai indiqué par l'API (défaut: 60s)
Max 3 retries
```

## 🎯 Actions suggérées

| Action Type | Description | Erreurs |
|------------|-------------|---------|
| check_credentials | Vérifier les identifiants | 401 |
| check_permissions | Vérifier les permissions | 403 |
| check_input | Vérifier les données saisies | 400, 404 |
| retry_later | Réessayer plus tard | 429, 503 |
| contact_support | Contacter le support | 500 |
| upgrade_plan | Upgrader le plan | 429 (limite plan) |
| refresh_token | Actualiser le token | 401 (token expiré) |

## 🔗 Relations

### Relations sortantes (FROM error_mapping)

- `error_mapping` → `service` (N:1 optionnel) : Pour erreurs spécifiques à un service
- `error_mapping` → `tool` (N:1 optionnel) : Pour erreurs spécifiques à un outil
- `error_mapping` → `i18n_key` (N:1) : Pour messages user/tech/action

### Relations entrantes (TO error_mapping)

Aucune relation entrante (les error_mappings sont utilisés par référence de code HTTP)

## 🤖 Usage IA

Les IA peuvent utiliser les error mappings pour :

1. **Interpréter les erreurs API**
   ```
   API retourne 401 → Chercher error_mapping avec http_code=401
   → Présenter le user_message_i18n
   → Suggérer l'action_type (check_credentials)
   ```

2. **Décider du retry automatique**
   ```
   Erreur 429 → is_retryable=true → Attendre retry_after_seconds
   → Retry avec backoff_strategy
   ```

3. **Contextualiser les erreurs**
   ```
   Slack API retourne 403 → Chercher error_mapping avec service_id=slack ET http_code=403
   → Si absent, fallback sur http_code=403 générique
   ```

4. **Logs intelligents**
   ```
   Erreur 500 → should_notify_admin=true → Alerter les admins
   → Logger avec technical_message
   ```

## 📚 Exemples de requêtes

### Récupérer le mapping pour un code HTTP

```surql
SELECT * FROM error_mapping 
WHERE identity.http_code = 401 
  AND identity.service_id = NONE
LIMIT 1;
```

### Récupérer le mapping spécifique à un service

```surql
SELECT * FROM error_mapping 
WHERE identity.http_code = 403 
  AND identity.service_id = service:slack
LIMIT 1;
```

### Récupérer tous les mappings retryables

```surql
SELECT * FROM error_mapping 
WHERE config.is_retryable = true;
```

### Récupérer les erreurs critiques

```surql
SELECT * FROM error_mapping 
WHERE presentation.severity = 'critical';
```

### Recherche par catégorie

```surql
SELECT * FROM error_mapping 
WHERE identity.error_category = 'auth';
```

## 🎨 Usage UI

### Affichage d'une erreur

```typescript
async function displayError(httpCode: number, serviceId?: string) {
  // Chercher le mapping spécifique au service
  let mapping = await db.query(`
    SELECT * FROM error_mapping 
    WHERE identity.http_code = $code 
      AND identity.service_id = $service
    LIMIT 1
  `, { code: httpCode, service: serviceId });
  
  // Fallback sur le mapping générique
  if (!mapping) {
    mapping = await db.query(`
      SELECT * FROM error_mapping 
      WHERE identity.http_code = $code 
        AND identity.service_id = NONE
      LIMIT 1
    `, { code: httpCode });
  }
  
  // Afficher le message
  showNotification({
    type: mapping.presentation.severity,
    icon: mapping.presentation.icon,
    color: mapping.presentation.color,
    message: translate(mapping.presentation.user_message_i18n),
    action: {
      type: mapping.suggested_action.action_type,
      message: translate(mapping.suggested_action.action_message_i18n),
      url: mapping.suggested_action.help_url
    }
  });
}
```

### Gestion du retry automatique

```typescript
async function executeWithRetry(apiCall: Function, toolId: string) {
  let attempts = 0;
  
  while (true) {
    try {
      return await apiCall();
    } catch (error) {
      const mapping = await getErrorMapping(error.httpCode, error.serviceId);
      
      if (!mapping.config.is_retryable || attempts >= mapping.config.max_retries) {
        throw error;
      }
      
      attempts++;
      const delay = calculateBackoff(
        attempts, 
        mapping.config.retry_after_seconds, 
        mapping.config.backoff_strategy
      );
      
      await sleep(delay * 1000);
    }
  }
}

function calculateBackoff(attempt: number, baseDelay: number, strategy: string): number {
  switch (strategy) {
    case 'exponential':
      return baseDelay * Math.pow(2, attempt - 1);
    case 'linear':
      return baseDelay * attempt;
    default:
      return baseDelay;
  }
}
```

## 📦 Import

### Import manuel

```bash
surreal import --conn http://localhost:8000 --user root --pass root \
  --ns lyxal --db main \
  integrations/reference/error_mapping/error_mapping_seeds.surql

surreal import --conn http://localhost:8000 --user root --pass root \
  --ns lyxal --db main \
  integrations/reference/error_mapping/error_mapping_i18n_keys.surql

surreal import --conn http://localhost:8000 --user root --pass root \
  --ns lyxal --db main \
  integrations/reference/error_mapping/error_mapping_i18n_translations.surql
```

### Import automatique

Voir `../../IMPORT_ALL_SEEDS.ps1` pour l'import de tous les modules.

## 🔄 Ajout de nouveaux mappings

Pour ajouter un error mapping :

1. **Éditer `generate_error_mappings.py`**
   - Ajouter l'entrée dans `SERVICE_SPECIFIC_ERRORS`
   
2. **Régénérer**
   ```bash
   python generate_error_mappings.py
   python generate_seeds.py
   ```

3. **Importer les nouveaux seeds**

## ⚠️ Notes importantes

1. **Hiérarchie de résolution** : Spécifique (tool) → Service → Générique
2. **Fallback garanti** : Tous les codes HTTP courants ont un mapping générique
3. **i18n obligatoire** : Tous les messages passent par i18n
4. **Retry intelligent** : Stratégies de backoff basées sur le type d'erreur
5. **Notifications admin** : Erreurs critiques (500) notifient automatiquement

## 🚀 Évolutions futures

- [ ] Ajout de mappings spécifiques par service (extraction depuis n8n)
- [ ] Support des error_code spécifiques aux APIs (au-delà des codes HTTP)
- [ ] Statistiques d'erreurs par service/tool
- [ ] Suggestions d'amélioration basées sur les erreurs fréquentes
- [ ] Intégration avec un système de monitoring

## 📚 Voir aussi

- [Schema error_mapping.surql](../../database/error_mapping/error_mapping.surql)
- [Module tool](../tool/)
- [Module service](../service/)
- [i18n system](../../i18n/)

