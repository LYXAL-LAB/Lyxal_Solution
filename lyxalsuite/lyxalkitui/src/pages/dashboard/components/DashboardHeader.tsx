import React from 'react';
import { DashboardLevel } from '../LevelDashboard';

interface DashboardHeaderProps {
  title: string;
  subtitle: string;
  currentLevel: DashboardLevel;
  onLevelChange: (level: DashboardLevel) => void;
}

export const DashboardHeader: React.FC<DashboardHeaderProps> = ({
  title,
  subtitle,
  currentLevel
}) => {
  const getLevelInfo = (level: DashboardLevel) => {
    switch (level) {
      case 'investor':
        return {
          icon: '💼',
          label: 'Investisseur',
          description: 'Vue globale de la plateforme et des performances',
          color: 'text-primary'
        };
      case 'developer':
        return {
          icon: '👨‍💻',
          label: 'Développeur',
          description: 'Gestion des SaaS et des workspaces',
          color: 'text-secondary'
        };
      case 'contractor':
        return {
          icon: '🔧',
          label: 'Contractant',
          description: 'Outils et ressources pour les projets',
          color: 'text-accent'
        };
    }
  };

  const levelInfo = getLevelInfo(currentLevel);

  return (
    <div className="w-full bg-base-100">
      <div className="container mx-auto px-4">
        <div className="py-8">
          <div className="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-6">
            {/* Titre principal */}
            <div className="flex-1">
              <h1 className="text-3xl md:text-4xl lg:text-5xl font-bold text-base-content mb-2">
                {title}
              </h1>
              <p className="text-base md:text-lg opacity-70 text-base-content">
                {subtitle}
              </p>
            </div>

            {/* Indicateur de niveau actuel */}
            <div className="flex-shrink-0">
              <div className="card bg-base-200 shadow-lg">
                <div className="card-body p-4">
                  <div className="flex items-center space-x-3">
                    <div className="text-2xl">{levelInfo.icon}</div>
                    <div>
                      <div className={`font-semibold ${levelInfo.color}`}>
                        Niveau {levelInfo.label}
                      </div>
                      <div className="text-sm opacity-70">
                        {levelInfo.description}
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}; 
import { DashboardLevel } from '../LevelDashboard';

interface DashboardHeaderProps {
  title: string;
  subtitle: string;
  currentLevel: DashboardLevel;
  onLevelChange: (level: DashboardLevel) => void;
}

export const DashboardHeader: React.FC<DashboardHeaderProps> = ({
  title,
  subtitle,
  currentLevel
}) => {
  const getLevelInfo = (level: DashboardLevel) => {
    switch (level) {
      case 'investor':
        return {
          icon: '💼',
          label: 'Investisseur',
          description: 'Vue globale de la plateforme et des performances',
          color: 'text-primary'
        };
      case 'developer':
        return {
          icon: '👨‍💻',
          label: 'Développeur',
          description: 'Gestion des SaaS et des workspaces',
          color: 'text-secondary'
        };
      case 'contractor':
        return {
          icon: '🔧',
          label: 'Contractant',
          description: 'Outils et ressources pour les projets',
          color: 'text-accent'
        };
    }
  };

  const levelInfo = getLevelInfo(currentLevel);

  return (
    <div className="w-full bg-base-100">
      <div className="container mx-auto px-4">
        <div className="py-8">
          <div className="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-6">
            {/* Titre principal */}
            <div className="flex-1">
              <h1 className="text-3xl md:text-4xl lg:text-5xl font-bold text-base-content mb-2">
                {title}
              </h1>
              <p className="text-base md:text-lg opacity-70 text-base-content">
                {subtitle}
              </p>
            </div>

            {/* Indicateur de niveau actuel */}
            <div className="flex-shrink-0">
              <div className="card bg-base-200 shadow-lg">
                <div className="card-body p-4">
                  <div className="flex items-center space-x-3">
                    <div className="text-2xl">{levelInfo.icon}</div>
                    <div>
                      <div className={`font-semibold ${levelInfo.color}`}>
                        Niveau {levelInfo.label}
                      </div>
                      <div className="text-sm opacity-70">
                        {levelInfo.description}
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};