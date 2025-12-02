/**
 * Composant UniversalButton - Bouton universel avec toutes les caractéristiques
 * Combine les 89 variantes en un seul composant configurable
 */

import React, { useState, useEffect } from 'react';
import { buildButtonClasses, Size, Color, Variant, Animation, Shape, VisualTheme } from './buttonStyles';

// ============= TYPES =============

export interface UniversalButtonProps {
  // Basiques
  size?: Size;
  color?: Color;
  variant?: Variant;
  shape?: Shape;
  
  // Animations & Effets
  animation?: Animation;
  visualTheme?: VisualTheme;
  
  // Icône
  icon?: React.ReactNode;
  iconPosition?: 'left' | 'right' | 'only' | 'none';
  
  // États
  disabled?: boolean;
  loading?: boolean;
  success?: boolean;
  
  // Effets spéciaux
  hasRipple?: boolean;
  hasProgress?: boolean;
  progressValue?: number;
  hasBadge?: boolean;
  badgeContent?: string | number;
  hasGlow?: boolean;
  
  // Layout
  fullWidth?: boolean;
  
  // Callbacks
  onClick?: (e: React.MouseEvent<HTMLButtonElement>) => void;
  
  // Contenu
  children?: React.ReactNode;
  
  // HTML attributes
  type?: 'button' | 'submit' | 'reset';
  ariaLabel?: string;
}

interface Ripple {
  id: number;
  x: number;
  y: number;
}

// ============= COMPOSANT =============

export function UniversalButton(props: UniversalButtonProps) {
  const {
    size = 'md',
    color = 'blue',
    variant = 'solid',
    shape = 'rounded',
    animation = 'none',
    visualTheme = 'modern',
    icon,
    iconPosition = 'none',
    disabled = false,
    loading = false,
    success = false,
    hasRipple = false,
    hasProgress = false,
    progressValue = 0,
    hasBadge = false,
    badgeContent,
    hasGlow = false,
    fullWidth = false,
    onClick,
    children,
    type = 'button',
    ariaLabel
  } = props;

  // États pour effets interactifs
  const [ripples, setRipples] = useState<Ripple[]>([]);

  // Gestion du ripple effect
  const handleRipple = (e: React.MouseEvent<HTMLButtonElement>) => {
    if (!hasRipple) return;
    
    const rect = e.currentTarget.getBoundingClientRect();
    const x = e.clientX - rect.left;
    const y = e.clientY - rect.top;
    
    setRipples([...ripples, { id: Date.now(), x, y }]);
    setTimeout(() => setRipples(r => r.slice(1)), 600);
  };

  // Click handler
  const handleClick = (e: React.MouseEvent<HTMLButtonElement>) => {
    if (disabled || loading) {
      e.preventDefault();
      return;
    }
    
    handleRipple(e);
    onClick?.(e);
  };

  // Construire les classes CSS
  const buttonClasses = buildButtonClasses({
    size,
    color,
    variant,
    shape,
    animation,
    visualTheme,
    disabled: disabled || loading,
    fullWidth
  });

  // Classes supplémentaires
  const additionalClasses = [
    hasRipple ? 'relative overflow-hidden' : '',
    hasGlow ? `shadow-lg shadow-${color}-500/50 hover:shadow-${color}-500/70` : '',
    'relative' // Pour les badges et effets
  ].filter(Boolean).join(' ');

  // Rendu du contenu selon iconPosition
  const renderContent = () => {
    // Loading state
    if (loading) {
      return (
        <>
          <svg className="animate-spin h-5 w-5 mr-2" fill="none" viewBox="0 0 24 24">
            <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" />
            <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z" />
          </svg>
          Chargement...
        </>
      );
    }

    // Success state
    if (success) {
      return (
        <>
          <svg className="h-5 w-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
          </svg>
          {children || 'Succès !'}
        </>
      );
    }

    // Icon only
    if (iconPosition === 'only') {
      return icon;
    }

    // Icon left
    if (iconPosition === 'left' && icon) {
      return (
        <>
          {icon}
          {children && <span className="ml-2">{children}</span>}
        </>
      );
    }

    // Icon right
    if (iconPosition === 'right' && icon) {
      return (
        <>
          {children && <span className="mr-2">{children}</span>}
          {icon}
        </>
      );
    }

    // No icon
    return children;
  };

  return (
    <button
      type={type}
      disabled={disabled || loading}
      onClick={handleClick}
      className={`${buttonClasses} ${additionalClasses} flex items-center justify-center`}
      aria-label={ariaLabel}
    >
      {/* Ripple effect */}
      {hasRipple && ripples.map(r => (
        <span
          key={r.id}
          className="absolute bg-white rounded-full opacity-50 animate-ping pointer-events-none"
          style={{
            left: r.x,
            top: r.y,
            width: '20px',
            height: '20px',
            transform: 'translate(-50%, -50%)'
          }}
        />
      ))}

      {/* Progress bar */}
      {hasProgress && (
        <div 
          className="absolute bottom-0 left-0 h-1 bg-white/50 transition-all duration-300"
          style={{ width: `${progressValue}%` }}
        />
      )}

      {/* Badge */}
      {hasBadge && badgeContent && (
        <span className="absolute -top-2 -right-2 min-w-[1.5rem] h-6 bg-red-500 text-white text-xs rounded-full flex items-center justify-center font-bold px-1.5">
          {badgeContent}
        </span>
      )}

      {/* Contenu */}
      {renderContent()}

      {/* Shine effect pour animation shine */}
      {animation === 'shine' && (
        <div className="absolute inset-0 bg-gradient-to-r from-transparent via-white to-transparent opacity-0 group-hover:opacity-30 transform -skew-x-12 group-hover:translate-x-full transition-all duration-1000 pointer-events-none" />
      )}
    </button>
  );
}

export default UniversalButton;

