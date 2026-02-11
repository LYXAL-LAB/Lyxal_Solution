import { saasThemeGenerator } from './SaasThemeGenerator';

interface AIAnalysis {
  saasType: 'crm' | 'ecommerce' | 'analytics' | 'blog' | 'portfolio' | 'custom';
  industry: string;
  style: 'professional' | 'creative' | 'minimal' | 'bold' | 'corporate';
  targetAudience: 'b2b' | 'b2c' | 'internal';
  suggestedName: string;
  confidence: number;
  reasoning: string;
}

class SaasAIAgent {
  private static instance: SaasAIAgent;

  private constructor() {}

  static getInstance(): SaasAIAgent {
    if (!SaasAIAgent.instance) {
      SaasAIAgent.instance = new SaasAIAgent();
    }
    return SaasAIAgent.instance;
  }

  /**
   * Analyse une demande en langage naturel et génère un SaaS
   */
  async generateSaasFromPrompt(prompt: string): Promise<any> {
    console.log(`🤖 Agent IA: Analyse de la demande - "${prompt}"`);
    
    // 1. Analyser la demande
    const analysis = await this.analyzePrompt(prompt);
    console.log(`📊 Analyse terminée:`, analysis);

    // 2. Générer le SaaS avec le thème optimal
    const generatedSaaS = await saasThemeGenerator.generateSaaS(
      {
        type: analysis.saasType,
        industry: analysis.industry,
        style: analysis.style,
        targetAudience: analysis.targetAudience
      },
      analysis.suggestedName
    );

    console.log(`✅ SaaS généré: ${generatedSaaS.deploymentUrl}`);
    
    return {
      ...generatedSaaS,
      aiAnalysis: analysis,
      generationTime: this.calculateGenerationTime(),
      prompt: prompt
    };
  }

  /**
   * Analyse intelligente du prompt utilisateur
   */
  private async analyzePrompt(prompt: string): Promise<AIAnalysis> {
    const lowercasePrompt = prompt.toLowerCase();
    
    // Détection du type de SaaS
    const saasType = this.detectSaasType(lowercasePrompt);
    
    // Détection de l'industrie
    const industry = this.detectIndustry(lowercasePrompt);
    
    // Détection du style
    const style = this.detectStyle(lowercasePrompt);
    
    // Détection de l'audience
    const targetAudience = this.detectTargetAudience(lowercasePrompt);
    
    // Génération du nom
    const suggestedName = this.generateName(saasType, industry, lowercasePrompt);
    
    // Calcul de la confiance
    const confidence = this.calculateConfidence(lowercasePrompt, saasType, industry);

    const reasoning = this.generateReasoning(saasType, industry, style, targetAudience);

    return {
      saasType,
      industry,
      style,
      targetAudience,
      suggestedName,
      confidence,
      reasoning
    };
  }

  private detectSaasType(prompt: string): AIAnalysis['saasType'] {
    const typeKeywords = {
      'crm': ['crm', 'client', 'customer', 'contact', 'vente', 'sales', 'pipeline', 'lead'],
      'ecommerce': ['boutique', 'shop', 'ecommerce', 'vente en ligne', 'marketplace', 'store', 'produit'],
      'analytics': ['analytics', 'analyse', 'donnée', 'data', 'statistique', 'reporting', 'dashboard'],
      'blog': ['blog', 'article', 'contenu', 'content', 'actualité', 'news'],
      'portfolio': ['portfolio', 'vitrine', 'showcase', 'présentation', 'galerie']
    };

    for (const [type, keywords] of Object.entries(typeKeywords)) {
      if (keywords.some(keyword => prompt.includes(keyword))) {
        return type as AIAnalysis['saasType'];
      }
    }

    return 'custom';
  }

  private detectIndustry(prompt: string): string {
    const industryKeywords = {
      'real-estate': ['immobilier', 'real estate', 'bien', 'propriété', 'agence immobilière'],
      'healthcare': ['santé', 'health', 'médical', 'hospital', 'clinique', 'docteur'],
      'finance': ['finance', 'banque', 'comptabilité', 'accounting', 'investment'],
      'technology': ['tech', 'software', 'développement', 'startup', 'it'],
      'creative': ['design', 'créatif', 'art', 'graphique', 'web design'],
      'education': ['éducation', 'formation', 'école', 'université', 'cours'],
      'legal': ['juridique', 'avocat', 'legal', 'droit', 'cabinet'],
      'restaurant': ['restaurant', 'food', 'cuisine', 'café', 'bar'],
      'fashion': ['mode', 'fashion', 'vêtement', 'style', 'boutique mode'],
      'fitness': ['fitness', 'sport', 'gym', 'musculation', 'coach']
    };

    for (const [industry, keywords] of Object.entries(industryKeywords)) {
      if (keywords.some(keyword => prompt.includes(keyword))) {
        return industry;
      }
    }

    return 'technology'; // par défaut
  }

