import React from 'react';

// --- Icônes Utilitaires ---

const CheckIcon = () => (
  <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="pricing-card-icon size-5 text-primary">
    <path d="M5 12l5 5l10 -10"></path>
  </svg>
);

const CrossIcon = () => (
  <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="pricing-card-icon size-5 text-base-content/50">
    <path d="M18 6l-12 12"></path>
    <path d="M6 6l12 12"></path>
  </svg>
);

const CircleIcon = () => (
  <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="currentColor" className="pricing-card-icon size-2.5 mt-1.5 text-primary">
     <circle cx="12" cy="12" r="12" />
  </svg>
);

const CircleCheckIcon = () => (
  <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="pricing-card-icon size-5 text-primary fill-primary/10">
    <circle cx="12" cy="12" r="10"></circle>
    <path d="M9 12l2 2l4 -4"></path>
  </svg>
);

// --- Types ---

export type FeatureItem = string | { 
  text: string; 
  included?: boolean; // true = check, false = cross/grisé
  icon?: React.ReactNode; // Pour surcharger l'icône spécifique
};

export interface PricingCardProps {
  title: string;
  price: string;
  description: string;
  features: FeatureItem[];
  
  /* Contenu libre (ex: logos de paiement, disclaimer) */
  children?: React.ReactNode;

  /* Options de contenu optionnelles */
  featuresTitle?: string;
  defaultFeatureIcon?: 'check' | 'circle' | 'circle-check' | React.ReactNode; // Ajout de 'circle-check'
  icon?: React.ReactNode;
  currency?: string;
  frequency?: string;
  
  /* Options de mise en avant */
  isPopular?: boolean;
  badgeText?: string;
  
  /* Options de bouton */
  btnText?: string;
  btnClass?: string;
  
  /* Options de style avancé */
  backgroundIcon?: React.ReactNode;
  className?: string;
}

const PricingCard: React.FC<PricingCardProps> = ({ 
  title, 
  price, 
  description, 
  features,
  
  featuresTitle,
  defaultFeatureIcon = 'check',
  icon,
  currency = '$',
  frequency = '/month',
  
  isPopular = false, 
  badgeText = "Most Popular",
  
  btnText = "Get started",
  btnClass = "btn-soft",
  
  backgroundIcon,
  children, // Récupération de children
  className = ""
}) => {

  // Helper pour rendre l'icône d'une feature
  const renderFeatureIcon = (item: FeatureItem) => {
    // 1. Si l'item a sa propre icône, on l'utilise
    if (typeof item === 'object' && item.icon) return item.icon;
    
    // 2. Si l'item est explicitement exclu (included: false), on met une croix
    if (typeof item === 'object' && item.included === false) return <CrossIcon />;

    // 3. Sinon, on utilise l'icône par défaut de la carte
    if (React.isValidElement(defaultFeatureIcon)) return defaultFeatureIcon;
    if (defaultFeatureIcon === 'circle') return <CircleIcon />;
    if (defaultFeatureIcon === 'circle-check') return <CircleCheckIcon />;
    return <CheckIcon />;
  };

  // Helper pour le texte
  const getFeatureText = (item: FeatureItem) => typeof item === 'string' ? item : item.text;
  
  // Helper pour le style (grisé si exclu)
  const getFeatureClass = (item: FeatureItem) => {
    if (typeof item === 'object' && item.included === false) return "opacity-50";
    return "";
  };

  return (
    <div className={`pricing-card ${isPopular ? 'pricing-card-popular' : ''} ${className}`}>
      
      {isPopular && (
        <span className="pricing-card-badge">{badgeText}</span>
      )}

      {backgroundIcon && (
        <div className="absolute top-4 right-4 text-primary/10 pointer-events-none z-0">
          {backgroundIcon}
        </div>
      )}

      <div className="pricing-card-body relative z-10">
        
        <div className="pricing-card-header">
          {icon && (
             <div className={`mb-2 flex justify-center ${isPopular ? 'text-primary-content bg-primary rounded-full w-12 h-12 items-center mx-auto' : 'text-primary'}`}>
               {icon}
             </div>
          )}

          <h3 className="pricing-card-title">{title}</h3>
          <p className="pricing-card-desc">{description}</p>
          
          <div className="pricing-card-price">
            <span className="text-lg opacity-70">{currency}</span>
            <span className="pricing-card-amount">{price}</span>
            <span className="text-sm opacity-70">{frequency}</span>
          </div>
        </div>

        <button className={`btn w-full ${isPopular ? 'btn-primary' : btnClass}`}>
          {btnText}
        </button>

        {featuresTitle && (
          <div className="pricing-card-features-header mt-4 pt-4 border-t border-base-content/10">
            <span className="text-base font-semibold opacity-90">{featuresTitle}</span>
          </div>
        )}

        <ul className={`pricing-card-features ${featuresTitle ? 'mt-2' : ''}`}>
          {features.map((feature, idx) => (
            <li key={idx} className={`pricing-card-feature ${getFeatureClass(feature)}`}>
              {renderFeatureIcon(feature)}
              <span>{getFeatureText(feature)}</span>
            </li>
          ))}
        </ul>

        {/* Zone de contenu libre (ex: logos de paiement) - Placée en bas ou avant le bouton selon besoin */}
        {/* Note: Dans PricingDetailed, les logos sont avant le bouton. 
            Pour l'instant, on le met APRES les features (ordre naturel du flux).
            Si on veut le mettre AVANT le bouton, il faudrait une prop spécifique ou revoir l'ordre.
            Ici, on le met à la fin pour la flexibilité générale. */}
        {children && <div className="mt-4">{children}</div>}
      </div>
    </div>
  );
};

export default PricingCard;
