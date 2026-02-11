import React from 'react';

export const ContractorDashboard: React.FC = () => {
  const contractorMetrics = [
    {
      title: 'Projets Assignés',
      value: '8',
      change: { value: 2, type: 'increase' as const },
      icon: '📋',
      color: 'bg-primary text-primary-content'
    },
    {
      title: 'Tâches Complétées',
      value: '156',
      change: { value: 12, type: 'increase' as const },
      icon: '✅',
      color: 'bg-success text-success-content'
    },
    {
      title: 'Heures Facturées',
      value: '324h',
      change: { value: 8, type: 'increase' as const },
      icon: '⏰',
      color: 'bg-info text-info-content'
    },
    {
      title: 'Revenus Mois',
      value: '€4,850',
      change: { value: 15, type: 'increase' as const },
      icon: '💰',
      color: 'bg-warning text-warning-content'
    }
  ];

  const activeProjects = [
    {
      name: 'ACME Corp - Module CRM',
      client: 'ACME Corporation',
      deadline: '2025-07-15',
      progress: 75,
      priority: 'Haute',
      tasks: 12,
      completedTasks: 9,
      budget: '€3,500'
    },
    {
      name: 'TechStart - Analytics Dashboard',
      client: 'TechStart Inc.',
      deadline: '2025-07-20',
      progress: 45,
      priority: 'Moyenne',
      tasks: 8,
      completedTasks: 4,
      budget: '€2,800'
    },
    {
      name: 'RetailPro - E-commerce Integration',
      client: 'RetailPro Ltd.',
      deadline: '2025-08-01',
      progress: 20,
      priority: 'Basse',
      tasks: 15,
      completedTasks: 3,
      budget: '€4,200'
    }
  ];

  const recentTasks = [
    { task: 'Implémentation authentification OAuth', project: 'ACME Corp CRM', status: 'Terminé', time: '3h' },
    { task: 'Tests unitaires module Analytics', project: 'TechStart Dashboard', status: 'En cours', time: '2h' },
    { task: 'Documentation API E-commerce', project: 'RetailPro Integration', status: 'En attente', time: '1.5h' },
    { task: 'Revue de code - Module GDPR', project: 'HealthCare Plus', status: 'Terminé', time: '1h' },
    { task: 'Configuration CI/CD Pipeline', project: 'EduTech Platform', status: 'En cours', time: '4h' }
  ];

  const tools = [
    { name: 'VS Code', description: 'Éditeur de code', status: 'active', icon: '💻' },
    { name: 'Git/GitHub', description: 'Contrôle de version', status: 'active', icon: '🔧' },
    { name: 'Docker', description: 'Conteneurisation', status: 'active', icon: '🐳' },
    { name: 'Postman', description: 'Test API', status: 'active', icon: '📡' },
    { name: 'SurrealDB Studio', description: 'Base de données', status: 'active', icon: '🗄️' },
    { name: 'Figma', description: 'Design UI/UX', status: 'inactive', icon: '🎨' }
  ];

  const getPriorityColor = (priority: string) => {
    switch (priority.toLowerCase()) {
      case 'haute': return 'badge-error';
      case 'moyenne': return 'badge-warning';
      case 'basse': return 'badge-success';
      default: return 'badge-neutral';
    }
  };

  const getTaskStatusColor = (status: string) => {
    switch (status.toLowerCase()) {
      case 'terminé': return 'badge-success';
      case 'en cours': return 'badge-warning';
      case 'en attente': return 'badge-secondary';
      default: return 'badge-neutral';
    }
  };

  return (
    <div className="container mx-auto px-4 py-8">
      {/* Métriques contractant */}
      <div className="mb-8">
        <h2 className="text-2xl font-bold text-base-content mb-6">
          🔧 Tableau de Bord Contractant
        </h2>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          {contractorMetrics.map((metric, index) => (
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
                      {metric.change.type === 'increase' ? '↗' : '↘'} {Math.abs(metric.change.value)}%
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

      {/* Projets actifs et tâches récentes */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 mb-8">
        {/* Projets actifs */}
        <div className="card bg-base-200 shadow-lg">
          <div className="card-body">
            <h3 className="card-title text-base-content mb-4">
              📋 Projets Actifs
            </h3>
            <div className="space-y-4">
              {activeProjects.map((project, index) => (
                <div key={index} className="card bg-base-100 shadow">
                  <div className="card-body p-4">
                    <div className="flex items-start justify-between mb-3">
                      <div className="flex-1">
                        <h4 className="font-semibold text-base-content mb-1">
                          {project.name}
                        </h4>
                        <p className="text-sm text-base-content opacity-70">
                          {project.client}
                        </p>
                      </div>
                      <div className="flex flex-col items-end space-y-1">
                        <div className={`badge ${getPriorityColor(project.priority)}`}>
                          {project.priority}
                        </div>
                        <div className="text-xs text-base-content opacity-50">
                          {new Date(project.deadline).toLocaleDateString('fr-FR')}
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

                    {/* Statistiques du projet */}
                    <div className="flex justify-between text-sm">
                      <div>
                        <span className="text-base-content opacity-70">Tâches: </span>
                        <span className="text-base-content font-medium">
                          {project.completedTasks}/{project.tasks}
                        </span>
                      </div>
                      <div>
                        <span className="text-base-content opacity-70">Budget: </span>
                        <span className="text-base-content font-medium text-success">
                          {project.budget}
                        </span>
                      </div>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Tâches récentes */}
        <div className="card bg-base-200 shadow-lg">
          <div className="card-body">
            <h3 className="card-title text-base-content mb-4">
              ⏱️ Activité Récente
            </h3>
            <div className="space-y-3">
              {recentTasks.map((item, index) => (
                <div key={index} className="flex items-center justify-between p-3 bg-base-100 rounded-lg">
                  <div className="flex-1">
                    <div className="font-medium text-base-content text-sm mb-1">
                      {item.task}
                    </div>
                    <div className="text-xs text-base-content opacity-50">
                      {item.project} • {item.time}
                    </div>
                  </div>
                  <div className={`badge badge-sm ${getTaskStatusColor(item.status)}`}>
                    {item.status}
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>

      {/* Outils et ressources */}
      <div className="card bg-base-200 shadow-lg mb-8">
        <div className="card-body">
          <h3 className="card-title text-base-content mb-6">
            🛠️ Outils et Ressources
          </h3>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            {tools.map((tool, index) => (
              <div key={index} className="card bg-base-100 shadow hover:shadow-md transition-shadow cursor-pointer">
                <div className="card-body p-4">
                  <div className="flex items-center justify-between mb-2">
                    <div className="flex items-center space-x-3">
                      <span className="text-2xl">{tool.icon}</span>
                      <div>
                        <h4 className="font-semibold text-base-content text-sm">
                          {tool.name}
                        </h4>
                        <p className="text-xs text-base-content opacity-70">
                          {tool.description}
                        </p>
                      </div>
                    </div>
                    <div className={`badge badge-xs ${
                      tool.status === 'active' ? 'badge-success' : 'badge-secondary'
                    }`}>
                      {tool.status === 'active' ? 'Actif' : 'Inactif'}
                    </div>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Planning et calendrier */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 mb-8">
        {/* Planning de la semaine */}
        <div className="card bg-base-200 shadow-lg">
          <div className="card-body">
            <h3 className="card-title text-base-content mb-4">
              📅 Planning de la Semaine
            </h3>
            <div className="space-y-3">
              <div className="flex items-center justify-between p-3 bg-base-100 rounded-lg">
                <div>
                  <div className="font-medium text-base-content">Lundi 17/06</div>
                  <div className="text-sm text-base-content opacity-70">ACME Corp - Développement CRM</div>
                </div>
                <div className="text-sm text-base-content">8h - 17h</div>
              </div>
              <div className="flex items-center justify-between p-3 bg-base-100 rounded-lg">
                <div>
                  <div className="font-medium text-base-content">Mardi 18/06</div>
                  <div className="text-sm text-base-content opacity-70">TechStart - Tests Analytics</div>
                </div>
                <div className="text-sm text-base-content">9h - 16h</div>
              </div>
              <div className="flex items-center justify-between p-3 bg-base-100 rounded-lg">
                <div>
                  <div className="font-medium text-base-content">Mercredi 19/06</div>
                  <div className="text-sm text-base-content opacity-70">RetailPro - Documentation API</div>
                </div>
                <div className="text-sm text-base-content">10h - 18h</div>
              </div>
            </div>
          </div>
        </div>

        {/* Notifications et alertes */}
        <div className="card bg-base-200 shadow-lg">
          <div className="card-body">
            <h3 className="card-title text-base-content mb-4">
              🔔 Notifications
            </h3>
            <div className="space-y-3">
              <div className="alert alert-warning">
                <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L3.732 16.5c-.77.833.192 2.5 1.732 2.5z" />
                </svg>
                <div>
                  <div className="font-medium">Deadline approchante</div>
                  <div className="text-sm opacity-70">ACME Corp CRM - 2 jours restants</div>
                </div>
              </div>
              
              <div className="alert alert-info">
                <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                <div>
                  <div className="font-medium">Nouvelle tâche assignée</div>
                  <div className="text-sm opacity-70">TechStart - Optimisation base de données</div>
                </div>
              </div>

              <div className="alert alert-success">
                <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                <div>
                  <div className="font-medium">Paiement reçu</div>
                  <div className="text-sm opacity-70">€1,200 - Projet RetailPro</div>
                </div>
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
            ⏰ Pointer Temps
          </button>
          <button className="btn btn-secondary">
            📋 Nouvelle Tâche
          </button>
          <button className="btn btn-accent">
            💬 Messages
          </button>
          <button className="btn btn-info">
            📊 Rapport Activité
          </button>
        </div>
      </div>
    </div>
  );
}; 