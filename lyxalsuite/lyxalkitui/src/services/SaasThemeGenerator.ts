interface SaasConfig {
  type: 'crm' | 'ecommerce' | 'analytics' | 'blog' | 'portfolio' | 'custom';
  industry: string;
  brandColors?: {
    primary: string;
    secondary: string;
    accent: string;
  };
  style: 'professional' | 'creative' | 'minimal' | 'bold' | 'corporate';
  targetAudience: 'b2b' | 'b2c' | 'internal';
}

interface GeneratedSaaS {
  id: string;
  name: string;
  subdomain: string;
  config: SaasConfig;
  theme: {
    name: string;
    colors: Record<string, string>;
    customCSS: string;
  };
  modules: string[];
  deploymentUrl: string;
}

class SaasThemeGenerator {
  private static instance: SaasThemeGenerator;

  private constructor() {}

  static getInstance(): SaasThemeGenerator {
    if (!SaasThemeGenerator.instance) {
      SaasThemeGenerator.instance = new SaasThemeGenerator();
    }
    return SaasThemeGenerator.instance;
  }

  // Mappage industrie -> thème recommandé
  private industryThemeMap: Record<string, string[]> = {
    'finance': ['corporate', 'business', 'luxury'],
    'healthcare': ['cupcake', 'emerald', 'light'],
    'technology': ['dark', 'synthwave', 'cyberpunk'],
    'creative': ['valentine', 'fantasy', 'retro'],
    'ecommerce': ['autumn', 'emerald', 'corporate'],
    'real-estate': ['luxury', 'corporate', 'business'],
    'education': ['emerald', 'forest', 'light'],
    'legal': ['dark', 'corporate', 'luxury'],
    'restaurant': ['autumn', 'coffee', 'forest'],
    'fashion': ['valentine', 'luxury', 'black'],
    'gaming': ['synthwave', 'cyberpunk', 'dracula'],
    'fitness': ['emerald', 'forest', 'aqua']
  };

  // Style -> thèmes compatibles
  private styleThemeMap: Record<string, string[]> = {
    'professional': ['corporate', 'business', 'luxury', 'light'],
    'creative': ['synthwave', 'valentine', 'fantasy', 'retro'],
    'minimal': ['light', 'dark', 'wireframe', 'emerald'],
    'bold': ['cyberpunk', 'dracula', 'halloween', 'acid'],
    'corporate': ['corporate', 'business', 'luxury', 'nord']
  };

  /**
   * Génère un thème optimal pour un SaaS basé sur sa configuration
   */
  generateOptimalTheme(config: SaasConfig): string {
    const industryThemes = this.industryThemeMap[config.industry] || ['light'];
    const styleThemes = this.styleThemeMap[config.style] || ['light'];
    
    // Intersection des thèmes compatibles
    const compatibleThemes = industryThemes.filter(theme => 
      styleThemes.includes(theme)
    );

    // Si pas d'intersection, utiliser les thèmes du style
    const selectedThemes = compatibleThemes.length > 0 ? compatibleThemes : styleThemes;
    
    // Sélection basée sur le type de SaaS
    let recommendedTheme = selectedThemes[0];

    switch (config.type) {
      case 'crm':
        recommendedTheme = selectedThemes.find(t => ['corporate', 'business'].includes(t)) || selectedThemes[0];
        break;
      case 'ecommerce':
        recommendedTheme = selectedThemes.find(t => ['emerald', 'autumn', 'corporate'].includes(t)) || selectedThemes[0];
        break;
      case 'analytics':
        recommendedTheme = selectedThemes.find(t => ['dark', 'synthwave', 'corporate'].includes(t)) || selectedThemes[0];
        break;
      default:
        recommendedTheme = selectedThemes[0];
    }

    return recommendedTheme;
  }

  /**
   * Génère des couleurs personnalisées basées sur les couleurs de marque
   */
  generateCustomColors(brandColors?: SaasConfig['brandColors']) {
    if (!brandColors) return {};

    return {
      '--color-primary': brandColors.primary,
      '--color-secondary': brandColors.secondary || brandColors.primary,
      '--color-accent': brandColors.accent || brandColors.primary,
    };
  }