  private detectStyle(prompt: string): AIAnalysis['style'] {
    const styleKeywords = {
      'professional': ['professionnel', 'business', 'corporate', 'sérieux'],
      'creative': ['créatif', 'artistique', 'moderne', 'innovant', 'coloré'],
      'minimal': ['minimal', 'simple', 'épuré', 'clean', 'sobre'],
      'bold': ['audacieux', 'bold', 'vibrant', 'impactant'],
      'corporate': ['corporate', 'entreprise', 'formel', 'classique']
    };

    for (const [style, keywords] of Object.entries(styleKeywords)) {
      if (keywords.some(keyword => prompt.includes(keyword))) {
        return style as AIAnalysis['style'];
      }
    }

    return 'professional'; // par défaut
  }

  private detectTargetAudience(prompt: string): AIAnalysis['targetAudience'] {
    if (prompt.includes('b2b') || prompt.includes('entreprise') || prompt.includes('business')) {
      return 'b2b';
    }
    if (prompt.includes('b2c') || prompt.includes('particulier') || prompt.includes('consommateur')) {
      return 'b2c';
    }
    if (prompt.includes('interne') || prompt.includes('équipe') || prompt.includes('internal')) {
      return 'internal';
    }
    
    return 'b2b'; // par défaut
  }

  private generateName(saasType: string, industry: string, prompt: string): string {
    // Extraire un nom potentiel du prompt
    const words = prompt.split(' ');
    const meaningfulWords = words.filter(word => 
      word.length > 3 && 
      !['pour', 'avec', 'dans', 'une', 'des', 'les', 'the', 'and', 'for'].includes(word.toLowerCase())
    );

    if (meaningfulWords.length > 0) {
      const baseName = meaningfulWords[0].charAt(0).toUpperCase() + meaningfulWords[0].slice(1);
      return `${baseName}${saasType.charAt(0).toUpperCase() + saasType.slice(1)}`;
    }

    // Génération par défaut
    const prefixes = {
      'crm': 'Customer',
      'ecommerce': 'Shop',
      'analytics': 'Data',
      'blog': 'Content',
      'portfolio': 'Show'
    };

    return `${prefixes[saasType as keyof typeof prefixes] || 'Smart'}${industry.charAt(0).toUpperCase() + industry.slice(1)}`;
  }

  private calculateConfidence(prompt: string, saasType: string, industry: string): number {
    let confidence = 0.5; // base
    
    // Plus de mots-clés = plus de confiance
    const wordCount = prompt.split(' ').length;
    confidence += Math.min(wordCount * 0.02, 0.3);
    
    // Présence de mots-clés spécifiques
    if (prompt.includes(saasType)) confidence += 0.2;
    if (prompt.includes(industry)) confidence += 0.15;
    
    return Math.min(confidence, 1.0);
  }

  private generateReasoning(saasType: string, industry: string, style: string, targetAudience: string): string {
    return `Détecté: SaaS ${saasType} pour l'industrie ${industry}, style ${style}, ciblant ${targetAudience}. Thème sélectionné automatiquement pour optimiser l'expérience utilisateur.`;
  }

  private calculateGenerationTime(): string {
    const minutes = Math.floor(Math.random() * 3) + 2; // 2-4 minutes
    const seconds = Math.floor(Math.random() * 60);
    return `${minutes}m ${seconds}s`;
  }

  /**
   * Exemples de prompts pour tester l'agent
   */
  getExamplePrompts(): string[] {
    return [
      "Je veux un CRM pour une agence immobilière, style professionnel",
      "Créer une boutique en ligne pour des vêtements de mode, design créatif",
      "Dashboard analytics pour une startup tech, style minimal et moderne",
      "Site portfolio pour un designer graphique, très créatif et coloré",
      "Blog d'entreprise pour une société de conseil, style corporate",
      "CRM pour cabinet d'avocats, très professionnel et sombre",
      "Boutique en ligne de produits artisanaux, style chaleureux",
      "Analytics pour une salle de sport, style énergique et motivant"
    ];
  }
}

export const saasAIAgent = SaasAIAgent.getInstance();
export default SaasAIAgent; 