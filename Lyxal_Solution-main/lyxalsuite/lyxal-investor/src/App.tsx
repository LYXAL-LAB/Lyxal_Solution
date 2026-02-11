import React from 'react';
import { InvestorDashboard } from './pages/InvestorDashboard';

/**
 * App - Application principale INVESTOR
 * 
 * Point d'entrée de l'application INVESTOR qui affiche
 * le dashboard principal avec monitoring intégré.
 */
function App() {
  return (
    <div className="app">
      <InvestorDashboard />
    </div>
  );
}

export default App; 