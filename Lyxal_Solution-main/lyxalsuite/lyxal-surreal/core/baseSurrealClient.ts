import { Surreal } from 'surrealdb';
import type { SurrealConfig, PerformanceMetrics } from './types';
import { metadataCache, queryCache, performanceMonitor } from './utils';

/**
 * Client SurrealDB de base - Fonctionnalités communes
 * 
 * Responsabilités :
 * - Connexion et authentification SurrealDB
 * - Gestion des namespaces/databases
 * - Cache intelligent
 * - Monitoring de performance
 * - Méthodes de base pour requêtes
 */
export class BaseSurrealClient {
  private static instance: BaseSurrealClient;
  private db: Surreal;
  private defaultConfig: SurrealConfig;
  private currentNamespace: string;
  private currentDatabase: string;
  
  constructor(config: SurrealConfig) {
    this.db = new Surreal();
    this.defaultConfig = config;
    this.currentNamespace = config.namespace;
    this.currentDatabase = config.database;
  }

  /**
   * Obtenir l'instance unique du client (Singleton)
   */
  public static getInstance(config?: SurrealConfig): BaseSurrealClient {
    if (!BaseSurrealClient.instance) {
      if (!config) {
        throw new Error("Configuration requise pour initialiser le client SurrealDB");
      }
      BaseSurrealClient.instance = new BaseSurrealClient(config);
    }
    return BaseSurrealClient.instance;
  }

  /**
   * Réinitialiser l'instance singleton (utile pour les tests)
   */
  public static resetInstance(): void {
    BaseSurrealClient.instance = null as any;
  }

  /**
   * Initialiser la connexion à SurrealDB Cloud
   */
  public async initialize(): Promise<void> {
    try {
      await this.db.connect(this.defaultConfig.url);
      
      await this.db.signin({
        username: this.defaultConfig.user,
        password: this.defaultConfig.pass,
      });
      
      await this.db.use({
        namespace: this.defaultConfig.namespace,
        database: this.defaultConfig.database
      });
      
      console.log(`🔌 Connecté à SurrealDB Cloud: ${this.defaultConfig.url}`);
    } catch (error) {
      console.error('Erreur de connexion à SurrealDB:', error);
      throw error;
    }
  }

  /**
   * Sélectionner un namespace et une base de données
   */
  public async use(namespace: string, database: string = 'main'): Promise<void> {
    try {
      await this.db.use({
        namespace: namespace,
        database: database
      });
      
      this.currentNamespace = namespace;
      this.currentDatabase = database;
      console.log(`✅ Utilisation du namespace: ${namespace}, database: ${database}`);
    } catch (error) {
      console.error(`Erreur lors de la sélection du namespace ${namespace}:`, error);
      throw error;
    }
  }

  /**
   * Vérifier si un namespace existe (avec cache)
   */
  public async namespaceExists(namespace: string): Promise<boolean> {
    const cacheKey = `namespace_exists:${namespace}`;
    return await metadataCache.cached(cacheKey, async () => {
      try {
        const previousNs = this.currentNamespace;
        const previousDb = this.currentDatabase;
        
        await this.use('system', 'system');
        const result = await this.db.query('INFO FOR ROOT');
        
        await this.use(previousNs, previousDb);
        
        const info = result[0] as any;
        const namespaces = info?.namespaces || {};
        
        let exists = namespace in namespaces;
        
        if (!exists) {
          await new Promise(resolve => setTimeout(resolve, 1500));
          const retryResult = await this.db.query('INFO FOR ROOT');
          const retryInfo = retryResult[0] as any;
          const retryNamespaces = retryInfo?.namespaces || {};
          exists = namespace in retryNamespaces;
        }
        
        return exists;
      } catch (error) {
        console.error(`❌ Error in namespaceExists for ${namespace}:`, error);
        try {
          await this.use(this.currentNamespace, this.currentDatabase);
        } catch (restoreError) {
          // Ignorer les erreurs de restauration
        }
        return false;
      }
    }, 10 * 1000);
  }

  /**
   * Vérifier si une database existe dans un namespace
   */
  public async databaseExists(namespace: string, database: string): Promise<boolean> {
    const cacheKey = `database_exists:${namespace}:${database}`;
    return await metadataCache.cached(cacheKey, async () => {
      try {
        const previousNs = this.currentNamespace;
        const previousDb = this.currentDatabase;
        
        const namespaceExistsAlready = await this.namespaceExists(namespace);
        if (!namespaceExistsAlready) {
          return false;
        }
        
        await this.use(namespace, 'system');
        const result = await this.db.query(`INFO FOR NS`);
        
        await this.use(previousNs, previousDb);
        
        const info = result[0] as any;
        const databases = info?.databases || {};
        
        return database in databases;
      } catch (error) {
        console.error(`❌ Error in databaseExists for ${namespace}:${database}:`, error);
        try {
          await this.use(this.currentNamespace, this.currentDatabase);
        } catch (restoreError) {
          // Ignorer les erreurs de restauration
        }
        return false;
      }
    }, 10 * 1000);
  }

