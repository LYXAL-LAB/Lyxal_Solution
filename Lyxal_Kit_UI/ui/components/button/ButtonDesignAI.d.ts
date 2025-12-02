/**
 * Agent IA spécialisé dans le choix de design de boutons
 * Analyse le contexte d'application et recommande le style optimal
 * Connecté au ThemeManager pour cohérence avec le thème actif
 */
import { Size, Color, Variant, Animation, Shape, VisualTheme } from './buttonStyles';
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
export type ButtonIntent = 'primary-action' | 'secondary-action' | 'destructive' | 'navigation' | 'toggle' | 'submit' | 'loading' | 'success' | 'premium' | 'social';
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
export declare class ButtonDesignAI {
    /**
     * Analyse le contexte et recommande un style de bouton
     * Utilise les couleurs du thème actif pour cohérence
     */
    recommend(intent: ButtonIntent, context: AppContext): ButtonRecommendation;
    /**
     * Obtient le style de base selon le contexte d'application
     * Utilise les couleurs du thème actif pour cohérence
     */
    private getBaseStyleForContext;
    /**
     * Applique les modifications selon l'intention du bouton
     */
    private getIntentModifications;
    /**
     * Calcule le score de confiance de la recommandation
     */
    private calculateConfidence;
    /**
     * Génère l'explication de la recommandation
     * Inclut le thème actif dans le raisonnement
     */
    private generateReasoning;
    /**
     * Obtient plusieurs recommandations alternatives
     */
    getAlternatives(intent: ButtonIntent, context: AppContext, count?: number): ButtonRecommendation[];
}
export declare const buttonDesignAI: ButtonDesignAI;
