# 🚀 Stratégie de Monitoring Native SurrealDB - LyxalSuite

*Architecture de monitoring bicéphale alignée sur ARCHITECTURE-REFERENCE.md*

---

## 📋 **Contexte et Alignement Architectural**

### **Référence Architecturale**
- ✅ Utilise `INVESTOR_LEVEL` et `DEVELOPER_LEVEL` de `ARCHITECTURE-REFERENCE.md`
- ✅ Suit les patterns standardisés LyxalSuite
- ✅ Use cases définis dans la référence principale

### **Situation Actuelle**
- ✅ Interfaces de monitoring créées dans `lyxalkitui`
- ✅ Hooks et services backend implémentés dans `lyxal-surreal`
- ❌ Données simulées avec `Math.random()` au lieu de vraies métriques
- ❌ Pas de tables de monitoring définies dans les schémas `.surql`

### **Objectifs**
1. **Monitoring temps réel** des performances SurrealDB
2. **Architecture multi-tenant** (SaaS/Workspace)
3. **Exploitation native** des capacités SurrealDB
4. **Intelligence artificielle** pour prédictions et alertes
5. **Scalabilité** pour l'écosystème LyxalSuite

---

## 🏗️ **Architecture Bicéphale de Monitoring**

### **INVESTOR_LEVEL (Niveau 1 - Global)**
```sql
-- Namespace: catalog
-- Scope: Monitoring global de tous les SaaS
NAMESPACE catalog
    DATABASE monitoring
        TABLE global_system_metrics     -- Métriques système globales
        TABLE global_saas_health        -- Santé de tous les SaaS
        TABLE global_performance_trends -- Tendances performance
        TABLE global_alerts             -- Alertes système globales
        TABLE cross_saas_analytics      -- Analytics cross-SaaS
```

**Use Cases INVESTOR_LEVEL :**
- `global_platform_health` - Santé globale de la plateforme
- `cross_saas_performance` - Performance comparative des SaaS
- `platform_resource_usage` - Utilisation des ressources globales
- `global_error_tracking` - Suivi des erreurs sur tous les SaaS

### **DEVELOPER_LEVEL (Niveau 2 - SaaS)**
```sql
-- Namespace: {saas_id} (ex: acme-corp)
-- Scope: Monitoring d'un SaaS spécifique
NAMESPACE acme_corp
    DATABASE monitoring
        TABLE saas_system_metrics       -- Métriques système SaaS
        TABLE saas_query_metrics        -- Métriques requêtes SaaS
        TABLE saas_performance_analytics -- Analytics performance SaaS
        TABLE saas_alerts               -- Alertes SaaS
    DATABASE workspace_prod
        TABLE workspace_metrics         -- Métriques workspace
        TABLE workspace_queries         -- Requêtes workspace
```

**Use Cases DEVELOPER_LEVEL :**
- `saas_performance_monitoring` - Monitoring performance SaaS
- `business_analytics` - Analytics business spécifiques
- `saas_user_management` - Gestion utilisateurs SaaS
- `operational_reporting` - Rapports opérationnels

---

## 📊 **Structures de Tables par Niveau**

### **INVESTOR_LEVEL - Tables Globales**

#### **1. Global System Metrics**
```sql
-- Namespace: catalog, Database: monitoring
DEFINE TABLE global_system_metrics SCHEMAFULL
    COMMENT "Métriques système globales tous SaaS"
    PERMISSIONS
        FOR select WHERE $auth.level = 'platform_admin'
        FOR create WHERE $auth.level = 'system'
        FOR update, delete WHERE $auth.level = 'platform_admin';

DEFINE FIELD timestamp ON global_system_metrics TYPE datetime DEFAULT time::now();
DEFINE FIELD total_saas_count ON global_system_metrics TYPE int;
DEFINE FIELD total_active_connections ON global_system_metrics TYPE int;
DEFINE FIELD total_queries_per_second ON global_system_metrics TYPE float;
DEFINE FIELD global_cpu_usage ON global_system_metrics TYPE float;
DEFINE FIELD global_memory_usage ON global_system_metrics TYPE float;
DEFINE FIELD global_disk_usage ON global_system_metrics TYPE float;
DEFINE FIELD total_storage_used ON global_system_metrics TYPE float;
DEFINE FIELD global_cache_hit_ratio ON global_system_metrics TYPE float;
DEFINE FIELD platform_health_score ON global_system_metrics TYPE float;
```

