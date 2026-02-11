# 🔒 SSL AUTOMATION - Module Infrastructure

## 📋 **Vue d'ensemble**

Module technique pour la gestion automatisée des certificats SSL via Let's Encrypt dans l'architecture LyxalSuite multi-tenant.

**Référence architecturale :** `deployment/ARCHITECTURE-HEBERGEMENT-CNAME.md`

---

## 🔐 **SSL Automatique - Let's Encrypt**

### **Configuration SSL par Domaine**

```typescript
// Interface SSL Configuration
interface SSLConfig {
  domain: string;
  type: 'letsencrypt' | 'custom';
  auto_renew: boolean;
  status: 'active' | 'pending' | 'expired' | 'error';
  expires_at: Date;
  last_renewal: Date;
}

// Activation SSL automatique
const enableSSL = async (domain: string): Promise<SSLConfig> => {
  try {
    // 1. Vérification pré-requis
    await validateDomainReadiness(domain);
    
    // 2. Demande certificat Let's Encrypt
    const certificate = await requestLetsEncryptCertificate(domain);
    
    // 3. Installation certificat
    await installCertificate(domain, certificate);
    
    // 4. Configuration auto-renewal
    await setupAutoRenewal(domain);
    
    return {
      domain,
      type: 'letsencrypt',
      auto_renew: true,
      status: 'active',
      expires_at: certificate.expires_at,
      last_renewal: new Date()
    };
    
  } catch (error) {
    console.error(`Erreur SSL pour ${domain}:`, error);
    throw new Error(`Impossible d'activer SSL pour ${domain}`);
  }
};
```

---

## 🎫 **Let's Encrypt Integration**

### **Client ACME**

```typescript
// Configuration ACME
interface ACMEConfig {
  directoryUrl: string;
  accountEmail: string;
  challengeType: 'http-01' | 'dns-01';
}

const acmeConfig: ACMEConfig = {
  directoryUrl: 'https://acme-v02.api.letsencrypt.org/directory', // URL officielle Let's Encrypt
  accountEmail: process.env.ACME_EMAIL || 'admin@exemple.com',
  challengeType: 'http-01'
};

class LetsEncryptClient {
  private config: ACMEConfig;
  private account: any;
  
  constructor(config: ACMEConfig) {
    this.config = config;
  }
  
  async initialize() {
    // Initialisation compte ACME
    this.account = await this.createOrLoadAccount();
  }
  
  async requestCertificate(domain: string) {
    try {
      // 1. Créer ordre de certificat
      const order = await this.createOrder([domain, `www.${domain}`]);
      
      // 2. Résoudre challenges
      await this.completeChallenges(order.authorizations);
      
      // 3. Finaliser ordre
      const certificate = await this.finalizeCertificate(order);
      
      return {
        domain,
        certificate: certificate.cert,
        privateKey: certificate.key,
        expires_at: new Date(Date.now() + 90 * 24 * 60 * 60 * 1000) // 90 jours
      };
      
    } catch (error) {
      throw new Error(`Erreur Let's Encrypt: ${error.message}`);
    }
  }
  
  private async createOrder(domains: string[]) {
    // Implémentation création ordre ACME
  }
  
  private async completeChallenges(authorizations: any[]) {
    // Implémentation résolution challenges HTTP-01
    for (const auth of authorizations) {
      await this.completeHttpChallenge(auth);
    }
  }
  
  private async completeHttpChallenge(authorization: any) {
    // Configuration challenge HTTP-01 via LWS
    const challenge = authorization.challenges.find(
      (c: any) => c.type === 'http-01'
    );
    
    if (!challenge) {
      throw new Error('Challenge HTTP-01 non disponible');
    }
    
    // Création fichier de validation
    await this.createChallengeFile(
      authorization.identifier.value,
      challenge.token,
      challenge.keyAuthorization
    );
    
    // Validation challenge
    await this.validateChallenge(challenge);
  }
  
  private async createChallengeFile(domain: string, token: string, keyAuth: string) {
    // Utilisation API LWS pour créer fichier .well-known/acme-challenge/
    await lwsAPI.createFile({
      domain,
      path: `.well-known/acme-challenge/${token}`,
      content: keyAuth
    });
  }
}
```

---

## 🔄 **Auto-Renewal System**

### **Surveillance et Renouvellement**

```typescript
// Gestionnaire de renouvellement automatique
class SSLRenewalManager {
  private domains: Map<string, SSLConfig> = new Map();
  private renewalThreshold = 30; // Renouveler 30 jours avant expiration
  
  async startMonitoring() {
    // Vérification quotidienne
    setInterval(() => {
      this.checkExpirations();
    }, 24 * 60 * 60 * 1000); // 24h
    
    console.log('Surveillance SSL démarrée');
  }
  
