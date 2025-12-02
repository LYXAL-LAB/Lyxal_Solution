/**
 * theme-generator.ts - Générateur automatique de thèmes
 * Génère des thèmes complets basés sur la théorie des couleurs
 */

// ============= TYPES =============

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

// ============= CLASSE =============

export class ThemeGenerator {
  /**
   * Génère un thème complet à partir d'une couleur primaire
   * @param primaryColor - Couleur hex (ex: '#3b82f6')
   * @returns ThemeVariables complètes
   */
  static generateFromPrimary(primaryColor: string): ThemeVariables {
    const primary = this.hexToRgb(primaryColor);
    const hsl = this.rgbToHsl(...primary);
    
    return {
      // Primary
      '--color-primary': primary.join(' '),
      '--color-primary-focus': this.adjustBrightness(primary, -15).join(' '),
      '--color-primary-content': this.getContrastColor(primary).join(' '),
      
      // Secondary (couleur complémentaire)
      '--color-secondary': this.getComplementary(primary).join(' '),
      '--color-secondary-focus': this.adjustBrightness(this.getComplementary(primary), -15).join(' '),
      '--color-secondary-content': this.getContrastColor(this.getComplementary(primary)).join(' '),
      
      // Accent (triadique)
      '--color-accent': this.getTriadic(primary)[0].join(' '),
      '--color-accent-focus': this.adjustBrightness(this.getTriadic(primary)[0], -15).join(' '),
      '--color-accent-content': this.getContrastColor(this.getTriadic(primary)[0]).join(' '),
      
      // Neutral (gris basé sur la teinte primaire)
      '--color-neutral': this.generateNeutral(primary, 70).join(' '),
      '--color-neutral-focus': this.generateNeutral(primary, 60).join(' '),
      '--color-neutral-content': '255 255 255',
      
      // Base colors
      '--color-base-100': '255 255 255',
      '--color-base-200': '249 250 251',
      '--color-base-300': '243 244 246',
      '--color-base-content': '31 41 55',
      
      // Status colors
      '--color-info': '14 165 233',
      '--color-success': '34 197 94',
      '--color-warning': '249 115 22',
      '--color-error': '239 68 68',
      
      // Design tokens
      '--rounded-box': '1rem',
      '--rounded-btn': '0.5rem',
      '--rounded-badge': '1.9rem',
      '--animation-btn': '0.25s',
      '--animation-input': '0.2s',
      '--btn-focus-scale': '0.95',
      '--border-btn': '1px',
    };
  }

  /**
   * Génère un thème sombre à partir d'un thème clair
   * @param lightTheme - Thème clair source
   * @returns Thème sombre adapté
   */
  static generateDarkVariant(lightTheme: ThemeVariables): ThemeVariables {
    const darkTheme = { ...lightTheme };
    
    Object.keys(lightTheme).forEach(key => {
      const typedKey = key as keyof ThemeVariables;
      
      if (key.includes('base-100')) {
        darkTheme[typedKey] = '17 24 39';
      } else if (key.includes('base-200')) {
        darkTheme[typedKey] = '31 41 55';
      } else if (key.includes('base-300')) {
        darkTheme[typedKey] = '55 65 81';
      } else if (key.includes('base-content')) {
        darkTheme[typedKey] = '229 231 235';
      } else if (key.includes('primary') && !key.includes('content')) {
        const rgb = lightTheme[typedKey].split(' ').map(Number) as RGB;
        darkTheme[typedKey] = this.adjustBrightness(rgb, 30).join(' ');
      }
    });
    
    return darkTheme;
  }

  /**
   * Génère une palette de couleurs analogues
   * @param baseColor - Couleur hex de base
   * @param count - Nombre de couleurs à générer
   * @returns Tableau de couleurs hex
   */
  static generateAnalogousPalette(baseColor: string, count: number = 5): string[] {
    const rgb = this.hexToRgb(baseColor);
    const hsl = this.rgbToHsl(...rgb);
    const palette: string[] = [];
    
    const step = 30; // Degrés de rotation
    
    for (let i = 0; i < count; i++) {
      const offset = (i - Math.floor(count / 2)) * step;
      const newHue = (hsl[0] + offset + 360) % 360;
      const newRgb = this.hslToRgb(newHue, hsl[1], hsl[2]);
      palette.push(this.rgbToHex(...newRgb));
    }
    
    return palette;
  }

