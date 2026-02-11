# WebSocket pour les Tables Credentials

## Vue d'ensemble

Les tables du module `credentials` supportent les mises à jour en temps réel via WebSocket grâce à la fonctionnalité `LIVE SELECT` de SurrealDB. Ce document centralise toutes les informations relatives à l'utilisation des WebSockets pour les tables `auth_type`, `credential_type`, `transmission_method`, `uses_credential`, et `user_service_credential`.

## Architecture

Toutes les tables credentials utilisent :
- **ETag automatique** : UUID v7 généré automatiquement à chaque modification (`DEFAULT ALWAYS rand::uuid::v7()`)
- **Support WebSocket** : Via `LIVE SELECT` pour les mises à jour en temps réel
- **Optimistic locking** : Utilisation de l'ETag pour détecter les conflits de modification

---

## 1. auth_type

### Exemple d'utilisation

**Côté serveur (SurrealDB) :**
```surql
LIVE SELECT * FROM auth_type WHERE is_active = true;
```

**Côté client (JavaScript) :**
```javascript
ws.on('message', (data) => {
  if (data.action === 'CREATE' || data.action === 'UPDATE') {
    console.log('Auth type modifié:', data.result);
    console.log('Nouveau ETag:', data.result.etag);
    // Mettre à jour le cache local et l'UI
    updateCache(data.result);
    refreshUI(data.result);
  }
});
```

### Flow de mise à jour

1. Client A écoute les changements via `LIVE SELECT`
2. Client B modifie `auth_type:oauth2`
3. SurrealDB génère un nouvel ETag automatiquement
4. Client A reçoit la notification avec le nouvel ETag
5. Client A met à jour son UI en temps réel

### Avantages

- Détection instantanée des changements
- Évite les conflits de mise à jour (optimistic locking)
- Cache intelligent côté client
- Synchronisation multi-utilisateurs

---

## 2. credential_type

### Exemple d'utilisation

**Côté serveur (SurrealDB) :**
```surql
LIVE SELECT * FROM credential_type WHERE is_active = true;
```

**Côté client (JavaScript) :**
```javascript
ws.on('message', (data) => {
  if (data.action === 'CREATE' || data.action === 'UPDATE') {
    console.log('Credential type modifié:', data.result);
    console.log('Nouveau ETag:', data.result.etag);
    updateCache(data.result);
    refreshUI(data.result);
  }
});
```

### Flow de mise à jour

1. Client A écoute les changements via `LIVE SELECT`
2. Client B crée/modifie un `credential_type`
3. ETag généré automatiquement (DEFAULT)
4. Client A reçoit la notification avec le nouvel ETag
5. Client A met à jour son UI en temps réel

---

## 3. transmission_method

### Exemple d'utilisation

**Côté serveur (SurrealDB) :**
```surql
LIVE SELECT * FROM transmission_method WHERE is_active = true;
```

**Côté client (JavaScript) :**
```javascript
ws.on('message', (data) => {
  if (data.action === 'CREATE' || data.action === 'UPDATE') {
    console.log('Transmission method modifiée:', data.result);
    console.log('Nouveau ETag:', data.result.etag);
    updateCache(data.result);
    refreshUI(data.result);
  }
});
```

### Flow de mise à jour

1. Client écoute les changements via `LIVE SELECT`
2. Admin modifie un `transmission_method`
3. ETag généré automatiquement
4. Tous les clients reçoivent la notification
5. UI met à jour dynamiquement la liste des méthodes disponibles

---

## 4. uses_credential

### Exemple d'utilisation

**Côté serveur (SurrealDB) :**
```surql
LIVE SELECT * FROM uses_credential WHERE in = service:google_sheets;
```

