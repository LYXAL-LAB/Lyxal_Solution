import React from 'react';

export const InvestorDashboard: React.FC = () => {
  const globalMetrics = [
    {
      title: 'SaaS Actifs',
      value: '247',
      change: { value: 12, type: 'increase' as const },
      icon: '🏢',
      color: 'bg-primary text-primary-content'
    },
    {
      title: 'Revenus Mensuels',
      value: '€127,450',
      change: { value: 8.5, type: 'increase' as const },
      icon: '💰',
      color: 'bg-success text-success-content'
    },
    {
      title: 'Utilisateurs Actifs',
      value: '45,892',
      change: { value: 15.3, type: 'increase' as const },
      icon: '👥',
      color: 'bg-info text-info-content'
    },
    {
      title: 'Taux de Conversion',
      value: '3.2%',
      change: { value: -2.1, type: 'decrease' as const },
      icon: '📈',
      color: 'bg-warning text-warning-content'
    }
  ];

  const topPerformingSaas = [
    { name: 'ACME Corp CRM', revenue: '€15,420', growth: '+23%', users: 1250 },
    { name: 'TechStart Analytics', revenue: '€12,890', growth: '+18%', users: 980 },
    { name: 'RetailPro Suite', revenue: '€11,340', growth: '+15%', users: 756 },
    { name: 'HealthCare Plus', revenue: '€9,870', growth: '+12%', users: 634 },
    { name: 'EduTech Platform', revenue: '€8,560', growth: '+9%', users: 523 }
  ];

  return (
    <div className="container mx-auto px-4 py-8">
      {/* Métriques globales */}
      <div className="mb-8">
        <h2 className="text-2xl font-bold text-base-content mb-6">
          📊 Vue d'ensemble de la plateforme
        </h2>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          {globalMetrics.map((metric, index) => (
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

      {/* Graphiques et analytics */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 mb-8">
        {/* Évolution des revenus */}
        <div className="card bg-base-200 shadow-lg">
          <div className="card-body">
            <h3 className="card-title text-base-content mb-4">
              📈 Évolution des Revenus (6 derniers mois)
            </h3>
            <div className="h-64 flex items-center justify-center bg-base-100 rounded-lg">
              <div className="text-center">
                <div className="text-4xl mb-2">📊</div>
                <p className="text-base-content opacity-70">
                  Graphique interactif à implémenter
                </p>
                <p className="text-sm text-base-content opacity-50">
                  (Chart.js ou Recharts)
                </p>
              </div>
            </div>
          </div>
        </div>

        {/* Répartition par secteur */}
        <div className="card bg-base-200 shadow-lg">
          <div className="card-body">
            <h3 className="card-title text-base-content mb-4">
              🥧 Répartition par Secteur
            </h3>
            <div className="h-64 flex items-center justify-center bg-base-100 rounded-lg">
              <div className="text-center">
                <div className="text-4xl mb-2">🎯</div>
                <p className="text-base-content opacity-70">
                  Graphique en secteurs à implémenter
                </p>
                <div className="mt-4 space-y-2">
                  <div className="flex items-center justify-between text-sm">
                    <span>🏢 Entreprise</span>
                    <span className="badge badge-primary">45%</span>
                  </div>
                  <div className="flex items-center justify-between text-sm">
                    <span>🛒 E-commerce</span>
                    <span className="badge badge-secondary">30%</span>
                  </div>
                  <div className="flex items-center justify-between text-sm">
                    <span>🎓 Éducation</span>
                    <span className="badge badge-accent">25%</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Top SaaS performants */}
      <div className="card bg-base-200 shadow-lg">
        <div className="card-body">
          <h3 className="card-title text-base-content mb-6">
            🏆 Top 5 SaaS Performants
          </h3>
          <div className="overflow-x-auto">
            <table className="table table-zebra w-full">
              <thead>
                <tr>
                  <th className="text-base-content">Rang</th>
                  <th className="text-base-content">SaaS</th>
                  <th className="text-base-content">Revenus</th>
                  <th className="text-base-content">Croissance</th>
                  <th className="text-base-content">Utilisateurs</th>
                  <th className="text-base-content">Actions</th>
                </tr>
              </thead>
              <tbody>
                {topPerformingSaas.map((saas, index) => (
                  <tr key={index} className="hover:bg-base-300">
                    <td>
                      <div className="flex items-center space-x-2">
                        <span className="text-lg">
                          {index === 0 ? '🥇' : index === 1 ? '🥈' : index === 2 ? '🥉' : `#${index + 1}`}
                        </span>
                      </div>
                    </td>
                    <td>
                      <div className="font-medium text-base-content">
                        {saas.name}
                      </div>
                    </td>
                    <td>
                      <div className="font-semibold text-success">
                        {saas.revenue}
                      </div>
                    </td>
                    <td>
                      <div className="badge badge-success">
                        {saas.growth}
                      </div>
                    </td>
                    <td>
                      <div className="text-base-content">
                        {saas.users.toLocaleString()}
                      </div>
                    </td>
                    <td>
                      <div className="flex space-x-2">
                        <button className="btn btn-xs btn-primary">
                          Détails
                        </button>
                        <button className="btn btn-xs btn-outline">
                          Analytics
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </div>

      {/* Actions rapides */}
      <div className="mt-8">
        <h3 className="text-xl font-bold text-base-content mb-4">
          ⚡ Actions Rapides
        </h3>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <button className="btn btn-primary btn-lg">
            📊 Rapport Complet
          </button>
          <button className="btn btn-secondary btn-lg">
            💼 Gestion Portfolio
          </button>
          <button className="btn btn-accent btn-lg">
            🎯 Stratégie & ROI
          </button>
        </div>
      </div>
    </div>
  );
};