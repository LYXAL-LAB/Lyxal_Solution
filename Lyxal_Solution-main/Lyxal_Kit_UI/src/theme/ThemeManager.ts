/**
 * ThemeManager.ts - Gestionnaire de thèmes dynamiques
 * Gère l'application, la sauvegarde et les transitions de thèmes
 */

import { ThemeVariables } from "./theme-generator";

// ============= TYPES =============

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
  detail: { theme: ThemeName };
}

// ============= CLASSE =============

export class ThemeManager {
  private currentTheme: ThemeName;
  private customThemes: Record<ThemeName, Partial<ThemeVariables>>;

  constructor() {
    this.currentTheme = this.getSavedTheme() || "light";
    this.customThemes = this.loadCustomThemes();
    this.init();
  }

  // ============= INITIALISATION =============

  /**
   * Initialise le gestionnaire de thèmes
   */
  private init(): void {
    this.applyTheme(this.currentTheme);
    this.setupListeners();
  }

  // ============= GESTION DES THÈMES =============

  /**
   * Applique un thème
   * @param themeName - Nom du thème à appliquer
   */
  applyTheme(themeName: ThemeName): void {
    const html = document.documentElement;

    // Supprimer l'ancien attribut de thème
    const oldTheme = html.getAttribute("data-theme");
    if (oldTheme) {
      html.removeAttribute("data-theme");
    }

    // Appliquer le nouveau thème (sauf pour 'light' qui est le défaut)
    if (themeName !== "light") {
      html.setAttribute("data-theme", themeName);
    }

    this.currentTheme = themeName;
    this.saveTheme(themeName);

    // Émettre un événement personnalisé
    window.dispatchEvent(
      new CustomEvent("themechange", {
        detail: { theme: themeName },
      }) as ThemeChangeEvent,
    );
  }

  /**
   * Crée un thème personnalisé
   * @param name - Nom du thème
   * @param colors - Couleurs du thème
   */
  createCustomTheme(name: ThemeName, colors: CustomThemeColors): void {
    if (!this.validateColors(colors)) {
      throw new Error("Invalid colors provided");
    }

    const theme: Partial<ThemeVariables> = {
      "--color-primary": this.rgbFromHex(colors.primary),
      "--color-primary-focus": this.rgbFromHex(
        colors.primaryFocus || colors.primary,
      ),
      "--color-primary-content": this.rgbFromHex(
        colors.primaryContent || "#ffffff",
      ),

      "--color-secondary": this.rgbFromHex(colors.secondary),
      "--color-secondary-focus": this.rgbFromHex(
        colors.secondaryFocus || colors.secondary,
      ),
      "--color-secondary-content": this.rgbFromHex(
        colors.secondaryContent || "#ffffff",
      ),

      "--color-accent": this.rgbFromHex(colors.accent),
      "--color-accent-focus": this.rgbFromHex(
        colors.accentFocus || colors.accent,
      ),
      "--color-accent-content": this.rgbFromHex(
        colors.accentContent || "#ffffff",
      ),

      "--color-neutral": this.rgbFromHex(colors.neutral || "#1f2937"),
      "--color-neutral-focus": this.rgbFromHex(
        colors.neutralFocus || "#111827",
      ),
      "--color-neutral-content": this.rgbFromHex(
        colors.neutralContent || "#ffffff",
      ),

      "--color-base-100": this.rgbFromHex(colors.base100 || "#ffffff"),
      "--color-base-200": this.rgbFromHex(colors.base200 || "#f9fafb"),
      "--color-base-300": this.rgbFromHex(colors.base300 || "#f3f4f6"),
      "--color-base-content": this.rgbFromHex(colors.baseContent || "#1f2937"),

      "--color-info": this.rgbFromHex(colors.info || "#0ea5e9"),
      "--color-success": this.rgbFromHex(colors.success || "#22c55e"),
      "--color-warning": this.rgbFromHex(colors.warning || "#f97316"),
      "--color-error": this.rgbFromHex(colors.error || "#ef4444"),
    };

    this.customThemes[name] = theme;
    this.saveCustomThemes();
    this.applyCustomTheme(name);
  }

