// Export de la page principale
export { SurrealMonitoringPage } from './pages/SurrealMonitoringPage';

// Export des sections
export { MetricsHeaderSection } from './sections/MetricsHeaderSection';
export { MetricsGridSection } from './sections/MetricsGridSection';
export { MaintenanceSection } from './sections/MaintenanceSection';
export { HeroHeaderSection } from './sections/HeroHeaderSection';

// Export des composants
export { MetricsCard } from './components/MetricsCard';

// Export des utilitaires
export * from './utils/monitoringHelpers';

// Types
export interface PerformanceMetrics {
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

export interface SurrealMonitoringPageProps {
  surrealClient?: any;
  className?: string;
  onRefresh?: () => void;
  autoRefresh?: boolean;
  refreshInterval?: number;
} 