  /**
   * Exécuter une requête SurrealQL avec monitoring de performance
   */
  public async query(query: string, vars?: Record<string, any>): Promise<any> {
    return await performanceMonitor.measureQuery(
      query,
      this.currentNamespace,
      this.currentDatabase,
      async () => {
        try {
          const result = await this.db.query(query, vars || {});
          return result;
        } catch (error) {
          console.error('Erreur lors de l\'exécution de la requête:', error);
          throw error;
        }
      },
      false
    );
  }

  /**
   * Exécuter une requête avec cache intelligent
   */
  public async cachedQuery(
    query: string, 
    vars?: Record<string, any>, 
    cacheKey?: string,
    ttl?: number
  ): Promise<any> {
    const finalCacheKey = cacheKey || `query:${this.currentNamespace}:${this.currentDatabase}:${query}:${JSON.stringify(vars || {})}`;
    
    return await queryCache.cached(finalCacheKey, async () => {
      return await this.query(query, vars);
    }, ttl);
  }

  /**
   * Invalider le cache pour un pattern donné
   */
  public invalidateCache(pattern: string): number {
    const metadataCount = metadataCache.invalidatePattern(pattern);
    const queryCount = queryCache.invalidatePattern(pattern);
    console.log(`🗑️ Cache invalidé: ${metadataCount + queryCount} entrées supprimées`);
    return metadataCount + queryCount;
  }

  /**
   * Obtenir les métriques de performance
   */
  public getPerformanceMetrics(): PerformanceMetrics {
    return {
      cache: {
        metadata: metadataCache.getMetrics(),
        query: queryCache.getMetrics()
      },
      monitoring: performanceMonitor.getAggregatedMetrics()
    };
  }

  /**
   * Générer un rapport de performance complet
   */
  public generatePerformanceReport(): string {
    const cacheMetadataMetrics = metadataCache.getMetrics();
    const cacheQueryMetrics = queryCache.getMetrics();
    const monitoringReport = performanceMonitor.generateReport();
    
    return `
RAPPORT DE PERFORMANCE LYXAL SURREAL
═══════════════════════════════════

📊 Cache métadonnées
• Hits: ${cacheMetadataMetrics.totalHits}
• Misses: ${cacheMetadataMetrics.totalMisses}
• Taux de hit: ${(cacheMetadataMetrics.hitRatio * 100).toFixed(1)}%
• Entrées: ${cacheMetadataMetrics.totalEntries}
• Mémoire: ${(cacheMetadataMetrics.totalMemoryUsage / 1024).toFixed(1)}KB
• Temps moyen: ${cacheMetadataMetrics.avgResponseTime.toFixed(2)}ms

📊 Cache requêtes
• Hits: ${cacheQueryMetrics.totalHits}
• Misses: ${cacheQueryMetrics.totalMisses}
• Taux de hit: ${(cacheQueryMetrics.hitRatio * 100).toFixed(1)}%
• Entrées: ${cacheQueryMetrics.totalEntries}
• Mémoire: ${(cacheQueryMetrics.totalMemoryUsage / 1024).toFixed(1)}KB
• Temps moyen: ${cacheQueryMetrics.avgResponseTime.toFixed(2)}ms

${monitoringReport}
`;
  }

  /**
   * Obtenir l'instance SurrealDB sous-jacente
   */
  public getDB(): Surreal {
    return this.db;
  }

  /**
   * Obtenir le namespace actuel
   */
  public getCurrentNamespace(): string {
    return this.currentNamespace;
  }

  /**
   * Obtenir la database actuelle
   */
  public getCurrentDatabase(): string {
    return this.currentDatabase;
  }

  /**
   * Obtenir la configuration par défaut
   */
  public getDefaultConfig(): SurrealConfig {
    return this.defaultConfig;
  }

  /**
   * Fermer la connexion à SurrealDB et nettoyer les ressources
   */
  public async close(): Promise<void> {
    try {
      await this.db.close();
      console.log('🔌 Connexion SurrealDB fermée');
    } catch (error) {
      console.error('Erreur lors de la fermeture de la connexion:', error);
    }
  }

