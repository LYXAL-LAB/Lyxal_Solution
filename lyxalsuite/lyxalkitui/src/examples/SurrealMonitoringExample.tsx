import React from 'react';
import { SurrealMonitoringPage } from '../pages/monitoring/surreal/pages/SurrealMonitoringPage';

/**
 * Exemple d'utilisation de la page de monitoring SurrealDB
 */

// Mock du client SurrealDB pour la démo
const mockSurrealClient = {
  initialize: async () => {
    console.log('🔌 Connexion à SurrealDB...');
    // Simulation d'une connexion réaliste
    await new Promise(resolve => setTimeout(resolve, 800 + Math.random() * 400));
  },
  
  getPerformanceMetrics: async () => {
    // Simulation de métriques réalistes avec variations
    const baseMetrics = {
      monitoring: {
        totalQueries: Math.floor(Math.random() * 5000) + 8000,
        avgResponseTime: Math.floor(Math.random() * 80) + 15,
        slowQueries: Array.from({ length: Math.floor(Math.random() * 3) }, (_, i) => ({
          id: i,
          query: `SELECT * FROM complex_table_${i} WHERE conditions`,
          duration: Math.floor(Math.random() * 1500) + 1000
        }))
      },
      cache: {
        query: {
          hitRatio: Math.random() * 0.25 + 0.75 // Entre 75% et 100%
        }
      }
    };

    // Simulation d'une latence réseau
    await new Promise(resolve => setTimeout(resolve, 100 + Math.random() * 200));
    
    return baseMetrics;
  }
};

export function SurrealMonitoringExample() {
  const handleRefresh = React.useCallback(() => {
    console.log('🔄 Refresh manuel');
  }, []);

  return (
    <SurrealMonitoringPage 
      surrealClient={mockSurrealClient}
      onRefresh={handleRefresh}
      autoRefresh={true}
      refreshInterval={5000}
    />
  );
}

// Code d'exemple pour l'intégration
export const integrationExample = `
import { SurrealMonitoringPage } from '@lyxalsuite/lyxalkitui';
import { SurrealClient } from '@lyxalsuite/lyxal-surreal';

function AdminDashboard() {
  const surrealClient = SurrealClient.getInstance();
  
  const handleRefresh = () => {
    console.log('Refresh manuel déclenché');
  };
  
  return (
    <div className="admin-layout">
      <h1>Administration SurrealDB</h1>
      
      <SurrealMonitoringPage 
        surrealClient={surrealClient}
        onRefresh={handleRefresh}
        autoRefresh={true}
        refreshInterval={3000}
        className="my-custom-class"
      />
    </div>
  );
}
`;

// Props disponibles
export const availableProps = {
  surrealClient: 'Instance du client SurrealDB',
  className: 'Classes CSS personnalisées',
  onRefresh: 'Callback appelé lors du refresh manuel',
  autoRefresh: 'Activation du refresh automatique (défaut: true)',
  refreshInterval: 'Intervalle de refresh en ms (défaut: 5000)'
}; 