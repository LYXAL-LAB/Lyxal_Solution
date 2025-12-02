/**
 * Configuration complète des styles de boutons
 * Extrait des 89 variantes de button.tsx et components.tsx
 */
export type Size = 'xs' | 'sm' | 'md' | 'lg' | 'xl';
export type Color = 'primary' | 'secondary' | 'accent' | 'blue' | 'green' | 'red' | 'yellow' | 'purple' | 'pink' | 'orange' | 'cyan' | 'indigo' | 'gray';
export type Variant = 'solid' | 'outline' | 'ghost' | 'gradient' | 'glass' | 'neon' | '3d';
export type Animation = 'none' | 'pulse' | 'bounce' | 'scale' | 'ripple' | 'confetti' | 'burst' | 'glitch' | 'sparkle' | 'shine';
export type Shape = 'rectangle' | 'rounded' | 'pill' | 'circle' | 'square';
export type IconPosition = 'left' | 'right' | 'only' | 'none';
export type VisualTheme = 'modern' | 'retro' | 'cyberpunk' | 'brutalist' | 'neumorphism' | 'minimal' | 'corporate' | 'glassmorphism';
export declare const sizeConfig: Record<Size, string>;
export declare const colorConfig: Record<Color, {
    solid: string;
    outline: string;
    ghost: string;
}>;
export declare const gradientConfig: Record<Color, string>;
export declare const shapeConfig: Record<Shape, string>;
export declare const animationConfig: Record<Animation, string>;
export declare const visualThemeConfig: Record<VisualTheme, string>;
/**
 * Construit les classes CSS du bouton selon les props
 */
export declare function buildButtonClasses(props: {
    size?: Size;
    color?: Color;
    variant?: Variant;
    shape?: Shape;
    animation?: Animation;
    visualTheme?: VisualTheme;
    disabled?: boolean;
    fullWidth?: boolean;
}): string;
/**
 * Obtient les classes pour les effets spéciaux
 */
export declare function getSpecialEffectClasses(effect: 'neon' | 'shine' | 'border-spin' | 'holographic', color?: Color): string;