  /**
   * Génère une palette monochromatique
   * @param baseColor - Couleur hex de base
   * @param count - Nombre de nuances
   * @returns Tableau de couleurs hex
   */
  static generateMonochromaticPalette(baseColor: string, count: number = 9): string[] {
    const rgb = this.hexToRgb(baseColor);
    const hsl = this.rgbToHsl(...rgb);
    const palette: string[] = [];
    
    for (let i = 0; i < count; i++) {
      const lightness = 95 - (i * (90 / (count - 1)));
      const newRgb = this.hslToRgb(hsl[0], hsl[1], lightness);
      palette.push(this.rgbToHex(...newRgb));
    }
    
    return palette;
  }

  /**
   * Génère un thème basé sur une image
   * @param imageUrl - URL de l'image
   * @returns Promise<ThemeVariables>
   * @todo Implémenter avec color-thief ou vibrant.js
   */
  static async generateFromImage(imageUrl: string): Promise<ThemeVariables | null> {
    // Cette fonction nécessiterait une bibliothèque d'extraction de couleurs
    // Comme color-thief ou vibrant.js
    console.warn('Feature coming soon: extract colors from image', imageUrl);
    return null;
  }

  // ============= CONVERSIONS DE COULEURS =============

  /**
   * Convertit HEX en RGB
   * @param hex - Couleur hex (ex: '#3b82f6')
   * @returns Tableau RGB [r, g, b]
   */
  static hexToRgb(hex: string): RGB {
    const cleanHex = hex.replace('#', '');
    
    if (!/^[0-9A-Fa-f]{6}$/.test(cleanHex)) {
      throw new Error(`Invalid hex color: ${hex}`);
    }
    
    return [
      parseInt(cleanHex.substring(0, 2), 16),
      parseInt(cleanHex.substring(2, 4), 16),
      parseInt(cleanHex.substring(4, 6), 16)
    ];
  }

  /**
   * Convertit RGB en HEX
   * @param r - Rouge (0-255)
   * @param g - Vert (0-255)
   * @param b - Bleu (0-255)
   * @returns Couleur hex
   */
  static rgbToHex(r: number, g: number, b: number): string {
    return '#' + [r, g, b].map(x => {
      const hex = Math.round(Math.max(0, Math.min(255, x))).toString(16);
      return hex.length === 1 ? '0' + hex : hex;
    }).join('');
  }

  /**
   * Convertit RGB en HSL
   * @param r - Rouge (0-255)
   * @param g - Vert (0-255)
   * @param b - Bleu (0-255)
   * @returns Tableau HSL [h, s, l]
   */
  static rgbToHsl(r: number, g: number, b: number): HSL {
    r /= 255;
    g /= 255;
    b /= 255;

    const max = Math.max(r, g, b);
    const min = Math.min(r, g, b);
    let h = 0;
    let s = 0;
    const l = (max + min) / 2;

    if (max !== min) {
      const d = max - min;
      s = l > 0.5 ? d / (2 - max - min) : d / (max + min);
      
      switch (max) {
        case r: h = ((g - b) / d + (g < b ? 6 : 0)) / 6; break;
        case g: h = ((b - r) / d + 2) / 6; break;
        case b: h = ((r - g) / d + 4) / 6; break;
      }
    }

    return [Math.round(h * 360), Math.round(s * 100), Math.round(l * 100)];
  }

  /**
   * Convertit HSL en RGB
   * @param h - Teinte (0-360)
   * @param s - Saturation (0-100)
   * @param l - Luminosité (0-100)
   * @returns Tableau RGB [r, g, b]
   */
  static hslToRgb(h: number, s: number, l: number): RGB {
    h /= 360;
    s /= 100;
    l /= 100;

    let r: number, g: number, b: number;

    if (s === 0) {
      r = g = b = l;
    } else {
      const hue2rgb = (p: number, q: number, t: number): number => {
        if (t < 0) t += 1;
        if (t > 1) t -= 1;
        if (t < 1/6) return p + (q - p) * 6 * t;
        if (t < 1/2) return q;
        if (t < 2/3) return p + (q - p) * (2/3 - t) * 6;
        return p;
      };

      const q = l < 0.5 ? l * (1 + s) : l + s - l * s;
      const p = 2 * l - q;

      r = hue2rgb(p, q, h + 1/3);
      g = hue2rgb(p, q, h);
      b = hue2rgb(p, q, h - 1/3);
    }

    return [Math.round(r * 255), Math.round(g * 255), Math.round(b * 255)];
  }

  // ============= MANIPULATION DE COULEURS =============

  /**
   * Ajuste la luminosité d'une couleur
   * @param rgb - Couleur RGB
   * @param percent - Pourcentage d'ajustement (-100 à 100)
   * @returns Nouvelle couleur RGB
   */
  static adjustBrightness(rgb: RGB, percent: number): RGB {
    return rgb.map(value => {
      const adjusted = value + (value * percent / 100);
      return Math.max(0, Math.min(255, adjusted));
    }) as RGB;
  }

