# 🔍 Comment `surreal.infrastructure.getDomain()` Fonctionne ?

## 🤔 **Ta Question : Comment C'est Possible ?**

```typescript
const domain = await surreal.infrastructure.getDomain('lyxal.com');
```

Très bonne question ! Laisse-moi te montrer **étape par étape** comment ça marche.

---

## 🏗️ **Architecture : Comment Tout Se Connecte**

### **Étape 1 : La Gateway Principale**
```typescript
// SurrealGateway.ts - Le "chef d'orchestre"
export class SurrealGateway {
  private client: SimpleSurrealClient;
  
  // Les services spécialisés
  public infrastructure: SurrealInfrastructureService;
  public realtime: SurrealRealtimeService;
  public ai: SurrealAIService;
  
  constructor(config: SurrealConfig) {
    // 1. Créer le client de base
    this.client = new SimpleSurrealClient(config);
    
    // 2. Injecter le MÊME client dans tous les services
    this.infrastructure = new SurrealInfrastructureService(this.client);
    this.realtime = new SurrealRealtimeService(this.client);
    this.ai = new SurrealAIService(this.client);
  }
}
```

### **Étape 2 : Le Service Infrastructure**
```typescript
// SurrealInfrastructureService.ts
export class SurrealInfrastructureService {
  // Il reçoit le client SurrealDB du gateway
  constructor(private client: SimpleSurrealClient) {}
  
  async getDomain(domain: string) {
    // Il utilise le client pour faire la requête
    return this.client.query(`
      RETURN fn::lws_domain_get($domain)
    `, { domain });
  }
}
```

### **Étape 3 : Le Client Simple**
```typescript
// SimpleSurrealClient.ts
export class SimpleSurrealClient {
  private db: Surreal; // Connexion SurrealDB
  
  constructor(private config: SurrealConfig) {
    this.db = new Surreal();
  }
  
  async query(sql: string, vars?: object) {
    // Ici on fait vraiment l'appel à SurrealDB
    return this.db.query(sql, vars);
  }
}
```

---

## 🔄 **Flux Complet : Que Se Passe-t-il ?**

### **1. Tu Appelles la Méthode**
```typescript
const domain = await surreal.infrastructure.getDomain('lyxal.com');
```

### **2. Ça Va Dans le Service Infrastructure**
```typescript
// Dans SurrealInfrastructureService
async getDomain(domain: string) {
  // "domain" = 'lyxal.com'
  return this.client.query(`
    RETURN fn::lws_domain_get($domain)
  `, { domain: 'lyxal.com' });
}
```

### **3. Le Service Appelle le Client Simple**
```typescript
// Dans SimpleSurrealClient  
async query(sql: string, vars?: object) {
  // sql = "RETURN fn::lws_domain_get($domain)"
  // vars = { domain: 'lyxal.com' }
  
  return this.db.query(sql, vars); // Vraie requête SurrealDB
}
```

### **4. SurrealDB Execute la Fonction**
```sql
-- Dans SurrealDB, ta fonction existante :
DEFINE FUNCTION fn::lws_domain_get($domain: string) {
    -- Récupère credentials
    LET $credentials = SELECT * FROM lws_credentials:master_ultimate LIMIT 1;
    LET $cred = $credentials[0];
    
    -- Appel HTTP vers LWS
    RETURN http::get("https://api.lws.net/v1/domain/" + $domain, {
        "headers": {
            "X-Auth-Login": $cred.auth_login,
            "X-Auth-Pass": $cred.auth_pass
        }
    });
};
```

### **5. Résultat Remonte**
```typescript
// Résultat remonte la chaîne :
SurrealDB → SimpleSurrealClient → SurrealInfrastructureService → Ton code

const domain = await surreal.infrastructure.getDomain('lyxal.com');
// domain = { domain: "lyxal.com", dns1: "ns9.lwsdns.com", ... }
```

---

## 🔗 **Schéma Visuel**

```
TON CODE
    ↓ appelle
surreal.infrastructure.getDomain('lyxal.com')
    ↓ délègue à
SurrealInfrastructureService.getDomain()
    ↓ utilise
SimpleSurrealClient.query("RETURN fn::lws_domain_get($domain)")
    ↓ exécute dans
SurrealDB Cloud
    ↓ appelle
fn::lws_domain_get() → API LWS
    ↓ retourne
Données du domaine
    ↑ remonte vers
TON CODE
```

---

## 💡 **Pourquoi C'est Génial ?**

### **🎯 Pour Toi (Simplicité)**
```typescript
// Tu écris juste ça :
const domain = await surreal.infrastructure.getDomain('lyxal.com');

// Au lieu de ça :
const client = new LyxalSurrealClient(config);
await client.initialize();
await client.use('master_ultimate', 'main');
const result = await client.query("RETURN fn::lws_domain_get($domain)", { domain: 'lyxal.com' });
const domain = result[0];
```

### **🔧 Pour la Maintenance**
Si tu veux changer la façon de récupérer un domaine, tu modifies **seulement** `SurrealInfrastructureService.getDomain()`.

Tous les endroits qui utilisent `surreal.infrastructure.getDomain()` continuent de fonctionner !

### **🧪 Pour les Tests**
```typescript
// Test facile à écrire
const mockClient = new MockSurrealClient();
const service = new SurrealInfrastructureService(mockClient);

const domain = await service.getDomain('test.com');
// Pas besoin de mocker toute la base SurrealDB !
```

---

## 🚀 **Exemple Complet d'Utilisation**

```typescript
// 1. Créer la gateway
const surreal = new SurrealGateway({
  url: 'wss://your-surrealdb.cloud/rpc',
  user: 'admin',
  pass: 'password',
  namespace: 'lyxal_platform',
  database: 'main'
});

// 2. Se connecter
await surreal.initialize();

// 3. Utiliser les services
const domain = await surreal.infrastructure.getDomain('lyxal.com');
console.log('Domain info:', domain);

// 4. Temps réel
surreal.realtime.watchDomainChanges('lyxal.com', (changes) => {
  console.log('Domain changed:', changes);
});

// 5. IA
const optimization = await surreal.ai.optimizeDomain('lyxal.com');
console.log('AI suggestions:', optimization);
```

---

## 📦 **Structure des Fichiers**

```
lyxal-surreal-v2/
├── SurrealGateway.ts           # Point d'entrée (chef d'orchestre)
├── SimpleSurrealClient.ts      # Client de base (connexion)
├── services/
│   ├── SurrealInfrastructureService.ts  # Service infrastructure
│   ├── SurrealRealtimeService.ts        # Service temps réel
│   └── SurrealAIService.ts              # Service IA
└── types.ts                    # Types partagés
```

---

## ✅ **En Résumé**

`surreal.infrastructure.getDomain('lyxal.com')` fonctionne grâce à :

1. **SurrealGateway** expose le service `infrastructure`
2. **SurrealInfrastructureService** a la méthode `getDomain()`
3. **SimpleSurrealClient** fait la vraie requête SurrealDB
4. **Tes fonctions SurrealDB existantes** (`fn::lws_domain_get`) font le travail
5. **Tout reste identique** côté SurrealDB !

C'est juste une **API plus propre** pour utiliser ce que tu as déjà ! 🎯

Est-ce que c'est plus clair maintenant ? 😊 