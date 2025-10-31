# 📊 MONITORING SYSTEM - Module Infrastructure

## 📋 **Vue d'ensemble**

Module technique pour la surveillance automatisée des domaines, DNS, SSL et disponibilité dans l'architecture LyxalSuite multi-tenant.

**Référence architecturale :** `deployment/ARCHITECTURE-HEBERGEMENT-CNAME.md`

---

## 🔍 **Surveillance DNS et SSL**

### **Monitoring Principal**

```typescript
interface MonitoringResult {
  dns: 'propagated' | 'pending' | 'error';
  ssl: 'active' | 'pending' | 'expired';
  accessibility: 'online' | 'offline' | 'error';
  performance: {
    response_time: number;
    uptime_percentage: number;
  };
  last_check: Date;
}

// Fonction principale de monitoring
const monitorSaaS = async (domain: string): Promise<MonitoringResult> => {
  const startTime = Date.now();
  
  try {
    // Exécution parallèle des vérifications
    const [dnsStatus, sslStatus, accessibilityStatus] = await Promise.all([
      checkDNSPropagation(domain),
      checkSSLCertificate(domain),
      checkSiteAccessibility(`https://${domain}`)
    ]);
    
    const responseTime = Date.now() - startTime;
    const uptimePercentage = await calculateUptime(domain);
    
    return {
      dns: dnsStatus.status,
      ssl: sslStatus.status,
      accessibility: accessibilityStatus.status,
      performance: {
        response_time: responseTime,
        uptime_percentage: uptimePercentage
      },
      last_check: new Date()
    };
    
  } catch (error) {
    console.error(`Erreur monitoring ${domain}:`, error);
    return {
      dns: 'error',
      ssl: 'error',
      accessibility: 'error',
      performance: {
        response_time: -1,
        uptime_percentage: 0
      },
      last_check: new Date()
    };
  }
};
```

---

## 🌐 **Surveillance DNS**

### **Vérification Propagation DNS**

```typescript
const checkDNSPropagation = async (domain: string) => {
  try {
    // Vérification via DNS Google
    const response = await fetch(`https://dns.google/resolve?name=${domain}&type=CNAME`, {
      signal: AbortSignal.timeout(5000)
    });
    
    const data = await response.json();
    
    // Vérifier si CNAME pointe vers app.lyxal.com
    const hasCNAME = data.Answer?.some((record: any) => 
      record.type === 5 && record.data === 'app.lyxal.com.'
    );
    
    // Vérification additionnelle via d'autres DNS
    const cloudflareCheck = await checkDNSCloudflare(domain);
    const opendnsCheck = await checkDNSOpenDNS(domain);
    
    const propagationScore = [hasCNAME, cloudflareCheck, opendnsCheck]
      .filter(Boolean).length;
    
    return {
      status: propagationScore >= 2 ? 'propagated' : 'pending',
      propagation_score: propagationScore,
      details: {
        google_dns: hasCNAME,
        cloudflare_dns: cloudflareCheck,
        opendns: opendnsCheck
      }
    };
    
  } catch (error) {
    console.error(`Erreur vérification DNS pour ${domain}:`, error);
    return { status: 'error', propagation_score: 0 };
  }
};

const checkDNSCloudflare = async (domain: string): Promise<boolean> => {
  try {
    const response = await fetch(`https://cloudflare-dns.com/dns-query?name=${domain}&type=CNAME`, {
      headers: { 'Accept': 'application/dns-json' },
      signal: AbortSignal.timeout(3000)
    });
    
    const data = await response.json();
    return data.Answer?.some((record: any) => 
      record.type === 5 && record.data === 'app.lyxal.com.'
    ) || false;
  } catch {
    return false;
  }
};