  /**
   * Génère le CSS personnalisé pour le SaaS
   */
  generateCustomThemeCSS(saasId: string, theme: string, customColors: Record<string, string>): string {
    let css = `/* Thème personnalisé pour SaaS: ${saasId} */\n`;
    css += `[data-saas-id="${saasId}"] {\n`;
    css += `  /* Thème de base: ${theme} */\n`;
    
    // Appliquer les couleurs personnalisées
    Object.entries(customColors).forEach(([property, value]) => {
      css += `  ${property}: ${value};\n`;
    });

    css += '}\n\n';

    // CSS spécifique selon le type de SaaS
    css += this.generateTypeSpecificCSS(saasId);

    return css;
  }

  /**
   * CSS spécifique selon le type de SaaS
   */
  private generateTypeSpecificCSS(saasId: string): string {
    return `
/* Styles spécifiques pour ${saasId} */
[data-saas-id="${saasId}"] .saas-header {
  background: oklch(var(--color-primary));
  color: oklch(var(--color-primary-content));
}

[data-saas-id="${saasId}"] .saas-sidebar {
  background: oklch(var(--color-base-200));
  border-right: 1px solid oklch(var(--color-base-300));
}

[data-saas-id="${saasId}"] .saas-card {
  background: oklch(var(--color-base-100));
  border: 1px solid oklch(var(--color-base-300));
  border-radius: var(--radius-box);
}
`;
  }

  /**
   * Génère un SaaS complet avec thème personnalisé
   */
  async generateSaaS(config: SaasConfig, name: string): Promise<GeneratedSaaS> {
    const saasId = `saas-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
    const subdomain = name.toLowerCase().replace(/[^a-z0-9]/g, '-');
    
    // Sélectionner le thème optimal
    const selectedTheme = this.generateOptimalTheme(config);
    
    // Générer les couleurs personnalisées
    const customColors = this.generateCustomColors(config.brandColors);
    
    // Générer le CSS personnalisé
    const customCSS = this.generateCustomThemeCSS(saasId, selectedTheme, customColors);

    // Déterminer les modules nécessaires
    const modules = this.determineRequiredModules(config);

    const generatedSaaS: GeneratedSaaS = {
      id: saasId,
      name,
      subdomain,
      config,
      theme: {
        name: selectedTheme,
        colors: customColors,
        customCSS
      },
      modules,
      deploymentUrl: `https://${subdomain}.lyxalsuite.com`
    };

    // Sauvegarder la configuration
    await this.saveSaasConfig(generatedSaaS);
    
    // Déclencher le déploiement
    await this.deploySaaS(generatedSaaS);

    return generatedSaaS;
  }

  /**
   * Détermine les modules nécessaires selon le type de SaaS
   */
  private determineRequiredModules(config: SaasConfig): string[] {
    const baseModules = ['lyxalkitui', 'lyxalauth'];
    
    const moduleMap: Record<string, string[]> = {
      'crm': [...baseModules, 'lyxalcrm', 'lyxalanalytics'],
      'ecommerce': [...baseModules, 'lyxalecommerce', 'lyxalanalytics'],
      'analytics': [...baseModules, 'lyxalanalytics'],
      'blog': [...baseModules, 'lyxalcms'],
      'portfolio': [...baseModules, 'lyxalcms'],
      'custom': baseModules
    };

    return moduleMap[config.type] || baseModules;
  }

  /**
   * Sauvegarde la configuration du SaaS
   */
  private async saveSaasConfig(saas: GeneratedSaaS): Promise<void> {
    try {
      await fetch('/api/saas/configurations', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(saas)
      });
    } catch (error) {
      console.error('Erreur lors de la sauvegarde:', error);
    }
  }

  /**
   * Déclenche le déploiement du SaaS
   */
  private async deploySaaS(saas: GeneratedSaaS): Promise<void> {
    try {
      await fetch('/api/saas/deploy', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          saasId: saas.id,
          modules: saas.modules,
          theme: saas.theme,
          subdomain: saas.subdomain
        })
      });
    } catch (error) {
      console.error('Erreur lors du déploiement:', error);
    }
  }

  /**
   * Récupère tous les SaaS générés
   */
  async getGeneratedSaasList(): Promise<GeneratedSaaS[]> {
    try {
      const response = await fetch('/api/saas/list');
      return await response.json();
    } catch (error) {
      console.error('Erreur lors de la récupération:', error);
      return [];
    }
  }
}

export const saasThemeGenerator = SaasThemeGenerator.getInstance();
export default SaasThemeGenerator; 