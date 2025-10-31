# 🏗️ Architecture - Bunny Magic Containers pour Lyxal

Architecture technique détaillée de l'utilisation de Magic Containers dans l'écosystème Lyxal.

---

## 🎯 Vue d'Ensemble

Magic Containers repose sur une architecture **edge-native** où les applications sont déployées au plus proche des utilisateurs sur **41+ régions globales**.

```
┌────────────────────────────────────────────────────────────────┐
│                    EDGE NETWORK (41+ Régions)                   │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐      │
│  │ Americas │  │  Europe  │  │   Asia   │  │ Oceania  │  ...  │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘      │
│       │             │              │             │             │
│  [Containers] [Containers]  [Containers]  [Containers]        │
└───────┬─────────────┬──────────────┬─────────────┬────────────┘
        │             │              │             │
        └─────────────┴──────────────┴─────────────┘
                      │ Anycast Routing
                      ↓
┌────────────────────────────────────────────────────────────────┐
│                     USERS (Global)                              │
│  • Requête routée vers la région la plus proche                │
│  • Latence minimale (<30ms pour 95% des users)                │
│  • Failover automatique si région down                         │
└────────────────────────────────────────────────────────────────┘
```

---

## 🔄 Flux de Déploiement Complet

### 1. Code → Build → Deploy

```
┌─────────────────────────────────────────────────────────────┐
│ ÉTAPE 1 : DÉVELOPPEMENT                                     │
│                                                              │
│  Developer                                                   │
│    ↓ git push                                               │
│  GitHub Repository                                           │
│    • Code source                                            │
│    • Dockerfile                                             │
│    • .github/workflows/deploy.yml                           │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ↓ Trigger GitHub Actions
┌─────────────────────────────────────────────────────────────┐
│ ÉTAPE 2 : CI/CD (GitHub Actions)                            │
│                                                              │
│  1. Checkout code                                           │
│  2. Run tests                                               │
│  3. Build Docker image                                      │
│  4. Push to Docker Hub / GHCR                              │
│  5. Deploy to Magic Containers (API call)                  │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ↓ Pull image
┌─────────────────────────────────────────────────────────────┐
│ ÉTAPE 3 : BUNNY MAGIC CONTAINERS                            │
│                                                              │
│  AI Provisioning Engine analyse :                           │
│    • Traffic patterns                                       │
│    • Latency requirements                                   │
│    • Cost optimization                                      │
│                                                              │
│  Décision de déploiement :                                  │
│    • Quelles régions activer                               │
│    • Combien de pods par région                            │
│    • Allocation CPU/RAM                                    │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ↓ Deploy containers
┌─────────────────────────────────────────────────────────────┐
│ ÉTAPE 4 : RUNNING CONTAINERS (Edge)                         │
│                                                              │
│  Region 1 (NY)    Region 2 (LON)   Region 3 (SG)          │
│    ├─ Pod 1          ├─ Pod 1         ├─ Pod 1            │
│    └─ Pod 2          └─ Pod 2         └─ Pod 2            │
│                                                              │
│  Health Monitoring :                                        │
│    • Check /health endpoint (30s)                          │
│    • Auto-restart if crash                                 │
│    • Alert if persistent failure                           │
└─────────────────────────────────────────────────────────────┘
```

---

## 🧠 AI Auto-Scaling Engine

### Comment Ça Fonctionne

Magic Containers utilise un **AI Provisioning Engine** qui :

1. **Analyse en temps réel** :
   - Géolocalisation des requêtes
   - Latence actuelle
   - Utilisation CPU/RAM
   - Patterns de traffic

2. **Optimise automatiquement** :
   - Ajoute des régions si latence >50ms
   - Réduit les régions si traffic faible
   - Scale verticalement (CPU/RAM) si besoin
   - Scale horizontalement (pods) si pic de traffic

3. **Minimise les coûts** :
   - Désactive les régions inutilisées
   - Ajuste CPU/RAM au minimum nécessaire
   - Prédit les pics et pré-scale

### Exemple Concret (Lyxal Mail)

