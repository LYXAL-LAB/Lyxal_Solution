/**
 * Composant UniversalButton - Bouton universel avec toutes les caractéristiques
 * Combine les 89 variantes en un seul composant configurable
 */
import React from 'react';
import { Size, Color, Variant, Animation, Shape, VisualTheme } from './buttonStyles';
export interface UniversalButtonProps {
    size?: Size;
    color?: Color;
    variant?: Variant;
    shape?: Shape;
    animation?: Animation;
    visualTheme?: VisualTheme;
    icon?: React.ReactNode;
    iconPosition?: 'left' | 'right' | 'only' | 'none';
    disabled?: boolean;
    loading?: boolean;
    success?: boolean;
    hasRipple?: boolean;
    hasProgress?: boolean;
    progressValue?: number;
    hasBadge?: boolean;
    badgeContent?: string | number;
    hasGlow?: boolean;
    fullWidth?: boolean;
    onClick?: (e: React.MouseEvent<HTMLButtonElement>) => void;
    children?: React.ReactNode;
    type?: 'button' | 'submit' | 'reset';
    ariaLabel?: string;
}
export declare function UniversalButton(props: UniversalButtonProps): import("react/jsx-runtime").JSX.Element;
export default UniversalButton;
