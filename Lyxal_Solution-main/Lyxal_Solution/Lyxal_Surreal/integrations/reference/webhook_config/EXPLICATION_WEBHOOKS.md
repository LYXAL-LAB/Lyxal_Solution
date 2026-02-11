# 🔔 Les Webhooks : Explication complète

## 🤔 C'est quoi un webhook ?

Un **webhook** est l'**inverse d'une API classique**.

### **API classique** (ton app appelle le service) :
```
TON APP  ──────────→  SERVICE EXTERNE
         "Donne-moi les nouveaux messages"
         
TON APP  ←──────────  SERVICE EXTERNE
         "Voici les messages"
```
☝️ **Tu dois demander** régulièrement (polling) : "Y'a du nouveau ?"

### **Webhook** (le service appelle ton app) :
```
TON APP  ←──────────  SERVICE EXTERNE
         "Nouveau message reçu !"
         
TON APP  ──────────→  SERVICE EXTERNE
         "OK, merci !"
```
☝️ **Le service te prévient automatiquement** quand un événement se produit.

---

## 🎯 **Exemple concret : Slack**

### **Scénario** : Tu veux être notifié à chaque nouveau message dans un channel Slack.

### **Sans webhook** (polling) ❌ :
```javascript
// Ton app doit faire ça TOUTES LES 5 SECONDES :
setInterval(() => {
  const messages = await slack.getMessages('#general');
  if (hasNewMessages(messages)) {
    handleNewMessage(messages);
  }
}, 5000); // 5 secondes
```

**Problèmes** :
- ⚡ Gaspillage de ressources (17,280 appels API par jour !)
- ⏱️ Délai de 5 secondes minimum
- 💸 Coûteux en API calls

### **Avec webhook** ✅ :
```javascript
// 1. Configuration UNIQUE (une seule fois)
await slack.createWebhook({
  url: 'https://lyxal.app/webhook/slack',
  events: ['message.channels'] // On s'abonne à l'événement
});

// 2. Slack appelle TON URL automatiquement
app.post('/webhook/slack', (req, res) => {
  const message = req.body.event;
  handleNewMessage(message); // Traitement instantané !
  res.send('OK');
});
```

**Avantages** :
- ⚡ Instantané (< 1 seconde)
- 💰 Zéro appel API gaspillé
- 🚀 Scalable

---

## 🏗️ **Comment ça marche techniquement ?**

### **Étape 1 : Configuration du webhook**

Ton app dit à Slack : "Préviens-moi à cette URL quand il y a un nouveau message"

```http
POST https://slack.com/api/webhooks.create
{
  "url": "https://lyxal.app/webhook/slack/abc123",
  "events": ["message.channels", "reaction_added"],
  "channel": "C1234567890"
}
```

Slack enregistre et répond :
```json
{
  "ok": true,
  "webhook_id": "WH123456",
  "url": "https://lyxal.app/webhook/slack/abc123"
}
```

### **Étape 2 : Événement se produit**

Quelqu'un poste un message dans le channel :

```
Alice : "Hello tout le monde !"
```

### **Étape 3 : Slack appelle ton webhook**

Slack fait **immédiatement** un `POST` vers ton URL :

```http
POST https://lyxal.app/webhook/slack/abc123
Content-Type: application/json

{
  "type": "event_callback",
  "event": {
    "type": "message",
    "channel": "C1234567890",
    "user": "U0987654321",
    "text": "Hello tout le monde !",
    "ts": "1234567890.123456"
  }
}
```

### **Étape 4 : Ton app répond**

```http
HTTP/1.1 200 OK

(Slack considère que tu as bien reçu)
```

---

## 📋 **Configuration webhook dans n8n**

Voici ce que j'ai trouvé dans le code source n8n :

### **1. Configuration de base (SlackTrigger.node.ts, ligne 33)** :

```typescript
webhooks: [
  {
    name: 'default',
    httpMethod: 'POST',           // Méthode HTTP acceptée
    responseMode: 'onReceived',   // Répondre immédiatement
    path: 'webhook',              // Chemin : /webhook-test/abc123/webhook
  }
]
```

### **2. Événements écoutés (ligne 62-106)** :

```typescript
{
  displayName: 'Trigger On',
  name: 'trigger',
  type: 'multiOptions',
  options: [
    {
      name: 'Bot / App Mention',
      value: 'app_mention',  // ← Valeur envoyée à l'API Slack
    },
    {
      name: 'New Message Posted to Channel',
      value: 'message',
    },
    {
      name: 'Reaction Added',
      value: 'reaction_added',
    },
    {
      name: 'New Public Channel Created',
      value: 'channel_created',
    },
    // ... etc
  ]
}
```