  /**
   * Obtient la couleur complémentaire
   * @param rgb - Couleur RGB source
   * @returns Couleur complémentaire RGB
   */
  static getComplementary(rgb: RGB): RGB {
    const hsl = this.rgbToHsl(...rgb);
    const newHue = (hsl[0] + 180) % 360;
    return this.hslToRgb(newHue, hsl[1], hsl[2]);
  }

  /**
   * Obtient les couleurs triadiques
   * @param rgb - Couleur RGB source
   * @returns Tableau de 2 couleurs RGB
   */
  static getTriadic(rgb: RGB): [RGB, RGB] {
    const hsl = this.rgbToHsl(...rgb);
    return [
      this.hslToRgb((hsl[0] + 120) % 360, hsl[1], hsl[2]),
      this.hslToRgb((hsl[0] + 240) % 360, hsl[1], hsl[2])
    ];
  }

  /**
   * Génère une couleur neutre (gris) avec la teinte de base
   * @param rgb - Couleur RGB source
   * @param lightness - Luminosité cible (0-100)
   * @returns Couleur neutre RGB
   */
  static generateNeutral(rgb: RGB, lightness: number): RGB {
    const hsl = this.rgbToHsl(...rgb);
    return this.hslToRgb(hsl[0], Math.min(hsl[1], 10), lightness);
  }

  /**
   * Obtient la couleur de texte optimale (noir ou blanc)
   * @param rgb - Couleur de fond RGB
   * @returns Couleur de texte RGB (noir ou blanc)
   */
  static getContrastColor(rgb: RGB): RGB {
    // Calcul de la luminance relative
    const luminance = (0.299 * rgb[0] + 0.587 * rgb[1] + 0.114 * rgb[2]) / 255;
    return luminance > 0.5 ? [0, 0, 0] : [255, 255, 255];
  }

  // ============= VALIDATION ACCESSIBILITÉ =============

  /**
   * Valide le contraste WCAG entre deux couleurs
   * @param foreground - Couleur de premier plan RGB
   * @param background - Couleur de fond RGB
   * @returns Résultats de validation WCAG
   */
  static checkContrast(foreground: RGB, background: RGB): ContrastResult {
    const getLuminance = (rgb: RGB): number => {
      const [r, g, b] = rgb.map(val => {
        const normalized = val / 255;
        return normalized <= 0.03928 
          ? normalized / 12.92 
          : Math.pow((normalized + 0.055) / 1.055, 2.4);
      });
      return 0.2126 * r + 0.7152 * g + 0.0722 * b;
    };

    const l1 = getLuminance(foreground);
    const l2 = getLuminance(background);
    const ratio = (Math.max(l1, l2) + 0.05) / (Math.min(l1, l2) + 0.05);

    return {
      ratio: ratio.toFixed(2),
      AA: ratio >= 4.5,
      AAA: ratio >= 7,
      AALarge: ratio >= 3,
      AAALarge: ratio >= 4.5
    };
  }

  // ============= EXPORT =============

  /**
   * Exporte le thème en différents formats
   * @param theme - Thème à exporter
   * @param format - Format de sortie
   * @returns Thème exporté sous forme de string
   */
  static exportTheme(theme: ThemeVariables, format: ExportFormat = 'css'): string {
    switch (format) {
      case 'css':
        return Object.entries(theme)
          .map(([key, value]) => `  ${key}: ${value};`)
          .join('\n');
      
      case 'json':
        return JSON.stringify(theme, null, 2);
      
      case 'tailwind': {
        const tailwindConfig: Record<string, string> = {};
        Object.entries(theme).forEach(([key, value]) => {
          if (key.startsWith('--color-')) {
            const colorName = key.replace('--color-', '').replace(/-/g, '');
            tailwindConfig[colorName] = `rgb(${value})`;
          }
        });
        return JSON.stringify({ colors: tailwindConfig }, null, 2);
      }
      
      default:
        return JSON.stringify(theme);
    }
  }

  // ============= VALIDATION =============

  /**
   * Valide qu'une couleur hex est correcte
   * @param hex - Couleur hex à valider
   * @returns true si valide
   */
  static validateHex(hex: string): boolean {
    const cleanHex = hex.replace('#', '');
    return /^[0-9A-Fa-f]{6}$/.test(cleanHex);
  }

  /**
   * Valide qu'une couleur RGB est correcte
   * @param rgb - Couleur RGB à valider
   * @returns true si valide
   */
  static validateRgb(rgb: RGB): boolean {
    return rgb.every(val => val >= 0 && val <= 255);
  }
}

// Export par défaut pour compatibilité CommonJS
export default ThemeGenerator;

