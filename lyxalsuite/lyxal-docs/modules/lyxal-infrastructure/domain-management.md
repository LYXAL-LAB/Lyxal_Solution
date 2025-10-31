# 🌐 DOMAIN MANAGEMENT - Module Infrastructure

## 📋 **Vue d'ensemble**

Module technique pour la gestion automatisée des domaines et configuration DNS dans l'architecture LyxalSuite.

**Référence architecturale :** `deployment/ARCHITECTURE-HEBERGEMENT-CNAME.md`

---

## 🔗 **API LWS - Gestion Domaines**

### **Processus de Création Nouveau SaaS**

```typescript
// Interface pour création SaaS
interface CreateSaaSRequest {
  name: string;
  domain: string;
  template: string;
}

interface SaaSResponse {
  domain: string;
  url: string;
  status: 'ready' | 'pending' | 'error';
  estimated_propagation?: string;
  ssl_status: 'active' | 'pending' | 'expired';
}

// Fonction principale de création
const createSaaS = async (data: CreateSaaSRequest): Promise<SaaSResponse> => {
  // 1. Vérification disponibilité domaine
  const domainAvailable = await checkDomainAvailability(data.domain);
  
  if (!domainAvailable) {
    throw new Error('Domaine non disponible');
  }
  
  // 2. Achat domaine via API LWS
  const domainPurchase = await lwsAPI.purchaseDomain({
    domain: data.domain,
    period: 1,
    auto_renew: true
  });
  
  // 3. Configuration DNS automatique
  const dnsConfig = await lwsAPI.configureDNS({
    domain: data.domain,
    records: [
      {
        type: 'CNAME',
        name: '@',
        content: 'app.lyxal.com',
        ttl: 3600
      },
      {
        type: 'CNAME',
        name: 'www',
        content: 'app.lyxal.com',
        ttl: 3600
      }
    ]
  });
  
  // 4. SSL automatique
  const sslConfig = await lwsAPI.enableSSL({
    domain: data.domain,
    type: 'letsencrypt',
    auto_renew: true
  });
  
  // 5. Configuration SurrealDB
  const siteConfig = await surrealDB.create('site_configurations', {
    domain: data.domain,
    namespace: generateNamespace(data.name),
    theme: data.template,
    status: 'active',
    created_at: new Date()
  });
  
  return {
    domain: data.domain,
    url: `https://${data.domain}`,
    status: 'ready',
    estimated_propagation: '2-10 minutes',
    ssl_status: 'active'
  };
};
```

---

## 🔍 **API LWS - Fonctions Utilitaires**

### **Vérification Disponibilité Domaine**

```typescript
const checkDomainAvailability = async (domain: string): Promise<boolean> => {
  try {
    const response = await lwsAPI.checkDomain({
      domain: domain
    });
    
    return response.available;
  } catch (error) {
    console.error('Erreur vérification domaine:', error);
    return false;
  }
};
```

### **Configuration DNS**

```typescript
interface DNSRecord {
  type: 'CNAME' | 'A' | 'AAAA' | 'TXT' | 'MX';
  name: string;
  content: string;
  ttl: number;
}

const configureDNS = async (domain: string, records: DNSRecord[]) => {
  try {
    const response = await lwsAPI.configureDNS({
      domain: domain,
      records: records
    });
    
    return {
      success: true,
      propagation_time: response.estimated_propagation,
      records_added: records.length
    };
  } catch (error) {
    throw new Error(`Erreur configuration DNS: ${error.message}`);
  }
};
```

### **Génération Namespace**

```typescript
const generateNamespace = (name: string): string => {
  return name
    .toLowerCase()
    .replace(/[^a-z0-9]/g, '_')
    .replace(/_{2,}/g, '_')
    .replace(/^_|_$/g, '');
};
```

---

## 🛠️ **Configuration Module**

### **Variables d'Environnement**

```typescript
interface LWSConfig {
  apiKey: string;
  apiSecret: string;
  baseUrl: string;
  timeout: number;
}

const lwsConfig: LWSConfig = {
  apiKey: process.env.LWS_API_KEY || '',
  apiSecret: process.env.LWS_API_SECRET || '',
  baseUrl: 'https://api.exemple-hebergeur.fr/v1', // Exemple API hébergeur
  timeout: 30000
};
```

### **Client API LWS**

```typescript
class LWSApiClient {
  private config: LWSConfig;
  
  constructor(config: LWSConfig) {
    this.config = config;
  }
  
  async purchaseDomain(params: any) {
    return this.request('POST', '/domains/purchase', params);
  }
  
  async configureDNS(params: any) {
    return this.request('POST', '/dns/configure', params);
  }
  
