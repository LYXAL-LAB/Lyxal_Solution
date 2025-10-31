import { Surreal } from 'surrealdb';

export interface SurrealConfig {
  url: string;
  user: string;
  pass: string;
  namespace: string;
  database: string;
}

/**
 * Client SurrealDB Simple - Responsabilité Unique
 * 
 * OBJECTIF : Juste connexion + requêtes de base
 * PAS de cache, monitoring, business logic, etc.
 */
export class SurrealClient {
  private db: Surreal;
  private connected: boolean = false;
  
  constructor(private config: SurrealConfig) {
    this.db = new Surreal();
  }
  
  /**
   * Se connecter à SurrealDB Cloud
   */
  async connect(): Promise<void> {
    if (this.connected) return;
    
    try {
      await this.db.connect(this.config.url);
      
      await this.db.signin({
        username: this.config.user,
        password: this.config.pass,
      });
      
      await this.db.use({
        namespace: this.config.namespace,
        database: this.config.database
      });
      
      this.connected = true;
      console.log(`✅ SurrealDB connecté: ${this.config.namespace}/${this.config.database}`);
    } catch (error) {
      console.error('❌ Erreur connexion SurrealDB:', error);
      throw error;
    }
  }
  
  /**
   * Exécuter une requête SurrealQL
   */
  async query<T = any>(sql: string, vars?: Record<string, any>): Promise<T[]> {
    if (!this.connected) {
      throw new Error('SurrealDB non connecté. Appelez connect() d\'abord.');
    }
    
    try {
      const result = await this.db.query(sql, vars || {});
      return result as T[];
    } catch (error) {
      console.error('❌ Erreur requête SurrealDB:', error);
      throw error;
    }
  }
  
  /**
   * Créer un enregistrement
   */
  async create<T = any>(table: string, data: Record<string, any>): Promise<T> {
    if (!this.connected) {
      throw new Error('SurrealDB non connecté. Appelez connect() d\'abord.');
    }
    
    const result = await this.db.create(table, data);
    return result as T;
  }
  
  /**
   * Mettre à jour un enregistrement
   */
  async update<T = any>(id: string, data: Record<string, any>): Promise<T> {
    if (!this.connected) {
      throw new Error('SurrealDB non connecté. Appelez connect() d\'abord.');
    }
    
    const result = await this.db.update(id, data);
    return result as T;
  }
  
  /**
   * Supprimer un enregistrement
   */
  async delete<T = any>(id: string): Promise<T> {
    if (!this.connected) {
      throw new Error('SurrealDB non connecté. Appelez connect() d\'abord.');
    }
    
    const result = await this.db.delete(id);
    return result as T;
  }
  
  /**
   * Live queries (temps réel)
   */
  async live<T = any>(sql: string, callback: (action: string, result: T) => void): Promise<string> {
    if (!this.connected) {
      throw new Error('SurrealDB non connecté. Appelez connect() d\'abord.');
    }
    
    const queryId = await this.db.live(sql, (action, result) => {
      callback(action, result as T);
    });
    return queryId.toString();
  }
  
  /**
   * Arrêter une live query
   */
  async kill(queryId: string): Promise<void> {
    if (!this.connected) {
      throw new Error('SurrealDB non connecté. Appelez connect() d\'abord.');
    }
    
    await this.db.kill(queryId as any);
  }
  
  /**
   * Fermer la connexion
   */
  async close(): Promise<void> {
    if (this.connected) {
      await this.db.close();
      this.connected = false;
      console.log('✅ SurrealDB connexion fermée');
    }
  }
  
  /**
   * Vérifier si connecté
   */
  isConnected(): boolean {
    return this.connected;
  }
  
  /**
   * Obtenir la configuration actuelle
   */
  getConfig(): SurrealConfig {
    return { ...this.config };
  }
} 