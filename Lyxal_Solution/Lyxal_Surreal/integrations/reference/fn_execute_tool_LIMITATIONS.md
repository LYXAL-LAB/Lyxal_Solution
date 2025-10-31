# ⚠️ Limitations de fn::execute_tool

**Date** : 30 octobre 2025  
**Fonction** : `fn::execute_tool()` - Fonction générique pour exécuter les tools

---

## 🎯 Résumé

**Couverture estimée** : ~70-80% des cas d'usage  
**Cas simples** : ✅ Fonctionne parfaitement  
**Cas complexes** : ⚠️ Nécessite des fonctions spécialisées

---

## ✅ **CAS OÙ ÇA FONCTIONNE PARFAITEMENT**

### **1. Appels API Simples (GET, POST, PUT, DELETE)**

**Exemples** :
- ✅ Poster un message Slack
- ✅ Créer une issue GitHub
- ✅ Ajouter un événement Google Calendar
- ✅ Envoyer un email via SendGrid
- ✅ Créer un utilisateur
- ✅ Mettre à jour un enregistrement
- ✅ Supprimer une ressource

**Estimation** : ~60% des 2,436 tools

```surql
-- ✅ Fonctionne
LET $result = fn::execute_tool(
  tool:slack_message_post,
  {channel: '#general', text: 'Hello!'},
  user:john
);
```

---

### **2. Paramètres dans le Path**

**Exemples** :
- ✅ `/users/{userId}`
- ✅ `/repos/{owner}/{repo}/issues`
- ✅ `/channels/{channelId}/messages`

**La fonction remplace automatiquement** :
```javascript
// Endpoint: /repos/{owner}/{repo}/issues
// Params: {owner: 'lyxal', repo: 'app'}
// Résultat: /repos/lyxal/app/issues
```

```surql
-- ✅ Fonctionne
LET $result = fn::execute_tool(
  tool:github_issue_list,
  {owner: 'lyxal', repo: 'app', state: 'open'},
  user:john
);
```

---

### **3. Body Templates Simples**

**Exemples** :
- ✅ `{"name": "{{name}}", "email": "{{email}}"}`
- ✅ `{"channel": "{{channel}}", "text": "{{text}}"}`
- ✅ `{"title": "{{title}}", "body": "{{body}}"}`

**La fonction remplace les variables** :
```javascript
// Template: {"channel": "{{channel}}", "text": "{{text}}"}
// Params: {channel: '#general', text: 'Hello'}
// Résultat: {"channel": "#general", "text": "Hello"}
```

```surql
-- ✅ Fonctionne
LET $result = fn::execute_tool(
  tool:slack_message_post,
  {channel: '#general', text: 'Hello'},
  user:john
);
```

---

### **4. Authentification Standard**

**Types supportés** :
- ✅ **OAuth2** : `Authorization: Bearer <token>`
- ✅ **API Key** (header) : `X-API-Key: <key>`
- ✅ **Basic Auth** : `Authorization: Basic <base64>`

**La fonction gère automatiquement** :
```javascript
if (authType === 'oauth2') {
  headers['Authorization'] = `Bearer ${credentials.access_token}`;
} else if (authType === 'api_key') {
  headers[credentials.header_name] = credentials.api_key;
}
```

```surql
-- ✅ Fonctionne (si credentials existent)
LET $result = fn::execute_tool(
  tool:github_issue_create,
  {owner: 'lyxal', repo: 'app', title: 'Bug'},
  user:john
);
```

---

### **5. Extraction de Données Simple**

**La fonction supporte** :
- ✅ `data_path` : Extraire un sous-objet (`response.channel`)
- ✅ `fields_to_extract` : Filtrer les champs (`['id', 'name']`)

