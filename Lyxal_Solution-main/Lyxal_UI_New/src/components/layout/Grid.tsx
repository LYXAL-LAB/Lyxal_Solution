import React, { type ReactNode } from 'react';

type GridCols = 1 | 2 | 3 | 4 | 12;
type GridGap = 'none' | 'sm' | 'md' | 'lg';
type GridVariant = 'default' | 'dashboard' | 'dashboard-collapsed' | 'holy-grail' | 'auto-fit';

interface GridProps {
  children: ReactNode;
  
  /* Configuration de base */
  cols?: GridCols;
  gap?: GridGap;
  variant?: GridVariant;
  
  /* Pour désactiver le responsive mobile (garder les colonnes) */
  keepColsOnMobile?: boolean;
  
  className?: string;
  
  /* Props HTML standard */
  style?: React.CSSProperties;
  id?: string;
  as?: 'div' | 'section' | 'ul' | 'main' | 'aside'; // Polymorphisme
}

const Grid: React.FC<GridProps> = ({ 
  children, 
  cols,
  gap = 'md',
  variant = 'default',
  keepColsOnMobile = false,
  className = '',
  as: Component = 'div', // Par défaut c'est une <div>
  ...props
}) => {
  
  // Construction des classes
  const classes = [
    'grid-root',
    variant !== 'default' ? `grid-${variant}` : '',
    cols ? `grid-cols-${cols}` : '', // Si cols est défini, on l'applique
    gap !== 'md' ? `gap-${gap}` : '', // md est le défaut
    keepColsOnMobile ? 'grid-keep-cols' : '',
    className
  ].filter(Boolean).join(' ');

  return (
    <Component className={classes} {...props}>
      {children}
    </Component>
  );
};

export default Grid;

