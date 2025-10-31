import type { SurrealConfig } from '../core/types';

/**
 * 🚀 LYXAL GATEWAY UNIFIÉE
 * 
 * Point d'entrée unique pour toute l'architecture SurrealDB
 * Organise tous les services par domaines logiques
 * 
 * Usage:
 * import { surreal } from '@lyxal/gateway';
 * 
 * await surreal.data.findUsers();
 * await surreal.infrastructure.createDomain();
 * await surreal.realtime.subscribeToUsers();
 */

/**
 * Interface pour les services de base
 */
export interface BaseService {
  readonly name: string;
  readonly version: string;
  isInitialized(): boolean;
}

/**
 * Service de données business (CRUD, requêtes métier)
 */
export interface DataService extends BaseService {
  // 👥 Gestion utilisateurs
  findUsers(filters?: any): Promise<any[]>;
  createUser(userData: any): Promise<any>;
  updateUser(id: string, data: any): Promise<any>;
  deleteUser(id: string): Promise<boolean>;
  
  // 📄 Gestion générique des enregistrements
  select(table: string, filters?: any): Promise<any[]>;
  create(table: string, data: any): Promise<any>;
  update(table: string, id: string, data: any): Promise<any>;
  delete(table: string, id: string): Promise<boolean>;
  
  // 🔍 Recherche avancée
  search(query: string, tables?: string[]): Promise<any[]>;
  count(table: string, filters?: any): Promise<number>;
}

/**
 * Service temps réel (Live queries, WebSockets)
 */
export interface RealtimeService extends BaseService {
  // 🔄 Subscriptions temps réel
  subscribeToTable(table: string, callback: (data: any) => void): Promise<string>;
  subscribeToQuery(query: string, callback: (data: any) => void): Promise<string>;
  unsubscribe(subscriptionId: string): Promise<void>;
  
  // 📡 Broadcast events
  broadcast(channel: string, data: any): Promise<void>;
  listen(channel: string, callback: (data: any) => void): Promise<string>;
  
  // 👥 User presence
  trackUserPresence(userId: string): Promise<void>;
  getUsersOnline(): Promise<any[]>;
}

/**
 * Service infrastructure (Domaines, LWS, Environnements)
 */
export interface InfrastructureService extends BaseService {
  // 🌐 Gestion domaines
  createDomain(domain: string, config?: any): Promise<any>;
  getDomainStatus(domain: string): Promise<any>;
  updateDomainConfig(domain: string, config: any): Promise<any>;
  deleteDomain(domain: string): Promise<boolean>;
  
  // 🏗️ Environnements (SaaS, Workspaces)
  createEnvironment(envId: string, config?: any): Promise<any>;
  getEnvironmentStatus(envId: string): Promise<any>;
  
  // 🔧 LWS API Integration
  callLWSAPI(endpoint: string, params?: any): Promise<any>;
  syncWithLWS(): Promise<any>;
}

/**
 * Service authentification
 */
export interface AuthService extends BaseService {
  // 🔐 Authentification
  login(email: string, password: string): Promise<any>;
  logout(): Promise<void>;
  getCurrentUser(): Promise<any | null>;
  
  // 🛡️ Autorisations
  hasPermission(permission: string): Promise<boolean>;
  getUserRoles(userId: string): Promise<string[]>;
  
  // 🔑 Tokens
  refreshToken(): Promise<string>;
  validateToken(token: string): Promise<boolean>;
}

/**
 * Service analytics et monitoring
 */
export interface AnalyticsService extends BaseService {
  // 📊 Métriques business
  getUserStats(): Promise<any>;
  getUsageStats(): Promise<any>;
  
  // 🔍 Performance monitoring
  getPerformanceMetrics(): Promise<any>;
  trackEvent(event: string, data?: any): Promise<void>;
  
  // 📈 Reporting
  generateReport(type: string, filters?: any): Promise<any>;
}

/**
 * Gateway principale - Point d'entrée unique
 */
export class LyxalGateway {
  private static instance: LyxalGateway;
  private _config: SurrealConfig | null = null;
  private _isInitialized: boolean = false;
  
  // Services (initialisés de manière lazy)
  private _dataService: DataService | null = null;
  private _realtimeService: RealtimeService | null = null;
  private _infrastructureService: InfrastructureService | null = null;
  private _authService: AuthService | null = null;
  private _analyticsService: AnalyticsService | null = null;

  private constructor() {}

  /**
   * Obtenir l'instance unique de la gateway
   */
  public static getInstance(): LyxalGateway {
    if (!LyxalGateway.instance) {
      LyxalGateway.instance = new LyxalGateway();
    }
    return LyxalGateway.instance;
  }