```javascript
// Réponse API: {ok: true, channel: {id: '123', name: '#general', ...}}
// data_path: 'channel'
// Résultat: {id: '123', name: '#general', ...}

// Réponse API: {id: '123', name: 'John', email: 'john@example.com', ...}
// fields_to_extract: ['id', 'name']
// Résultat: {id: '123', name: 'John'}
```

```surql
-- ✅ Fonctionne
LET $result = fn::execute_tool(
  tool:slack_channel_info,
  {channel: 'C123456'},
  user:john
);
-- Retourne seulement les champs configurés dans config.response
```

---

## ⚠️ **CAS OÙ ÇA NE FONCTIONNE PAS (ou pas optimalement)**

### **1. Pagination 📄**

**Problème** : Les APIs retournent souvent des résultats paginés (ex: 100 issues sur 1000).

**Exemple GitHub** :
```json
// Réponse API
{
  "items": [...], // 100 issues
  "total_count": 1000,
  "has_next": true,
  "next_page": "https://api.github.com/repos/.../issues?page=2"
}
```

**fn::execute_tool fait 1 seul appel** :
```surql
-- ❌ Retourne seulement 100 issues (pas les 1000)
LET $result = fn::execute_tool(
  tool:github_issue_list,
  {owner: 'lyxal', repo: 'app'},
  user:john
);
-- $result.data contient seulement 100 issues
```

**Solution nécessaire** : Fonction spécialisée avec boucle
```surql
DEFINE FUNCTION fn::execute_tool_paginated($tool_id, $params, $user_id) {
  RETURN function() {
    let allResults = [];
    let page = 1;
    let hasMore = true;
    
    while (hasMore) {
      const result = await fn::execute_tool($tool_id, {...$params, page}, $user_id);
      allResults = allResults.concat(result.data);
      hasMore = result.metadata.has_next;
      page++;
    }
    
    return {success: true, data: allResults};
  };
};
```

**Estimation** : ~20% des tools ont de la pagination

---

### **2. Upload de Fichiers 📎**

**Problème** : Les uploads nécessitent `multipart/form-data`, pas `application/json`.

**Exemple Slack** :
```javascript
// Upload d'un fichier
const formData = new FormData();
formData.append('file', fileBuffer);
formData.append('channels', 'C123456');

fetch('https://slack.com/api/files.upload', {
  method: 'POST',
  headers: {'Authorization': 'Bearer token'},
  body: formData  // ❌ fn::execute_tool envoie du JSON
});
```

**fn::execute_tool ne gère que JSON** :
```surql
-- ❌ Ne fonctionne pas pour upload de fichiers
LET $result = fn::execute_tool(
  tool:slack_file_upload,
  {file: '<binary data>', channels: 'C123456'},
  user:john
);
```

**Solution nécessaire** : Fonction spécialisée
```surql
DEFINE FUNCTION fn::execute_tool_file_upload($tool_id, $file, $params, $user_id) {
  RETURN function() {
    // Construire multipart/form-data
    const formData = new FormData();
    formData.append('file', $file);
    // ...
  };
};
```

**Estimation** : ~5% des tools (uploads de fichiers, images, documents)

---

### **3. Webhooks 🔔**

**Problème** : Webhooks = l'API nous appelle, pas l'inverse.

**Exemple** :
```javascript
// Slack webhook
POST https://lyxal.com/api/webhooks/slack
{
  "event": {
    "type": "message",
    "text": "Hello",
    "channel": "C123456"
  }
}
```

**fn::execute_tool ne peut pas gérer ça** car :
- ❌ Ce n'est pas Lyxal qui appelle l'API
- ❌ C'est l'API qui appelle Lyxal

**Solution** : Utiliser `DEFINE API` (comme documenté dans `EXPLICATION_WEBHOOKS.md`)
```surql
DEFINE API "/webhooks/slack"
  FOR post
  MIDDLEWARE fn::verify_slack_signature
  THEN fn::handle_slack_webhook($request);
```

**Estimation** : ~50 services avec webhooks (~300-500 événements)

---

