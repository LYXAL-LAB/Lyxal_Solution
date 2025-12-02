/**
 * Configuration complète des styles de boutons
 * Extrait des 89 variantes de button.tsx et components.tsx
 */

// ============= TYPES =============

export type Size = 'xs' | 'sm' | 'md' | 'lg' | 'xl';
export type Color = 
  // Couleurs du thème (dynamiques - s'adaptent au thème actif)
  | 'primary' | 'secondary' | 'accent'
  // Couleurs directes (statiques - toujours les mêmes)
  | 'blue' | 'green' | 'red' | 'yellow' | 'purple' 
  | 'pink' | 'orange' | 'cyan' | 'indigo' | 'gray';
export type Variant = 
  | 'solid' 
  | 'outline' 
  | 'ghost' 
  | 'gradient' 
  | 'glass' 
  | 'neon'
  | '3d';
export type Animation = 
  | 'none'
  | 'pulse'
  | 'bounce'
  | 'scale'
  | 'ripple'
  | 'confetti'
  | 'burst'
  | 'glitch'
  | 'sparkle'
  | 'shine';
export type Shape = 'rectangle' | 'rounded' | 'pill' | 'circle' | 'square';
export type IconPosition = 'left' | 'right' | 'only' | 'none';
export type VisualTheme = 
  | 'modern'
  | 'retro'
  | 'cyberpunk'
  | 'brutalist'
  | 'neumorphism'
  | 'minimal'
  | 'corporate'
  | 'glassmorphism';

// ============= CONFIGURATIONS =============

export const sizeConfig: Record<Size, string> = {
  xs: 'px-2 py-1 text-xs rounded',
  sm: 'px-4 py-2 text-sm rounded-md',
  md: 'px-6 py-3 rounded-lg',
  lg: 'px-8 py-4 text-lg rounded-xl',
  xl: 'px-10 py-5 text-xl rounded-2xl'
};

export const colorConfig: Record<Color, { solid: string; outline: string; ghost: string }> = {
  // ============= COULEURS THÈME (S'ADAPTENT AU THÈME ACTIF) =============
  primary: {
    solid: 'bg-primary hover:bg-primary-focus text-primary-content',
    outline: 'border-2 border-primary text-primary hover:bg-primary hover:text-primary-content',
    ghost: 'text-primary hover:bg-base-200'
  },
  secondary: {
    solid: 'bg-secondary hover:bg-secondary-focus text-secondary-content',
    outline: 'border-2 border-secondary text-secondary hover:bg-secondary hover:text-secondary-content',
    ghost: 'text-secondary hover:bg-base-200'
  },
  accent: {
    solid: 'bg-accent hover:bg-accent-focus text-accent-content',
    outline: 'border-2 border-accent text-accent hover:bg-accent hover:text-accent-content',
    ghost: 'text-accent hover:bg-base-200'
  },
  
  // ============= COULEURS DIRECTES (TOUJOURS IDENTIQUES) =============
  blue: {
    solid: 'bg-blue-600 hover:bg-blue-700 text-white',
    outline: 'border-2 border-blue-600 text-blue-600 hover:bg-blue-600 hover:text-white',
    ghost: 'text-blue-600 hover:bg-blue-50'
  },
  green: {
    solid: 'bg-green-600 hover:bg-green-700 text-white',
    outline: 'border-2 border-green-600 text-green-600 hover:bg-green-600 hover:text-white',
    ghost: 'text-green-600 hover:bg-green-50'
  },
  red: {
    solid: 'bg-red-600 hover:bg-red-700 text-white',
    outline: 'border-2 border-red-600 text-red-600 hover:bg-red-600 hover:text-white',
    ghost: 'text-red-600 hover:bg-red-50'
  },
  yellow: {
    solid: 'bg-yellow-500 hover:bg-yellow-600 text-white',
    outline: 'border-2 border-yellow-500 text-yellow-600 hover:bg-yellow-500 hover:text-white',
    ghost: 'text-yellow-600 hover:bg-yellow-50'
  },
  purple: {
    solid: 'bg-purple-600 hover:bg-purple-700 text-white',
    outline: 'border-2 border-purple-600 text-purple-600 hover:bg-purple-600 hover:text-white',
    ghost: 'text-purple-600 hover:bg-purple-50'
  },
  pink: {
    solid: 'bg-pink-600 hover:bg-pink-700 text-white',
    outline: 'border-2 border-pink-600 text-pink-600 hover:bg-pink-600 hover:text-white',
    ghost: 'text-pink-600 hover:bg-pink-50'
  },
  orange: {
    solid: 'bg-orange-600 hover:bg-orange-700 text-white',
    outline: 'border-2 border-orange-600 text-orange-600 hover:bg-orange-600 hover:text-white',
    ghost: 'text-orange-600 hover:bg-orange-50'
  },
  cyan: {
    solid: 'bg-cyan-600 hover:bg-cyan-700 text-white',
    outline: 'border-2 border-cyan-600 text-cyan-600 hover:bg-cyan-600 hover:text-white',
    ghost: 'text-cyan-600 hover:bg-cyan-50'
  },
  indigo: {
    solid: 'bg-indigo-600 hover:bg-indigo-700 text-white',
    outline: 'border-2 border-indigo-600 text-indigo-600 hover:bg-indigo-600 hover:text-white',
    ghost: 'text-indigo-600 hover:bg-indigo-50'
  },
  gray: {
    solid: 'bg-gray-800 hover:bg-gray-900 text-white',
    outline: 'border-2 border-gray-800 text-gray-800 hover:bg-gray-800 hover:text-white',
    ghost: 'text-gray-600 hover:bg-gray-50'
  }
};

