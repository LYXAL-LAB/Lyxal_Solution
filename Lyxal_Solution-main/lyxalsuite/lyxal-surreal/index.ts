/**
 * LYXAL SURREAL CLIENT - Point d'entrée principal
 * 
 * Architecture modulaire révolutionnaire pour l'écosystème LYXAL
 * Solution commercialisable 100k€-500k€
 */

import { BaseSurrealClient } from './core/baseSurrealClient';
import { Level0MasterClient } from './levels/level0-master.client';
import type { SurrealConfig, PerformanceMetrics } from './core/types';

// Re-export des types pour l'API publique
export type {
  SurrealConfig,
  PerformanceMetrics,
  Environment,
  DaisyUITheme,
  SystemIdentity,
  SystemInfrastructure,
  SystemConfigMetadata,
  CreateMasterPlatformData,
  CreateMasterPlatformResponse,
  UpdateMasterConfigData,
  UpdateMasterConfigResponse,
  InvestorRegistry,
  BusinessRegistry,
  DeveloperRegistry,
  ContractorRegistry,
  GlobalMetrics,
  RevenueDistribution,
  HierarchyView,
  RegistryQueryOptions,
  RegistryPaginatedResult,
  ValidationResult
} from './core/types';

export { NiveauArchitectural } from './core/types';

/**
 * Client LYXAL Surreal unifié - Architecture modulaire
 * 
 * Composition des niveaux hiérarchiques :
 * - Niveau 0: MASTER (contrôle plateforme globale)
 * - Niveau 1: INVESTOR (à venir)
 * - Niveau 2: BUSINESS (à venir)
 * - Niveau 3: DEVELOPER (à venir)
 * - Niveau 4: CONTRACTOR (à venir)
 * - Niveau 5: END_USERS (à venir)
 */
export class LyxalSurrealClient {
  private baseClient: BaseSurrealClient;
  
  // Clients par niveau (composition)
  public readonly master: Level0MasterClient;
  
  // À venir dans les prochaines versions
  // public readonly investor: Level1InvestorClient;
  // public readonly business: Level2BusinessClient;
  // public readonly developer: Level3DeveloperClient;
  // public readonly contractor: Level4ContractorClient;
  // public readonly endUsers: Level5EndUsersClient;
  
  // Registry et analytics (à venir)
  // public readonly registry: RegistryManager;
  // public readonly analytics: AnalyticsManager;

  constructor(config: SurrealConfig) {
    this.baseClient = BaseSurrealClient.getInstance(config);
    
    // Injection du client de base dans chaque niveau
    this.master = new Level0MasterClient(this.baseClient);
  }

  /**
   * Initialiser la connexion à SurrealDB
   */
  public async initialize(): Promise<void> {
    await this.baseClient.initialize();
    console.log('🚀 LYXAL Surreal Client initialisé avec succès');
  }

  /**
   * Vérifier l'état de la connexion
   */
  public async healthCheck(): Promise<{
    connected: boolean;
    namespace: string;
    database: string;
    masterConfigured: boolean;
    performance: PerformanceMetrics;
  }> {
    try {
      const masterConfigured = await this.master.isMasterLevelConfigured();
      const performance = this.baseClient.getPerformanceMetrics();
      
      return {
        connected: true,
        namespace: this.baseClient.getCurrentNamespace(),
        database: this.baseClient.getCurrentDatabase(),
        masterConfigured,
        performance
      };
    } catch (error) {
      return {
        connected: false,
        namespace: '',
        database: '',
        masterConfigured: false,
        performance: this.baseClient.getPerformanceMetrics()
      };
    }
  }

  /**
   * Obtenir les métriques de performance globales
   */
  public getPerformanceMetrics(): PerformanceMetrics {
    return this.baseClient.getPerformanceMetrics();
  }

  /**
   * Générer un rapport de performance complet
   */
  public generatePerformanceReport(): string {
    return this.baseClient.generatePerformanceReport();
  }

  /**
   * Invalider le cache pour un pattern donné
   */
  public invalidateCache(pattern: string): number {
    return this.baseClient.invalidateCache(pattern);
  }

  /**
   * Accès au client de base (pour usage avancé)
   */
  public getBaseClient(): BaseSurrealClient {
    return this.baseClient;
  }

  /**
   * Fermer la connexion et nettoyer les ressources
   */
  public async close(): Promise<void> {
    await this.baseClient.close();
    console.log('✅ LYXAL Surreal Client fermé proprement');
  }

  /**
   * Réinitialiser l'instance singleton (utile pour les tests)
   */
  public static resetInstance(): void {
    BaseSurrealClient.resetInstance();
  }
}

/**
 * Factory function pour créer une instance du client
 */
export function createLyxalSurrealClient(config: SurrealConfig): LyxalSurrealClient {
  return new LyxalSurrealClient(config);
}

/**
 * Configuration par défaut pour les tests/développement
 */
export const defaultConfig: SurrealConfig = {
  url: 'wss://accurate-horse-06bnu0f1k1tv1215mv54m347tc.aws-euw1.surreal.cloud/rpc',
  user: 'admin',
  pass: 'admin',
  namespace: 'lyxal_platform',
  database: 'platform'
};

// Export par défaut
export default LyxalSurrealClient; 