# @lyxalsuite/lyxal-surreal

Module SurrealDB pour LyxalSuite - Monitoring et gestion de base de données en temps réel.

## 🚀 Fonctionnalités

- **Monitoring en temps réel** : Surveillance des performances SurrealDB
- **Métriques détaillées** : Temps de réponse, utilisation mémoire, cache, etc.
- **Hooks React** : Intégration facile avec React/Next.js
- **Gestion d'état** : Compatible Redux, Zustand et autres gestionnaires d'état
- **Actions de maintenance** : Optimisation, nettoyage cache, export de logs
- **Alertes intelligentes** : Notifications basées sur des seuils configurables
- **Health checks** : Vérification automatique de la santé système

## 📦 Installation

```bash
npm install @lyxalsuite/lyxal-surreal
# ou
yarn add @lyxalsuite/lyxal-surreal
# ou
pnpm add @lyxalsuite/lyxal-surreal
```

### Dépendances peer

Ce module nécessite SurrealDB.js :

```bash
npm install surrealdb.js
```

## 🔧 Utilisation

### Service de monitoring

```typescript
import { SurrealMonitoringService } from '@lyxalsuite/lyxal-surreal';
import Surreal from 'surrealdb.js';

// Initialisation du client SurrealDB
const db = new Surreal();
await db.connect('ws://localhost:8000/rpc');
await db.use({ ns: 'monitoring', db: 'lyxal' });

// Création du service de monitoring
const monitoringService = new SurrealMonitoringService(db);
await monitoringService.initialize();

// Récupération des métriques
const metrics = await monitoringService.getPerformanceMetrics();
console.log('Métriques de performance:', metrics);
```

### Hooks React

```typescript
import { useSurrealMonitoring } from '@lyxalsuite/lyxal-surreal';

function MonitoringDashboard() {
  const {
    metrics,
    isLoading,
    error,
    connectionStatus,
    refresh
  } = useSurrealMonitoring(surrealClient, {
    autoRefresh: true,
    refreshInterval: 5000
  });

  if (isLoading) return <div>Chargement...</div>;
  if (error) return <div>Erreur: {error}</div>;

  return (
    <div>
      <h1>Dashboard SurrealDB</h1>
      <div>Status: {connectionStatus}</div>
      <div>Requêtes totales: {metrics?.totalQueries}</div>
      <div>Temps de réponse: {metrics?.avgResponseTime}ms</div>
      <button onClick={refresh}>Actualiser</button>
    </div>
  );
}
```

### Actions de maintenance

```typescript
import { useMaintenanceActions } from '@lyxalsuite/lyxal-surreal';

function MaintenancePanel() {
  const { clearCache, optimizeDatabase, exportLogs, isExecuting } = 
    useMaintenanceActions(surrealClient);

  return (
    <div>
      <button 
        onClick={clearCache} 
        disabled={isExecuting}
      >
        Vider le cache
      </button>
      
      <button 
        onClick={optimizeDatabase}
        disabled={isExecuting}
      >
        Optimiser la base
      </button>
      
      <button 
        onClick={() => exportLogs(new Date(Date.now() - 24*60*60*1000))}
        disabled={isExecuting}
      >
        Exporter les logs (24h)
      </button>
    </div>
  );
}
```

### Gestion d'état Redux

```typescript
import { 
  monitoringReducer, 
  monitoringActions, 
  monitoringSelectors 
} from '@lyxalsuite/lyxal-surreal';
import { configureStore } from '@reduxjs/toolkit';

// Configuration du store
const store = configureStore({
  reducer: {
    monitoring: monitoringReducer
  }
});

// Dispatch d'actions
store.dispatch(monitoringActions.setPerformanceMetrics(metrics));

// Utilisation des sélecteurs
const metrics = monitoringSelectors.getPerformanceMetrics(store.getState());
```

## 📊 Types de données

### PerformanceMetrics

```typescript
interface PerformanceMetrics {
  totalQueries: number;
  avgResponseTime: number;
  slowQueries: number;
  cacheHitRate: number;
  activeConnections: number;
  totalSaaS: number;
  totalWorkspaces: number;
  uptime: number;
  memoryUsage: number;
  diskUsage: number;
}
```

### HealthCheck

```typescript
interface HealthCheck {
  status: 'healthy' | 'degraded' | 'unhealthy';
  checks: {
    database: boolean;
    connection: boolean;
    performance: boolean;
    storage: boolean;
  };
  lastCheck: Date;
  issues: string[];
}
```

## 🛠️ Utilitaires

```typescript
import { 
  formatResponseTime,
  getPerformanceStatus,
  calculateCacheEfficiency,
  formatBytes,
  formatUptime
} from '@lyxalsuite/lyxal-surreal';

// Formatage du temps de réponse
const formatted = formatResponseTime(1500); // "1.50s"

// Statut de performance
const status = getPerformanceStatus(250, {
  excellent: 100,
  good: 200,
  warning: 500
}); // "warning"

// Efficacité du cache
const efficiency = calculateCacheEfficiency(850, 150); // 85%
```

## 🔔 Alertes

```typescript
import { useMonitoringAlerts } from '@lyxalsuite/lyxal-surreal';

function AlertsPanel({ metrics }) {
  const { alerts, acknowledgeAlert, clearAlerts, hasUnacknowledged } = 
    useMonitoringAlerts(metrics, {
      responseTime: 500,
      memoryUsage: 80,
      diskUsage: 85,
      errorRate: 5
    });

  return (
    <div>
      {hasUnacknowledged && <div className="alert-badge">!</div>}
      {alerts.map(alert => (
        <div key={alert.id} className={`alert alert-${alert.type}`}>
          <span>{alert.message}</span>
          <button onClick={() => acknowledgeAlert(alert.id)}>
            Acquitter
          </button>
        </div>
      ))}
    </div>
  );
}
```

## 🔧 Configuration

```typescript
interface MonitoringConfig {
  refreshInterval: number;        // Intervalle de rafraîchissement (ms)
  autoRefresh: boolean;          // Actualisation automatique
  alertThresholds: {             // Seuils d'alerte
    responseTime: number;        // Temps de réponse max (ms)
    memoryUsage: number;         // Utilisation mémoire max (%)
    diskUsage: number;           // Utilisation disque max (%)
    errorRate: number;           // Taux d'erreur max (%)
  };
  retentionPeriod: number;       // Période de rétention (jours)
}
```

## 🏗️ Architecture

```
src/
├── monitoring/
│   ├── types/           # Interfaces TypeScript
│   ├── services/        # Service principal SurrealDB
│   ├── hooks/           # Hooks React
│   ├── actions/         # Actions Redux/state management
│   ├── utils/           # Utilitaires et helpers
│   └── index.ts         # Point d'entrée
└── index.ts             # Export principal
```

## 🤝 Intégration avec LyxalKitUI

Ce module est conçu pour fonctionner parfaitement avec les composants UI de `@lyxalsuite/lyxalkitui` :

```typescript
import { SurrealMonitoringPage } from '@lyxalsuite/lyxalkitui';
import { useSurrealMonitoring } from '@lyxalsuite/lyxal-surreal';

function App() {
  const monitoring = useSurrealMonitoring(surrealClient);
  
  return (
    <SurrealMonitoringPage 
      surrealClient={surrealClient}
      {...monitoring}
    />
  );
}
```

## 📝 Licence

MIT

## 🔗 Liens

- [SurrealDB](https://surrealdb.com/)
- [LyxalSuite](https://github.com/lyxalsuite)
- [Documentation complète](https://docs.lyxalsuite.com/lyxal-surreal) 