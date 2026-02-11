/**
 * Agent IA spécialisé dans le choix de design de boutons
 * Analyse le contexte d'application et recommande le style optimal
 * Connecté au ThemeManager pour cohérence avec le thème actif
 */

import { Size, Color, Variant, Animation, Shape, VisualTheme } from './buttonStyles';
import { themeManager } from '../../../src/theme';

// ============= TYPES =============

export type AppType = 'saas' | 'e-commerce' | 'corporate' | 'creative' | 'gaming' | 'health' | 'education' | 'finance';
export type AppTheme = 'minimal' | 'modern' | 'glassmorphism' | 'cyberpunk' | 'corporate' | 'playful';
export type Industry = 'tech' | 'finance' | 'health' | 'education' | 'retail' | 'entertainment' | 'business';
export type Audience = 'b2b' | 'b2c' | 'internal' | 'consumer' | 'professional';

export interface AppContext {
  type: AppType;
  theme: AppTheme;
  industry: Industry;
  audience: Audience;
}

export type ButtonIntent = 
  | 'primary-action'      // CTA principal (ex: "Commencer", "Acheter")
  | 'secondary-action'    // Action secondaire (ex: "En savoir plus")
  | 'destructive'         // Action dangereuse (ex: "Supprimer")
  | 'navigation'          // Navigation/Liens
  | 'toggle'              // On/off, états
  | 'submit'              // Soumettre formulaire
  | 'loading'             // État de chargement
  | 'success'             // Confirmation
  | 'premium'             // Upsell/Upgrade
  | 'social';             // Partage social

export interface ButtonRecommendation {
  size: Size;
  color: Color;
  variant: Variant;
  shape: Shape;
  animation: Animation;
  visualTheme: VisualTheme;
  confidence: number;
  reasoning: string;
}

// ============= AGENT IA =============

export class ButtonDesignAI {
  /**
   * Analyse le contexte et recommande un style de bouton
   * Utilise les couleurs du thème actif pour cohérence
   */
  recommend(intent: ButtonIntent, context: AppContext): ButtonRecommendation {
    // Récupérer le thème actuel
    const currentTheme = themeManager.getCurrentTheme();
    
    // Logique de décision basée sur l'analyse du contexte
    const baseStyle = this.getBaseStyleForContext(context, currentTheme);
    const intentModifications = this.getIntentModifications(intent, context);
    
    // Fusionner avec valeurs par défaut garanties
    const merged = {
      ...baseStyle,
      ...intentModifications
    };
    
    return {
      size: merged.size || 'md',
      color: merged.color || 'primary',
      variant: merged.variant || 'solid',
      shape: merged.shape || 'rounded',
      animation: merged.animation || 'none',
      visualTheme: merged.visualTheme || 'modern',
      confidence: this.calculateConfidence(context, intent),
      reasoning: this.generateReasoning(context, intent, baseStyle, intentModifications, currentTheme)
    };
  }

  /**
   * Obtient le style de base selon le contexte d'application
   * Utilise les couleurs du thème actif pour cohérence
   */
  private getBaseStyleForContext(context: AppContext, currentTheme: string): Partial<ButtonRecommendation> {
    // Matrice de décision par type d'app
    const styleMatrix: Record<AppType, Partial<ButtonRecommendation>> = {
      saas: {
        size: 'lg',
        variant: 'gradient',
        color: 'primary', // ✅ Utilise la couleur du thème
        shape: 'rounded',
        animation: 'scale',
        visualTheme: 'modern'
      },
      'e-commerce': {
        size: 'lg',
        variant: 'solid',
        color: 'green', // Garde green pour conversion
        shape: 'rounded',
        animation: 'scale',
        visualTheme: 'modern'
      },
      corporate: {
        size: 'md',
        variant: 'solid',
        color: 'primary', // ✅ Utilise la couleur du thème
        shape: 'rounded',
        animation: 'none',
        visualTheme: 'corporate'
      },
      creative: {
        size: 'lg',
        variant: 'gradient',
        color: 'accent', // ✅ Utilise accent du thème
        shape: 'rounded',
        animation: 'sparkle',
        visualTheme: 'modern'
      },
      gaming: {
        size: 'lg',
        variant: 'solid',
        color: 'cyan',
        shape: 'rectangle',
        animation: 'glitch',
        visualTheme: 'cyberpunk'
      },
      health: {
        size: 'md',
        variant: 'solid',
        color: 'green',
        shape: 'rounded',
        animation: 'none',
        visualTheme: 'minimal'
      },
      education: {
        size: 'md',
        variant: 'solid',
        color: 'secondary', // ✅ Utilise secondary du thème
        shape: 'rounded',
        animation: 'none',
        visualTheme: 'modern'
      },
      finance: {
        size: 'md',
        variant: 'solid',
        color: 'primary', // ✅ Utilise la couleur du thème
        shape: 'rounded',
        animation: 'none',
        visualTheme: 'corporate'
      }
    };

    // Ajustements selon le thème
    const baseStyle = styleMatrix[context.type];
    
    if (context.theme === 'glassmorphism') {
      baseStyle.variant = 'glass';
      baseStyle.visualTheme = 'glassmorphism';
    } else if (context.theme === 'cyberpunk') {
      baseStyle.visualTheme = 'cyberpunk';
      baseStyle.shape = 'rectangle';
    } else if (context.theme === 'minimal') {
      baseStyle.visualTheme = 'minimal';
      baseStyle.animation = 'none';
    }

    return baseStyle;
  }