#### **2. Global SaaS Health**
```sql
DEFINE TABLE global_saas_health SCHEMAFULL
    COMMENT "Santé individuelle de chaque SaaS"
    PERMISSIONS
        FOR select WHERE $auth.level = 'platform_admin'
        FOR create WHERE $auth.level = 'system';

DEFINE FIELD timestamp ON global_saas_health TYPE datetime DEFAULT time::now();
DEFINE FIELD saas_namespace ON global_saas_health TYPE string;
DEFINE FIELD saas_name ON global_saas_health TYPE string;
DEFINE FIELD health_score ON global_saas_health TYPE float;
DEFINE FIELD active_users ON global_saas_health TYPE int;
DEFINE FIELD total_workspaces ON global_saas_health TYPE int;
DEFINE FIELD queries_per_minute ON global_saas_health TYPE float;
DEFINE FIELD avg_response_time ON global_saas_health TYPE float;
DEFINE FIELD error_rate ON global_saas_health TYPE float;
DEFINE FIELD storage_usage ON global_saas_health TYPE float;
DEFINE FIELD last_activity ON global_saas_health TYPE datetime;
```

#### **3. Cross-SaaS Analytics**
```sql
DEFINE TABLE cross_saas_analytics SCHEMAFULL
    COMMENT "Analytics comparatives entre SaaS"
    PERMISSIONS
        FOR select WHERE $auth.level = 'platform_admin'
        FOR create WHERE $auth.level = 'system';

DEFINE FIELD analysis_period ON cross_saas_analytics TYPE string; -- 'hourly', 'daily', 'weekly'
DEFINE FIELD period_start ON cross_saas_analytics TYPE datetime;
DEFINE FIELD period_end ON cross_saas_analytics TYPE datetime;
DEFINE FIELD top_performing_saas ON cross_saas_analytics TYPE array;
DEFINE FIELD resource_usage_ranking ON cross_saas_analytics TYPE array;
DEFINE FIELD growth_trends ON cross_saas_analytics TYPE object;
DEFINE FIELD performance_benchmarks ON cross_saas_analytics TYPE object;
DEFINE FIELD scaling_recommendations ON cross_saas_analytics TYPE array;
```

### **DEVELOPER_LEVEL - Tables SaaS**

#### **1. SaaS System Metrics**
```sql
-- Namespace: {saas_id}, Database: monitoring
DEFINE TABLE saas_system_metrics SCHEMAFULL
    COMMENT "Métriques système pour ce SaaS uniquement"
    PERMISSIONS
        FOR select WHERE $auth.ns = $this.saas_namespace
        FOR create WHERE $auth.level = 'system'
        FOR update WHERE $auth.level CONTAINS 'saas_admin';

DEFINE FIELD timestamp ON saas_system_metrics TYPE datetime DEFAULT time::now();
DEFINE FIELD saas_namespace ON saas_system_metrics TYPE string;
DEFINE FIELD cpu_usage ON saas_system_metrics TYPE float;
DEFINE FIELD memory_usage ON saas_system_metrics TYPE float;
DEFINE FIELD disk_usage ON saas_system_metrics TYPE float;
DEFINE FIELD connection_count ON saas_system_metrics TYPE int;
DEFINE FIELD active_sessions ON saas_system_metrics TYPE int;
DEFINE FIELD cache_hit_ratio ON saas_system_metrics TYPE float;
DEFINE FIELD avg_query_time ON saas_system_metrics TYPE float;
DEFINE FIELD slow_queries_count ON saas_system_metrics TYPE int;
```