### **3. Gestion de l'événement reçu (ligne 317-428)** :

```typescript
async webhook(this: IWebhookFunctions): Promise<IWebhookResponseData> {
  const filters = this.getNodeParameter('trigger', []) as string[];
  const req = this.getRequestObject();
  
  // 1. Vérification de la signature (sécurité)
  if (!(await verifySignature.call(this))) {
    res.status(401).send('Unauthorized');
    return { noWebhookResponse: true };
  }
  
  // 2. Challenge Slack (vérification initiale)
  if (req.body.type === 'url_verification') {
    res.status(200).json({ challenge: req.body.challenge });
    return { noWebhookResponse: true };
  }
  
  // 3. Filtrage par type d'événement
  const eventType = req.body.event.type;
  if (!filters.includes(eventType) && !filters.includes('any_event')) {
    return {}; // Ignorer cet événement
  }
  
  // 4. Filtrage par channel
  const eventChannel = req.body.event.channel;
  if (!watchWorkspace && eventChannel !== selectedChannel) {
    return {}; // Mauvais channel, ignorer
  }
  
  // 5. Enrichissement optionnel (résolution d'IDs)
  if (options.resolveIds) {
    req.body.event.user_resolved = await getUserInfo(req.body.event.user);
    req.body.event.channel_resolved = await getChannelInfo(eventChannel);
  }
  
  // 6. Retour des données pour le workflow
  return {
    workflowData: [[{ json: req.body.event }]]
  };
}
```

---

## 📋 **Configuration webhook GitHub**

### **1. Création du webhook (ligne 491-560)** :

```typescript
async create(this: IHookFunctions): Promise<boolean> {
  const webhookUrl = this.getNodeWebhookUrl('default');
  const owner = this.getNodeParameter('owner');
  const repository = this.getNodeParameter('repository');
  const events = this.getNodeParameter('events', []); // ['push', 'pull_request', etc.]
  
  // Appel API GitHub pour créer le webhook
  const endpoint = `/repos/${owner}/${repository}/hooks`;
  const body = {
    name: 'web',
    config: {
      url: webhookUrl,              // https://lyxal.app/webhook/abc123
      content_type: 'json',         // Format JSON
      insecure_ssl: '0'             // Vérifier SSL
    },
    events: events,                 // ['push', 'issues', 'pull_request']
    active: true
  };
  
  const responseData = await githubApiRequest.call(this, 'POST', endpoint, body);
  
  // Sauvegarder l'ID du webhook pour pouvoir le supprimer plus tard
  webhookData.webhookId = responseData.id;
  webhookData.webhookEvents = responseData.events;
  
  return true;
}
```

### **2. Suppression du webhook (ligne 568-601)** :

```typescript
async delete(this: IHookFunctions): Promise<boolean> {
  const webhookData = this.getWorkflowStaticData('node');
  
  if (webhookData.webhookId !== undefined) {
    const owner = this.getNodeParameter('owner');
    const repository = this.getNodeParameter('repository');
    const endpoint = `/repos/${owner}/${repository}/hooks/${webhookData.webhookId}`;
    
    try {
      await githubApiRequest.call(this, 'DELETE', endpoint);
    } catch (error) {
      return false;
    }
    
    delete webhookData.webhookId;
    delete webhookData.webhookEvents;
  }
  
  return true;
}
```

---

## 🔐 **Sécurité : Vérification de signature**

**Problème** : N'importe qui pourrait appeler ton webhook avec des fausses données !

**Solution** : Les services signent leurs requêtes avec un secret partagé.

### **Exemple Slack (SlackTriggerHelpers.ts)** :

```typescript
export async function verifySignature(this: IWebhookFunctions): Promise<boolean> {
  const credentials = await this.getCredentials('slackApi');
  const signingSecret = credentials.signingSecret as string;
  
  if (!signingSecret) {
    return true; // Pas de secret = pas de vérification (dangereux)
  }
  
  const req = this.getRequestObject();
  const timestamp = req.headers['x-slack-request-timestamp'] as string;
  const signature = req.headers['x-slack-signature'] as string;
  const body = JSON.stringify(req.body);
  
  // Recalculer la signature attendue
  const baseString = `v0:${timestamp}:${body}`;
  const expectedSignature = `v0=${crypto
    .createHmac('sha256', signingSecret)
    .update(baseString)
    .digest('hex')}`;
  
  // Comparer avec la signature reçue
  return crypto.timingSafeEqual(
    Buffer.from(expectedSignature),
    Buffer.from(signature)
  );
}
```