  /**
   * Applique les modifications selon l'intention du bouton
   */
  private getIntentModifications(intent: ButtonIntent, context: AppContext): Partial<ButtonRecommendation> {
    const modifications: Record<ButtonIntent, Partial<ButtonRecommendation>> = {
      'primary-action': {
        size: 'lg',
        variant: context.type === 'saas' ? 'gradient' : 'solid',
        color: 'primary', // ✅ Utilise primary du thème
        animation: 'scale'
      },
      'secondary-action': {
        size: 'md',
        variant: 'outline',
        color: 'primary', // ✅ Utilise primary en outline
        animation: 'none'
      },
      'destructive': {
        color: 'red', // Garde red (sémantique danger)
        variant: 'outline',
        animation: 'none'
      },
      'navigation': {
        size: 'sm',
        variant: 'ghost',
        animation: 'none'
      },
      'toggle': {
        size: 'md',
        variant: 'solid',
        color: 'primary', // ✅ Utilise primary
        shape: 'pill',
        animation: 'none'
      },
      'submit': {
        size: 'md',
        variant: 'solid',
        color: 'primary', // ✅ Utilise primary du thème
        animation: 'none'
      },
      'loading': {
        size: 'md',
        variant: 'solid',
        color: 'primary', // ✅ Utilise primary
        animation: 'pulse'
      },
      'success': {
        color: 'green', // Garde green (sémantique succès)
        variant: 'solid',
        animation: 'scale'
      },
      'premium': {
        size: 'lg',
        variant: 'gradient',
        color: 'yellow', // Garde yellow (sémantique premium/or)
        animation: 'sparkle'
      },
      'social': {
        size: 'md',
        variant: 'solid',
        color: 'primary', // ✅ Utilise primary
        shape: 'pill',
        animation: 'scale'
      }
    };

    return modifications[intent];
  }

  /**
   * Calcule le score de confiance de la recommandation
   */
  private calculateConfidence(context: AppContext, intent: ButtonIntent): number {
    // Score de base
    let confidence = 0.7;

    // Bonus pour correspondances fortes
    if (context.type === 'saas' && intent === 'primary-action') confidence += 0.2;
    if (context.type === 'e-commerce' && intent === 'primary-action') confidence += 0.15;
    if (context.audience === 'b2b' && intent === 'primary-action') confidence += 0.05;
    
    // Bonus pour cohérence thématique
    if (context.theme === context.type) confidence += 0.05;

    return Math.min(0.99, confidence);
  }

  /**
   * Génère l'explication de la recommandation
   * Inclut le thème actif dans le raisonnement
   */
  private generateReasoning(
    context: AppContext, 
    intent: ButtonIntent,
    baseStyle: Partial<ButtonRecommendation>,
    intentMods: Partial<ButtonRecommendation>,
    currentTheme: string
  ): string {
    const reasons: string[] = [];

    // Contexte thème
    reasons.push(`Thème actif: "${currentTheme}"`);
    if (baseStyle.color === 'primary' || baseStyle.color === 'secondary' || baseStyle.color === 'accent') {
      reasons.push(`Utilise la couleur "${baseStyle.color}" du thème pour cohérence globale`);
    }

    // Contexte app
    if (context.type === 'saas') {
      reasons.push('Style SaaS moderne avec gradients pour modernité');
    } else if (context.type === 'e-commerce') {
      reasons.push('Couleurs vives et appel à l\'action clair pour conversion');
    } else if (context.type === 'corporate') {
      reasons.push('Style professionnel sobre et fiable');
    } else if (context.type === 'gaming') {
      reasons.push('Esthétique gaming avec effets néon');
    }

    // Intent
    if (intent === 'primary-action') {
      reasons.push('Taille large pour visibilité maximale du CTA principal');
    } else if (intent === 'destructive') {
      reasons.push('Rouge en outline pour signaler le danger sans être trop agressif');
    } else if (intent === 'premium') {
      reasons.push('Or et effets sparkle pour évoquer le premium');
    }

    // Audience
    if (context.audience === 'b2b') {
      reasons.push('Audience B2B = style professionnel privilégié');
    } else if (context.audience === 'b2c') {
      reasons.push('Audience B2C = animations plus prononcées pour engagement');
    }

    return reasons.join('. ') + '.';
  }

  /**
   * Obtient plusieurs recommandations alternatives
   */
  getAlternatives(intent: ButtonIntent, context: AppContext, count: number = 3): ButtonRecommendation[] {
    const currentTheme = themeManager.getCurrentTheme();
    const primary = this.recommend(intent, context);
    const alternatives: ButtonRecommendation[] = [primary];

    // Variation 1: Changer le variant
    if (primary.variant === 'gradient') {
      alternatives.push({
        ...primary,
        variant: 'solid',
        confidence: primary.confidence - 0.1,
        reasoning: `Alternative avec variant solid pour plus de sobriété (Thème: ${currentTheme})`
      });
    }

    // Variation 2: Changer la taille
    if (primary.size === 'lg') {
      alternatives.push({
        ...primary,
        size: 'md',
        confidence: primary.confidence - 0.15,
        reasoning: `Alternative plus compacte (Thème: ${currentTheme})`
      });
    }

    return alternatives.slice(0, count);
  }
}

// ============= INSTANCE SINGLETON =============

export const buttonDesignAI = new ButtonDesignAI();

