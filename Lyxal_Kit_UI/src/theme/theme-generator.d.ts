/**
 * theme-generator.ts - Générateur automatique de thèmes
 * Génère des thèmes complets basés sur la théorie des couleurs
 */
export interface ThemeVariables {
    '--color-primary': string;
    '--color-primary-focus': string;
    '--color-primary-content': string;
    '--color-secondary': string;
    '--color-secondary-focus': string;
    '--color-secondary-content': string;
    '--color-accent': string;
    '--color-accent-focus': string;
    '--color-accent-content': string;
    '--color-neutral': string;
    '--color-neutral-focus': string;
    '--color-neutral-content': string;
    '--color-base-100': string;
    '--color-base-200': string;
    '--color-base-300': string;
    '--color-base-content': string;
    '--color-info': string;
    '--color-success': string;
    '--color-warning': string;
    '--color-error': string;
    '--rounded-box': string;
    '--rounded-btn': string;
    '--rounded-badge': string;
    '--animation-btn': string;
    '--animation-input': string;
    '--btn-focus-scale': string;
    '--border-btn': string;
}
export type RGB = [number, number, number];
export type HSL = [number, number, number];
export interface ContrastResult {
    ratio: string;
    AA: boolean;
    AAA: boolean;
    AALarge: boolean;
    AAALarge: boolean;
}
export type ExportFormat = 'css' | 'json' | 'tailwind';
export declare class ThemeGenerator {
    /**
     * Génère un thème complet à partir d'une couleur primaire
     * @param primaryColor - Couleur hex (ex: '#3b82f6')
     * @returns ThemeVariables complètes
     */
    static generateFromPrimary(primaryColor: string): ThemeVariables;
    /**
     * Génère un thème sombre à partir d'un thème clair
     * @param lightTheme - Thème clair source
     * @returns Thème sombre adapté
     */
    static generateDarkVariant(lightTheme: ThemeVariables): ThemeVariables;
    /**
     * Génère une palette de couleurs analogues
     * @param baseColor - Couleur hex de base
     * @param count - Nombre de couleurs à générer
     * @returns Tableau de couleurs hex
     */
    static generateAnalogousPalette(baseColor: string, count?: number): string[];
    /**
     * Génère une palette monochromatique
     * @param baseColor - Couleur hex de base
     * @param count - Nombre de nuances
     * @returns Tableau de couleurs hex
     */
    static generateMonochromaticPalette(baseColor: string, count?: number): string[];
    /**
     * Génère un thème basé sur une image
     * @param imageUrl - URL de l'image
     * @returns Promise<ThemeVariables>
     * @todo Implémenter avec color-thief ou vibrant.js
     */
    static generateFromImage(imageUrl: string): Promise<ThemeVariables | null>;
    /**
     * Convertit HEX en RGB
     * @param hex - Couleur hex (ex: '#3b82f6')
     * @returns Tableau RGB [r, g, b]
     */
    static hexToRgb(hex: string): RGB;
    /**
     * Convertit RGB en HEX
     * @param r - Rouge (0-255)
     * @param g - Vert (0-255)
     * @param b - Bleu (0-255)
     * @returns Couleur hex
     */
    static rgbToHex(r: number, g: number, b: number): string;
    /**
     * Convertit RGB en HSL
     * @param r - Rouge (0-255)
     * @param g - Vert (0-255)
     * @param b - Bleu (0-255)
     * @returns Tableau HSL [h, s, l]
     */
    static rgbToHsl(r: number, g: number, b: number): HSL;
    /**
     * Convertit HSL en RGB
     * @param h - Teinte (0-360)
     * @param s - Saturation (0-100)
     * @param l - Luminosité (0-100)
     * @returns Tableau RGB [r, g, b]
     */
    static hslToRgb(h: number, s: number, l: number): RGB;
    /**
     * Ajuste la luminosité d'une couleur
     * @param rgb - Couleur RGB
     * @param percent - Pourcentage d'ajustement (-100 à 100)
     * @returns Nouvelle couleur RGB
     */
    static adjustBrightness(rgb: RGB, percent: number): RGB;
    /**
     * Obtient la couleur complémentaire
     * @param rgb - Couleur RGB source
     * @returns Couleur complémentaire RGB
     */
    static getComplementary(rgb: RGB): RGB;
    /**
     * Obtient les couleurs triadiques
     * @param rgb - Couleur RGB source
     * @returns Tableau de 2 couleurs RGB
     */
    static getTriadic(rgb: RGB): [RGB, RGB];
    /**
     * Génère une couleur neutre (gris) avec la teinte de base
     * @param rgb - Couleur RGB source
     * @param lightness - Luminosité cible (0-100)
     * @returns Couleur neutre RGB
     */
    static generateNeutral(rgb: RGB, lightness: number): RGB;
    /**
     * Obtient la couleur de texte optimale (noir ou blanc)
     * @param rgb - Couleur de fond RGB
     * @returns Couleur de texte RGB (noir ou blanc)
     */
    static getContrastColor(rgb: RGB): RGB;
    /**
     * Valide le contraste WCAG entre deux couleurs
     * @param foreground - Couleur de premier plan RGB
     * @param background - Couleur de fond RGB
     * @returns Résultats de validation WCAG
     */
    static checkContrast(foreground: RGB, background: RGB): ContrastResult;
    /**
     * Exporte le thème en différents formats
     * @param theme - Thème à exporter
     * @param format - Format de sortie
     * @returns Thème exporté sous forme de string
     */
    static exportTheme(theme: ThemeVariables, format?: ExportFormat): string;
    /**
     * Valide qu'une couleur hex est correcte
     * @param hex - Couleur hex à valider
     * @returns true si valide
     */
    static validateHex(hex: string): boolean;
    /**
     * Valide qu'une couleur RGB est correcte
     * @param rgb - Couleur RGB à valider
     * @returns true si valide
     */
    static validateRgb(rgb: RGB): boolean;
}
export default ThemeGenerator;