  async enableSSL(params: any) {
    return this.request('POST', '/ssl/enable', params);
  }
  
  private async request(method: string, endpoint: string, data?: any) {
    const response = await fetch(`${this.config.baseUrl}${endpoint}`, {
      method,
      headers: {
        'Authorization': `Bearer ${this.config.apiKey}`,
        'Content-Type': 'application/json'
      },
      body: data ? JSON.stringify(data) : undefined,
      signal: AbortSignal.timeout(this.config.timeout)
    });
    
    if (!response.ok) {
      throw new Error(`LWS API Error: ${response.statusText}`);
    }
    
    return response.json();
  }
}

const lwsAPI = new LWSApiClient(lwsConfig);
```

---

## 📚 **Références**

### **Documentation Liée**
- `deployment/ARCHITECTURE-HEBERGEMENT-CNAME.md` - Vue architecturale
- `lyxal-infrastructure/multi-tenant-frontend.md` - Frontend adaptatif
- `lyxal-infrastructure/ssl-automation.md` - Gestion SSL
- `lyxal-infrastructure/monitoring-system.md` - Surveillance système

---

## **🔄 GESTION SOUS-DOMAINES MULTIPLES**

### **Architecture Template vs Client**

Si votre template prévoit plusieurs sous-domaines :
```
Template:
├── exemple.com (landing)
├── app.exemple.com (application)
├── admin.exemple.com (administration)
└── api.exemple.com (API)
```

### **Configuration CNAME Optimale (Approche Mixte)**

```typescript
interface SubdomainConfig {
  clientDomain: string;
  template: {
    main: string;    // exemple.com
    app: string;     // app.exemple.com  
  };
}

const configureClientCNAME = async (clientDomain: string, masterUserId: string) => {
  // VÉRIFICATION CRITIQUE : Permissions MASTER ultimate
  await checkDomainPermissions(masterUserId);
  
  const dnsRecords = [
    // Domaine principal → landing template
    {
      type: 'CNAME',
      name: clientDomain,
      value: 'exemple.com',
      ttl: 300
    },
    // Wildcard → application template
    {
      type: 'CNAME', 
      name: `*.${clientDomain}`,
      value: 'app.exemple.com',
      ttl: 300
    }
  ];
  
  // Audit log pour traçabilité
  await logDomainOperation({
    action: 'CREATE_CNAME',
    domain: clientDomain,
    masterUserId,
    timestamp: new Date(),
    records: dnsRecords
  });
  
  return createDNSRecords(dnsRecords);
};
```

### **Routage par Sous-domaine**

```typescript
const detectSubdomainType = (host: string): SubdomainType => {
  const parts = host.split('.');
  
  if (parts.length < 2) return 'invalid';
  
  // Domaine principal (restaurant-bistro.com)
  if (parts.length === 2) {
    return 'landing';
  }
  
  // Sous-domaine (app.restaurant-bistro.com)
  const subdomain = parts[0];
  
  switch (subdomain) {
    case 'app': return 'application';
    case 'admin': return 'administration'; 
    case 'api': return 'api';
    default: return 'application'; // Par défaut
  }
};

const routeRequest = (request: Request) => {
  const host = request.headers.get('host') || '';
  const type = detectSubdomainType(host);
  
  switch (type) {
    case 'landing':
      return renderLandingPage(host);
      
    case 'application':
      return renderMainApp(host);
      
    case 'administration':
      return renderAdminPanel(host);
      
    case 'api':
      return handleApiRequest(request);
      
    default:
      return new Response('Not Found', { status: 404 });
  }
};
```

### **Avantages Architecture Mixte**

```
✅ SIMPLICITÉ DNS
├── 2 enregistrements CNAME seulement
├── Wildcard pour tous sous-domaines
└── Gestion automatique nouveaux sous-domaines

✅ FLEXIBILITÉ
├── Landing page dédiée sur domaine principal
├── Application sur sous-domaines
├── Routage intelligent côté serveur
└── SSL wildcard simple

✅ PERFORMANCE  
├── Routage optimal selon sous-domaine
├── Cache adapté par type de contenu
├── CDN configuration spécialisée
└── Monitoring granulaire
```

**Date de création :** Décembre 2024  
**Statut :** Module technique - Implémentation domain management  
**Version :** 1.0

## **🔒 RESTRICTIONS DE SÉCURITÉ**

### **⚠️ ACCÈS EXCLUSIF NIVEAU MASTER**

```typescript
interface MasterUltimatePermissions {
  level: 'MASTER';
  ultimate: true;
  permissions: {
    domain_management: true;
    cname_configuration: true;
    ssl_automation: true;
    dns_administration: true;
  };
}