  async checkExpirations() {
    console.log('Vérification expirations SSL...');
    
    for (const [domain, config] of this.domains) {
      const daysUntilExpiry = this.getDaysUntilExpiry(config.expires_at);
      
      if (daysUntilExpiry <= this.renewalThreshold) {
        console.log(`Renouvellement nécessaire pour ${domain} (expire dans ${daysUntilExpiry} jours)`);
        await this.renewCertificate(domain);
      }
    }
  }
  
  private getDaysUntilExpiry(expiryDate: Date): number {
    const now = new Date();
    const diff = expiryDate.getTime() - now.getTime();
    return Math.ceil(diff / (1000 * 60 * 60 * 24));
  }
  
  async renewCertificate(domain: string) {
    try {
      console.log(`Renouvellement SSL pour ${domain}...`);
      
      // 1. Demander nouveau certificat
      const newCertificate = await letsEncryptClient.requestCertificate(domain);
      
      // 2. Installer nouveau certificat
      await this.installCertificate(domain, newCertificate);
      
      // 3. Mettre à jour configuration
      const config = this.domains.get(domain);
      if (config) {
        config.expires_at = newCertificate.expires_at;
        config.last_renewal = new Date();
        config.status = 'active';
        this.domains.set(domain, config);
      }
      
      console.log(`✅ SSL renouvelé avec succès pour ${domain}`);
      
    } catch (error) {
      console.error(`❌ Erreur renouvellement SSL pour ${domain}:`, error);
      
      // Notification d'échec
      await this.notifyRenewalFailure(domain, error);
    }
  }
  
  private async installCertificate(domain: string, certificate: any) {
    // Installation via API LWS
    await lwsAPI.installSSLCertificate({
      domain,
      certificate: certificate.certificate,
      privateKey: certificate.privateKey,
      chainCertificate: certificate.chain
    });
  }
  
  private async notifyRenewalFailure(domain: string, error: Error) {
    // Système de notification (email, webhook, etc.)
    console.error(`Notification d'échec SSL pour ${domain}:`, error.message);
  }
  
  // Méthodes publiques
  addDomain(domain: string, config: SSLConfig) {
    this.domains.set(domain, config);
  }
  
  removeDomain(domain: string) {
    this.domains.delete(domain);
  }
  
  getStatus(domain: string): SSLConfig | undefined {
    return this.domains.get(domain);
  }
}

const sslRenewalManager = new SSLRenewalManager();
```

---

## 📊 **Monitoring SSL**

### **Vérification Status SSL**

```typescript
// Utilitaires de vérification SSL
const checkSSLStatus = async (domain: string): Promise<{
  isValid: boolean;
  expiresAt: Date;
  issuer: string;
  daysUntilExpiry: number;
}> => {
  try {
    // Vérification du certificat via connexion HTTPS
    const response = await fetch(`https://${domain}`, {
      method: 'HEAD',
      signal: AbortSignal.timeout(10000)
    });
    
    // Récupération infos certificat (nécessite une lib spécialisée)
    const certInfo = await getCertificateInfo(domain);
    
    const expiresAt = new Date(certInfo.validTo);
    const now = new Date();
    const daysUntilExpiry = Math.ceil((expiresAt.getTime() - now.getTime()) / (1000 * 60 * 60 * 24));
    
    return {
      isValid: response.ok && certInfo.valid,
      expiresAt,
      issuer: certInfo.issuer,
      daysUntilExpiry
    };
    
  } catch (error) {
    console.error(`Erreur vérification SSL pour ${domain}:`, error);
    return {
      isValid: false,
      expiresAt: new Date(),
      issuer: 'unknown',
      daysUntilExpiry: 0
    };
  }
};

// Fonction helper pour récupérer infos certificat
const getCertificateInfo = async (domain: string) => {
  // Implémentation avec une bibliothèque comme 'tls' ou 'https'
  const https = require('https');
  const { URL } = require('url');
  
  return new Promise((resolve, reject) => {
    const options = {
      hostname: domain,
      port: 443,
      method: 'GET',
      rejectUnauthorized: false
    };
    
    const req = https.request(options, (res: any) => {
      const cert = res.socket.getPeerCertificate();
      resolve({
        valid: res.socket.authorized,
        validTo: cert.valid_to,
        issuer: cert.issuer.CN,
        subject: cert.subject.CN
      });
    });
    
    req.on('error', reject);
    req.end();
  });
};
```

---

## 🚨 **Gestion des Erreurs SSL**

### **Récupération et Fallback**

```typescript
// Gestionnaire d'erreurs SSL
class SSLErrorHandler {
  async handleSSLError(domain: string, error: Error) {
    console.error(`Erreur SSL pour ${domain}:`, error.message);
    
    switch (error.message) {
      case 'CERTIFICATE_EXPIRED':
        await this.handleExpiredCertificate(domain);
        break;
        
      case 'DOMAIN_NOT_VALIDATED':
        await this.handleDomainValidation(domain);
        break;
        
      case 'RATE_LIMIT_EXCEEDED':
        await this.handleRateLimit(domain);
        break;
        
      default:
        await this.handleGenericError(domain, error);
    }
  }
  
