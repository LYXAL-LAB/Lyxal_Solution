import React from 'react';
import { SurrealMonitoringPage } from '../../../lyxalkitui/src/pages/monitoring/surreal/pages/SurrealMonitoringPage';

/**
 * InvestorDashboard - Interface principale INVESTOR
 * 
 * Réutilise SurrealMonitoringPage en mode INVESTOR_LEVEL pour afficher
 * une vue consolidée de tous les SaaS déployés.
 * 
 * Architecture:
 * - Namespace: "catalog" (INVESTOR_LEVEL)
 * - Vue: Tous les SaaS (pas de saasNamespace spécifique)
 * - Monitoring: Métriques consolidées de tous les SaaS
 */
export const InvestorDashboard: React.FC = () => {
  return (
    <div className="investor-dashboard">
      <div className="dashboard-header mb-6">
        <h1 className="text-3xl font-bold text-primary">Dashboard INVESTOR</h1>
        <p className="text-base-content/70">Vue consolidée de tous vos SaaS déployés</p>
      </div>
      
      <SurrealMonitoringPage 
        userLevel="INVESTOR_LEVEL"
        // Pas de saasNamespace = vue de tous les SaaS
        autoRefresh={true}
        refreshInterval={10000}
      />
    </div>
  );
};

export default InvestorDashboard; 