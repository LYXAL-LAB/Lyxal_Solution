import React from 'react';
import Layout from './components/app/Layout';

// Composant pour afficher l'aperçu des couleurs d'un thème avec 4 cercles colorés
export const ThemeColorPreview: React.FC<{ theme: string; className?: string }> = ({ theme, className = "mr-3" }) => {
  return (
    <div 
      className={`w-6 h-6 rounded-lg ${className} flex-shrink-0 border border-base-content/20 overflow-hidden p-0.5`}
      data-theme={theme}
    >
      <div className="w-full h-full grid grid-cols-2 grid-rows-2 gap-0.5">
        <div className="bg-primary rounded-full w-2 h-2"></div>
        <div className="bg-secondary rounded-full w-2 h-2"></div>
        <div className="bg-accent rounded-full w-2 h-2"></div>
        <div className="bg-neutral rounded-full w-2 h-2"></div>
      </div>
    </div>
  );
};

function App() {
  return (
    <Layout
      initialTheme="light"
      footerProps={{
        companyName: "LYXAL Platform"
      }}
    >
      {/* Contenu de la page principale */}
      <div id="page-content" className="flex-1 p-6 overflow-auto">
        <div id="content-wrapper" className="max-w-7xl mx-auto">
          <h1 id="page-title" className="text-3xl font-bold text-base-content mb-6">LYXAL Master Console</h1>
          <div id="dashboard-grid" className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {/* Card de statut système */}
            <div id="system-status-card" className="card bg-base-100 shadow-xl">
              <div className="card-body">
                <h2 id="system-status-title" className="card-title text-success">
                  <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24" aria-hidden="true">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                  </svg>
                  Système Opérationnel
                </h2>
                <p id="system-status-description">Tous les services sont en ligne</p>
                <div className="card-actions justify-end">
                  <div id="system-status-badge" className="badge badge-success">En ligne</div>
                </div>
              </div>
            </div>

            {/* Card des investisseurs */}
            <div id="investors-card" className="card bg-base-100 shadow-xl">
              <div className="card-body">
                <h2 id="investors-title" className="card-title">
                  <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24" aria-hidden="true">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
                  </svg>
                  Investisseurs Actifs
                </h2>
                <p id="investors-description">Gestion des comptes investisseurs</p>
                <div className="card-actions justify-end">
                  <div id="investors-badge" className="badge badge-info">127 actifs</div>
                </div>
              </div>
            </div>

            {/* Card des plateformes */}
            <div id="platforms-card" className="card bg-base-100 shadow-xl">
              <div className="card-body">
                <h2 id="platforms-title" className="card-title">
                  <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24" aria-hidden="true">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10" />
                  </svg>
                  Plateformes
                </h2>
                <p id="platforms-description">Supervision des instances client</p>
                <div className="card-actions justify-end">
                  <div id="platforms-badge" className="badge badge-warning">8 en maintenance</div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </Layout>
  );
}

export default App;