  /**
   * Validation des paramètres (méthode utilitaire)
   */
  protected validateParams(id?: string, type: string = 'ID'): void {
    if (id !== undefined) {
      if (!id || typeof id !== 'string' || id.trim().length === 0) {
        throw new Error(`${type} doit être une chaîne non vide`);
      }
      if (!/^[a-zA-Z0-9_-]+$/.test(id)) {
        throw new Error(`${type} ne peut contenir que des lettres, chiffres, tirets et underscores`);
      }
    }
  }

  // ==========================================
  // MÉTHODES SAAS/WORKSPACE (ARCHITECTURE BICÉPHALE)
  // ==========================================

  /**
   * Utiliser une instance SaaS (namespace)
   */
  public async useSaaS(saasId: string): Promise<void> {
    await this.use(saasId, 'main');
  }

  /**
   * Utiliser un workspace dans une instance SaaS (database)
   */
  public async useWorkspace(saasId: string, workspaceId: string): Promise<void> {
    await this.use(saasId, workspaceId);
  }

  /**
   * Vérifier si une instance SaaS existe
   */
  public async saasExists(saasId: string): Promise<boolean> {
    return await this.namespaceExists(saasId);
  }

  /**
   * Vérifier si un workspace existe dans une instance SaaS
   */
  public async workspaceExists(saasId: string, workspaceId: string): Promise<boolean> {
    return await this.databaseExists(saasId, workspaceId);
  }

  /**
   * Créer une nouvelle instance SaaS
   */
  public async createSaaS(saasId: string, config: Partial<any>): Promise<void> {
    try {
      // Créer le namespace SaaS
      await this.use('system', 'system');
      
      // Créer la configuration SaaS
      await this.query(`
        CREATE saas_settings SET
          name = $saasId,
          displayName = $displayName,
          domain = $domain,
          status = 'active',
          createdAt = time::now(),
          plan = $plan,
          limits = $limits,
          settings = $settings
      `, {
        saasId,
        displayName: config.displayName || saasId,
        domain: config.domain || '',
        plan: config.plan || 'starter',
        limits: config.limits || { maxWorkspaces: 10, maxUsers: 100, maxStorage: 1000 },
        settings: config.settings || {}
      });

      // Basculer vers le nouveau namespace
      await this.useSaaS(saasId);
      
      console.log(`✅ Instance SaaS '${saasId}' créée avec succès`);
    } catch (error) {
      console.error(`❌ Erreur lors de la création de l'instance SaaS '${saasId}':`, error);
      throw error;
    }
  }

  /**
   * Créer un nouveau workspace dans une instance SaaS
   */
  public async createWorkspace(saasId: string, workspaceId: string, modules?: string[]): Promise<void> {
    try {
      // Basculer vers l'instance SaaS
      await this.useSaaS(saasId);
      
      // Créer l'entrée dans le registry des workspaces
      await this.query(`
        CREATE workspaces_registry SET
          name = $workspaceId,
          displayName = $displayName,
          status = 'active',
          createdAt = time::now(),
          lastAccessedAt = time::now(),
          modules = $modules,
          users = [],
          settings = {}
      `, {
        workspaceId,
        displayName: workspaceId,
        modules: modules || []
      });

      // Basculer vers le nouveau workspace
      await this.useWorkspace(saasId, workspaceId);
      
      console.log(`✅ Workspace '${workspaceId}' créé dans l'instance SaaS '${saasId}'`);
    } catch (error) {
      console.error(`❌ Erreur lors de la création du workspace '${workspaceId}':`, error);
      throw error;
    }
  }

  /**
   * Installer un module dans un workspace
   */
  public async installModuleInWorkspace(saasId: string, workspaceId: string, moduleName: string): Promise<void> {
    try {
      await this.useWorkspace(saasId, workspaceId);
      
      // Créer l'entrée du module installé
      await this.query(`
        CREATE workspace_modules SET
          workspaceId = $workspaceId,
          moduleName = $moduleName,
          version = '1.0.0',
          status = 'active',
          installedAt = time::now(),
          lastUpdatedAt = time::now(),
          configuration = {}
      `, { workspaceId, moduleName });

      console.log(`✅ Module '${moduleName}' installé dans le workspace '${workspaceId}'`);
    } catch (error) {
      console.error(`❌ Erreur lors de l'installation du module '${moduleName}':`, error);
      throw error;
    }
  }

  /**
   * Récupérer la liste des modules installés dans un workspace
   */
  public async getWorkspaceModules(saasId: string, workspaceId: string): Promise<any[]> {
    try {
      await this.useWorkspace(saasId, workspaceId);
      
      const result = await this.query(`
        SELECT * FROM workspace_modules WHERE workspaceId = $workspaceId
      `, { workspaceId });

      return result[0] || [];
    } catch (error) {
      console.error(`❌ Erreur lors de la récupération des modules du workspace '${workspaceId}':`, error);
      throw error;
    }
  }
} 