#### **2. SaaS Query Metrics**
```sql
DEFINE TABLE saas_query_metrics SCHEMAFULL
    COMMENT "Détail des requêtes pour ce SaaS"
    PERMISSIONS
        FOR select WHERE $auth.ns = $this.saas_namespace
        FOR create WHERE $auth.level = 'system';

DEFINE FIELD query_id ON saas_query_metrics TYPE uuid DEFAULT rand::uuid();
DEFINE FIELD timestamp ON saas_query_metrics TYPE datetime DEFAULT time::now();
DEFINE FIELD saas_namespace ON saas_query_metrics TYPE string;
DEFINE FIELD database_name ON saas_query_metrics TYPE string;
DEFINE FIELD query_text ON saas_query_metrics TYPE string;
DEFINE FIELD query_type ON saas_query_metrics TYPE string; -- SELECT, INSERT, UPDATE, etc.
DEFINE FIELD duration_ms ON saas_query_metrics TYPE float;
DEFINE FIELD rows_affected ON saas_query_metrics TYPE int;
DEFINE FIELD user_id ON saas_query_metrics TYPE option<string>;
DEFINE FIELD is_slow_query ON saas_query_metrics TYPE bool DEFAULT false;
DEFINE FIELD error_message ON saas_query_metrics TYPE option<string>;
```

#### **3. Workspace Metrics**
```sql
-- Namespace: {saas_id}, Database: workspace_{id}
DEFINE TABLE workspace_metrics SCHEMAFULL
    COMMENT "Métriques spécifiques au workspace"
    PERMISSIONS
        FOR select WHERE $auth.ns = $this.saas_namespace
        FOR create WHERE $auth.level = 'system';

DEFINE FIELD timestamp ON workspace_metrics TYPE datetime DEFAULT time::now();
DEFINE FIELD workspace_name ON workspace_metrics TYPE string;
DEFINE FIELD active_users_count ON workspace_metrics TYPE int;
DEFINE FIELD total_records ON workspace_metrics TYPE int;
DEFINE FIELD total_tables ON workspace_metrics TYPE int;
DEFINE FIELD data_size_mb ON workspace_metrics TYPE float;
DEFINE FIELD queries_per_minute ON workspace_metrics TYPE float;
DEFINE FIELD business_operations_count ON workspace_metrics TYPE int;
DEFINE FIELD module_usage_stats ON workspace_metrics TYPE object;
```

---

## 🔧 **Fonctions Natives par Niveau**

### **INVESTOR_LEVEL Functions**

#### **1. Global Health Scoring**
```sql
-- Fonction pour calculer la santé globale de la plateforme
DEFINE FUNCTION fn::calculate_global_health() {
    LET $saas_healths = SELECT health_score FROM global_saas_health 
                       WHERE timestamp > time::now() - 1h;
    
    LET $avg_health = math::mean($saas_healths.health_score);
    LET $min_health = math::min($saas_healths.health_score);
    LET $critical_count = count(SELECT * FROM $saas_healths WHERE health_score < 70);
    
    RETURN {
        global_score: $avg_health,
        worst_saas_score: $min_health,
        critical_saas_count: $critical_count,
        status: IF $avg_health > 90 THEN 'excellent'
               ELSE IF $avg_health > 75 THEN 'good'
               ELSE IF $avg_health > 50 THEN 'warning'
               ELSE 'critical' END,
        recommendation: fn::generate_platform_recommendations($avg_health, $critical_count)
    };
};
```

#### **2. Cross-SaaS Performance Comparison**
```sql
DEFINE FUNCTION fn::cross_saas_performance_ranking() {
    RETURN SELECT 
        saas_namespace,
        saas_name,
        health_score,
        queries_per_minute,
        avg_response_time,
        active_users,
        math::round(health_score * queries_per_minute / avg_response_time) as performance_index
    FROM global_saas_health 
    WHERE timestamp > time::now() - 1h
    ORDER BY performance_index DESC;
};
```

### **DEVELOPER_LEVEL Functions**

#### **1. SaaS Performance Scoring**
```sql
-- Fonction pour calculer le score de performance d'un SaaS
DEFINE FUNCTION fn::calculate_saas_performance($saas_namespace: string) {
    LET $recent_metrics = SELECT * FROM saas_system_metrics 
                         WHERE saas_namespace = $saas_namespace 
                         AND timestamp > time::now() - 1h
                         ORDER BY timestamp DESC;
    
    LET $avg_cpu = math::mean($recent_metrics.cpu_usage);
    LET $avg_memory = math::mean($recent_metrics.memory_usage);
    LET $avg_query_time = math::mean($recent_metrics.avg_query_time);
    LET $cache_hit = math::mean($recent_metrics.cache_hit_ratio);
    
    LET $cpu_score = (100 - $avg_cpu) / 100;
    LET $memory_score = (100 - $avg_memory) / 100;
    LET $query_score = math::min(1.0, 1000 / $avg_query_time);
    LET $cache_score = $cache_hit / 100;
    
    RETURN ($cpu_score + $memory_score + $query_score + $cache_score) / 4 * 100;
};
```