  private async handleExpiredCertificate(domain: string) {
    console.log(`Tentative de renouvellement pour certificat expiré: ${domain}`);
    await sslRenewalManager.renewCertificate(domain);
  }
  
  private async handleDomainValidation(domain: string) {
    console.log(`Vérification DNS pour ${domain}...`);
    
    // Attendre propagation DNS
    await this.waitForDNSPropagation(domain);
    
    // Réessayer après délai
    setTimeout(() => {
      enableSSL(domain);
    }, 5 * 60 * 1000); // 5 minutes
  }
  
  private async handleRateLimit(domain: string) {
    console.log(`Rate limit atteint pour ${domain}, programmation retry...`);
    
    // Programmer retry avec backoff exponentiel
    const delay = Math.min(60 * 60 * 1000, Math.pow(2, this.getRetryCount(domain)) * 1000);
    
    setTimeout(() => {
      enableSSL(domain);
    }, delay);
  }
  
  private async waitForDNSPropagation(domain: string) {
    const maxAttempts = 10;
    const interval = 30000; // 30 secondes
    
    for (let i = 0; i < maxAttempts; i++) {
      const isResolved = await this.checkDNSResolution(domain);
      if (isResolved) {
        console.log(`DNS résolu pour ${domain}`);
        return;
      }
      
      console.log(`Attente propagation DNS pour ${domain} (${i + 1}/${maxAttempts})`);
      await new Promise(resolve => setTimeout(resolve, interval));
    }
    
    throw new Error(`Timeout propagation DNS pour ${domain}`);
  }
  
  private async checkDNSResolution(domain: string): Promise<boolean> {
    try {
      const response = await fetch(`https://dns.google/resolve?name=${domain}&type=CNAME`);
      const data = await response.json();
      
      return data.Answer?.some((record: any) => 
        record.type === 5 && record.data === 'app.lyxal.com.'
      ) || false;
    } catch {
      return false;
    }
  }
  
  private getRetryCount(domain: string): number {
    // Logique de comptage des tentatives
    return 1;
  }
  
  private async handleGenericError(domain: string, error: Error) {
    // Log et notification pour erreurs non gérées
    console.error(`Erreur SSL non gérée pour ${domain}:`, error);
  }
}

const sslErrorHandler = new SSLErrorHandler();
```

---

## 🔧 **Configuration et Initialisation**

### **Setup Module SSL**

```typescript
// Initialisation du module SSL
const initializeSSLModule = async () => {
  try {
    // 1. Initialiser client Let's Encrypt
    const letsEncryptClient = new LetsEncryptClient(acmeConfig);
    await letsEncryptClient.initialize();
    
    // 2. Démarrer surveillance renouvellement
    await sslRenewalManager.startMonitoring();
    
    // 3. Charger domaines existants
    await loadExistingDomains();
    
    console.log('✅ Module SSL initialisé avec succès');
    
  } catch (error) {
    console.error('❌ Erreur initialisation module SSL:', error);
    throw error;
  }
};

const loadExistingDomains = async () => {
  // Charger domaines depuis SurrealDB
  const domains = await surrealDB.query(`
    SELECT domain, ssl_config FROM site_configurations 
    WHERE ssl_config.status = 'active'
  `);
  
  domains[0]?.result?.forEach((site: any) => {
    sslRenewalManager.addDomain(site.domain, site.ssl_config);
  });
  
  console.log(`Chargé ${domains[0]?.result?.length || 0} domaines SSL`);
};

// Export des fonctions principales
export {
  enableSSL,
  checkSSLStatus,
  sslRenewalManager,
  sslErrorHandler,
  initializeSSLModule
};
```

---

## 📚 **Références**

### **Documentation Liée**
- `deployment/ARCHITECTURE-HEBERGEMENT-CNAME.md` - Vue architecturale
- `lyxal-infrastructure/domain-management.md` - Gestion domaines
- `lyxal-infrastructure/multi-tenant-frontend.md` - Frontend adaptatif
- `lyxal-infrastructure/monitoring-system.md` - Surveillance système

### **APIs Externes**
- [Let's Encrypt ACME](https://letsencrypt.org/docs/client-options/) - Protocole ACME
- [API Hébergeur](https://api.exemple-hebergeur.fr/docs) - Exemple gestion SSL

---

**Date de création :** Décembre 2024  
**Statut :** Module technique - Gestion SSL automatique  
**Version :** 1.0
