import React, { type ReactNode } from 'react';

type SectionPadding = 'none' | 'sm' | 'md' | 'lg' | 'xl';
type SectionWidth = 'standard' | 'narrow' | 'wide' | 'full';

// On permet soit un booléen (true = base-100), soit une couleur spécifique
type SectionBgColor = 'base' | 'muted' | 'primary' | 'dark';

interface SectionProps {
  children: ReactNode;
  
  /* Configuration */
  padding?: SectionPadding;
  width?: SectionWidth;
  
  /* Gestion de la couleur de fond :
     - false / undefined : transparent (défaut)
     - true : base-100
     - 'muted' : base-200, etc.
  */
  color?: boolean | SectionBgColor;
  
  /* Structure */
  id?: string;
  className?: string;
  containerClassName?: string;
  
  /* Style inline */
  style?: React.CSSProperties;
}

const Section: React.FC<SectionProps> = ({ 
  children, 
  padding = 'md',
  width = 'standard',
  color = false, // Par défaut : transparent
  id,
  className = '',
  containerClassName = '',
  style
}) => {
  
  // Détermination de la classe de fond
  let bgClass = '';
  
  if (color === true) {
    bgClass = 'section-bg-base'; // Cas booléen : on met le standard (base-100)
  } else if (typeof color === 'string') {
    bgClass = `section-bg-${color}`; // Cas string : on met la variante demandée
  }
  // Si color === false (défaut), bgClass reste vide -> transparent via CSS par défaut

  // Classes pour la section externe
  const rootClasses = [
    'section-root',
    `section-py-${padding}`,
    bgClass,
    className
  ].filter(Boolean).join(' ');

  // Classes pour le conteneur interne
  const containerClasses = [
    'section-container',
    width !== 'standard' ? `section-width-${width}` : '',
    containerClassName
  ].filter(Boolean).join(' ');

  return (
    <section id={id} className={rootClasses} style={style}>
      <div className={containerClasses}>
        {children}
      </div>
    </section>
  );
};

export default Section;