### **4. Streaming / Real-time 📡**

**Problème** : Certaines APIs streament des données (SSE, WebSocket).

**Exemples** :
- ❌ OpenAI ChatGPT (streaming de tokens)
- ❌ Twitch (événements temps réel)
- ❌ Discord (gateway WebSocket)

**fn::execute_tool ne supporte que HTTP req/res classique** :
```surql
-- ❌ Ne peut pas streamer
LET $result = fn::execute_tool(
  tool:openai_chat_stream,
  {prompt: 'Hello'},
  user:john
);
```

**Solution** : Fonction spécialisée avec WebSocket/SSE
```surql
DEFINE FUNCTION fn::execute_tool_stream($tool_id, $params, $user_id) {
  RETURN function() {
    // Gérer WebSocket ou SSE
    const ws = new WebSocket(url);
    ws.onmessage = (event) => {
      // Stream les données
    };
  };
};
```

**Estimation** : ~5% des tools (AI, chat, événements temps réel)

---

### **5. Batch Operations 📦**

**Problème** : Besoin de faire plusieurs appels API en parallèle.

**Exemple** : Envoyer 100 messages Slack différents
```surql
-- ❌ Inefficace : 100 appels séquentiels (lent)
FOR $message IN $messages {
  LET $result = fn::execute_tool(
    tool:slack_message_post,
    {channel: $message.channel, text: $message.text},
    user:john
  );
};
```

**Solution** : Fonction spécialisée avec Promise.all()
```surql
DEFINE FUNCTION fn::execute_tool_batch($tool_id, $params_array, $user_id) {
  RETURN function() {
    const promises = $params_array.map(params => 
      fn::execute_tool($tool_id, params, $user_id)
    );
    return Promise.all(promises);
  };
};
```

**Estimation** : ~10% des cas d'usage (bulk operations)

---

### **6. Complex Workflows 🔄**

**Problème** : Opérations nécessitant plusieurs appels API séquentiels.

**Exemple** : Créer un repo GitHub ET ajouter un webhook
```javascript
// 1. Créer le repo
const repo = await createRepo({name: 'my-repo'});

// 2. Utiliser l'ID du repo pour créer le webhook
const webhook = await createWebhook({
  repo_id: repo.id,  // ⚠️ Dépend de l'étape 1
  url: 'https://lyxal.com/webhook'
});
```

**fn::execute_tool fait 1 seul appel** :
```surql
-- ❌ Ne peut pas faire 2 appels liés
LET $repo = fn::execute_tool(tool:github_repo_create, {name: 'my-repo'}, user:john);
LET $webhook = fn::execute_tool(
  tool:github_webhook_create,
  {repo_id: $repo.data.id, url: 'https://lyxal.com/webhook'},
  user:john
);
-- ⚠️ Fonctionne mais pas atomique (si étape 2 échoue, étape 1 persiste)
```

**Solution** : Fonction spécialisée avec transaction
```surql
DEFINE FUNCTION fn::execute_workflow_github_repo_with_webhook($params, $user_id) {
  RETURN function() {
    // Transaction pour rollback si erreur
    try {
      const repo = await fn::execute_tool(...);
      const webhook = await fn::execute_tool(...);
      return {success: true, repo, webhook};
    } catch (e) {
      // Rollback: supprimer le repo si webhook échoue
    }
  };
};
```

**Estimation** : ~15% des cas d'usage (workflows complexes)

---

### **7. OAuth Flow Initial 🔐**

**Problème** : fn::execute_tool suppose que les credentials existent déjà.

**OAuth2 flow** :
```javascript
// 1. Rediriger l'utilisateur vers le provider
window.location = 'https://slack.com/oauth/authorize?client_id=...';

// 2. Callback avec authorization code
GET /callback?code=abc123

// 3. Échanger le code contre un token
POST https://slack.com/api/oauth.v2.access
{client_id, client_secret, code}

// 4. Sauvegarder le token
INSERT INTO user_service_credential (access_token, refresh_token)
```

