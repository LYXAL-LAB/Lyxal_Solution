import React from 'react';
import {
  HiOutlineBadgeCheck,
  HiOutlineLightningBolt,
  HiOutlineRefresh,
  HiOutlineExclamationCircle
} from 'react-icons/hi';

interface HeroHeaderSectionProps {
  connectionStatus: 'connected' | 'connecting' | 'disconnected';
  lastUpdate?: Date | null;
  isRefreshing?: boolean;
  onRefresh?: () => void;
  className?: string;
}

export const HeroHeaderSection: React.FC<HeroHeaderSectionProps> = ({
  connectionStatus,
  lastUpdate,
  isRefreshing = false,
  onRefresh,
  className = ''
}) => {
  return (
    <section id="hero-header-wrapper" className={`bg-gradient-to-r from-primary to-secondary text-primary-content flex items-center justify-center min-h-[60vh] ${className}`} aria-labelledby="hero-title">
      <div id="hero-header-container" className="w-[90%] mx-auto px-6 sm:px-8 lg:px-12 py-16 lg:py-24">
        <div id="hero-header-content" className="w-full">
          {/* Layout responsive amélioré */}
          <div className="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-8 text-center lg:text-left">
            <div id="hero-text-section" className="flex-1 flex flex-col items-center lg:items-start">
              {/* Titre principal - Icône plus petite pour éviter le retour à la ligne */}
              <h1 id="hero-title" className="text-4xl lg:text-5xl xl:text-6xl font-bold mb-6 leading-tight flex items-center gap-3 flex-wrap justify-center lg:justify-start">
                <HiOutlineBadgeCheck className="w-10 h-10 lg:w-12 lg:h-12 flex-shrink-0" aria-hidden="true" />
                <span className="whitespace-nowrap">Monitoring SurrealDB</span>
              </h1>
              
              {/* Sous-titre - Texte plus court */}
              <h2 id="hero-subtitle" className="text-xl md:text-2xl lg:text-3xl text-primary-content/85 mb-8 text-center lg:text-left font-semibold max-w-2xl">
                Surveillance temps réel des performances
              </h2>
              
              {/* Section statut - Layout vertical centré */}
              <div id="hero-status-section" className="flex flex-col items-center lg:items-start gap-4 w-full max-w-md" aria-label="Statut du système et dernière mise à jour">
                {/* Statut de connexion - Centré sur mobile */}
                <div 
                  id="connection-status-badge" 
                  className={`badge badge-lg px-6 py-3 text-base font-semibold flex items-center gap-2 ${
                    connectionStatus === 'connected' ? 'badge-success' :
                    connectionStatus === 'connecting' ? 'badge-warning' : 'badge-error'
                  }`}
                  role="status"
                  aria-live="polite"
                  aria-label={`Statut de connexion: ${
                    connectionStatus === 'connected' ? 'Système en ligne' :
                    connectionStatus === 'connecting' ? 'Connexion en cours' : 'Système hors ligne'
                  }`}
                >
                  {connectionStatus === 'connected' ? (
                    <>
                      <HiOutlineLightningBolt className="w-4 h-4" aria-hidden="true" />
                      Système en ligne
                    </>
                  ) : connectionStatus === 'connecting' ? (
                    <>
                      <HiOutlineRefresh className="w-4 h-4 animate-spin" aria-hidden="true" />
                      Connexion en cours...
                    </>
                  ) : (
                    <>
                      <HiOutlineExclamationCircle className="w-4 h-4" aria-hidden="true" />
                      Système hors ligne
                    </>
                  )}
                </div>
                
                {/* Dernière mise à jour - Alignée avec le badge */}
                {lastUpdate && (
                  <div id="last-update-info" className="text-primary-content/85 text-sm text-center lg:text-left" aria-label={`Dernière mise à jour: ${lastUpdate.toLocaleTimeString()}`}>
                    Dernière mise à jour : {lastUpdate.toLocaleTimeString()}
                  </div>
                )}
              </div>
            </div>
            
            {/* Actions Header - Grille responsive pour conformité */}
            <div id="hero-actions-section" className="flex justify-center lg:justify-end" aria-label="Actions de contrôle du monitoring">
              <div className="grid grid-cols-1 gap-4">
                <button 
                  id="refresh-button"
                  className={`btn btn-outline btn-lg text-primary-content border-primary-content hover:bg-primary-content hover:text-primary transition-all duration-300 flex items-center gap-3 px-4 focus:ring-2 focus:ring-primary focus:ring-offset-2 focus:outline-none ${isRefreshing ? 'loading' : ''}`}
                  onClick={onRefresh}
                  disabled={isRefreshing}
                  aria-label="Actualiser les données de monitoring"
                  aria-describedby={lastUpdate ? "last-update-info" : undefined}
                >
                  {!isRefreshing && <HiOutlineRefresh className="w-5 h-5" aria-hidden="true" />}
                  Actualiser les données
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}; 