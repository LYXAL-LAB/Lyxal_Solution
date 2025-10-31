import React from 'react';
import {
  HiOutlineTrash,
  HiOutlineDocumentReport,
  HiOutlineCog,
  HiOutlineDownload
} from 'react-icons/hi';

interface MaintenanceSectionProps {
  className?: string;
  onClearCache?: () => void;
  onPerformanceReport?: () => void;
  onOptimizeDatabase?: () => void;
  onExportLogs?: () => void;
}

export const MaintenanceSection: React.FC<MaintenanceSectionProps> = ({ 
  className = '',
  onClearCache,
  onPerformanceReport,
  onOptimizeDatabase,
  onExportLogs
}) => {
  return (
    <section id="maintenance-wrapper" className={`w-full flex justify-center ${className}`} style={{ paddingTop: '2rem', paddingBottom: '2rem' }} aria-labelledby="maintenance-title">
      <div id="maintenance-container" className="w-[90%] mx-auto">
        <div id="maintenance-content" className="w-full">
          {/* Restauration de la structure card originale avec les classes standards DaisyUI */}
          <div className="card bg-base-200 shadow-xl rounded-2xl border border-base-300 hover:shadow-2xl transition-all duration-300 flex flex-col items-center animate-fade-in-scale" style={{paddingTop: '2rem', paddingBottom: '2rem'}}>
            <div id="maintenance-metrics-content" className="w-[90%] flex flex-col items-center text-center">
              <div id="maintenance-title-wrapper" className="w-full flex justify-center">
                <h2 id="maintenance-title" className="card-title text-3xl lg:text-4xl font-bold text-base-content justify-center mb-4 flex items-center gap-3 animate-fade-in-up">
                  <HiOutlineCog className="w-8 h-8 lg:w-10 lg:h-10" aria-hidden="true" />
                  Actions de Maintenance
                </h2>
              </div>
              <div id="maintenance-description-wrapper" className="w-full flex justify-center">
                <p id="maintenance-description" className="text-lg text-base-content/85 max-w-2xl text-center animate-slide-in-right" style={{ animationDelay: '0.2s' }}>
                  Outils de gestion et d'optimisation pour maintenir les performances optimales
                </p>
              </div>
              <div id="maintenance-buttons-grid" className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6 w-full justify-items-center" role="group" aria-labelledby="maintenance-title">
                <div id="clear-cache-button-wrapper" className="w-full">
                  <button 
                    id="clear-cache-btn" 
                    className="btn btn-outline btn-warning btn-lg h-auto p-6 flex flex-col items-center justify-center gap-2 hover:scale-[1.02] hover:-translate-y-1 hover:shadow-lg transition-all duration-300 ease-out w-full focus:ring-2 focus:ring-warning focus:ring-offset-2 focus:outline-none hover-lift animate-fade-in-up"
                    style={{ paddingTop: '0.2rem', paddingBottom: '0.2rem', animationDelay: '0.4s' }}
                    onClick={onClearCache}
                    aria-label="Vider le cache du système"
                    aria-describedby="clear-cache-text"
                  >
                    <div id="clear-cache-icon" className="flex items-center justify-center" aria-hidden="true">
                      <HiOutlineTrash className="w-8 h-8" />
                    </div>
                    <div id="clear-cache-text-wrapper" className="flex items-center justify-center">
                      <span id="clear-cache-text" className="text-sm font-semibold">Vider le cache</span>
                    </div>
                  </button>
                </div>
                
                <div id="performance-report-button-wrapper" className="w-full">
                  <button 
                    id="performance-report-btn" 
                    className="btn btn-outline btn-info btn-lg h-auto p-6 flex flex-col items-center justify-center gap-2 hover:scale-105 transition-transform w-full focus:ring-2 focus:ring-info focus:ring-offset-2 focus:outline-none hover-lift animate-fade-in-up"
                    style={{ paddingTop: '0.2rem', paddingBottom: '0.2rem', animationDelay: '0.5s' }}
                    onClick={onPerformanceReport}
                    aria-label="Générer un rapport de performance détaillé"
                    aria-describedby="performance-report-text"
                  >
                    <div id="performance-report-icon" className="flex items-center justify-center" aria-hidden="true">
                      <HiOutlineDocumentReport className="w-8 h-8" />
                    </div>
                    <div id="performance-report-text-wrapper" className="flex items-center justify-center">
                      <span id="performance-report-text" className="text-sm font-semibold">Rapport de performance</span>
                    </div>
                  </button>
                </div>
                
                <div id="optimize-db-button-wrapper" className="w-full">
                  <button 
                    id="optimize-db-btn" 
                    className="btn btn-outline btn-secondary btn-lg h-auto p-6 flex flex-col items-center justify-center gap-2 hover:scale-105 transition-transform w-full focus:ring-2 focus:ring-secondary focus:ring-offset-2 focus:outline-none hover-lift animate-fade-in-up"
                    style={{ paddingTop: '0.2rem', paddingBottom: '0.2rem', animationDelay: '0.6s' }}
                    onClick={onOptimizeDatabase}
                    aria-label="Optimiser les performances de la base de données"
                    aria-describedby="optimize-db-text"
                  >
                    <div id="optimize-db-icon" className="flex items-center justify-center" aria-hidden="true">
                      <HiOutlineCog className="w-8 h-8" />
                    </div>
                    <div id="optimize-db-text-wrapper" className="flex items-center justify-center">
                      <span id="optimize-db-text" className="text-sm font-semibold">Optimiser la base</span>
                    </div>
                  </button>
                </div>
                
                <div id="export-logs-button-wrapper" className="w-full">
                  <button 
                    id="export-logs-btn" 
                    className="btn btn-outline btn-accent btn-lg h-auto p-6 flex flex-col items-center justify-center gap-2 hover:scale-105 transition-transform w-full focus:ring-2 focus:ring-accent focus:ring-offset-2 focus:outline-none hover-lift animate-fade-in-up"
                    style={{ paddingTop: '0.2rem', paddingBottom: '0.2rem', animationDelay: '0.7s' }}
                    onClick={onExportLogs}
                    aria-label="Exporter les logs système pour analyse"
                    aria-describedby="export-logs-text"
                  >
                    <div id="export-logs-icon" className="flex items-center justify-center" aria-hidden="true">
                      <HiOutlineDownload className="w-8 h-8" />
                    </div>
                    <div id="export-logs-text-wrapper" className="flex items-center justify-center">
                      <span id="export-logs-text" className="text-sm font-semibold">Exporter les logs</span>
                    </div>
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}; 