#### **2. Slow Query Detection**
```sql
DEFINE FUNCTION fn::detect_slow_queries($saas_namespace: string, $threshold_ms: float) {
    RETURN SELECT 
        query_text,
        duration_ms,
        timestamp,
        user_id,
        database_name
    FROM saas_query_metrics 
    WHERE saas_namespace = $saas_namespace 
    AND duration_ms > $threshold_ms
    AND timestamp > time::now() - 1h
    ORDER BY duration_ms DESC
    LIMIT 10;
};
```

---

## ⚡ **Events & Triggers Automatiques**

### **INVESTOR_LEVEL - Capture Globale**
```sql
-- Event pour mise à jour automatique des métriques globales
DEFINE EVENT global_metrics_aggregation ON TABLE global_saas_health WHEN $event = "CREATE" THEN {
    -- Recalculer les métriques globales quand un SaaS report ses données
    LET $global_stats = fn::calculate_global_health();
    
    CREATE global_system_metrics CONTENT {
        timestamp: time::now(),
        total_saas_count: count(SELECT * FROM global_saas_health WHERE timestamp > time::now() - 1h),
        platform_health_score: $global_stats.global_score,
        total_active_connections: sum(SELECT active_users FROM global_saas_health),
        global_cache_hit_ratio: math::mean(SELECT cache_hit_ratio FROM saas_system_metrics WHERE timestamp > time::now() - 1h)
    };
};
```

### **DEVELOPER_LEVEL - Capture SaaS**
```sql
-- Event pour capture automatique des requêtes lentes
DEFINE EVENT slow_query_detection ON TABLE saas_query_metrics WHEN $event = "CREATE" THEN {
    IF $after.duration_ms > 1000 THEN {
        UPDATE saas_query_metrics SET is_slow_query = true WHERE id = $after.id;
        
        -- Créer une alerte si trop de requêtes lentes
        LET $slow_count = count(SELECT * FROM saas_query_metrics 
                               WHERE saas_namespace = $after.saas_namespace 
                               AND is_slow_query = true 
                               AND timestamp > time::now() - 5m);
        
        IF $slow_count > 5 THEN {
            CREATE saas_alerts CONTENT {
                alert_type: 'PERFORMANCE',
                severity: 'HIGH',
                saas_namespace: $after.saas_namespace,
                message: 'Détection de requêtes lentes répétées',
                metric_value: $slow_count,
                timestamp: time::now()
            };
        };
    };
};
```

---

## 🎨 **Intégration avec Hooks React**

### **INVESTOR_LEVEL Hooks**
```typescript
// Hook pour monitoring global avec use cases standards
export function useGlobalPlatformHealth() {
    const { data: globalHealth } = useSurrealQuery(`
        SELECT * FROM fn::calculate_global_health()
    `);
    
    const { data: liveMetrics, isConnected } = useSurrealLive(`
        LIVE SELECT * FROM global_system_metrics 
        ORDER BY timestamp DESC 
        LIMIT 1
    `);
    
    return {
        globalHealth,
        liveMetrics,
        isLive: isConnected,
        useCase: 'global_platform_health'
    };
}

export function useCrossSaaSPerformance() {
    const { data: rankings } = useSurrealQuery(`
        SELECT * FROM fn::cross_saas_performance_ranking()
    `);
    
    return {
        rankings,
        useCase: 'cross_saas_performance'
    };
}
```

