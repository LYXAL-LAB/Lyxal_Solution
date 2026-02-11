import React from 'react';

interface MetricCard {
  id: string;
  title: string;
  value: string | number;
  unit?: string;
  icon: React.ReactNode;
  color: 'primary' | 'secondary' | 'success' | 'warning' | 'error';
  change?: {
    value: number;
    type: 'increase' | 'decrease' | 'neutral';
  };
  threshold?: {
    good: number;
    warning: number;
  };
}

interface MetricsGridSectionProps {
  metricCards: MetricCard[];
  className?: string;
}

export const MetricsGridSection: React.FC<MetricsGridSectionProps> = ({ 
  metricCards, 
  className = '' 
}) => {
  return (
    <section id="metrics-grid-wrapper" className={`w-full flex justify-center ${className}`} style={{ paddingTop: '2rem', paddingBottom: '2rem' }} aria-label="Grille des métriques de performance">
      <div id="metrics-grid-container" className="w-[90%] mx-auto">
        <div id="metrics-grid-content" className="w-full" style={{ paddingBottom: '2rem' }}>
          {/* Titre de section H2 selon les standards */}
          <h2 className="text-3xl lg:text-4xl font-bold text-center mb-8 text-base-content animate-fade-in-up">
            Métriques de Performance
          </h2>
          
          {/* Grille des métriques - Layout professionnel avec espacement uniforme */}
          <div id="metrics-grid" className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-8 mb-16 w-full py-12" role="grid" aria-label="Métriques de performance SurrealDB">
            {metricCards.map((card, index) => (
              <div
                key={card.id}
                id={`metric-card-${card.id}`}
                className="metric-card flex justify-center animate-fade-in-up"
                style={{ animationDelay: `${index * 0.1}s` }}
                role="gridcell"
              >
                <div 
                  id={`metric-stat-${card.id}`} 
                  className="bg-base-200 shadow-xl rounded-2xl border border-base-300 hover:shadow-2xl transition-all duration-300 hover-lift p-6 w-full h-48 flex flex-col items-center justify-center text-center gap-2 focus:ring-2 focus:ring-primary focus:ring-offset-2 focus:outline-none"
                  tabIndex={0}
                  role="article"
                  aria-labelledby={`metric-title-${card.id}`}
                  aria-describedby={`metric-value-${card.id}`}
                >
                  <div id={`metric-icon-${card.id}`} className="text-primary flex items-center justify-center mb-4 animate-fade-in-scale" style={{ animationDelay: `${index * 0.1 + 0.2}s` }} aria-hidden="true">
                    {card.icon}
                  </div>
                  <div id={`metric-title-${card.id}`} className="text-base-content/85 text-sm font-medium text-center mb-3">
                    {card.title}
                  </div>
                  <div id={`metric-value-${card.id}`} className={`text-2xl font-bold text-center mb-2 ${
                    card.color === 'primary' ? 'text-primary' :
                    card.color === 'secondary' ? 'text-secondary' :
                    card.color === 'success' ? 'text-success' :
                    card.color === 'warning' ? 'text-warning' :
                    card.color === 'error' ? 'text-error' : 'text-base-content'
                  }`}>
                    {card.value}
                    {card.unit && <span id={`metric-unit-${card.id}`} className="text-sm opacity-85 ml-1">{card.unit}</span>}
                  </div>
                  {card.change && (
                    <div id={`metric-change-${card.id}`} className="flex items-center justify-center animate-slide-in-right" style={{ animationDelay: `${index * 0.1 + 0.4}s` }}>
                      <div 
                        id={`metric-badge-${card.id}`} 
                        className={`badge badge-sm ${
                          card.change.type === 'increase' ? 'badge-success' :
                          card.change.type === 'decrease' ? 'badge-error' : 'badge-primary'
                        }`}
                        aria-label={`Évolution: ${card.change.type === 'increase' ? 'augmentation' : card.change.type === 'decrease' ? 'diminution' : 'stable'} de ${Math.abs(card.change.value)}%`}
                      >
                        {card.change.type === 'increase' ? '↗' : card.change.type === 'decrease' ? '↘' : '→'}
                        {card.change.value > 0 ? '+' : ''}{card.change.value}%
                      </div>
                    </div>
                  )}
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
}; 