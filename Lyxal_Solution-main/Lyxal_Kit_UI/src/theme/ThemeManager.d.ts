/**
 * ThemeManager.ts - Gestionnaire de thèmes dynamiques
 * Gère l'application, la sauvegarde et les transitions de thèmes
 */
import { ThemeVariables } from './theme-generator';
export type ThemeName = string;
export interface CustomThemeColors {
    primary: string;
    secondary: string;
    accent: string;
    neutral?: string;
    base100?: string;
    base200?: string;
    base300?: string;
    baseContent?: string;
    primaryFocus?: string;
    primaryContent?: string;
    secondaryFocus?: string;
    secondaryContent?: string;
    accentFocus?: string;
    accentContent?: string;
    neutralFocus?: string;
    neutralContent?: string;
    info?: string;
    success?: string;
    warning?: string;
    error?: string;
}
export interface ThemeChangeEvent extends CustomEvent {
    detail: {
        theme: ThemeName;
    };
}
export declare class ThemeManager {
    private currentTheme;
    private customThemes;
    constructor();
    /**
     * Initialise le gestionnaire de thèmes
     */
    private init;
    /**
     * Applique un thème
     * @param themeName - Nom du thème à appliquer
     */
    applyTheme(themeName: ThemeName): void;
    /**
     * Crée un thème personnalisé
     * @param name - Nom du thème
     * @param colors - Couleurs du thème
     */
    createCustomTheme(name: ThemeName, colors: CustomThemeColors): void;
    /**
     * Applique un thème personnalisé
     * @param name - Nom du thème custom
     */
    applyCustomTheme(name: ThemeName): void;
    /**
     * Modifie une variable CSS spécifique
     * @param variableName - Nom de la variable CSS
     * @param value - Nouvelle valeur (hex ou rgb)
     */
    setVariable(variableName: string, value: string): void;
    /**
     * Obtient la valeur d'une variable CSS
     * @param variableName - Nom de la variable
     * @returns Valeur de la variable
     */
    getVariable(variableName: string): string;
    /**
     * Exporte le thème actuel
     * @returns Variables du thème actuel
     */
    exportTheme(): Record<string, string>;
    /**
     * Importe un thème
     * @param name - Nom du nouveau thème
     * @param themeData - Données du thème
     */
    importTheme(name: ThemeName, themeData: Partial<ThemeVariables>): void;
    /**
     * Bascule entre clair et sombre
     */
    toggleDarkMode(): void;
    /**
     * Obtient tous les thèmes disponibles
     * @returns Liste des thèmes
     */
    getAvailableThemes(): ThemeName[];
    /**
     * Obtient le thème actuel
     * @returns Nom du thème actuel
     */
    getCurrentTheme(): ThemeName;
    /**
     * Supprime un thème personnalisé
     * @param name - Nom du thème à supprimer
     */
    deleteCustomTheme(name: ThemeName): void;
    /**
     * Convertit hex en RGB (format string pour CSS)
     * @param hex - Couleur hex
     * @returns RGB string pour CSS variables
     */
    private rgbFromHex;
    /**
     * Valide un objet de couleurs
     * @param colors - Couleurs à valider
     * @returns true si valide
     */
    private validateColors;
    /**
     * Sauvegarde le thème actuel dans localStorage
     * @param themeName - Nom du thème
     */
    private saveTheme;
    /**
     * Récupère le thème sauvegardé
     * @returns Nom du thème ou null
     */
    private getSavedTheme;
    /**
     * Sauvegarde les thèmes personnalisés
     */
    private saveCustomThemes;
    /**
     * Charge les thèmes personnalisés
     * @returns Thèmes custom ou objet vide
     */
    private loadCustomThemes;
    /**
     * Écoute les changements système (préférence dark mode)
     */
    private setupListeners;
    /**
     * Importe les thèmes DaisyUI depuis leurs fichiers CSS
     */
    importDaisyUIThemes(): Promise<void>;
    /**
     * Parse un fichier de thème DaisyUI pour extraire les variables
     */
    private parseDaisyUITheme;
    /**
     * Convertit oklch() vers RGB approximatif (simplifié)
     * Pour une conversion précise, utiliser une bibliothèque comme color-convert
     */
    private convertOkLchToRgb;
    /**
     * Mappe les noms de variables DaisyUI vers nos noms
     */
    private mapDaisyUIVariable;
    /**
     * Applique un thème DaisyUI importé
     */
    applyDaisyUITheme(themeName: string): void;
    /**
     * Ajoute un écouteur pour les changements de thème
     * @param callback - Fonction appelée lors du changement
     * @returns Fonction pour retirer l'écouteur
     */
    onThemeChange(callback: (theme: ThemeName) => void): () => void;
}
export declare const themeManager: ThemeManager;
export default ThemeManager;