export const gradientConfig: Record<Color, string> = {
  // Couleurs thème (utilisent les classes Tailwind du plugin)
  primary: 'btn-gradient', // Utilise le composant .btn-gradient du plugin Tailwind
  secondary: 'bg-gradient-to-r from-secondary to-secondary-focus hover:opacity-90',
  accent: 'bg-gradient-to-r from-accent to-accent-focus hover:opacity-90',
  
  // Couleurs directes
  blue: 'bg-gradient-to-r from-blue-500 to-blue-700 hover:from-blue-600 hover:to-blue-800',
  green: 'bg-gradient-to-r from-green-400 to-cyan-500 hover:from-green-500 hover:to-cyan-600',
  red: 'bg-gradient-to-r from-orange-500 via-red-500 to-pink-500 hover:from-orange-600 hover:via-red-600 hover:to-pink-600',
  yellow: 'bg-gradient-to-r from-yellow-400 to-orange-500 hover:from-yellow-500 hover:to-orange-600',
  purple: 'bg-gradient-to-r from-purple-500 to-pink-500 hover:from-purple-600 hover:to-pink-600',
  pink: 'bg-gradient-to-r from-pink-500 to-purple-500 hover:from-pink-600 hover:to-purple-600',
  orange: 'bg-gradient-to-r from-orange-500 to-red-500 hover:from-orange-600 hover:to-red-600',
  cyan: 'bg-gradient-to-r from-cyan-400 via-purple-400 to-pink-400',
  indigo: 'bg-gradient-to-r from-indigo-500 to-purple-500 hover:from-indigo-600 hover:to-purple-600',
  gray: 'bg-gradient-to-r from-gray-800 via-gray-600 to-gray-800'
};

export const shapeConfig: Record<Shape, string> = {
  rectangle: 'rounded-none',
  rounded: 'rounded-lg',
  pill: 'rounded-full',
  circle: 'rounded-full aspect-square p-4',
  square: 'rounded-lg aspect-square'
};

