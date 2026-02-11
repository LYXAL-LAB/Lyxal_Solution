import type { VariantStyle } from '../types/component';
/**
 * Applique les variants et styles selon le variant spécifié
 *
 * Les variants sont des styles conditionnels définis dans la structure
 * du composant. Ils peuvent contenir des classes CSS et des variables CSS.
 *
 * @param variants - Objet contenant les définitions de variants
 * @param variant - Nom du variant à appliquer (ex: "primary", "secondary")
 * @param props - Props actuelles du composant
 * @returns Props avec les styles du variant appliqués
 */
export declare const applyVariants: (variants?: Record<string, VariantStyle>, variant?: string, props?: Record<string, any>) => Record<string, any>;
