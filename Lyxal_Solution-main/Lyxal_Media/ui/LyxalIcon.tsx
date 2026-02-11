import React from 'react';

export interface LyxalIconProps extends React.SVGProps<SVGSVGElement> {
  /** Nom du pack (ex: lucide) */
  pack?: string;
  /** Nom de l'icône (ex: home) */
  name?: string;
  /** Contenu SVG brut (prioritaire sur pack/name) */
  svgContent?: string;
  /** Taille en pixels (défaut: 24) */
  size?: number | string;
  /** Couleur (défaut: currentColor) */
  color?: string;
  className?: string;
}

/**
 * Composant LyxalIcon
 * Affiche une icône SVG normalisée issue du module Lyxal_SVG.
 */
export const LyxalIcon: React.FC<LyxalIconProps> = ({
  pack = 'lucide',
  name,
  svgContent,
  size = 24,
  color = 'currentColor',
  className = '',
  style,
  ...props
}) => {
  // 1. Si on a le contenu brut (ex: venant de la DB)
  if (svgContent) {
    // On nettoie le <svg> wrapper pour ne garder que le contenu interne ou on l'injecte tel quel
    // Mais nos SVGs en DB sont des tags <svg> complets.
    // L'astuce est de parser ou d'utiliser un span wrapper qui imite le svg.
    // Le mieux pour React est souvent d'avoir le PATH interne, mais ici on a stocké le SVG complet.
    
    // Approche robuste : injecter le SVG complet dans un conteneur dimensionné
    return (
      <span
        className={`lyxal-icon inline-flex items-center justify-center ${className}`}
        style={{ 
          width: size, 
          height: size, 
          color: color,
          ...style 
        }}
        dangerouslySetInnerHTML={{ __html: svgContent }}
        {...props as any} // Cast pour éviter conflits de props span vs svg
      />
    );
  }

  // 2. Fallback (ou chargement asynchrone à implémenter)
  return (
    <span 
        className={`lyxal-icon-placeholder ${className}`} 
        style={{ width: size, height: size, display: 'inline-block', background: '#eee', borderRadius: 4 }} 
        title={`Missing icon: ${pack}:${name}`}
    />
  );
};

