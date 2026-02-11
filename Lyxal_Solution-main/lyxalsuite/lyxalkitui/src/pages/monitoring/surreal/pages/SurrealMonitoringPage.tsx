import React, { useCallback } from 'react';
import { 
  HiOutlineChartBar,
  HiOutlineLightningBolt,
  HiOutlineClock,
  HiOutlineExclamationCircle,
  HiOutlineUsers,
  HiOutlineOfficeBuilding,
  HiOutlineDatabase,
  HiOutlineChip
} from 'react-icons/hi';
import { MetricsHeaderSection } from '../sections/MetricsHeaderSection';
import { MetricsGridSection } from '../sections/MetricsGridSection';
import { MaintenanceSection } from '../sections/MaintenanceSection';
import { HeroHeaderSection } from '../sections/HeroHeaderSection';
import { LoadingSection } from '../sections/LoadingSection';
import { ErrorSection } from '../sections/ErrorSection';
// Import du vrai module de monitoring SurrealDB (version production)
import { useSurrealMonitoring, useMaintenanceActions } from '../../../../../../lyxal-surreal/dist/monitoring';
import './SurrealMonitoringPage.css';

interface SurrealMonitoringPageProps {
  surrealClient?: any;
  className?: string;
  onRefresh?: () => void;
  autoRefresh?: boolean;
  refreshInterval?: number;
  // Nouveaux paramètres pour l'architecture bicéphale
  saasNamespace?: string;
  userLevel?: 'INVESTOR_LEVEL' | 'DEVELOPER_LEVEL';
}

interface MetricCard {
  id: string;
  title: string;
  value: string | number;
  unit?: string;
  icon: React.ReactNode;
  color: 'primary' | 'secondary' | 'success' | 'warning' | 'error';
  change?: {
    value: number;
    type: 'increase' | 'decrease' | 'neutral';
  };
  threshold?: {
    good: number;
    warning: number;
  };
}

