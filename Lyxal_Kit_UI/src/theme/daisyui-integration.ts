/**
 * Intégration des thèmes DaisyUI dans le système de thème
 * Utilise les thèmes importés depuis daisyui-themes.json
 */

import { themeManager } from './ThemeManager';
import daisyThemes from './daisyui-themes.json';

// ============= TYPES =============

export type DaisyUIThemeName =
  | 'light' | 'dark' | 'cupcake' | 'bumblebee' | 'emerald' | 'corporate'
  | 'synthwave' | 'retro' | 'cyberpunk' | 'valentine' | 'halloween'
  | 'garden' | 'forest' | 'aqua' | 'lofi' | 'pastel' | 'fantasy'
  | 'wireframe' | 'black' | 'luxury' | 'dracula' | 'cmyk' | 'autumn'
  | 'business' | 'acid' | 'lemonade' | 'night' | 'coffee' | 'winter'
  | 'dim' | 'nord' | 'sunset' | 'caramellatte' | 'abyss' | 'silk';

// ============= CLASSE D'INTÉGRATION =============

export class DaisyUIIntegration {
  /**
   * Liste tous les thèmes DaisyUI disponibles
   */
  static getAvailableThemes(): DaisyUIThemeName[] {
    return Object.keys(daisyThemes) as DaisyUIThemeName[];
  }

  /**
   * Applique un thème DaisyUI
   */
  static applyTheme(themeName: DaisyUIThemeName): void {
    const theme = daisyThemes[themeName];
    if (!theme) {
      console.error(`Thème DaisyUI '${themeName}' non trouvé`);
      return;
    }

    console.log(`🎨 Application du thème DaisyUI: ${themeName}`);

    // Injecter directement les variables CSS
    const root = document.documentElement;
    Object.entries(theme).forEach(([cssVar, value]) => {
      root.style.setProperty(cssVar, value);
    });

    // Sauvegarder dans le ThemeManager
    themeManager.saveTheme(`daisyui-${themeName}`);

    // Émettre l'événement personnalisé
    window.dispatchEvent(new CustomEvent('themechange', {
      detail: { theme: `daisyui-${themeName}` }
    }));
  }

  /**
   * Obtient les variables d'un thème DaisyUI
   */
  static getThemeVariables(themeName: DaisyUIThemeName): Record<string, string> | null {
    return daisyThemes[themeName] || null;
  }

  /**
   * Précharge tous les thèmes DaisyUI (optionnel)
   */
  static preloadAllThemes(): void {
    console.log('🔄 Préchargement des thèmes DaisyUI...');
    // Les thèmes sont déjà chargés via l'import JSON
    console.log(`✅ ${Object.keys(daisyThemes).length} thèmes prêts à l'emploi`);
  }

  /**
   * Recherche des thèmes par couleur
   */
  static findThemesByColor(colorType: 'primary' | 'secondary' | 'accent', targetColor: string): DaisyUIThemeName[] {
    const results: DaisyUIThemeName[] = [];

    Object.entries(daisyThemes).forEach(([themeName, variables]) => {
      const varName = `--color-${colorType}`;
      const themeColor = variables[varName];

      if (themeColor && themeColor.includes(targetColor)) {
        results.push(themeName as DaisyUIThemeName);
      }
    });

    return results;
  }

  /**
   * Obtient les informations d'un thème
   */
  static getThemeInfo(themeName: DaisyUIThemeName): {
    name: string;
    variables: number;
    primary: string;
    secondary: string;
    accent: string;
  } | null {
    const theme = daisyThemes[themeName];
    if (!theme) return null;

    return {
      name: themeName,
      variables: Object.keys(theme).length,
      primary: theme['--color-primary'] || 'N/A',
      secondary: theme['--color-secondary'] || 'N/A',
      accent: theme['--color-accent'] || 'N/A'
    };
  }
}

// ============= UTILITAIRES =============

/**
 * Applique un thème aléatoire DaisyUI
 */
export function applyRandomDaisyTheme(): void {
  const themes = DaisyUIIntegration.getAvailableThemes();
  const randomTheme = themes[Math.floor(Math.random() * themes.length)];
  DaisyUIIntegration.applyTheme(randomTheme);
  console.log(`🎲 Thème aléatoire appliqué: ${randomTheme}`);
}

/**
 * Crée une liste de boutons pour tester tous les thèmes
 */
export function createThemeSwitcherButtons(container: HTMLElement): void {
  const themes = DaisyUIIntegration.getAvailableThemes();

  themes.forEach(themeName => {
    const button = document.createElement('button');
    button.textContent = themeName;
    button.className = 'btn btn-sm m-1';
    button.onclick = () => DaisyUIIntegration.applyTheme(themeName);
    container.appendChild(button);
  });
}

// ============= EXEMPLE D'UTILISATION =============

/*
// Dans votre composant React:
import { DaisyUIIntegration } from '../theme/daisyui-integration';

// Appliquer un thème
DaisyUIIntegration.applyTheme('cupcake');

// Créer un sélecteur de thèmes
const ThemeSelector = () => {
  const themes = DaisyUIIntegration.getAvailableThemes();

  return (
    <select onChange={(e) => DaisyUIIntegration.applyTheme(e.target.value as DaisyUIThemeName)}>
      {themes.map(theme => (
        <option key={theme} value={theme}>{theme}</option>
      ))}
    </select>
  );
};
*/
