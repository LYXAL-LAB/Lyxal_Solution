import React from 'react';

export const DeveloperDashboard: React.FC = () => {
  const developmentMetrics = [
    {
      title: 'SaaS en Développement',
      value: '12',
      change: { value: 3, type: 'increase' as const },
      icon: '🚧',
      color: 'bg-warning text-warning-content'
    },
    {
      title: 'Workspaces Actifs',
      value: '34',
      change: { value: 5, type: 'increase' as const },
      icon: '💻',
      color: 'bg-info text-info-content'
    },
    {
      title: 'Modules Déployés',
      value: '127',
      change: { value: 8, type: 'increase' as const },
      icon: '📦',
      color: 'bg-success text-success-content'
    },
    {
      title: 'Issues Ouvertes',
      value: '23',
      change: { value: -15, type: 'decrease' as const },
      icon: '🐛',
      color: 'bg-error text-error-content'
    }
  ];

  const recentProjects = [
    { 
      name: 'ACME Corp CRM', 
      status: 'En production', 
      progress: 100, 
      lastUpdate: '2h',
      modules: ['CRM', 'Analytics', 'Auth']
    },
    { 
      name: 'TechStart Analytics', 
      status: 'Tests', 
      progress: 85, 
      lastUpdate: '4h',
      modules: ['Analytics', 'Dashboard', 'Reports']
    },
    { 
      name: 'RetailPro Suite', 
      status: 'Développement', 
      progress: 60, 
      lastUpdate: '1d',
      modules: ['E-commerce', 'Inventory', 'CRM']
    },
    { 
      name: 'HealthCare Plus', 
      status: 'Planification', 
      progress: 25, 
      lastUpdate: '2d',
      modules: ['GDPR', 'Analytics', 'Helpdesk']
    }
  ];

  const availableModules = [
    { name: 'lyxal-auth', version: 'v2.1.0', status: 'stable', deployments: 45 },
    { name: 'lyxal-crm', version: 'v1.8.2', status: 'stable', deployments: 32 },
    { name: 'lyxal-analytics', version: 'v1.5.1', status: 'beta', deployments: 18 },
    { name: 'lyxal-ecommerce', version: 'v1.2.0', status: 'alpha', deployments: 7 },
    { name: 'lyxal-gdpr', version: 'v1.0.5', status: 'stable', deployments: 23 }
  ];

  const getStatusColor = (status: string) => {
    switch (status.toLowerCase()) {
      case 'en production': return 'badge-success';
      case 'tests': return 'badge-warning';
      case 'développement': return 'badge-info';
      case 'planification': return 'badge-secondary';
      default: return 'badge-neutral';
    }
  };

  const getModuleStatusColor = (status: string) => {
    switch (status.toLowerCase()) {
      case 'stable': return 'badge-success';
      case 'beta': return 'badge-warning';
      case 'alpha': return 'badge-error';
      default: return 'badge-neutral';
    }
  };

  return (
    <div className="container mx-auto px-4 py-8">
      {/* Métriques de développement */}
      <div className="mb-8">
        <h2 className="text-2xl font-bold text-base-content mb-6">
          👨‍💻 Tableau de Bord Développement
        </h2>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          {developmentMetrics.map((metric, index) => (
            <div key={index} className="card bg-base-200 shadow-lg hover:shadow-xl transition-all duration-200">
              <div className="card-body p-6">
                <div className="flex items-center justify-between mb-4">
                  <div className={`p-3 rounded-full ${metric.color}`}>
                    <span className="text-2xl">{metric.icon}</span>
                  </div>
                  {metric.change && (
                    <div className={`badge ${
                      metric.change.type === 'increase' ? 'badge-success' : 'badge-error'
                    }`}>
                      {metric.change.type === 'increase' ? '↗' : '↘'} {Math.abs(metric.change.value)}
                    </div>
                  )}
                </div>
                <div>
                  <h3 className="text-sm font-medium text-base-content opacity-70 mb-1">
                    {metric.title}
                  </h3>
                  <p className="text-2xl font-bold text-base-content">
                    {metric.value}
                  </p>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Projets récents et modules */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 mb-8">
        {/* Projets récents */}
        <div className="card bg-base-200 shadow-lg">
          <div className="card-body">
            <h3 className="card-title text-base-content mb-4">
              🚀 Projets Récents
            </h3>
            <div className="space-y-4">
              {recentProjects.map((project, index) => (
                <div key={index} className="card bg-base-100 shadow">
                  <div className="card-body p-4">
                    <div className="flex items-center justify-between mb-3">
                      <h4 className="font-semibold text-base-content">
                        {project.name}
                      </h4>
                      <div className="flex items-center space-x-2">
                        <div className={`badge ${getStatusColor(project.status)}`}>
                          {project.status}
                        </div>
                        <div className="text-xs text-base-content opacity-50">
                          {project.lastUpdate}
                        </div>
                      </div>
                    </div>
                    
                    {/* Barre de progression */}
                    <div className="mb-3">
                      <div className="flex justify-between text-sm mb-1">
                        <span className="text-base-content opacity-70">Progression</span>
                        <span className="text-base-content">{project.progress}%</span>
                      </div>
                      <progress 
                        className="progress progress-primary w-full" 
                        value={project.progress} 
                        max="100"
                      ></progress>
                    </div>

                    {/* Modules */}
                    <div className="flex flex-wrap gap-1">
                      {project.modules.map((module, idx) => (
                        <div key={idx} className="badge badge-outline badge-sm">
                          {module}
                        </div>
                      ))}
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Modules disponibles */}
        <div className="card bg-base-200 shadow-lg">
          <div className="card-body">
            <h3 className="card-title text-base-content mb-4">
              📦 Modules Disponibles
            </h3>
            <div className="space-y-3">
              {availableModules.map((module, index) => (
                <div key={index} className="flex items-center justify-between p-3 bg-base-100 rounded-lg">
                  <div className="flex-1">
                    <div className="flex items-center space-x-3">
                      <div className="font-medium text-base-content">
                        {module.name}
                      </div>
                      <div className="text-sm text-base-content opacity-50">
                        {module.version}
                      </div>
                      <div className={`badge badge-xs ${getModuleStatusColor(module.status)}`}>
                        {module.status}
                      </div>
                    </div>
                    <div className="text-xs text-base-content opacity-50 mt-1">
                      {module.deployments} déploiements
                    </div>
                  </div>
                  <div className="flex space-x-2">
                    <button className="btn btn-xs btn-primary">
                      Installer
                    </button>
                    <button className="btn btn-xs btn-outline">
                      Docs
                    </button>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>

      {/* Outils de développement */}
      <div className="card bg-base-200 shadow-lg mb-8">
        <div className="card-body">
          <h3 className="card-title text-base-content mb-6">
            🛠️ Outils de Développement
          </h3>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
            <div className="card bg-base-100 shadow hover:shadow-md transition-shadow cursor-pointer">
              <div className="card-body p-4 text-center">
                <div className="text-3xl mb-2">🗄️</div>
                <h4 className="font-semibold text-base-content">SurrealDB</h4>
                <p className="text-xs text-base-content opacity-70">Base de données</p>
                <div className="badge badge-success badge-sm mt-2">En ligne</div>
              </div>
            </div>

            <div className="card bg-base-100 shadow hover:shadow-md transition-shadow cursor-pointer">
              <div className="card-body p-4 text-center">
                <div className="text-3xl mb-2">🔐</div>
                <h4 className="font-semibold text-base-content">Logto Auth</h4>
                <p className="text-xs text-base-content opacity-70">Authentification</p>
                <div className="badge badge-success badge-sm mt-2">En ligne</div>
              </div>
            </div>

            <div className="card bg-base-100 shadow hover:shadow-md transition-shadow cursor-pointer">
              <div className="card-body p-4 text-center">
                <div className="text-3xl mb-2">🚀</div>
                <h4 className="font-semibold text-base-content">CI/CD</h4>
                <p className="text-xs text-base-content opacity-70">Déploiement</p>
                <div className="badge badge-warning badge-sm mt-2">Occupé</div>
              </div>
            </div>

            <div className="card bg-base-100 shadow hover:shadow-md transition-shadow cursor-pointer">
              <div className="card-body p-4 text-center">
                <div className="text-3xl mb-2">📈</div>
                <h4 className="font-semibold text-base-content">Monitoring</h4>
                <p className="text-xs text-base-content opacity-70">Surveillance</p>
                <div className="badge badge-success badge-sm mt-2">En ligne</div>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Actions rapides */}
      <div>
        <h3 className="text-xl font-bold text-base-content mb-4">
          ⚡ Actions Rapides
        </h3>
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
          <button className="btn btn-primary">
            🆕 Nouveau SaaS
          </button>
          <button className="btn btn-secondary">
            📦 Gérer Modules
          </button>
          <button className="btn btn-accent">
            🔧 Workspaces
          </button>
          <button className="btn btn-info">
            📊 Analytics
          </button>
        </div>
      </div>
    </div>
  );
}; 