const checkDNSOpenDNS = async (domain: string): Promise<boolean> => {
  try {
    // Vérification via OpenDNS ou autre service
    // Implémentation similaire
    return true; // Placeholder
  } catch {
    return false;
  }
};
```

---

## 🔒 **Surveillance SSL**

### **Vérification Certificats**

```typescript
const checkSSLCertificate = async (domain: string) => {
  try {
    // Test connexion HTTPS
    const response = await fetch(`https://${domain}`, { 
      method: 'HEAD',
      signal: AbortSignal.timeout(10000)
    });
    
    if (!response.ok) {
      return { status: 'error' };
    }
    
    // Récupération infos certificat
    const certInfo = await getCertificateDetails(domain);
    
    if (!certInfo) {
      return { status: 'error' };
    }
    
    const expiresAt = new Date(certInfo.validTo);
    const now = new Date();
    const daysUntilExpiry = Math.ceil((expiresAt.getTime() - now.getTime()) / (1000 * 60 * 60 * 24));
    
    let status: 'active' | 'pending' | 'expired';
    
    if (daysUntilExpiry <= 0) {
      status = 'expired';
    } else if (daysUntilExpiry <= 30) {
      status = 'pending'; // Renouvellement bientôt nécessaire
    } else {
      status = 'active';
    }
    
    return {
      status,
      expires_at: expiresAt,
      days_until_expiry: daysUntilExpiry,
      issuer: certInfo.issuer,
      is_letsencrypt: certInfo.issuer.includes('Let\'s Encrypt')
    };
    
  } catch (error) {
    console.error(`Erreur vérification SSL pour ${domain}:`, error);
    return { status: 'error' };
  }
};

const getCertificateDetails = async (domain: string) => {
  // Utilisation de bibliothèque spécialisée pour récupérer infos certificat
  const https = require('https');
  
  return new Promise((resolve, reject) => {
    const options = {
      hostname: domain,
      port: 443,
      method: 'GET',
      rejectUnauthorized: false,
      timeout: 5000
    };
    
    const req = https.request(options, (res: any) => {
      const cert = res.socket.getPeerCertificate();
      
      if (cert && Object.keys(cert).length > 0) {
        resolve({
          validTo: cert.valid_to,
          validFrom: cert.valid_from,
          issuer: cert.issuer.CN || cert.issuer.O,
          subject: cert.subject.CN
        });
      } else {
        resolve(null);
      }
    });
    
    req.on('error', () => resolve(null));
    req.on('timeout', () => {
      req.destroy();
      resolve(null);
    });
    
    req.end();
  });
};
```

---

## 🌍 **Surveillance Accessibilité**

### **Tests de Disponibilité**

```typescript
const checkSiteAccessibility = async (url: string) => {
  try {
    const startTime = Date.now();
    
    const response = await fetch(url, {
      method: 'GET',
      signal: AbortSignal.timeout(15000),
      headers: {
        'User-Agent': 'LyxalSuite-Monitor/1.0'
      }
    });
    
    const responseTime = Date.now() - startTime;
    
    return {
      status: response.ok ? 'online' : 'offline',
      response_code: response.status,
      response_time: responseTime,
      content_type: response.headers.get('content-type'),
      server: response.headers.get('server')
    };
    
  } catch (error) {
    console.error(`Erreur accessibilité pour ${url}:`, error);
    
    return {
      status: 'error',
      response_code: 0,
      response_time: -1,
      error_message: error.message
    };
  }
};

// Surveillance depuis plusieurs locations
const checkAccessibilityMultiLocation = async (domain: string) => {
  const locations = [
    { name: 'France', endpoint: 'https://fr.monitor.exemple.com' },
    { name: 'USA', endpoint: 'https://us.monitor.exemple.com' },
    { name: 'Asia', endpoint: 'https://asia.monitor.exemple.com' }
  ];
  
  const results = await Promise.allSettled(
    locations.map(async (location) => {
      try {
        const response = await fetch(`${location.endpoint}/check?domain=${domain}`, {
          signal: AbortSignal.timeout(10000)
        });
        
        const data = await response.json();
        return { ...data, location: location.name };
      } catch (error) {
        return { 
          status: 'error', 
          location: location.name, 
          error: error.message 
        };
      }
    })
  );
  
  return results.map((result, index) => ({
    location: locations[index].name,
    result: result.status === 'fulfilled' ? result.value : { status: 'error' }
  }));
};
```

---

## 📈 **Système de Métriques**

### **Calcul Performance et Uptime**

```typescript
class MetricsCalculator {
  private metricsStorage: Map<string, any[]> = new Map();
  
  async recordMetric(domain: string, metric: MonitoringResult) {
    const metrics = this.metricsStorage.get(domain) || [];
    
    // Garder seulement les 1440 dernières mesures (24h avec mesure/minute)
    if (metrics.length >= 1440) {
      metrics.shift();
    }
    
    metrics.push({
      timestamp: metric.last_check,
      dns_status: metric.dns,
      ssl_status: metric.ssl,
      accessibility: metric.accessibility,
      response_time: metric.performance.response_time
    });
    
    this.metricsStorage.set(domain, metrics);
    
    // Persist en base de données
    await this.persistMetrics(domain, metric);
  }
  