**fn::execute_tool ne gère pas les étapes 1-4** :
```surql
-- ❌ Échoue si pas de credentials
LET $result = fn::execute_tool(
  tool:slack_message_post,
  {channel: '#general', text: 'Hello'},
  user:new_user  -- Pas de token Slack
);
-- Erreur: credentials_not_found
```

**Solution** : Fonctions séparées pour OAuth
```surql
DEFINE FUNCTION fn::oauth_get_authorization_url($service_id, $redirect_uri);
DEFINE FUNCTION fn::oauth_exchange_code($service_id, $code);
DEFINE FUNCTION fn::oauth_refresh_token($credential_id);
```

**Estimation** : Concerne tous les services OAuth2 (~200 services)

---

### **8. Rate Limiting ⏱️**

**Problème** : APIs ont des limites (ex: 100 req/min).

**Exemple Slack** :
```javascript
// Slack limite à 50 req/min
for (let i = 0; i < 100; i++) {
  await fn::execute_tool(...);  // ❌ Dépassera la limite après 50
}
// Erreur 429: Rate limit exceeded
```

**fn::execute_tool ne gère pas les rate limits** :
```surql
-- ❌ Pas de throttling automatique
FOR $i IN 1..100 {
  LET $result = fn::execute_tool(tool:slack_message_post, {...}, user:john);
};
-- 429 après 50 appels
```

**Solution** : Fonction avec queue
```surql
DEFINE FUNCTION fn::execute_tool_throttled($tool_id, $params, $user_id) {
  RETURN function() {
    // Vérifier la rate limit depuis integration_log
    const recentCalls = await surrealdb.query(`
      SELECT count() FROM integration_log
      WHERE service_id = ${service_id}
      AND timestamp > time::now() - 1m
    `);
    
    if (recentCalls > 50) {
      await sleep(60000);  // Attendre 1 minute
    }
    
    return fn::execute_tool($tool_id, $params, $user_id);
  };
};
```

**Estimation** : Concerne tous les services (mais pas toujours nécessaire)

---

### **9. Retry Logic 🔁**

**Problème** : Erreurs transitoires (timeout, 503, etc.) nécessitent retry.

**fn::execute_tool ne retry pas** :
```surql
-- ❌ Échoue immédiatement sur erreur transitoire
LET $result = fn::execute_tool(tool:slack_message_post, {...}, user:john);
-- Si 503: {success: false, error: 'api_error', status_code: 503}
```

**Solution** : Fonction avec retry
```surql
DEFINE FUNCTION fn::execute_tool_with_retry(
  $tool_id, $params, $user_id, $max_retries: int = 3
) {
  RETURN function() {
    let retries = 0;
    
    while (retries < $max_retries) {
      const result = await fn::execute_tool($tool_id, $params, $user_id);
      
      if (result.success || !result.is_retryable) {
        return result;
      }
      
      retries++;
      await sleep(result.retry_delay_seconds * 1000);
    }
    
    return {success: false, error: 'max_retries_exceeded'};
  };
};
```

**Estimation** : Utile pour ~30% des cas (APIs instables)

---

### **10. Response Mapping Complexe 🔄**

**Problème** : Transformations complexes comme dans n8n (voir `EXEMPLES_REELS_N8N.md`).

**Exemples n8n** :
```typescript
// 1. Transformation de tableau
responseData = responseData.map(member => ({
  member_id: member,
  joined_at: new Date()
}));

// 2. Filtrage conditionnel
responseData = responseData.filter(item => item.is_active);

// 3. Agrégation
responseData = {
  total: responseData.length,
  items: responseData
};

// 4. Renommage de champs + calculs
responseData = responseData.map(item => ({
  id: item.user_id,
  full_name: `${item.first_name} ${item.last_name}`,
  age: new Date().getFullYear() - item.birth_year
}));
```

