import React, { useState } from 'react';
import { InvestorDashboard } from './sections/InvestorDashboard';
import { DeveloperDashboard } from './sections/DeveloperDashboard';
import { ContractorDashboard } from './sections/ContractorDashboard';
import { LevelSelector } from './components/LevelSelector';
import { DashboardHeader } from './components/DashboardHeader';

export type DashboardLevel = 'investor' | 'developer' | 'contractor';

interface LevelDashboardProps {
  className?: string;
  defaultLevel?: DashboardLevel;
  onLevelChange?: (level: DashboardLevel) => void;
}

const LevelDashboard: React.FC<LevelDashboardProps> = ({
  className = '',
  defaultLevel = 'developer',
  onLevelChange
}) => {
  const [currentLevel, setCurrentLevel] = useState<DashboardLevel>(defaultLevel);

  const handleLevelChange = (level: DashboardLevel) => {
    setCurrentLevel(level);
    onLevelChange?.(level);
  };

  const renderDashboardContent = () => {
    switch (currentLevel) {
      case 'investor':
        return <InvestorDashboard />;
      case 'developer':
        return <DeveloperDashboard />;
      case 'contractor':
        return <ContractorDashboard />;
      default:
        return <DeveloperDashboard />;
    }
  };

  return (
    <div className={`min-h-screen bg-base-100 ${className}`} style={{ minWidth: '320px' }}>
      {/* Header avec sélecteur de niveau */}
      <DashboardHeader
        title="Centre de Contrôle"
        subtitle="Supervision et gestion de la plateforme LyxalSuite"
        currentLevel={currentLevel}
        onLevelChange={handleLevelChange}
      />

      {/* Sélecteur de niveau */}
      <div className="w-full bg-base-100 border-b border-base-300">
        <div className="container mx-auto px-4 py-4">
          <LevelSelector
            currentLevel={currentLevel}
            onLevelChange={handleLevelChange}
          />
        </div>
      </div>

      {/* Contenu du dashboard selon le niveau */}
      <div className="w-full">
        {renderDashboardContent()}
      </div>
    </div>
  );
};

export default LevelDashboard; 