```
État Initial :
  • 1 région active (Paris)
  • 1 pod
  • 0.5 vCPU, 256 MB RAM

Après 1 semaine avec trafic :
  • 3 régions actives (Paris, NY, Singapore)
  • Paris: 2 pods (traffic élevé France)
  • NY: 1 pod (traffic moyen US)
  • Singapore: 1 pod (traffic faible Asie)
  • Auto-ajusté : 0.3-0.8 vCPU selon charge

Résultat :
  • Latence moyenne : 18ms (vs 150ms avec 1 région)
  • Coût : $1.20/mois (vs $0.90/mois, +33% pour -88% latence)
```

---

## 🌐 Networking

### Architecture Réseau

```
┌────────────────────────────────────────────────────────────┐
│            USER REQUEST (https://api.lyxal.com)            │
└────────────────────┬───────────────────────────────────────┘
                     │
                     ↓ DNS Resolution
┌────────────────────────────────────────────────────────────┐
│              BUNNY DNS (Anycast)                            │
│  • Retourne l'IP de la région la plus proche              │
│  • Basé sur geolocation + latency                         │
└────────────────────┬───────────────────────────────────────┘
                     │
                     ↓ Route to nearest region
┌────────────────────────────────────────────────────────────┐
│         MAGIC CONTAINERS - REGION X                         │
│  ┌────────────────────────────────────────────────────┐    │
│  │ BUNNY CDN (Edge Cache)                             │    │
│  │  • Cache les réponses statiques                    │    │
│  │  • Réduit la charge sur containers                 │    │
│  └───────────────────┬────────────────────────────────┘    │
│                      │                                      │
│                      ↓ Si pas en cache                      │
│  ┌────────────────────────────────────────────────────┐    │
│  │ LOAD BALANCER                                      │    │
│  │  • Round-robin entre pods                          │    │
│  │  • Health check actif                              │    │
│  └───────────────────┬────────────────────────────────┘    │
│                      │                                      │
│          ┌───────────┴──────────┐                          │
│          ↓                      ↓                          │
│     ┌────────┐            ┌────────┐                       │
│     │ Pod 1  │            │ Pod 2  │                       │
│     │ (0.5 vCPU)          │ (0.5 vCPU)                     │
│     │ (256MB)             │ (256MB)                        │
│     └────────┘            └────────┘                       │
└────────────────────────────────────────────────────────────┘
```

### Anycast IP (Optionnel - $2/mois)

Pour les protocoles **TCP/UDP** (non-HTTP) :

```
┌────────────────────────────────────────────────────────────┐
│        ANYCAST IP (185.x.x.x)                               │
│  • Même IP globalement                                     │
│  • Routing automatique vers région proche                  │
│  • Parfait pour :                                          │
│    - Game servers                                          │
│    - VPN                                                   │
│    - DNS servers                                           │
│    - Custom protocols                                      │
└────────────────────┬───────────────────────────────────────┘
                     │
        ┌────────────┴─────────────┐
        ↓                          ↓
   Region 1 (NY)              Region 2 (LON)
   Port 3000                   Port 3000
```

---

## 🔐 Sécurité

### Couches de Sécurité

1. **DDoS Protection (Bunny Shield)**
   - Inclus automatiquement
   - Protection jusqu'à 100 Gbps
   - Mitigation automatique

2. **SSL/TLS Automatique**
   - Certificats Let's Encrypt auto-renouvelés
   - HTTPS par défaut
   - TLS 1.3

3. **Network Isolation**
   - Containers isolés par tenant
   - Private networking disponible (bientôt)
   - Firewall rules configurables

4. **Secrets Management**
   - Environment variables encryptées
   - Bientôt : Secret vault intégré
   - Rotation automatique (roadmap)

5. **IAM & Access Control**
   - API keys avec scopes
   - IP whitelisting
   - Audit logs complets

---

## 📊 Monitoring & Observability

### Built-in Monitoring