### **DEVELOPER_LEVEL Hooks**
```typescript
// Hook pour monitoring SaaS spécifique
export function useSaaSPerformanceMonitoring(saasNamespace: string) {
    const { data: performance } = useSurrealFunction(
        'fn::calculate_saas_performance',
        { saas_namespace: saasNamespace }
    );
    
    const { data: liveMetrics } = useSurrealLive(`
        LIVE SELECT * FROM saas_system_metrics 
        WHERE saas_namespace = $namespace
        ORDER BY timestamp DESC
    `, { namespace: saasNamespace });
    
    return {
        performance,
        liveMetrics,
        useCase: 'saas_performance_monitoring'
    };
}

export function useBusinessAnalytics(saasNamespace: string) {
    const { data: analytics } = useSurrealQuery(`
        SELECT 
            workspace_name,
            total_records,
            queries_per_minute,
            business_operations_count
        FROM workspace_metrics 
        WHERE timestamp > time::now() - 24h
        ORDER BY timestamp DESC
    `);
    
    return {
        analytics,
        useCase: 'business_analytics'
    };
}
```

---

## 🚀 **Implémentation Services**

### **Refactoring SurrealMonitoringService**
```typescript
import { 
    ARCHITECTURE_LEVELS, 
    NAMESPACES, 
    DATABASES 
} from '@lyxalsuite/architecture-reference';

export class SurrealMonitoringService {
    private level: string;
    private namespace: string;
    private database: string;
    
    constructor(config: {
        level: string;
        saasId?: string;
        workspaceId?: string;
    }) {
        this.level = config.level;
        
        if (config.level === ARCHITECTURE_LEVELS.INVESTOR) {
            this.namespace = NAMESPACES.CATALOG;
            this.database = DATABASES[ARCHITECTURE_LEVELS.INVESTOR].MONITORING;
        } else {
            this.namespace = NAMESPACES.SAAS(config.saasId!);
            this.database = config.workspaceId 
                ? DATABASES[ARCHITECTURE_LEVELS.DEVELOPER].WORKSPACE(config.workspaceId)
                : DATABASES[ARCHITECTURE_LEVELS.DEVELOPER].MONITORING;
        }
    }
    
    async getPerformanceMetrics(): Promise<PerformanceMetrics> {
        if (this.level === ARCHITECTURE_LEVELS.INVESTOR) {
            return this.getGlobalPerformanceMetrics();
        } else {
            return this.getSaaSPerformanceMetrics();
        }
    }
    
    private async getGlobalPerformanceMetrics(): Promise<PerformanceMetrics> {
        // Vraies requêtes SurrealDB pour niveau global
        const result = await this.surrealClient.query(`
            SELECT * FROM fn::calculate_global_health()
        `);
        
        const globalMetrics = await this.surrealClient.query(`
            SELECT * FROM global_system_metrics 
            ORDER BY timestamp DESC 
            LIMIT 1
        `);
        
        return {
            totalQueries: globalMetrics[0]?.total_queries_per_second * 60 || 0,
            avgResponseTime: globalMetrics[0]?.avg_response_time || 0,
            // ... mapping des vraies données
        };
    }
    
    private async getSaaSPerformanceMetrics(): Promise<PerformanceMetrics> {
        // Vraies requêtes SurrealDB pour niveau SaaS
        const result = await this.surrealClient.query(`
            SELECT * FROM fn::calculate_saas_performance($namespace)
        `, { namespace: this.namespace });
        
        // ... implémentation avec vraies données
    }
}
```

---

## 📋 **Décisions Finalisées**

### ✅ **Architecture Retenue**
- **INVESTOR_LEVEL** : Monitoring global dans `catalog/monitoring`
- **DEVELOPER_LEVEL** : Monitoring SaaS dans `{saas_id}/monitoring`

### ✅ **Use Cases Standardisés**
- Utilisation des use cases de `ARCHITECTURE-REFERENCE.md`
- Alignment parfait avec l'architecture bicéphale

### ✅ **Structure Technique**
- Tables natives SurrealDB avec permissions granulaires
- Functions pour analytics avancées
- Events pour capture automatique
- LIVE queries pour temps réel

---

## 🎯 **Prochaines Étapes**

1. ✅ **Architecture définie** selon référence standard
2. 🔄 **Création des schémas** `.surql` par niveau
3. 🔄 **Implémentation des functions** natives
4. 🔄 **Refactoring du service** avec vraies données
5. 🔄 **Tests** avec données réelles sur environnement de dev

---

*Cette stratégie de monitoring est maintenant parfaitement alignée sur l'architecture de référence LyxalSuite avec les niveaux INVESTOR_LEVEL et DEVELOPER_LEVEL standardisés.* 