export function SurrealMonitoringPage({ 
  surrealClient, 
  className = '',
  onRefresh,
  autoRefresh = true,
  refreshInterval = 5000,
  saasNamespace,
  userLevel = 'DEVELOPER_LEVEL'
}: SurrealMonitoringPageProps) {
  // Utilisation du vrai hook de monitoring SurrealDB
  const {
    metrics,
    isLoading,
    isRefreshing,
    error,
    connectionStatus,
    lastUpdate,
    refresh,
    userLevel: currentUserLevel,
    saasNamespace: currentSaasNamespace
  } = useSurrealMonitoring(surrealClient, {
    autoRefresh,
    refreshInterval,
    saasNamespace,
    userLevel,
    onError: (err: any) => console.error('Erreur monitoring:', err),
    onConnectionChange: (status: any) => console.log('Statut connexion:', status)
  });

  // Hook pour les actions de maintenance
  const {
    executeAction,
    isExecuting,
    lastAction,
    error: maintenanceError
  } = useMaintenanceActions(surrealClient, {
    saasNamespace,
    userLevel
  });

  // Icônes SVG pour les métriques
  const icons = {
    queries: <HiOutlineLightningBolt className="w-8 h-8" />,
    responseTime: <HiOutlineClock className="w-8 h-8" />,
    cache: <HiOutlineDatabase className="w-8 h-8" />,
    slowQueries: <HiOutlineExclamationCircle className="w-8 h-8" />,
    connections: <HiOutlineUsers className="w-8 h-8" />,
    saas: <HiOutlineOfficeBuilding className="w-8 h-8" />,
    workspaces: <HiOutlineChartBar className="w-8 h-8" />,
    memory: <HiOutlineChip className="w-8 h-8" />
  };

  // Gestion du refresh manuel
  const handleRefresh = useCallback(async () => {
    await refresh();
    if (onRefresh) {
      onRefresh();
    }
  }, [refresh, onRefresh]);

  // Actions de maintenance avec vraies fonctions SurrealDB
  const handleClearCache = useCallback(async () => {
    try {
      const result = await executeAction('clearCache');
      console.log('✅ Cache vidé:', result);
    } catch (err) {
      console.error('❌ Erreur vidage cache:', err);
    }
  }, [executeAction]);

  const handleOptimizeDatabase = useCallback(async () => {
    try {
      const result = await executeAction('optimizeDatabase');
      console.log('✅ Base optimisée:', result);
    } catch (err) {
      console.error('❌ Erreur optimisation:', err);
    }
  }, [executeAction]);

  const handleExportLogs = useCallback(async () => {
    try {
      const result = await executeAction('exportLogs');
      console.log('✅ Logs exportés:', result);
      // Ici on pourrait déclencher un téléchargement du fichier
    } catch (err) {
      console.error('❌ Erreur export logs:', err);
    }
  }, [executeAction]);

  const handlePerformanceReport = useCallback(async () => {
    try {
      const result = await executeAction('healthCheck');
      console.log('✅ Rapport de performance:', result);
    } catch (err) {
      console.error('❌ Erreur rapport:', err);
    }
  }, [executeAction]);

  // Génération des cartes de métriques avec vraies données
  const getMetricCards = useCallback((): MetricCard[] => {
    if (!metrics) return [];

    return [
      {
        id: 'queries',
        title: userLevel === 'INVESTOR_LEVEL' ? 'Requêtes globales' : 'Requêtes SaaS',
        value: metrics.totalQueries.toLocaleString(),
        icon: icons.queries,
        color: 'primary',
        change: { value: 12, type: 'increase' }
      },
      {
        id: 'responseTime',
        title: 'Temps de réponse',
        value: metrics.avgResponseTime,
        unit: 'ms',
        icon: icons.responseTime,
        color: metrics.avgResponseTime <= 50 ? 'success' : metrics.avgResponseTime <= 100 ? 'warning' : 'error',
        threshold: { good: 50, warning: 100 }
      },
      {
        id: 'cache',
        title: 'Cache Hit Rate',
        value: metrics.cacheHitRate.toFixed(1),
        unit: '%',
        icon: icons.cache,
        color: metrics.cacheHitRate >= 90 ? 'success' : metrics.cacheHitRate >= 70 ? 'warning' : 'error',
        change: { value: 5, type: 'increase' }
      },
      {
        id: 'slowQueries',
        title: 'Requêtes lentes',
        value: metrics.slowQueries,
        icon: icons.slowQueries,
        color: metrics.slowQueries === 0 ? 'success' : metrics.slowQueries <= 5 ? 'warning' : 'error'
      },
      {
        id: 'connections',
        title: 'Connexions actives',
        value: metrics.activeConnections,
        icon: icons.connections,
        color: 'secondary'
      },
      {
        id: 'saas',
        title: userLevel === 'INVESTOR_LEVEL' ? 'SaaS déployés' : 'SaaS actuel',
        value: metrics.totalSaaS,
        icon: icons.saas,
        color: 'primary'
      },
      {
        id: 'workspaces',
        title: 'Workspaces',
        value: metrics.totalWorkspaces,
        icon: icons.workspaces,
        color: 'secondary'
      },
      {
        id: 'memory',
        title: 'Utilisation mémoire',
        value: metrics.memoryUsage.toFixed(1),
        unit: '%',
        icon: icons.memory,
        color: metrics.memoryUsage <= 60 ? 'success' : metrics.memoryUsage <= 80 ? 'warning' : 'error'
      }
    ];
  }, [metrics, userLevel]);

  if (isLoading) {
    return <LoadingSection />;
  }

  const metricCards = getMetricCards();

  return (
    <div id="main-container" className={`min-h-screen bg-base-100 ${className}`}>
      {/* Header Hero Section - Mise en page professionnelle */}
      <HeroHeaderSection 
        connectionStatus={connectionStatus === 'error' ? 'disconnected' : connectionStatus}
        lastUpdate={lastUpdate}
        isRefreshing={isRefreshing}
        onRefresh={handleRefresh}
      />

      {/* Badge de niveau utilisateur */}
      <div className="w-full flex justify-center py-4">
        <div className={`badge ${userLevel === 'INVESTOR_LEVEL' ? 'badge-primary' : 'badge-secondary'} badge-lg`}>
          {userLevel === 'INVESTOR_LEVEL' ? '🏛️ Vue Investisseur' : '🏢 Vue Développeur'}
          {currentSaasNamespace && ` - ${currentSaasNamespace}`}
        </div>
      </div>

      {/* Contenu principal - Layout professionnel centré */}
      <div id="main-content" className="w-full flex flex-col items-center justify-center py-12">
        <div id="main-content-wrapper" className="max-w-7xl w-full mx-auto px-6 sm:px-8 lg:px-12 py-12 lg:py-16">
        
          {/* Message d'erreur - Nouvelle section */}
          {(error || maintenanceError) && (
            <ErrorSection error={(error || maintenanceError) as string} />
          )}

          {/* Section Titre des Métriques */}
          <MetricsHeaderSection />

          {/* Grille des métriques avec vraies données */}
          <MetricsGridSection metricCards={metricCards} />

          {/* Section Actions de Maintenance avec vraies fonctions */}
          <MaintenanceSection 
            onClearCache={handleClearCache}
            onPerformanceReport={handlePerformanceReport}
            onOptimizeDatabase={handleOptimizeDatabase}
            onExportLogs={handleExportLogs}
          />

          {/* Informations de debug en mode développement */}
          {process.env.NODE_ENV === 'development' && (
            <div className="mt-8 p-4 bg-base-200 rounded-lg">
              <h3 className="text-lg font-semibold mb-2">🔧 Debug Info</h3>
              <div className="text-sm space-y-1">
                <p><strong>Niveau:</strong> {currentUserLevel}</p>
                <p><strong>Namespace:</strong> {currentSaasNamespace || 'Non défini'}</p>
                <p><strong>Statut:</strong> {connectionStatus}</p>
                <p><strong>Dernière action:</strong> {lastAction || 'Aucune'}</p>
                <p><strong>En cours:</strong> {isExecuting ? 'Oui' : 'Non'}</p>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
} 