**Côté client (JavaScript) :**
```javascript
ws.on('message', (data) => {
  if (data.action === 'CREATE' || data.action === 'UPDATE') {
    console.log('Credential relation modifiée:', data.result);
    console.log('Nouveau ETag:', data.result.etag);
    // Mettre à jour la liste des credentials disponibles dans l'UI
    updateCredentialsSelector(data.result);
  } else if (data.action === 'DELETE') {
    console.log('Credential relation supprimée');
    removeCredentialFromUI(data.result.id);
  }
});
```

### Flow de mise à jour

1. Client écoute les changements via `LIVE SELECT`
2. Admin ajoute un nouveau credential à un service
3. ETag généré automatiquement (DEFAULT)
4. Tous les clients reçoivent la notification
5. UI met à jour dynamiquement la liste des authentifications disponibles

### Avantages

- Synchronisation instantanée multi-utilisateurs
- UI toujours à jour sans refresh manuel
- Gestion d'état simplifiée côté client

---

## 5. user_service_credential

### Exemple d'utilisation

**Côté serveur (SurrealDB) :**
```surql
LIVE SELECT * FROM user_service_credential WHERE user_id = $auth.id AND is_active = true;
```

**Côté client (JavaScript) :**
```javascript
ws.on('message', (data) => {
  if (data.action === 'CREATE' || data.action === 'UPDATE') {
    console.log('User credential modifiée:', data.result);
    console.log('Nouveau ETag:', data.result.etag);
    // Mettre à jour la liste des credentials de l'utilisateur
    updateUserCredentialsList(data.result);
  } else if (data.action === 'DELETE') {
    console.log('User credential supprimée');
    removeCredentialFromUI(data.result.id);
  }
});
```

### Flow de mise à jour

1. Client écoute les changements via `LIVE SELECT` (filtré par `user_id`)
2. Utilisateur crée/modifie/supprime une credential
3. ETag généré automatiquement (DEFAULT)
4. Le client reçoit la notification avec le nouvel ETag
5. UI met à jour dynamiquement la liste des credentials

### Sécurité

- Les permissions SurrealDB garantissent que chaque utilisateur ne voit que ses propres credentials
- Les données sensibles (`credentials.*`) doivent être chiffrées côté application avant stockage

---

## Implémentation côté client

### Exemple complet JavaScript

```javascript
class CredentialsWebSocketManager {
  constructor(surrealEndpoint, authToken) {
    this.ws = new WebSocket(surrealEndpoint);
    this.authToken = authToken;
    this.listeners = new Map();
    this.setupConnection();
  }

  setupConnection() {
    this.ws.onopen = () => {
      console.log('[WebSocket] Connected to SurrealDB');
      // Authentifier
      this.ws.send(JSON.stringify({
        id: 'auth',
        method: 'authenticate',
        params: [this.authToken]
      }));
    };

    this.ws.onmessage = (event) => {
      const data = JSON.parse(event.data);
      this.handleMessage(data);
    };

    this.ws.onerror = (error) => {
      console.error('[WebSocket] Error:', error);
    };

    this.ws.onclose = () => {
      console.log('[WebSocket] Disconnected');
      // Reconnexion automatique après 5 secondes
      setTimeout(() => this.setupConnection(), 5000);
    };
  }

  subscribeToAuthTypes(callback) {
    const query = 'LIVE SELECT * FROM auth_type WHERE is_active = true;';
    this.ws.send(JSON.stringify({
      id: 'auth_types_live',
      method: 'query',
      params: [query]
    }));
    this.listeners.set('auth_types', callback);
  }

  subscribeToCredentialTypes(callback) {
    const query = 'LIVE SELECT * FROM credential_type WHERE is_active = true;';
    this.ws.send(JSON.stringify({
      id: 'credential_types_live',
      method: 'query',
      params: [query]
    }));
    this.listeners.set('credential_types', callback);
  }

  subscribeToUserCredentials(userId, callback) {
    const query = `LIVE SELECT * FROM user_service_credential WHERE user_id = user:${userId} AND is_active = true;`;
    this.ws.send(JSON.stringify({
      id: 'user_credentials_live',
      method: 'query',
      params: [query]
    }));
    this.listeners.set('user_credentials', callback);
  }

  handleMessage(data) {
    if (data.result) {
      // Traiter les résultats LIVE SELECT
      const action = data.result.action; // CREATE, UPDATE, DELETE
      const result = data.result.result;

      // Appeler les callbacks appropriés
      this.listeners.forEach((callback, key) => {
        callback(action, result);
      });
    }
  }
}

// Usage
const wsManager = new CredentialsWebSocketManager('ws://localhost:8000/rpc', 'token');

wsManager.subscribeToAuthTypes((action, data) => {
  console.log(`Auth type ${action}:`, data);
  // Mettre à jour le cache et l'UI
  updateAuthTypesCache(data);
  refreshAuthTypesUI(data);
});

wsManager.subscribeToUserCredentials('user123', (action, data) => {
  console.log(`User credential ${action}:`, data);
  // Mettre à jour la liste des credentials de l'utilisateur
  updateUserCredentialsList(data);
});
```

