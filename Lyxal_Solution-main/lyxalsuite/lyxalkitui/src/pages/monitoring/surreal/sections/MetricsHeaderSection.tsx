import React from 'react';

export function MetricsHeaderSection() {
  return (
    <section id="metrics-header-wrapper" className="w-full flex justify-center" style={{ paddingTop: '2rem', paddingBottom: '2rem' }} aria-labelledby="metrics-title">
      <div id="metrics-header-container" className="w-[90%] mx-auto">
        <div id="metrics-header-content" className="w-full flex flex-col text-center">
          <div className="grid grid-cols-1 sm:grid-cols-1 lg:grid-cols-1 gap-6">
            <div id="metrics-title-section" className="w-full flex flex-col" aria-label="Titre de la section métriques">
              <div id="metrics-title-wrapper" className="w-full">
                <h2 id="metrics-title" className="text-3xl lg:text-4xl font-bold mb-6">
                  Métriques SurrealDB
                </h2>
              </div>
            </div>
            <div id="metrics-description-section" className="w-full flex flex-col" aria-label="Description des métriques">
              <div id="metrics-description-wrapper" className="w-full">
                <p id="metrics-description" className="text-base lg:text-lg opacity-85" aria-describedby="metrics-title">
                  Performances et état de votre base de données en temps réel
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}