export const animationConfig: Record<Animation, string> = {
  none: '',
  pulse: 'animate-pulse',
  bounce: 'hover:animate-bounce',
  scale: 'hover:scale-105 transform',
  ripple: '', // Géré par logique JS
  confetti: '', // Géré par logique JS
  burst: '', // Géré par logique JS
  glitch: '', // Géré par logique JS
  sparkle: '', // Géré par logique JS
  shine: '' // Effet CSS spécial
};

export const visualThemeConfig: Record<VisualTheme, string> = {
  modern: 'shadow-lg hover:shadow-xl transition-all',
  retro: 'border-4 border-black shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] hover:shadow-[2px_2px_0px_0px_rgba(0,0,0,1)] hover:translate-x-[2px] hover:translate-y-[2px]',
  cyberpunk: 'border-2 shadow-[0_0_10px_rgba(0,255,255,0.5)] hover:shadow-[0_0_20px_rgba(0,255,255,0.8)] uppercase tracking-wider',
  brutalist: 'rounded-none border-4 uppercase font-black',
  neumorphism: 'shadow-[8px_8px_16px_#b3b3b3,-8px_-8px_16px_#ffffff] hover:shadow-[4px_4px_8px_#b3b3b3,-4px_-4px_8px_#ffffff]',
  minimal: 'border border-gray-300 hover:border-gray-900 font-light tracking-wide',
  corporate: 'shadow-md hover:shadow-lg',
  glassmorphism: 'bg-white/20 backdrop-blur-lg border border-white/30 shadow-lg'
};

// ============= UTILITAIRES =============

/**
 * Construit les classes CSS du bouton selon les props
 */
export function buildButtonClasses(props: {
  size?: Size;
  color?: Color;
  variant?: Variant;
  shape?: Shape;
  animation?: Animation;
  visualTheme?: VisualTheme;
  disabled?: boolean;
  fullWidth?: boolean;
}): string {
  const {
    size = 'md',
    color = 'blue',
    variant = 'solid',
    shape = 'rounded',
    animation = 'none',
    visualTheme = 'modern',
    disabled = false,
    fullWidth = false
  } = props;

  const classes = [
    'font-semibold transition-all',
    sizeConfig[size],
    
    // Variant
    variant === 'gradient' 
      ? gradientConfig[color]
      : variant === 'glass'
      ? visualThemeConfig.glassmorphism
      : variant === 'neon' || variant === '3d'
      ? colorConfig[color].solid // Neon et 3d utilisent solid comme base
      : (variant === 'solid' || variant === 'outline' || variant === 'ghost')
      ? colorConfig[color][variant]
      : colorConfig[color].solid, // Fallback
    
    // Effets spéciaux pour neon et 3d
    variant === 'neon' ? `shadow-lg shadow-${color}-500/50 hover:shadow-${color}-500/70` : '',
    variant === '3d' ? 'shadow-lg hover:shadow-xl hover:-translate-y-1' : '',
    
    // Shape
    shapeConfig[shape],
    
    // Animation
    animationConfig[animation],
    
    // Visual theme
    visualTheme !== 'modern' ? visualThemeConfig[visualTheme] : visualThemeConfig.modern,
    
    // États
    disabled ? 'opacity-50 cursor-not-allowed' : 'cursor-pointer',
    fullWidth ? 'w-full' : '',
  ];

  return classes.filter(Boolean).join(' ');
}

/**
 * Obtient les classes pour les effets spéciaux
 */
export function getSpecialEffectClasses(effect: 'neon' | 'shine' | 'border-spin' | 'holographic', color?: Color): string {
  switch (effect) {
    case 'neon':
      return `shadow-lg shadow-${color || 'purple'}-500/50 hover:shadow-${color || 'purple'}-500/70 hover:shadow-xl`;
    case 'shine':
      return 'relative overflow-hidden group';
    case 'border-spin':
      return 'relative overflow-hidden';
    case 'holographic':
      return 'bg-gradient-to-r from-cyan-400 via-purple-400 to-pink-400 shadow-2xl hover:shadow-3xl';
    default:
      return '';
  }
}