  /**
   * Applique un thème personnalisé
   * @param name - Nom du thème custom
   */
  applyCustomTheme(name: ThemeName): void {
    const theme = this.customThemes[name];
    if (!theme) {
      console.error(`Theme "${name}" not found`);
      return;
    }

    const root = document.documentElement;
    Object.entries(theme).forEach(([variable, value]) => {
      if (value) {
        root.style.setProperty(variable, value);
      }
    });

    this.currentTheme = name;
    this.saveTheme(name);
  }

  /**
   * Modifie une variable CSS spécifique
   * @param variableName - Nom de la variable CSS
   * @param value - Nouvelle valeur (hex ou rgb)
   */
  setVariable(variableName: string, value: string): void {
    const root = document.documentElement;

    // Si c'est une couleur hex, convertir en RGB
    let finalValue = value;
    if (value.startsWith("#")) {
      finalValue = this.rgbFromHex(value);
    }

    root.style.setProperty(variableName, finalValue);

    // Sauvegarder dans le thème personnalisé actuel
    if (this.customThemes[this.currentTheme]) {
      this.customThemes[this.currentTheme][
        variableName as keyof ThemeVariables
      ] = finalValue;
      this.saveCustomThemes();
    }
  }

  /**
   * Obtient la valeur d'une variable CSS
   * @param variableName - Nom de la variable
   * @returns Valeur de la variable
   */
  getVariable(variableName: string): string {
    return getComputedStyle(document.documentElement)
      .getPropertyValue(variableName)
      .trim();
  }

  /**
   * Exporte le thème actuel
   * @returns Variables du thème actuel
   */
  exportTheme(): Record<string, string> {
    const variables = [
      "--color-primary",
      "--color-primary-focus",
      "--color-primary-content",
      "--color-secondary",
      "--color-secondary-focus",
      "--color-secondary-content",
      "--color-accent",
      "--color-accent-focus",
      "--color-accent-content",
      "--color-neutral",
      "--color-neutral-focus",
      "--color-neutral-content",
      "--color-base-100",
      "--color-base-200",
      "--color-base-300",
      "--color-base-content",
      "--color-info",
      "--color-success",
      "--color-warning",
      "--color-error",
      "--rounded-box",
      "--rounded-btn",
      "--rounded-badge",
      "--animation-btn",
      "--animation-input",
      "--btn-focus-scale",
      "--border-btn",
      "--tab-border",
      "--tab-radius",
    ];

    const theme: Record<string, string> = {};
    variables.forEach((variable) => {
      theme[variable] = this.getVariable(variable);
    });

    return theme;
  }

  /**
   * Importe un thème
   * @param name - Nom du nouveau thème
   * @param themeData - Données du thème
   */
  importTheme(name: ThemeName, themeData: Partial<ThemeVariables>): void {
    this.customThemes[name] = themeData;
    this.saveCustomThemes();
  }

  /**
   * Bascule entre clair et sombre
   */
  toggleDarkMode(): void {
    const newTheme = this.currentTheme === "light" ? "dark" : "light";
    this.applyTheme(newTheme);
  }

  /**
   * Obtient tous les thèmes disponibles
   * @returns Liste des thèmes
   */
  getAvailableThemes(): ThemeName[] {
    const builtInThemes = ["light", "dark", "ocean"];
    return [...builtInThemes, ...Object.keys(this.customThemes)];
  }

  /**
   * Obtient le thème actuel
   * @returns Nom du thème actuel
   */
  getCurrentTheme(): ThemeName {
    return this.currentTheme;
  }

  /**
   * Supprime un thème personnalisé
   * @param name - Nom du thème à supprimer
   */
  deleteCustomTheme(name: ThemeName): void {
    if (this.customThemes[name]) {
      delete this.customThemes[name];
      this.saveCustomThemes();

      if (this.currentTheme === name) {
        this.applyTheme("light");
      }
    }
  }

  // ============= UTILITAIRES =============