  async calculateUptime(domain: string, periodHours: number = 24): Promise<number> {
    const metrics = this.metricsStorage.get(domain) || [];
    
    if (metrics.length === 0) return 100;
    
    const cutoffTime = new Date(Date.now() - periodHours * 60 * 60 * 1000);
    const recentMetrics = metrics.filter(m => new Date(m.timestamp) >= cutoffTime);
    
    if (recentMetrics.length === 0) return 100;
    
    const uptime = recentMetrics.filter(m => 
      m.accessibility === 'online' && 
      m.dns_status === 'propagated' && 
      m.ssl_status === 'active'
    ).length;
    
    return (uptime / recentMetrics.length) * 100;
  }
  
  async getAverageResponseTime(domain: string, periodHours: number = 24): Promise<number> {
    const metrics = this.metricsStorage.get(domain) || [];
    const cutoffTime = new Date(Date.now() - periodHours * 60 * 60 * 1000);
    
    const recentMetrics = metrics
      .filter(m => new Date(m.timestamp) >= cutoffTime)
      .filter(m => m.response_time > 0);
    
    if (recentMetrics.length === 0) return 0;
    
    const totalResponseTime = recentMetrics.reduce((sum, m) => sum + m.response_time, 0);
    return totalResponseTime / recentMetrics.length;
  }
  
  private async persistMetrics(domain: string, metric: MonitoringResult) {
    try {
      await surrealDB.create('monitoring_metrics', {
        domain,
        timestamp: metric.last_check,
        dns_status: metric.dns,
        ssl_status: metric.ssl,
        accessibility: metric.accessibility,
        response_time: metric.performance.response_time,
        uptime_percentage: metric.performance.uptime_percentage
      });
    } catch (error) {
      console.error(`Erreur persistence métriques pour ${domain}:`, error);
    }
  }
}

const metricsCalculator = new MetricsCalculator();
```

---

## 🚨 **Système d'Alertes**

### **Notifications et Alertes**

```typescript
interface AlertConfig {
  domain: string;
  thresholds: {
    uptime_min: number;
    response_time_max: number;
    ssl_expiry_days: number;
  };
  notifications: {
    email: string[];
    webhook?: string;
    slack?: string;
  };
}

class AlertManager {
  private alertConfigs: Map<string, AlertConfig> = new Map();
  private lastAlerts: Map<string, Date> = new Map();
  private cooldownPeriod = 30 * 60 * 1000; // 30 minutes
  
  async checkAlerts(domain: string, metric: MonitoringResult) {
    const config = this.alertConfigs.get(domain);
    if (!config) return;
    
    const alerts: string[] = [];
    
    // Vérification uptime
    if (metric.performance.uptime_percentage < config.thresholds.uptime_min) {
      alerts.push(`Uptime faible: ${metric.performance.uptime_percentage.toFixed(2)}% (seuil: ${config.thresholds.uptime_min}%)`);
    }
    
    // Vérification temps de réponse
    if (metric.performance.response_time > config.thresholds.response_time_max) {
      alerts.push(`Temps de réponse élevé: ${metric.performance.response_time}ms (seuil: ${config.thresholds.response_time_max}ms)`);
    }
    
    // Vérification SSL
    if (metric.ssl === 'expired') {
      alerts.push('Certificat SSL expiré !');
    } else if (metric.ssl === 'pending') {
      alerts.push(`Certificat SSL expire bientôt (dans ${config.thresholds.ssl_expiry_days} jours)`);
    }
    
    // Vérification DNS
    if (metric.dns === 'error') {
      alerts.push('Erreur de résolution DNS');
    } else if (metric.dns === 'pending') {
      alerts.push('Propagation DNS en cours');
    }
    
    // Vérification accessibilité
    if (metric.accessibility === 'offline') {
      alerts.push('Site inaccessible');
    } else if (metric.accessibility === 'error') {
      alerts.push('Erreur d\'accessibilité');
    }
    
    // Envoi des alertes si nécessaire
    if (alerts.length > 0) {
      await this.sendAlerts(domain, alerts, config);
    }
  }
  
