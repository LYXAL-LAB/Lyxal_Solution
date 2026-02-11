# 🏗️ Infrastructure - Lyxal

Gestion de toute l'infrastructure Bunny.net (Storage, CDN, Containers) via SurrealDB.

---

## 🎯 Vision

**Infrastructure as Data** : Toute la configuration de l'infrastructure Bunny est stockée et gérée dans SurrealDB.

### Avantages

✅ **Centralisé** : Une seule source de vérité pour toute l'infra  
✅ **Versionné** : Historique complet des changements  
✅ **Auditable** : Traçabilité totale (qui, quand, quoi)  
✅ **Automatisable** : Scripts/Workers lisent depuis SurrealDB  
✅ **Multi-tenant** : Gestion fine par namespace/tenant  
✅ **Synchronisé** : API Bunny ↔ SurrealDB bidirectionnel  

---

## 🗂️ Structure

```
infrastructure/
├── README.md                    (ce fichier)
├── database/
│   ├── bunny_storage.surql     (Storage zones & fichiers)
│   ├── bunny_cdn.surql         (CDN pull zones & cache)
│   ├── bunny_containers.surql  (Magic Containers apps)
│   ├── bunny_dns.surql         (DNS zones & records)
│   └── infrastructure_logs.surql (Audit logs)
├── functions/
│   ├── fn_bunny_storage_sync.surql
│   ├── fn_bunny_cdn_purge.surql
│   ├── fn_bunny_container_deploy.surql
│   └── fn_infrastructure_audit.surql
└── workers/
    ├── bunny-sync-worker/      (Go worker sync Bunny ↔ SurrealDB)
    └── infrastructure-monitor/ (Monitoring infrastructure)
```

---

## 📊 Tables Principales

### 1. **bunny_storage_zone**
Configuration des zones de storage Bunny

```
- Zone ID, nom, région
- API keys
- Replication settings
- Usage stats
```

### 2. **bunny_storage_file**
Tous les fichiers uploadés sur Bunny Storage

```
- Fichier path, URL, checksum
- Metadata (size, type, owner)
- CDN URL associée
- Lifecycle (expiration, archive)
```

### 3. **bunny_cdn_zone**
Configuration des Pull Zones CDN

```
- Pull zone ID, hostname
- Origin URL
- Cache rules
- Edge rules (firewall, geo-blocking)
```

### 4. **bunny_container**
Applications déployées sur Magic Containers

```
- Container ID, nom, image Docker
- Regions actives
- Resources (CPU/RAM)
- Environment variables
- Health status
```

### 5. **bunny_dns_zone**
Zones DNS gérées via Bunny DNS

```
- Domain, NS records
- A/AAAA/CNAME records
- TTL, routing
```

### 6. **infrastructure_log**
Audit log de tous les changements infrastructure

```
- Timestamp, user, action
- Resource type & ID
- Avant/après (diff)
- Status (success/failed)
```

---

## 🔄 Synchronisation

### Bunny API → SurrealDB (Import)

Worker Go qui :
1. Fetch toutes les ressources Bunny via API
2. Sync dans SurrealDB
3. Run toutes les 5 minutes

### SurrealDB → Bunny API (Export)

Fonctions SurrealDB qui :
1. Déclenchées sur INSERT/UPDATE
2. Appellent API Bunny
3. Créent/modifient les ressources

---

## 🎯 Use Cases

### 1. Provisioning Automatique

```sql
-- Créer un nouveau Storage Zone
INSERT INTO bunny_storage_zone {
  name: 'lyxal-production',
  region: 'EU',
  replication: true
};

-- → Trigger automatique appelle Bunny API
-- → Storage zone créé sur Bunny
-- → ID Bunny stocké dans SurrealDB
```

### 2. Multi-Tenant CDN

```sql
-- Chaque tenant a sa propre Pull Zone
SELECT * FROM bunny_cdn_zone 
WHERE tenant = tenant:acme_corp;

-- Auto-configuration du CDN par tenant
```

### 3. Monitoring Centralisé

```sql
-- Voir l'usage de tous les containers
SELECT 
  name,
  resources.cpu_usage,
  resources.ram_usage,
  cost_estimate
FROM bunny_container
WHERE status = 'running';
```

### 4. Audit Trail

```sql
-- Qui a déployé quoi et quand
SELECT * FROM infrastructure_log
WHERE action = 'container_deploy'
AND timestamp > time::now() - 7d
ORDER BY timestamp DESC;
```

---

## 💰 Cost Tracking

Chaque ressource stocke son coût estimé :

```sql
-- Coût total infrastructure
SELECT 
  math::sum(cost_estimate) AS total_cost
FROM [
  bunny_storage_zone,
  bunny_cdn_zone,
  bunny_container
];
```

---

## 🚀 Démarrage Rapide

### 1. Créer les Tables

```bash
# Exécuter tous les schémas
surreal import --conn http://localhost:8000 \
  --user root --pass root \
  --ns lyxal_infrastructure --db main \
  infrastructure/database/*.surql
```

### 2. Importer la Config Existante

```bash
# Lancer le sync worker (import Bunny → SurrealDB)
cd workers/bunny-sync-worker
go run main.go
```

### 3. Vérifier

```sql
-- Dans SurrealDB
SELECT * FROM bunny_storage_zone;
SELECT * FROM bunny_cdn_zone;
SELECT * FROM bunny_container;
```

---

## 📖 Documentation

1. **[database/](./database/)** - Schémas SurrealDB
2. **[functions/](./functions/)** - Fonctions SurrealDB
3. **[workers/](./workers/)** - Workers Go pour sync

---

## 🔗 Intégrations

- **Bunny.net API** : Sync bidirectionnel
- **Magic Containers** : Déploiement automatisé
- **Lyxal Central** : Dashboard infrastructure
- **Monitoring** : Prometheus metrics

---

**Infrastructure as Data : Gérez Bunny comme une base de données** 🏗️📊

