import React from 'react';
import { LevelDashboard } from '../pages/dashboard';
import { ThemeProvider } from '../theme';

/**
 * Exemple d'utilisation du Dashboard multi-niveaux
 */
const DashboardLevelExample: React.FC = () => {
  return (
    <ThemeProvider defaultTheme="synthwave">
      <div className="min-h-screen">
        <LevelDashboard
          defaultLevel="developer"
          onLevelChange={(level) => {
            console.log('Niveau changé vers:', level);
          }}
        />
      </div>
    </ThemeProvider>
  );
};

export default DashboardLevelExample;