// Vérification des permissions avant toute opération domaine
const checkDomainPermissions = async (userId: string): Promise<boolean> => {
  const user = await getUserLevel(userId);
  
  // RESTRICTION CRITIQUE : Seul MASTER avec ultimate=true
  if (user.level !== 'MASTER' || user.ultimate !== true) {
    throw new Error('ACCÈS REFUSÉ: Seul MASTER ultimate peut gérer les domaines');
  }
  
  return true;
};
```

### **🛡️ Pourquoi cette Restriction ?**

```
🎯 SÉCURITÉ MAXIMALE
├── Domaines = Infrastructure critique
├── Prévention abus massifs
├── Contrôle centralisé absolu
└── Responsabilité claire

⚡ CONTRÔLE TOTAL
├── Un seul point de décision
├── Audit complet des actions
├── Révocation possible globale
└── Gestion des quotas centralisée

🚨 PRÉVENTION RISQUES
├── Évite création domaines malveillants
├── Contrôle coûts hébergement
├── Gestion certificats SSL sécurisée
└── Monitoring centralisé
```

## **🔐 WORKFLOW SÉCURISÉ COMPLET**

### **Processus de Création Domaine (MASTER Ultimate Only)**

```typescript
interface DomainCreationRequest {
  clientDomain: string;
  masterUserId: string;
  templateConfig: {
    landingDomain: string;
    appDomain: string;
  };
}

const createSecureDomain = async (request: DomainCreationRequest) => {
  // 1. VÉRIFICATION PERMISSIONS CRITIQUES
  await checkDomainPermissions(request.masterUserId);
  
  // 2. VALIDATION DOMAINE
  const validation = await validateDomain(request.clientDomain);
  if (!validation.valid) {
    throw new Error(`Domaine invalide: ${validation.reason}`);
  }
  
  // 3. VÉRIFICATION QUOTAS MASTER
  const quotas = await getMasterQuotas(request.masterUserId);
  if (quotas.domainsUsed >= quotas.domainsLimit) {
    throw new Error('Quota domaines atteint pour ce MASTER');
  }
  
  // 4. CRÉATION SÉCURISÉE
  const result = await performSecureDomainCreation(request);
  
  // 5. AUDIT COMPLET
  await auditDomainCreation({
    masterUserId: request.masterUserId,
    domain: request.clientDomain,
    result,
    timestamp: new Date()
  });
  
  return result;
};
```

### **Vérifications de Sécurité Multicouches**

```typescript
const performSecureDomainCreation = async (request: DomainCreationRequest) => {
  try {
    // Layer 1: Permissions
    await checkDomainPermissions(request.masterUserId);
    
    // Layer 2: Quotas et limites
    await validateMasterLimits(request.masterUserId);
    
    // Layer 3: Domaine disponible
    await checkDomainAvailability(request.clientDomain);
    
    // Layer 4: Configuration DNS
    const dnsConfig = await configureCNAME(request);
    
    // Layer 5: SSL automatique
    const sslConfig = await setupSSL(request.clientDomain);
    
    // Layer 6: Monitoring
    await setupDomainMonitoring(request.clientDomain);
    
    return {
      success: true,
      domain: request.clientDomain,
      dns: dnsConfig,
      ssl: sslConfig,
      monitoring: true
    };
    
  } catch (error) {
    // Audit des échecs également
    await auditFailedDomainCreation({
      masterUserId: request.masterUserId,
      domain: request.clientDomain,
      error: error.message,
      timestamp: new Date()
    });
    
    throw error;
  }
};
```

### **🚨 Contrôles Anti-Abus**

```typescript
interface MasterDomainLimits {
  dailyDomainCreations: number;
  totalDomainsLimit: number;
  suspiciousPatternDetection: boolean;
  geolocationRestrictions?: string[];
}

const validateMasterLimits = async (masterUserId: string) => {
  const limits = await getMasterLimits(masterUserId);
  const today = new Date().toDateString();
  
  // Vérification créations quotidiennes
  const todayCreations = await countTodayDomainCreations(masterUserId, today);
  if (todayCreations >= limits.dailyDomainCreations) {
    throw new Error('Limite quotidienne de créations domaines atteinte');
  }
  
  // Détection patterns suspects
  if (limits.suspiciousPatternDetection) {
    const pattern = await analyzeDomainPattern(masterUserId);
    if (pattern.suspicious) {
      await notifySecurityTeam(masterUserId, pattern);
      throw new Error('Pattern suspect détecté - Création bloquée');
    }
  }
  
  return true;
};
```