  private async sendAlerts(domain: string, alerts: string[], config: AlertConfig) {
    const lastAlert = this.lastAlerts.get(domain);
    const now = new Date();
    
    // Respecter la période de cooldown
    if (lastAlert && (now.getTime() - lastAlert.getTime()) < this.cooldownPeriod) {
      return;
    }
    
    const alertMessage = `🚨 Alertes pour ${domain}:\n${alerts.map(a => `• ${a}`).join('\n')}`;
    
    try {
      // Email
      if (config.notifications.email.length > 0) {
        await this.sendEmailAlert(config.notifications.email, domain, alertMessage);
      }
      
      // Webhook
      if (config.notifications.webhook) {
        await this.sendWebhookAlert(config.notifications.webhook, domain, alertMessage);
      }
      
      // Slack
      if (config.notifications.slack) {
        await this.sendSlackAlert(config.notifications.slack, domain, alertMessage);
      }
      
      this.lastAlerts.set(domain, now);
      console.log(`Alertes envoyées pour ${domain}`);
      
    } catch (error) {
      console.error(`Erreur envoi alertes pour ${domain}:`, error);
    }
  }
  
  private async sendEmailAlert(emails: string[], domain: string, message: string) {
    // Implémentation envoi email
    console.log(`Email alert to ${emails.join(', ')} for ${domain}: ${message}`);
  }
  
  private async sendWebhookAlert(webhook: string, domain: string, message: string) {
    await fetch(webhook, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ domain, message, timestamp: new Date() })
    });
  }
  
  private async sendSlackAlert(slackUrl: string, domain: string, message: string) {
    await fetch(slackUrl, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ text: message })
    });
  }
  
  addAlertConfig(domain: string, config: AlertConfig) {
    this.alertConfigs.set(domain, config);
  }
}

const alertManager = new AlertManager();
```

---

## 🔄 **Orchestrateur Principal**

### **Surveillance Continue**

```typescript
class MonitoringOrchestrator {
  private domains: Set<string> = new Set();
  private isRunning = false;
  private intervalId?: NodeJS.Timeout;
  
  async start(intervalMinutes: number = 5) {
    if (this.isRunning) {
      console.log('Monitoring déjà en cours');
      return;
    }
    
    this.isRunning = true;
    console.log(`Démarrage monitoring toutes les ${intervalMinutes} minutes`);
    
    // Première exécution immédiate
    await this.runMonitoringCycle();
    
    // Programmation récurrente
    this.intervalId = setInterval(async () => {
      await this.runMonitoringCycle();
    }, intervalMinutes * 60 * 1000);
  }
  
  stop() {
    if (this.intervalId) {
      clearInterval(this.intervalId);
      this.intervalId = undefined;
    }
    
    this.isRunning = false;
    console.log('Monitoring arrêté');
  }
  
  addDomain(domain: string) {
    this.domains.add(domain);
    console.log(`Domaine ajouté au monitoring: ${domain}`);
  }
  
  removeDomain(domain: string) {
    this.domains.delete(domain);
    console.log(`Domaine retiré du monitoring: ${domain}`);
  }
  
  private async runMonitoringCycle() {
    console.log(`Cycle de monitoring: ${this.domains.size} domaines`);
    
    const promises = Array.from(this.domains).map(async (domain) => {
      try {
        // Monitoring principal
        const result = await monitorSaaS(domain);
        
        // Enregistrement métriques
        await metricsCalculator.recordMetric(domain, result);
        
        // Vérification alertes
        await alertManager.checkAlerts(domain, result);
        
        return { domain, success: true, result };
        
      } catch (error) {
        console.error(`Erreur monitoring ${domain}:`, error);
        return { domain, success: false, error: error.message };
      }
    });
    
    const results = await Promise.allSettled(promises);
    
    const successful = results.filter(r => r.status === 'fulfilled').length;
    const failed = results.length - successful;
    
    console.log(`Cycle terminé: ${successful} succès, ${failed} échecs`);
  }
}

const monitoringOrchestrator = new MonitoringOrchestrator();

// Export des fonctions principales
export {
  monitorSaaS,
  checkDNSPropagation,
  checkSSLCertificate,
  checkSiteAccessibility,
  metricsCalculator,
  alertManager,
  monitoringOrchestrator
};
```

---

## 📚 **Références**

### **Documentation Liée**
- `deployment/ARCHITECTURE-HEBERGEMENT-CNAME.md` - Vue architecturale
- `lyxal-infrastructure/domain-management.md` - Gestion domaines
- `lyxal-infrastructure/multi-tenant-frontend.md` - Frontend adaptatif  
- `lyxal-infrastructure/ssl-automation.md` - Gestion SSL

---

**Date de création :** Décembre 2024  
**Statut :** Module technique - Surveillance système  
**Version :** 1.0