```
┌────────────────────────────────────────────────────────────┐
│              BUNNY DASHBOARD (Real-Time)                    │
│                                                              │
│  📊 Overview                                                │
│    • Total requests                                         │
│    • Average latency                                        │
│    • Error rate                                            │
│    • Active regions                                        │
│                                                              │
│  🌍 Regions                                                 │
│    Region        Pods   CPU Usage   RAM Usage   Requests   │
│    ─────────────────────────────────────────────────────   │
│    Paris         2      45%         60%         1.2K/min   │
│    New York      1      30%         40%         800/min    │
│    Singapore     1      20%         35%         400/min    │
│                                                              │
│  📋 Real-Time Logs                                          │
│    [2025-01-24 10:15:32] INFO: Email sent (id: 123)       │
│    [2025-01-24 10:15:35] INFO: Email sent (id: 124)       │
│    [2025-01-24 10:15:38] ERROR: SMTP timeout (id: 125)    │
│                                                              │
│  💚 Health Checks                                           │
│    • /health: ✅ OK (response: 20ms)                       │
│    • Last check: 15s ago                                   │
└────────────────────────────────────────────────────────────┘
```

### Alerting (Roadmap Q2 2025)

```javascript
// Configuration alertes (future)
{
  "alerts": [
    {
      "name": "High Error Rate",
      "condition": "error_rate > 5%",
      "channels": ["email", "slack", "webhook"]
    },
    {
      "name": "High Latency",
      "condition": "p95_latency > 500ms",
      "channels": ["email"]
    }
  ]
}
```

---

## 💾 Storage & Persistence

### Options de Storage

1. **Éphémère (Included)**
   - Storage local au container
   - Perdu lors du redéploiement
   - Gratuit, ultra-rapide (NVMe)
   - Parfait pour cache temporaire

2. **Bunny Storage (Recommandé)**
   - Object storage S3-compatible
   - Persistent, global
   - $0.005/GB/mois
   - Parfait pour assets, backups, logs

3. **SurrealDB Cloud (Database)**
   - Base de données managed
   - Highly available
   - Backup automatique
   - Parfait pour données business

4. **Persistent Volumes (Roadmap Q1 2025)**
   - Volumes attachés aux containers
   - Persistent entre redéploiements
   - Block storage haute performance

---

## 🚀 Performance

### Optimisations Automatiques

1. **Edge Caching**
   - Bunny CDN intégré
   - Cache les réponses HTTP
   - TTL configurable

2. **HTTP/3 & QUIC**
   - Protocole moderne
   - Meilleure performance mobile
   - Activé automatiquement

3. **Compression**
   - Gzip/Brotli automatique
   - Réduit bandwidth
   - Transparent pour l'app

4. **Connection Pooling**
   - Réutilisation des connexions
   - Réduit latence
   - Géré automatiquement

### Benchmarks (vs AWS Lambda)

**Test : Image Resizing (8 vCPU)**

| Metric | AWS Lambda | Magic Containers | Amélioration |
|--------|-----------|-----------------|-------------|
| **Cold Start** | 1.2s | N/A (always warm) | -100% |
| **Warm Latency** | 120ms | 80ms | -33% |
| **P95 Latency** | 180ms | 95ms | -47% |
| **Cost (1M req)** | $25 | $4 | -84% |

---

## 🔄 High Availability & Resilience

### Architecture HA

```
┌────────────────────────────────────────────────────────────┐
│                 GLOBAL LOAD BALANCER                        │
│  • Health check toutes les 30s                             │
│  • Failover automatique si région down                     │
└────────────────┬───────────────────────────────────────────┘
                 │
        ┌────────┴────────┐
        ↓                 ↓
   Region A           Region B
   (Primary)          (Backup)
   ├─ Pod 1           ├─ Pod 1
   └─ Pod 2           └─ Pod 2
```

### SLA

- **Uptime** : 99.9% garanti
- **Failover** : <30 secondes
- **Data Loss** : Zero (avec Bunny Storage)
- **Support** : 24/7 via email/chat

---

## 📈 Scaling Patterns

### Horizontal Scaling (Pods)

```
Low Traffic (0-100 req/min):
  • 1 pod par région
  • 0.2 vCPU, 128 MB RAM

Medium Traffic (100-1000 req/min):
  • 2-3 pods par région
  • 0.5 vCPU, 256 MB RAM

High Traffic (1000+ req/min):
  • 5-10 pods par région
  • 1.0 vCPU, 512 MB RAM
```

### Vertical Scaling (Resources)