  /**
   * Convertit hex en RGB (format string pour CSS)
   * @param hex - Couleur hex
   * @returns RGB string pour CSS variables
   */
  private rgbFromHex(hex: string): string {
    // Enlever le # si présent
    const cleanHex = hex.replace("#", "");

    if (!/^[0-9A-Fa-f]{6}$/.test(cleanHex)) {
      throw new Error(`Invalid hex color: ${hex}`);
    }

    // Convertir en RGB
    const r = parseInt(cleanHex.substring(0, 2), 16);
    const g = parseInt(cleanHex.substring(2, 4), 16);
    const b = parseInt(cleanHex.substring(4, 6), 16);

    return `${r} ${g} ${b}`;
  }

  /**
   * Valide un objet de couleurs
   * @param colors - Couleurs à valider
   * @returns true si valide
   */
  private validateColors(colors: CustomThemeColors): boolean {
    const required: (keyof CustomThemeColors)[] = [
      "primary",
      "secondary",
      "accent",
    ];

    // Vérifier présence des couleurs requises
    const hasRequired = required.every((key) => colors[key]);

    // Vérifier format hex
    const hexRegex = /^#[0-9A-Fa-f]{6}$/;
    const allValid = Object.values(colors).every(
      (color) => color === undefined || hexRegex.test(color),
    );

    return hasRequired && allValid;
  }

  // ============= PERSISTENCE =============

  /**
   * Sauvegarde le thème actuel dans localStorage
   * @param themeName - Nom du thème
   */
  private saveTheme(themeName: ThemeName): void {
    try {
      localStorage.setItem("selectedTheme", themeName);
    } catch (error) {
      console.error("Failed to save theme:", error);
    }
  }

  /**
   * Récupère le thème sauvegardé
   * @returns Nom du thème ou null
   */
  private getSavedTheme(): ThemeName | null {
    try {
      return localStorage.getItem("selectedTheme");
    } catch (error) {
      console.error("Failed to load theme:", error);
      return null;
    }
  }

  /**
   * Sauvegarde les thèmes personnalisés
   */
  private saveCustomThemes(): void {
    try {
      localStorage.setItem("customThemes", JSON.stringify(this.customThemes));
    } catch (error) {
      console.error("Failed to save custom themes:", error);
    }
  }

  /**
   * Charge les thèmes personnalisés
   * @returns Thèmes custom ou objet vide
   */
  private loadCustomThemes(): Record<ThemeName, Partial<ThemeVariables>> {
    try {
      const saved = localStorage.getItem("customThemes");
      return saved ? JSON.parse(saved) : {};
    } catch (error) {
      console.error("Failed to load custom themes:", error);
      return {};
    }
  }

  // ============= ÉVÉNEMENTS =============

  /**
   * Écoute les changements système (préférence dark mode)
   */
  private setupListeners(): void {
    const darkModeQuery = window.matchMedia("(prefers-color-scheme: dark)");

    darkModeQuery.addEventListener("change", (e) => {
      if (!this.getSavedTheme()) {
        this.applyTheme(e.matches ? "dark" : "light");
      }
    });
  }

  /**
   * Importe les thèmes DaisyUI depuis leurs fichiers CSS
   */
  async importDaisyUIThemes(): Promise<void> {
    const fs = require("fs").promises;
    const path = require("path");

    try {
      const themesDir = path.join(
        __dirname,
        "../../../daisyui-master/packages/daisyui/src/themes",
      );
      const files = await fs.readdir(themesDir);

      for (const file of files) {
        if (file.endsWith(".css")) {
          const themeName = file.replace(".css", "");
          const filePath = path.join(themesDir, file);
          const content = await fs.readFile(filePath, "utf-8");

          const variables = this.parseDaisyUITheme(content);
          if (variables) {
            this.customThemes[themeName] = variables;
          }
        }
      }

      console.log(
        `✅ ${Object.keys(this.customThemes).length} thèmes DaisyUI importés`,
      );
    } catch (error) {
      console.error("❌ Erreur lors de l'import DaisyUI:", error);
    }
  }

