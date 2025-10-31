 
import { DashboardLevel } from '../LevelDashboard';

interface LevelSelectorProps {
  currentLevel: DashboardLevel;
  onLevelChange: (level: DashboardLevel) => void;
}

export const LevelSelector: React.FC<LevelSelectorProps> = ({
  currentLevel,
  onLevelChange
}) => {
  const levels: Array<{
    id: DashboardLevel;
    label: string;
    icon: string;
    description: string;
    color: string;
  }> = [
    {
      id: 'investor',
      label: 'Investisseur',
      icon: '💼',
      description: 'Vue globale et analytics',
      color: 'btn-primary'
    },
    {
      id: 'developer',
      label: 'Développeur',
      icon: '👨‍💻',
      description: 'SaaS et workspaces',
      color: 'btn-secondary'
    },
    {
      id: 'contractor',
      label: 'Contractant',
      icon: '🔧',
      description: 'Projets et outils',
      color: 'btn-accent'
    }
  ];

  return (
    <div className="flex flex-col sm:flex-row gap-4">
      {/* Titre de section */}
      <div className="flex-shrink-0 flex items-center">
        <h3 className="text-lg font-semibold text-base-content">
          Niveau d'accès :
        </h3>
      </div>

      {/* Boutons de sélection */}
      <div className="flex flex-wrap gap-2">
        {levels.map((level) => (
          <button
            key={level.id}
            onClick={() => onLevelChange(level.id)}
            className={`
              btn btn-sm
              ${currentLevel === level.id 
                ? `${level.color} btn-active` 
                : 'btn-ghost hover:btn-outline'
              }
              transition-all duration-200
            `}
          >
            <span className="mr-2">{level.icon}</span>
            <div className="flex flex-col items-start">
              <span className="font-medium">{level.label}</span>
              <span className="text-xs opacity-70 hidden sm:block">
                {level.description}
              </span>
            </div>
          </button>
        ))}
      </div>

      {/* Indicateur mobile */}
      <div className="sm:hidden">
        <div className="alert alert-info">
          <div className="flex items-center space-x-2">
            <span className="text-lg">
              {levels.find(l => l.id === currentLevel)?.icon}
            </span>
            <div>
              <div className="font-medium">
                {levels.find(l => l.id === currentLevel)?.label}
              </div>
              <div className="text-sm opacity-70">
                {levels.find(l => l.id === currentLevel)?.description}
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};