```
Light Workload (API simple):
  • 0.1-0.3 vCPU
  • 128-256 MB RAM

Medium Workload (Image processing):
  • 0.5-1.0 vCPU
  • 512 MB - 1 GB RAM

Heavy Workload (PDF generation):
  • 1-2 vCPU
  • 1-2 GB RAM
```

---

## 🎯 Best Practices

### 1. Container Optimization

```dockerfile
# ✅ Bon : Multi-stage build
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .

FROM node:20-alpine
WORKDIR /app
COPY --from=builder /app .
CMD ["node", "index.js"]

# Image finale : 50 MB
```

### 2. Health Checks Robustes

```javascript
app.get('/health', async (req, res) => {
  // Vérifier les dépendances critiques
  const checks = {
    database: await checkDatabase(),
    smtp: await checkSMTP(),
    storage: await checkStorage()
  };
  
  const healthy = Object.values(checks).every(c => c);
  
  res.status(healthy ? 200 : 503).json({
    status: healthy ? 'ok' : 'degraded',
    checks
  });
});
```

### 3. Graceful Shutdown

```javascript
let isShuttingDown = false;

process.on('SIGTERM', async () => {
  isShuttingDown = true;
  console.log('Shutting down gracefully...');
  
  // Stop accepting new requests
  server.close(async () => {
    // Finish pending requests
    await finishPendingJobs();
    
    // Close connections
    await closeDatabase();
    await closeSMTP();
    
    console.log('Shutdown complete');
    process.exit(0);
  });
  
  // Force shutdown after 30s
  setTimeout(() => {
    console.error('Forced shutdown');
    process.exit(1);
  }, 30000);
});
```

### 4. Structured Logging

```javascript
const logger = {
  info: (message, meta = {}) => {
    console.log(JSON.stringify({
      level: 'info',
      timestamp: new Date().toISOString(),
      message,
      ...meta
    }));
  },
  error: (message, error, meta = {}) => {
    console.error(JSON.stringify({
      level: 'error',
      timestamp: new Date().toISOString(),
      message,
      error: {
        message: error.message,
        stack: error.stack
      },
      ...meta
    }));
  }
};
```

---

## 🔗 Intégrations

### SurrealDB Cloud

```javascript
// Connexion optimisée
const db = new Surreal();
await db.connect('wss://cloud.surrealdb.com:443/rpc', {
  // Pool de connexions
  poolSize: 10,
  // Reconnect automatique
  reconnect: true,
  // Timeout
  timeout: 5000
});
```

### Bunny Storage

```javascript
// Upload vers Bunny Storage
const uploadFile = async (file, path) => {
  const response = await fetch(
    `https://storage.bunnycdn.com/${ZONE}/${path}`,
    {
      method: 'PUT',
      headers: {
        'AccessKey': process.env.BUNNY_API_KEY,
        'Content-Type': file.type
      },
      body: file.buffer
    }
  );
  
  return response.ok;
};
```

---

## 📊 Architecture Comparison

### Magic Containers vs Traditional Cloud

```
Traditional Cloud (AWS/GCP):
  ├─ Load Balancer ($20/mois)
  ├─ Auto Scaling Group (config complexe)
  ├─ CloudWatch Logs ($10/mois)
  ├─ SSL Certificate (gratuit mais config)
  ├─ CDN ($30/mois)
  └─ EC2 Instances ($80-200/mois)
  
  Total: $140-260/mois + DevOps time

Magic Containers:
  ├─ Container déploiement (1 click)
  ├─ Auto-scaling (AI automatique)
  ├─ Logs (intégrés, gratuits)
  ├─ SSL (automatique, gratuit)
  ├─ CDN (intégré, gratuit)
  └─ Compute ($1-10/mois selon usage)
  
  Total: $1-10/mois + 0 DevOps time
```

**Économie : 90-95% + Simplicité maximale** 🎉

---

## 🚀 Prochaines Étapes

1. **[USE_CASES.md](./USE_CASES.md)** → Voir tous les cas d'usage Lyxal
2. **[DEPLOYMENT.md](./DEPLOYMENT.md)** → Guide de déploiement pratique
3. **[PRICING.md](./PRICING.md)** → Calcul détaillé des coûts

---

**Magic Containers : L'Edge Computing Simplifié** 🎩✨

