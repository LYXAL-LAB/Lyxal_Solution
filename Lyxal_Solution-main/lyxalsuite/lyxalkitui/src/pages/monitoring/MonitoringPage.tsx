import React from 'react';

interface MonitoringPageProps {
  className?: string;
}

const MonitoringPage: React.FC<MonitoringPageProps> = ({ className = '' }) => {
  return (
    <div className={`min-h-screen bg-base-100 ${className}`} style={{ minWidth: '320px' }}>
      {/* Header */}
      <div className="w-full bg-base-100">
        <div className="hero-container" style={{ width: '90%', margin: '0 auto' }}>
          <div className="metrics-content" style={{ width: '100%' }}>
            <div className="content" style={{ paddingTop: '2rem', paddingBottom: '2rem' }}>
              <div>
                <h1 className="text-3xl md:text-4xl lg:text-5xl font-bold text-base-content">
                  Centre de Monitoring
                </h1>
              </div>
              <div>
                <p className="text-base md:text-lg opacity-70 text-base-content mt-4">
                  Surveillance et supervision de tous vos systèmes
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Content */}
      <div className="w-full">
        <div className="hero-container" style={{ width: '90%', margin: '0 auto' }}>
          <div className="metrics-content" style={{ width: '100%' }}>
            <div className="content" style={{ paddingBottom: '2rem' }}>
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                
                {/* SurrealDB Card */}
                <div className="card bg-base-200 shadow-lg hover:shadow-xl transition-all duration-200 h-48 cursor-pointer hover:bg-base-300">
                  <div className="card-body p-6 flex flex-col justify-center items-center text-center">
                    <div className="flex flex-col items-center space-y-4">
                      <div className="p-3 rounded-full bg-primary text-primary-content">
                        <svg className="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 7v10c0 2.21 3.582 4 8 4s8-1.79 8-4V7M4 7c0 2.21 3.582 4 8 4s8-1.79 8-4M4 7c0-2.21 3.582-4 8-4s8 1.79 8 4" />
                        </svg>
                      </div>
                      <div>
                        <h3 className="text-xl font-semibold text-base-content mb-2">
                          SurrealDB
                        </h3>
                        <p className="text-base-content opacity-70 text-sm">
                          Monitoring de la base de données
                        </p>
                      </div>
                      <div className="mt-auto">
                        <div className="badge badge-success">Disponible</div>
                      </div>
                    </div>
                  </div>
                </div>

                {/* Analytics Card */}
                <div className="card bg-base-200 shadow-lg h-48 opacity-60">
                  <div className="card-body p-6 flex flex-col justify-center items-center text-center">
                    <div className="flex flex-col items-center space-y-4">
                      <div className="p-3 rounded-full bg-base-300 text-base-content">
                        <svg className="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
                        </svg>
                      </div>
                      <div>
                        <h3 className="text-xl font-semibold text-base-content mb-2">
                          Analytics
                        </h3>
                        <p className="text-base-content opacity-70 text-sm">
                          Métriques et analyses
                        </p>
                      </div>
                      <div className="mt-auto">
                        <div className="badge badge-warning">Bientôt disponible</div>
                      </div>
                    </div>
                  </div>
                </div>

                {/* Infrastructure Card */}
                <div className="card bg-base-200 shadow-lg h-48 opacity-60">
                  <div className="card-body p-6 flex flex-col justify-center items-center text-center">
                    <div className="flex flex-col items-center space-y-4">
                      <div className="p-3 rounded-full bg-base-300 text-base-content">
                        <svg className="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 12h14M5 12a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v4a2 2 0 01-2 2M5 12a2 2 0 00-2 2v4a2 2 0 002 2h14a2 2 0 002-2v-4a2 2 0 00-2-2" />
                        </svg>
                      </div>
                      <div>
                        <h3 className="text-xl font-semibold text-base-content mb-2">
                          Infrastructure
                        </h3>
                        <p className="text-base-content opacity-70 text-sm">
                          Serveurs et services
                        </p>
                      </div>
                      <div className="mt-auto">
                        <div className="badge badge-warning">Bientôt disponible</div>
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

export default MonitoringPage; 