  /**
   * Parse un fichier de thème DaisyUI pour extraire les variables
   */
  private parseDaisyUITheme(content: string): Partial<ThemeVariables> | null {
    const variables: Partial<ThemeVariables> = {};

    // Regex pour capturer les variables CSS
    const varRegex = /--([\w-]+):\s*([^;]+);/g;
    let match;

    while ((match = varRegex.exec(content)) !== null) {
      const [, name, value] = match;

      // Convertir oklch() en RGB approximatif ou garder tel quel
      const rgbValue = this.convertOkLchToRgb(value.trim());

      // Mapper vers nos noms de variables
      const mappedName = this.mapDaisyUIVariable(name);
      if (mappedName && rgbValue) {
        variables[mappedName as keyof ThemeVariables] = rgbValue;
      }
    }

    return Object.keys(variables).length > 0 ? variables : null;
  }

  /**
   * Convertit oklch() vers RGB approximatif (simplifié)
   * Pour une conversion précise, utiliser une bibliothèque comme color-convert
   */
  private convertOkLchToRgb(oklchValue: string): string | null {
    // Si c'est déjà un format connu, le garder
    if (oklchValue.includes("oklch(")) {
      // Pour l'instant, on garde tel quel - Tailwind supporte oklch()
      // Alternative: convertir vers RGB pour compatibilité maximale
      return oklchValue;
    }

    // Pour les autres formats, essayer de parser
    const rgbMatch = oklchValue.match(/(\d+)\s+(\d+)\s+(\d+)/);
    if (rgbMatch) {
      return `${rgbMatch[1]} ${rgbMatch[2]} ${rgbMatch[3]}`;
    }

    return null;
  }

  /**
   * Mappe les noms de variables DaisyUI vers nos noms
   */
  private mapDaisyUIVariable(daisyName: string): string | null {
    const mapping: Record<string, string> = {
      "color-primary": "--color-primary",
      "color-secondary": "--color-secondary",
      "color-accent": "--color-accent",
      "color-neutral": "--color-neutral",
      "color-base-100": "--color-base-100",
      "color-base-200": "--color-base-200",
      "color-base-300": "--color-base-300",
      "color-primary-content": "--color-primary-content",
      "color-secondary-content": "--color-secondary-content",
      "color-accent-content": "--color-accent-content",
      "color-neutral-content": "--color-neutral-content",
      "color-base-content": "--color-base-content",
      "color-info": "--color-info",
      "color-success": "--color-success",
      "color-warning": "--color-warning",
      "color-error": "--color-error",
    };

    return mapping[daisyName] || null;
  }

  /**
   * Applique un thème DaisyUI importé
   */
  applyDaisyUITheme(themeName: string): void {
    const theme = this.customThemes[themeName];
    if (!theme) {
      console.warn(`Thème DaisyUI '${themeName}' non trouvé`);
      return;
    }

    // Injecter directement les variables CSS
    const root = document.documentElement;
    Object.entries(theme).forEach(([key, value]) => {
      if (typeof value === "string") {
        root.style.setProperty(key, value);
      }
    });

    this.currentTheme = themeName;
    this.saveTheme(themeName);

    // Émettre l'événement
    window.dispatchEvent(
      new CustomEvent("themechange", {
        detail: { theme: themeName },
      }) as ThemeChangeEvent,
    );
  }

  /**
   * Ajoute un écouteur pour les changements de thème
   * @param callback - Fonction appelée lors du changement
   * @returns Fonction pour retirer l'écouteur
   */
  onThemeChange(callback: (theme: ThemeName) => void): () => void {
    const handler = ((event: ThemeChangeEvent) => {
      callback(event.detail.theme);
    }) as EventListener;

    window.addEventListener("themechange", handler);

    return () => window.removeEventListener("themechange", handler);
  }
}

// ============= INSTANCE SINGLETON =============

// Initialisation automatique
export const themeManager = new ThemeManager();

// Export par défaut pour compatibilité
export default ThemeManager;
