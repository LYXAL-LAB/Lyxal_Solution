/**
 * Intégration des thèmes DaisyUI dans le système de thème
 * Utilise les thèmes importés depuis daisyui-themes.json
 */
export type DaisyUIThemeName = 'light' | 'dark' | 'cupcake' | 'bumblebee' | 'emerald' | 'corporate' | 'synthwave' | 'retro' | 'cyberpunk' | 'valentine' | 'halloween' | 'garden' | 'forest' | 'aqua' | 'lofi' | 'pastel' | 'fantasy' | 'wireframe' | 'black' | 'luxury' | 'dracula' | 'cmyk' | 'autumn' | 'business' | 'acid' | 'lemonade' | 'night' | 'coffee' | 'winter' | 'dim' | 'nord' | 'sunset' | 'caramellatte' | 'abyss' | 'silk';
export declare class DaisyUIIntegration {
    /**
     * Liste tous les thèmes DaisyUI disponibles
     */
    static getAvailableThemes(): DaisyUIThemeName[];
    /**
     * Applique un thème DaisyUI
     */
    static applyTheme(themeName: DaisyUIThemeName): void;
    /**
     * Obtient les variables d'un thème DaisyUI
     */
    static getThemeVariables(themeName: DaisyUIThemeName): Record<string, string> | null;
    /**
     * Précharge tous les thèmes DaisyUI (optionnel)
     */
    static preloadAllThemes(): void;
    /**
     * Recherche des thèmes par couleur
     */
    static findThemesByColor(colorType: 'primary' | 'secondary' | 'accent', targetColor: string): DaisyUIThemeName[];
    /**
     * Obtient les informations d'un thème
     */
    static getThemeInfo(themeName: DaisyUIThemeName): {
        name: string;
        variables: number;
        primary: string;
        secondary: string;
        accent: string;
    } | null;
}
/**
 * Applique un thème aléatoire DaisyUI
 */
export declare function applyRandomDaisyTheme(): void;
/**
 * Crée une liste de boutons pour tester tous les thèmes
 */
export declare function createThemeSwitcherButtons(container: HTMLElement): void;
