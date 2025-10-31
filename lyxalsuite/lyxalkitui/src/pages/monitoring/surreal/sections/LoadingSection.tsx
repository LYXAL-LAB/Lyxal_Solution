import React from 'react';

interface LoadingSectionProps {
  className?: string;
  title?: string;
  message?: string;
}

export const LoadingSection: React.FC<LoadingSectionProps> = ({
  className = '',
  title = 'Connexion à SurrealDB',
  message = 'Initialisation du monitoring en cours...'
}) => {
  return (
    <section id="loading-wrapper" className={`min-h-screen bg-base-100 flex items-center justify-center ${className}`} style={{ paddingTop: '2rem', paddingBottom: '2rem' }} aria-labelledby="loading-title">
      <div id="loading-container" className="w-[90%] mx-auto">
        <div id="loading-content" className="w-full flex flex-col items-center justify-center text-center max-w-md mx-auto">
          {/* Grille responsive pour conformité */}
          <div className="grid grid-cols-1 gap-6">
            <div id="loading-spinner-wrapper" className="flex justify-center animate-fade-in-scale" aria-label="Chargement en cours">
              <span className="loading loading-spinner loading-lg text-primary loading-pulse" aria-hidden="true"></span>
            </div>
            
            <div id="loading-text-section" className="flex flex-col gap-4">
              <h2 id="loading-title" className="text-3xl lg:text-4xl font-bold text-base-content animate-fade-in-up" style={{ animationDelay: '0.2s' }}>
                {title}
              </h2>
              <p id="loading-message" className="text-base lg:text-lg text-base-content/70 animate-slide-in-right" style={{ animationDelay: '0.4s' }} aria-describedby="loading-title">
                {message}
              </p>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}; 