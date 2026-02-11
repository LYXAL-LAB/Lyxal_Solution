/**
 * Exports centralisés pour le système de boutons
 */

// Composants
export { UniversalButton } from './UniversalButton';
export { default as ButtonLibrary } from './button';
export { default as ButtonCustom } from './ButtonCustom';

// Agent IA
export { buttonDesignAI, ButtonDesignAI } from './ButtonDesignAI';
export type { 
  AppContext, 
  AppType, 
  ButtonIntent, 
  ButtonRecommendation,
  AppTheme,
  Industry,
  Audience
} from './ButtonDesignAI';

// Styles & Types
export type {
  Size,
  Color,
  Variant,
  Animation,
  Shape,
  VisualTheme,
  IconPosition
} from './buttonStyles';

export {
  buildButtonClasses,
  sizeConfig,
  colorConfig,
  gradientConfig,
  shapeConfig,
  animationConfig,
  visualThemeConfig,
  getSpecialEffectClasses
} from './buttonStyles';

// Props
export type { UniversalButtonProps } from './UniversalButton';