---

## 📊 **Types d'événements courants**

### **Slack** :
- `message.channels` - Nouveau message
- `app_mention` - Bot mentionné
- `reaction_added` - Réaction ajoutée
- `channel_created` - Nouveau channel
- `team_join` - Nouvel utilisateur
- `file_shared` - Fichier partagé

### **GitHub** :
- `push` - Commit poussé
- `pull_request` - PR créée/modifiée
- `issues` - Issue créée/modifiée
- `release` - Release publiée
- `star` - Repo starré
- `fork` - Repo forké

### **Stripe** :
- `payment_intent.succeeded` - Paiement réussi
- `customer.created` - Nouveau client
- `invoice.paid` - Facture payée
- `subscription.updated` - Abonnement modifié

---

## 🎯 **À quoi sert `webhook_config` dans Lyxal ?**

La table `webhook_config` doit stocker **comment configurer et gérer** les webhooks pour chaque service.

### **Informations à stocker** :

```surql
CREATE webhook_config:slack_new_message SET
    service_id = service:slack,
    event_name = 'message.channels',
    event_display_name_i18n = i18n_key:webhook_slack_message_name,
    event_description_i18n = i18n_key:webhook_slack_message_desc,
    config = {
        // Configuration de l'endpoint webhook
        http_method: 'POST',
        response_mode: 'immediate',  // 'immediate' | 'async'
        path_suffix: '/webhook',
        
        // API pour créer le webhook côté service
        creation_endpoint: '/api/webhooks.create',
        creation_method: 'POST',
        creation_body_template: {
            url: '{{webhook_url}}',
            events: ['message.channels'],
            channel: '{{channel_id}}'
        },
        
        // API pour supprimer le webhook
        deletion_endpoint: '/api/webhooks.delete',
        deletion_method: 'POST',
        deletion_body_template: {
            webhook_id: '{{webhook_id}}'
        },
        
        // Sécurité
        signature_verification: {
            enabled: true,
            header_name: 'x-slack-signature',
            algorithm: 'sha256',
            secret_field: 'signing_secret'
        },
        
        // Challenge/verification initiale
        initial_verification: {
            type: 'challenge_response',
            challenge_field: 'challenge',
            response_field: 'challenge'
        },
        
        // Extraction des données de l'événement
        event_data_path: 'event',
        event_type_path: 'event.type'
    },
    filters = {
        // Filtres optionnels configurables par l'utilisateur
        channel_filter: {
            enabled: true,
            parameter_name: 'channelId',
            event_field_path: 'event.channel'
        },
        user_filter: {
            enabled: true,
            parameter_name: 'userIds',
            event_field_path: 'event.user'
        }
    };
```

---

## ❌ **Peut-on extraire les configs webhook depuis n8n ?**

### **Partiellement extractible** ⚠️

**Ce qu'on PEUT extraire** :
- ✅ Liste des événements disponibles (ex: `message`, `app_mention`)
- ✅ Noms d'affichage des événements
- ✅ Méthode HTTP (`POST`)
- ✅ Mode de réponse (`onReceived`)

**Ce qu'on NE PEUT PAS extraire** :
- ❌ Endpoints API pour créer/supprimer les webhooks (hardcodé en TypeScript)
- ❌ Structure des body de création (hardcodé)
- ❌ Logique de vérification de signature (code procédural)
- ❌ Filtres et transformations (logique complexe)

---

## 📈 **Estimation extraction**

Sur **419 services** :
- **~50 services** ont des triggers webhook (~12%)
- Chaque trigger a **5-10 événements** en moyenne
- **~300-500 événements webhook** au total

**Données extractibles** : ~40%
- Noms et valeurs des événements : ✅ Oui
- Configuration technique : ❌ Non (hardcodé)

---

## ✅ **Recommandation pour Lyxal**

### **Option 1 : Créer le schéma + extraire les événements** ⭐ (recommandé)
- ✅ Schéma `webhook_config` conforme
- ✅ Seeds pour les **noms d'événements** (extractibles)
- ❌ Pas de config technique (impossible)
- 💡 Config technique à créer manuellement

### **Option 2 : Schéma vide seulement**
- ✅ Schéma conforme
- ❌ Aucune seed
- 💡 Tout à créer manuellement

**Je recommande l'Option 1** : On peut quand même extraire les 300-500 événements avec leurs noms !

---

**Veux-tu que je procède avec l'Option 1 pour `webhook_config` ?** 🚀