**fn::execute_tool ne fait que** :
- ✅ Extraire un sous-objet (`data_path`)
- ✅ Filtrer les champs (`fields_to_extract`)
- ❌ **Pas de transformations complexes**

```surql
-- ❌ Ne peut pas faire de transformations complexes
LET $result = fn::execute_tool(tool:slack_users_list, {}, user:john);
-- Retourne les données brutes, pas transformées
```

**Solution** : Post-traitement en SurrealQL
```surql
LET $result = fn::execute_tool(tool:slack_users_list, {}, user:john);

-- Transformation manuelle
LET $transformed = (
  SELECT 
    id,
    name,
    email,
    is_active
  FROM $result.data
  WHERE is_active = true
);

RETURN $transformed;
```

**Estimation** : ~30% des tools ont des transformations complexes

---

## 📊 **Tableau Récapitulatif**

| Cas d'Usage | fn::execute_tool | Estimation | Solution |
|-------------|------------------|------------|----------|
| **Appels simples** | ✅ Parfait | 60% | Aucune |
| **Path params** | ✅ Parfait | Inclus | Aucune |
| **Body templates** | ✅ Parfait | Inclus | Aucune |
| **Auth standard** | ✅ Parfait | Inclus | Aucune |
| **Extraction simple** | ✅ Parfait | Inclus | Aucune |
| **Pagination** | ⚠️ 1 page | 20% | `fn::execute_tool_paginated` |
| **Upload fichiers** | ❌ Non supporté | 5% | `fn::execute_tool_file_upload` |
| **Webhooks** | ❌ Non concerné | ~50 services | `DEFINE API` |
| **Streaming** | ❌ Non supporté | 5% | `fn::execute_tool_stream` |
| **Batch operations** | ⚠️ Séquentiel | 10% | `fn::execute_tool_batch` |
| **Workflows complexes** | ⚠️ Non atomique | 15% | Fonctions workflow |
| **OAuth initial** | ❌ Non supporté | ~200 services | `fn::oauth_*` |
| **Rate limiting** | ❌ Non géré | Tous | `fn::execute_tool_throttled` |
| **Retry logic** | ❌ Non géré | 30% | `fn::execute_tool_with_retry` |
| **Transformations** | ⚠️ Limitées | 30% | Post-traitement SurrealQL |

---

## ✅ **Conclusion**

### **fn::execute_tool est EXCELLENT pour** :
- ✅ 70-80% des cas d'usage simples
- ✅ Appels API standards (GET, POST, PUT, DELETE)
- ✅ Authentification classique (OAuth2, API Key, Basic)
- ✅ Extraction de données simple
- ✅ Point de départ rapide et efficace

### **Mais NÉCESSITE des fonctions spécialisées pour** :
- ⚠️ Pagination (20% des tools)
- ⚠️ Upload de fichiers (5% des tools)
- ⚠️ Webhooks (~50 services)
- ⚠️ Streaming (5% des tools)
- ⚠️ Workflows complexes (15% des cas)
- ⚠️ Transformations avancées (30% des tools)

### **Recommandation** :

**Phase 1 : fn::execute_tool** (Actuel)
- Couvre 70-80% des besoins
- Rapide à mettre en place
- Prouve le concept

**Phase 2 : Fonctions spécialisées** (Futur)
- `fn::execute_tool_paginated`
- `fn::execute_tool_file_upload`
- `fn::execute_tool_batch`
- `fn::execute_tool_with_retry`
- `fn::oauth_*` (pour OAuth flow)
- Fonctions workflow spécifiques

**Phase 3 : Optimisations** (Plus tard)
- Rate limiting automatique
- Cache intelligent
- Retry configurable
- Monitoring avancé

---

**Date** : 30 octobre 2025  
**Auteur** : Claude (Assistant IA)  
**Version** : 1.0

