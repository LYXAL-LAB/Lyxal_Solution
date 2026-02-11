/**
 * Pages prêtes à l'emploi pour LyxalKitUI
 * 
 * Ce module exporte des pages complètes qui peuvent être utilisées directement dans votre application.
 */

export { LoginPage } from './LoginPage';
export type { LoginPageProps } from './LoginPage';

export { Dashboard } from './Dashboard';
export type { DashboardProps, DashboardStats, DashboardAction } from './Dashboard';

// Dashboard multi-niveaux
export { LevelDashboard } from './dashboard';
export type { DashboardLevel } from './dashboard';
export { InvestorDashboard, DeveloperDashboard, ContractorDashboard } from './dashboard';

// Pages de monitoring
export { SurrealMonitoringPage } from './monitoring/surreal/pages/SurrealMonitoringPage';
export { MetricsCard } from './monitoring/surreal/components/MetricsCard';
export * from './monitoring/surreal/utils/monitoringHelpers';
export type { PerformanceMetrics, SurrealMonitoringPageProps } from './monitoring/surreal/index'; 