---

## Gestion de l'ETag pour Optimistic Locking

### Principe

L'ETag (UUID v7) change automatiquement à chaque modification grâce à `DEFAULT ALWAYS rand::uuid::v7()`. Cela permet de :

1. **Détecter les conflits** : Si deux clients tentent de modifier la même ressource
2. **Valider les mises à jour** : Vérifier que la ressource n'a pas changé depuis la dernière lecture
3. **Gérer le cache** : Invalider le cache côté client quand l'ETag change

### Exemple d'utilisation

```javascript
// Lecture avec ETag
const credential = await surreal.query('SELECT * FROM user_service_credential WHERE id = $id', {
  id: 'user_service_credential:123'
});

const currentEtag = credential[0].etag;

// Tentative de mise à jour avec vérification ETag
try {
  const result = await surreal.query(`
    UPDATE user_service_credential SET 
      is_active = false
    WHERE id = $id AND etag = $etag
  `, {
    id: 'user_service_credential:123',
    etag: currentEtag
  });

  if (result.length === 0) {
    // Conflit détecté : la ressource a été modifiée entre-temps
    console.warn('Conflit de modification détecté');
    // Recharger la ressource et réessayer
    await reloadCredentialAndRetry();
  }
} catch (error) {
  console.error('Erreur lors de la mise à jour:', error);
}
```

---

## Bonnes pratiques

1. **Gestion des reconnexions** : Implémenter une reconnexion automatique en cas de déconnexion
2. **Throttling** : Limiter le nombre de mises à jour UI pour éviter les surcharges
3. **Cache local** : Mettre en cache les données pour éviter les requêtes répétées
4. **Gestion des erreurs** : Gérer gracieusement les erreurs de connexion WebSocket
5. **Permissions** : Vérifier que les permissions SurrealDB sont correctement configurées
6. **Chiffrement** : Ne jamais oublier de chiffrer les données sensibles (`credentials.*`) côté application avant stockage

---

## Notes techniques

- **ETag** : Change automatiquement à chaque UPDATE grâce à SurrealDB
- **Permissions** : Chaque table a ses propres règles de permissions (voir les fichiers `.surql` correspondants)
- **Performance** : Les `LIVE SELECT` sont optimisés par SurrealDB, mais éviter de créer trop de subscriptions simultanées
- **Sécurité** : Les WebSockets doivent être authentifiés avec un token valide

---

## Références

- Documentation SurrealDB : [LIVE SELECT](https://surrealdb.com/docs/surrealql/statements/live)
- Documentation SurrealDB : [WebSocket](https://surrealdb.com/docs/integration/websocket)
- Tables concernées :
  - `integrations/database/credentials/auth_type.surql`
  - `integrations/database/credentials/credential_type.surql`
  - `integrations/database/credentials/transmission_method.surql`
  - `integrations/database/credentials/uses_credential.surql`
  - `integrations/database/credentials/user_service_credential.surql`