  /**
   * Initialiser la gateway avec la configuration SurrealDB
   */
  public async initialize(config: SurrealConfig): Promise<void> {
    if (this._isInitialized) {
      console.log('🎯 Gateway déjà initialisée');
      return;
    }

    try {
      this._config = config;
      
      console.log('🚀 Initialisation de la Lyxal Gateway...');
      console.log(`📍 Environment: ${config.namespace}/${config.database}`);
      
      // Les services seront initialisés de manière lazy quand ils sont utilisés
      this._isInitialized = true;
      
      console.log('✅ Lyxal Gateway initialisée avec succès !');
    } catch (error) {
      console.error('❌ Erreur lors de l\'initialisation de la Gateway:', error);
      throw error;
    }
  }

  /**
   * Vérifier si la gateway est initialisée
   */
  public isInitialized(): boolean {
    return this._isInitialized;
  }

  /**
   * Obtenir la configuration actuelle
   */
  public getConfig(): SurrealConfig | null {
    return this._config;
  }

  /**
   * Service de données business
   */
  public get data(): DataService {
    if (!this._isInitialized) {
      throw new Error('Gateway non initialisée. Appelez initialize() d\'abord.');
    }
    
    if (!this._dataService) {
      // TODO: Initialisation lazy du service data
      console.log('🔄 Initialisation du DataService...');
      // this._dataService = new SurrealDataService(this._config!);
      throw new Error('DataService pas encore implémenté - à créer dans le prochain module');
    }
    
    return this._dataService;
  }

  /**
   * Service temps réel
   */
  public get realtime(): RealtimeService {
    if (!this._isInitialized) {
      throw new Error('Gateway non initialisée. Appelez initialize() d\'abord.');
    }
    
    if (!this._realtimeService) {
      // TODO: Initialisation lazy du service realtime
      console.log('🔄 Initialisation du RealtimeService...');
      // this._realtimeService = new SurrealRealtimeService(this._config!);
      throw new Error('RealtimeService pas encore implémenté - à créer dans le prochain module');
    }
    
    return this._realtimeService;
  }

  /**
   * Service infrastructure
   */
  public get infrastructure(): InfrastructureService {
    if (!this._isInitialized) {
      throw new Error('Gateway non initialisée. Appelez initialize() d\'abord.');
    }
    
    if (!this._infrastructureService) {
      // TODO: Initialisation lazy du service infrastructure
      console.log('🔄 Initialisation de l\'InfrastructureService...');
      // this._infrastructureService = new SurrealInfrastructureService(this._config!);
      throw new Error('InfrastructureService pas encore implémenté - à créer dans le prochain module');
    }
    
    return this._infrastructureService;
  }

  /**
   * Service authentification
   */
  public get auth(): AuthService {
    if (!this._isInitialized) {
      throw new Error('Gateway non initialisée. Appelez initialize() d\'abord.');
    }
    
    if (!this._authService) {
      // TODO: Initialisation lazy du service auth
      console.log('🔄 Initialisation de l\'AuthService...');
      // this._authService = new SurrealAuthService(this._config!);
      throw new Error('AuthService pas encore implémenté - à créer dans le prochain module');
    }
    
    return this._authService;
  }

  /**
   * Service analytics
   */
  public get analytics(): AnalyticsService {
    if (!this._isInitialized) {
      throw new Error('Gateway non initialisée. Appelez initialize() d\'abord.');
    }
    
    if (!this._analyticsService) {
      // TODO: Initialisation lazy du service analytics
      console.log('🔄 Initialisation de l\'AnalyticsService...');
      // this._analyticsService = new SurrealAnalyticsService(this._config!);
      throw new Error('AnalyticsService pas encore implémenté - à créer dans le prochain module');
    }
    
    return this._analyticsService;
  }

  /**
   * Fermer proprement la gateway et tous ses services
   */
  public async close(): Promise<void> {
    console.log('🔄 Fermeture de la Lyxal Gateway...');
    
    // Fermer tous les services initialisés
    const services = [
      this._dataService,
      this._realtimeService,
      this._infrastructureService,
      this._authService,
      this._analyticsService
    ];
    
    for (const service of services) {
      if (service && 'close' in service) {
        try {
          await (service as any).close();
        } catch (error) {
          console.error('Erreur lors de la fermeture d\'un service:', error);
        }
      }
    }
    
    this._isInitialized = false;
    this._config = null;
    
    console.log('✅ Gateway fermée proprement');
  }

  /**
   * Reset pour les tests
   */
  public static resetInstance(): void {
    if (LyxalGateway.instance) {
      LyxalGateway.instance._isInitialized = false;
      LyxalGateway.instance._config = null;
    }
    LyxalGateway.instance = null as any;
  }
}

/**
 * 🎯 INSTANCE GLOBALE EXPORTÉE
 * 
 * Point d'entrée unique pour toute l'application
 * 
 * Usage:
 * import { surreal } from '@lyxal/gateway';
 * 
 * // Initialisation (une seule fois au démarrage)
 * await surreal.initialize(config);
 * 
 * // Utilisation dans l'app
 * const users = await surreal.data.findUsers();
 * const stats = await surreal.analytics.getUserStats();
 */
export const surreal = LyxalGateway.getInstance();

/**
 * 🚀 EXPORT PAR DÉFAUT
 * Pour les imports directs
 */
export default surreal; 