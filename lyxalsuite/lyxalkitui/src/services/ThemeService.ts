interface TenantThemeConfig {
  tenantId: string;
  primaryTheme: string;
  allowedThemes: string[];
  customColors?: {
    primary?: string;
    secondary?: string;
    accent?: string;
    logo?: string;
  };
  branding?: {
    logo?: string;
    favicon?: string;
    name?: string;
  };
}

interface UserThemePreferences {
  userId: string;
  tenantId: string;
  preferredTheme: string;
  darkModeEnabled: boolean;
  customSettings?: Record<string, any>;
}

class ThemeService {
  private static instance: ThemeService;
  private tenantConfig: TenantThemeConfig | null = null;
  private userPreferences: UserThemePreferences | null = null;

  private constructor() {}

  static getInstance(): ThemeService {
    if (!ThemeService.instance) {
      ThemeService.instance = new ThemeService();
    }
    return ThemeService.instance;
  }

  // Configuration du tenant
  async setTenantConfig(tenantId: string): Promise<void> {
    try {
      // Dans un vrai SaaS, ceci ferait appel à votre API
      const response = await fetch(`/api/tenants/${tenantId}/theme-config`);
      if (response.ok) {
        this.tenantConfig = await response.json();
        this.applyTenantBranding();
      } else {
        // Configuration par défaut si pas de config trouvée
        this.tenantConfig = {
          tenantId,
          primaryTheme: 'corporate',
          allowedThemes: ['light', 'dark', 'corporate'],
          customColors: {
            primary: '#4b6bfb',
            secondary: '#7b92ff',
            accent: '#67cba0'
          }
        };
      }
    } catch (error) {
      console.error('Erreur lors du chargement de la config tenant:', error);
      // Fallback vers la config par défaut
      this.tenantConfig = {
        tenantId,
        primaryTheme: 'light',
        allowedThemes: ['light', 'dark']
      };
    }
  }

  // Préférences utilisateur
  async setUserPreferences(userId: string, tenantId: string): Promise<void> {
    try {
      const response = await fetch(`/api/users/${userId}/theme-preferences`);
      if (response.ok) {
        this.userPreferences = await response.json();
      } else {
        // Préférences par défaut
        this.userPreferences = {
          userId,
          tenantId,
          preferredTheme: this.tenantConfig?.primaryTheme || 'light',
          darkModeEnabled: false
        };
      }
    } catch (error) {
      console.error('Erreur lors du chargement des préférences:', error);
    }
  }

  // Sauvegarder les préférences utilisateur
  async saveUserPreferences(preferences: Partial<UserThemePreferences>): Promise<void> {
    if (!this.userPreferences) return;

    try {
      const updatedPreferences = { ...this.userPreferences, ...preferences };
      
      const response = await fetch(`/api/users/${this.userPreferences.userId}/theme-preferences`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(updatedPreferences)
      });

      if (response.ok) {
        this.userPreferences = updatedPreferences;
      }
    } catch (error) {
      console.error('Erreur lors de la sauvegarde des préférences:', error);
    }
  }

  // Obtenir le thème recommandé pour l'utilisateur
  getRecommendedTheme(): string {
    // Priorité : préférences utilisateur > config tenant > défaut
    if (this.userPreferences?.preferredTheme) {
      return this.userPreferences.preferredTheme;
    }
    
    if (this.tenantConfig?.primaryTheme) {
      return this.tenantConfig.primaryTheme;
    }
    
    return 'light';
  }

  // Obtenir les thèmes autorisés pour le tenant
  getAllowedThemes(): string[] {
    return this.tenantConfig?.allowedThemes || ['light', 'dark'];
  }

  // Vérifier si un thème est autorisé
  isThemeAllowed(theme: string): boolean {
    const allowedThemes = this.getAllowedThemes();
    return allowedThemes.includes(theme);
  }

  // Appliquer le branding du tenant
  private applyTenantBranding(): void {
    if (!this.tenantConfig) return;

    const { customColors, branding } = this.tenantConfig;

    // Appliquer les couleurs personnalisées
    if (customColors) {
      const root = document.documentElement;
      
      if (customColors.primary) {
        root.style.setProperty('--color-primary', customColors.primary);
      }
      if (customColors.secondary) {
        root.style.setProperty('--color-secondary', customColors.secondary);
      }
      if (customColors.accent) {
        root.style.setProperty('--color-accent', customColors.accent);
      }
    }

    // Appliquer le branding
    if (branding) {
      if (branding.favicon) {
        const favicon = document.querySelector('link[rel="icon"]') as HTMLLinkElement;
        if (favicon) favicon.href = branding.favicon;
      }
      
      if (branding.name) {
        document.title = branding.name;
      }
    }
  }

  // Créer un thème personnalisé pour le tenant
  createCustomTheme(themeName: string, colors: Record<string, string>): void {
    const style = document.createElement('style');
    style.id = `custom-theme-${themeName}`;
    
    let css = `[data-theme="${themeName}"] {\n`;
    Object.entries(colors).forEach(([key, value]) => {
      css += `  --color-${key}: ${value};\n`;
    });
    css += '}\n';
    
    style.textContent = css;
    document.head.appendChild(style);
  }

  // Nettoyer les ressources
  cleanup(): void {
    this.tenantConfig = null;
    this.userPreferences = null;
  }
}

export const themeService = ThemeService.getInstance();
export default ThemeService; 