/**
 * Mock SurrealClient pour les tests
 * Compatible avec l'API lyxal-surreal et l'architecture SaaS/Workspace
 */

// Types locaux pour éviter l'import externe
interface SurrealConfig {
  url: string;
  user: string;
  pass: string;
  namespace: string;
  database: string;
}

interface SaaSRecord {
  id: string;
  name: string;
  displayName: string;
  domain: string;
  status: 'active' | 'inactive' | 'suspended';
  createdAt: Date;
  settings: Record<string, any>;
  plan: string;
  limits: {
    maxWorkspaces: number;
    maxUsers: number;
    maxStorage: number;
  };
}

interface WorkspaceRecord {
  id: string;
  saasId: string;
  name: string;
  displayName: string;
  status: 'active' | 'inactive';
  createdAt: Date;
  lastAccessedAt: Date;
  modules: string[];
  settings: Record<string, any>;
  users: string[];
}

interface CacheMetrics {
  totalHits: number;
  totalMisses: number;
  hitRatio: number;
  totalEntries: number;
  avgResponseTime: number;
  totalMemoryUsage: number;
}

interface PerformanceMetrics {
  cache: {
    metadata: CacheMetrics;
    query: CacheMetrics;
  };
  monitoring: {
    totalQueries: number;
    successfulQueries: number;
    failedQueries: number;
    avgResponseTime: number;
    minResponseTime: number;
    maxResponseTime: number;
    cacheHitRatio: number;
    queryCount: Record<string, number>;
    errorCount: Record<string, number>;
    slowQueries: any[];
    recentPerformance: any[];
  };
}

export interface MockSurrealResult {
  id?: string;
  [key: string]: any;
}

/**
 * Mock du SurrealClient de lyxal-surreal pour les tests
 */
export class MockSurrealClient {
  private static instance: MockSurrealClient;
  private data: Map<string, Map<string, any[]>> = new Map(); // namespace -> table -> records
  private connected = false;
  private currentNamespace = 'test';
  private currentDatabase = 'test';
  private config: SurrealConfig;

  private constructor(config: SurrealConfig) {
    this.config = config;
  }

  /**
   * Obtenir l'instance singleton (comme le vrai SurrealClient)
   */
  public static getInstance(config?: SurrealConfig): MockSurrealClient {
    if (!MockSurrealClient.instance) {
      if (!config) {
        throw new Error("Configuration requise pour initialiser le client SurrealDB");
      }
      MockSurrealClient.instance = new MockSurrealClient(config);
    }
    return MockSurrealClient.instance;
  }

  /**
   * Réinitialiser l'instance singleton (pour les tests)
   */
  public static resetInstance(): void {
    MockSurrealClient.instance = null as any;
  }

  /**
   * Initialiser la connexion (mock)
   */
  public async initialize(): Promise<void> {
    this.connected = true;
    console.log(`🔌 Mock connecté à SurrealDB: ${this.config.url}`);
  }

  /**
   * Sélectionner un namespace et une base de données
   */
  public async use(namespace: string, database: string = 'main'): Promise<void> {
    if (!this.connected) {
      throw new Error('Database not connected');
    }
    
    this.currentNamespace = namespace;
    this.currentDatabase = database;
    
    // Créer le namespace s'il n'existe pas
    if (!this.data.has(namespace)) {
      this.data.set(namespace, new Map());
    }
  }

  /**
   * Vérifier si un namespace existe
   */
  public async namespaceExists(namespace: string): Promise<boolean> {
    return this.data.has(namespace);
  }

  /**
   * Utiliser une instance SaaS (namespace)
   */
  public async useSaaS(saasId: string): Promise<void> {
    await this.use(saasId, 'configuration');
  }

  /**
   * Utiliser un workspace
   */
  public async useWorkspace(saasId: string, workspaceId: string): Promise<void> {
    await this.use(`${saasId}_${workspaceId}`, 'main');
  }

  /**
   * Vérifier si un SaaS existe
   */
  public async saasExists(saasId: string): Promise<boolean> {
    return this.namespaceExists(saasId);
  }

  /**
   * Vérifier si un workspace existe
   */
  public async workspaceExists(saasId: string, workspaceId: string): Promise<boolean> {
    return this.namespaceExists(`${saasId}_${workspaceId}`);
  }

  /**
   * Exécuter une requête SurrealDB (mock)
   */
  public async query(query: string, vars?: Record<string, any>): Promise<any> {
    if (!this.connected) {
      throw new Error('Database not connected');
    }

    const trimmedQuery = query.trim().toUpperCase();
    
    // ✅ CORRECTION : Ajouter la gestion d'erreurs pour les requêtes invalides
    if (trimmedQuery.includes('INVALID') || trimmedQuery.includes('SYNTAX ERROR')) {
      throw new Error('SQL syntax error: Invalid query syntax');
    }
    
    if (trimmedQuery.startsWith('CREATE')) {
      return this.mockCreate(query, vars);
    } else if (trimmedQuery.startsWith('SELECT')) {
      return this.mockSelect(query, vars);
    } else if (trimmedQuery.startsWith('UPDATE')) {
      return this.mockUpdate(query, vars);
    } else if (trimmedQuery.startsWith('DELETE')) {
      return this.mockDelete(query, vars);
    }

    // Requête non supportée, retourner un résultat vide
    return [];
  }

  /**
   * Requête avec cache (mock)
   */
  public async cachedQuery(
    query: string, 
    vars?: Record<string, any>, 
    _cacheKey?: string,
    _ttl?: number
  ): Promise<any> {
    // Pour les tests, on ignore le cache et on exécute directement
    return this.query(query, vars);
  }

  /**
   * Invalider le cache (mock)
   */
  public invalidateCache(_pattern: string): number {
    // Mock: retourne toujours 1 élément invalidé
    return 1;
  }

  /**
   * Créer un SaaS (mock)
   */
  public async createSaaS(saasId: string, config: Partial<SaaSRecord>): Promise<void> {
    const namespace = saasId;
    if (!this.data.has(namespace)) {
      this.data.set(namespace, new Map());
    }

    // Créer l'enregistrement SaaS
    const saasRecord: SaaSRecord = {
      id: `saas:${saasId}`,
      name: config.name || saasId,
      displayName: config.displayName || saasId,
      domain: config.domain || `${saasId}.lyxal.com`,
      status: config.status || 'active',
      createdAt: new Date(),
      settings: config.settings || {},
      plan: config.plan || 'starter',
      limits: config.limits || {
        maxWorkspaces: 10,
        maxUsers: 100,
        maxStorage: 1000
      },
      ...config
    };

    this.mockCreateRecord('saas', saasRecord, namespace);
  }

  /**
   * Créer un workspace (mock)
   */
  public async createWorkspace(saasId: string, workspaceId: string, modules: string[] = []): Promise<void> {
    const namespace = `${saasId}_${workspaceId}`;
    if (!this.data.has(namespace)) {
      this.data.set(namespace, new Map());
    }

    // Créer l'enregistrement workspace
    const workspaceRecord: WorkspaceRecord = {
      id: `workspace:${workspaceId}`,
      saasId: saasId,
      name: workspaceId,
      displayName: workspaceId,
      status: 'active',
      createdAt: new Date(),
      lastAccessedAt: new Date(),
      modules: modules,
      settings: {},
      users: []
    };

    this.mockCreateRecord('workspace', workspaceRecord, namespace);
  }

  /**
   * Obtenir les métriques de performance (mock)
   */
  public getPerformanceMetrics(): PerformanceMetrics {
    return {
      cache: {
        metadata: {
          totalHits: 0,
          totalMisses: 0,
          hitRatio: 1.0,
          totalEntries: 0,
          avgResponseTime: 0,
          totalMemoryUsage: 0
        },
        query: {
          totalHits: 0,
          totalMisses: 0,
          hitRatio: 1.0,
          totalEntries: 0,
          avgResponseTime: 0,
          totalMemoryUsage: 0
        }
      },
      monitoring: {
        totalQueries: 0,
        successfulQueries: 0,
        failedQueries: 0,
        avgResponseTime: 0,
        minResponseTime: 0,
        maxResponseTime: 0,
        cacheHitRatio: 1.0,
        queryCount: {},
        errorCount: {},
        slowQueries: [],
        recentPerformance: []
      }
    };
  }

  /**
   * Fermer la connexion (mock)
   */
  public async close(): Promise<void> {
    this.connected = false;
    console.log('🔌 Mock SurrealDB déconnecté');
  }

  /**
   * Créer un enregistrement
   */
  public async create(table: string, data: any): Promise<any> {
    if (!this.connected) {
      throw new Error('Database not connected');
    }

    const id = data.id || `${table}:${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    const record = { id, ...data };
    
    this.mockCreateRecord(table, record);
    return record;
  }

  /**
   * Sélectionner un enregistrement par ID
   */
  public async select(id: string): Promise<any> {
    if (!this.connected) {
      throw new Error('Database not connected');
    }

    // ✅ CORRECTION : Parser l'ID correctement
    let table: string;
    let recordId: string;
    
    if (id.includes(':')) {
      [table, recordId] = id.split(':', 2);
    } else {
      // Si pas de table spécifiée, chercher dans toutes les tables
      const allTables = this.getTableData('');
      for (const record of allTables) {
        if (record.id === id || record.id?.endsWith(`:${id}`)) {
          return record;
        }
      }
      return undefined;
    }

    const data = this.getTableData(table!);
    
    // ✅ CORRECTION : Chercher par ID complet ou partiel
    const record = data.find(item => {
      return item.id === id || 
             item.id === `${table}:${recordId}` ||
             item.id?.endsWith(`:${recordId}`);
    });

    return record || undefined; // ✅ Retourner undefined si non trouvé
  }

  /**
   * Mettre à jour un enregistrement
   */
  public async update(id: string, data: any): Promise<any> {
    if (!this.connected) {
      throw new Error('Database not connected');
    }

    // ✅ CORRECTION : Parser l'ID correctement
    let table: string;
    let recordId: string;
    
    if (id.includes(':')) {
      [table, recordId] = id.split(':', 2);
    } else {
      throw new Error(`Invalid ID format: ${id}. Expected format: table:id`);
    }

    const tableData = this.getTableData(table!);
    const recordIndex = tableData.findIndex(item => {
      return item.id === id || 
             item.id === `${table}:${recordId}` ||
             item.id?.endsWith(`:${recordId}`);
    });

    if (recordIndex === -1) {
      // ✅ Créer l'enregistrement s'il n'existe pas
      const newRecord = { 
        id: id.includes(':') ? id : `${table}:${recordId}`, 
        ...data,
        updated_at: new Date().toISOString()
      };
      this.mockCreateRecord(table!, newRecord);
      return newRecord;
    }

    // Mettre à jour l'enregistrement existant
    const updatedRecord = { 
      ...tableData[recordIndex], 
      ...data,
      updated_at: new Date().toISOString()
    };
    
    tableData[recordIndex] = updatedRecord;
    return updatedRecord;
  }

  /**
   * Supprimer un enregistrement
   */
  public async delete(id: string): Promise<boolean> {
    if (!this.connected) {
      throw new Error('Database not connected');
    }

    const parts = id.split(':');
    if (parts.length < 2) {
      return false;
    }
    
    const table = parts[0]!;
    const namespace = this.currentNamespace;
    
    if (!this.data.has(namespace)) {
      return false;
    }
    
    const namespaceData = this.data.get(namespace)!;
    if (!namespaceData.has(table)) {
      return false;
    }
    
    const tableData = namespaceData.get(table)!;
    const recordIndex = tableData.findIndex(record => record.id === id);
    
    if (recordIndex >= 0) {
      tableData.splice(recordIndex, 1);
      return true;
    }
    
    return false;
  }

  // ==========================================
  // MÉTHODES UTILITAIRES POUR LES TESTS
  // ==========================================

  /**
   * Nettoyer une table dans le namespace courant
   */
  public clearTable(table: string): void {
    const namespaceData = this.data.get(this.currentNamespace);
    if (namespaceData) {
      namespaceData.set(table, []);
    }
  }

  /**
   * Nettoyer tous les namespaces
   */
  public clearAll(): void {
    this.data.clear();
  }

  /**
   * Obtenir les données d'une table
   */
  public getTableData(table: string, namespace?: string): any[] {
    const ns = namespace || this.currentNamespace;
    const namespaceData = this.data.get(ns);
    return namespaceData?.get(table) || [];
  }

  /**
   * Vérifier si connecté
   */
  public isConnected(): boolean {
    return this.connected;
  }

  /**
   * Obtenir le namespace courant
   */
  public getCurrentNamespace(): string {
    return this.currentNamespace;
  }

  // ==========================================
  // MÉTHODES PRIVÉES POUR SIMULER LES REQUÊTES
  // ==========================================

  /**
   * Créer un enregistrement via requête SQL
   */
  private mockCreate(query: string, vars?: Record<string, any>): any {
    // ✅ Parser CREATE table CONTENT $variable
    const createContentMatch = query.match(/CREATE\s+(\w+)\s+CONTENT\s+\$(\w+)/i);
    if (createContentMatch && vars) {
      const table = createContentMatch[1]!;
      const varName = createContentMatch[2]!;
      const content = vars[varName];
      
      if (content) {
        const id = content.id || `${table}:${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
        const record = { id, ...content };
        this.mockCreateRecord(table, record);
        return record;
      }
    }

    // ✅ Parser CREATE table SET field=value
    const createSetMatch = query.match(/CREATE\s+(\w+)\s+SET\s+(.*)/i);
    if (createSetMatch) {
      const table = createSetMatch[1]!;
      const setClause = createSetMatch[2]!;
      
      // Parser simple des SET clauses
      const record: any = {};
      const assignments = setClause.split(',');
      assignments.forEach(assignment => {
        const [field, value] = assignment.split('=').map(s => s.trim());
        if (field && value) {
          // Remplacer les variables
          let finalValue = value;
          if (value.startsWith('$') && vars) {
            const varName = value.substring(1);
            finalValue = vars[varName] || value;
          }
          // Supprimer les quotes
          if (typeof finalValue === 'string' && finalValue.startsWith('"') && finalValue.endsWith('"')) {
            finalValue = finalValue.slice(1, -1);
          }
          record[field] = finalValue;
        }
      });
      
      const id = record.id || `${table}:${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
      const finalRecord = { id, ...record };
      this.mockCreateRecord(table, finalRecord);
      return finalRecord;
    }

    // ✅ Parser CREATE table CONTENT { object } - Améliorer le parsing JSON
    const createContentObjectMatch = query.match(/CREATE\s+(\w+)\s+CONTENT\s+(\{[^}]+\})/i);
    if (createContentObjectMatch) {
      const table = createContentObjectMatch[1]!;
      const objectStr = createContentObjectMatch[2]!;
      
      try {
        // Tenter de parser comme JSON valide
        const parsedObject = JSON.parse(objectStr);
        const id = parsedObject.id || `${table}:${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
        const record = { id, ...parsedObject };
        this.mockCreateRecord(table, record);
        return record;
      } catch (e) {
        // Fallback: parser manuel simple
        console.warn('Failed to parse JSON, using fallback parser:', objectStr);
        const record = this.parseSimpleObject(objectStr);
        const id = record.id || `${table}:${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
        const finalRecord = { id, ...record };
        this.mockCreateRecord(table, finalRecord);
        return finalRecord;
      }
    }

    // ✅ Parser CREATE table { object } - Sans CONTENT
    const createObjectMatch = query.match(/CREATE\s+(\w+)\s+(\{[^}]+\})/i);
    if (createObjectMatch) {
      const table = createObjectMatch[1]!;
      const objectStr = createObjectMatch[2]!;
      
      try {
        // Tenter de parser comme JSON valide
        const parsedObject = JSON.parse(objectStr);
        const id = parsedObject.id || `${table}:${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
        const record = { id, ...parsedObject };
        this.mockCreateRecord(table, record);
        return record;
      } catch (e) {
        // Fallback: parser manuel simple
        const record = this.parseSimpleObject(objectStr);
        const id = record.id || `${table}:${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
        const finalRecord = { id, ...record };
        this.mockCreateRecord(table, finalRecord);
        return finalRecord;
      }
    }

    // Fallback: créer un enregistrement vide
    const tableMatch = query.match(/CREATE\s+(\w+)/i);
    if (tableMatch) {
      const table = tableMatch[1]!;
      const id = `${table}:${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
      const record = { id };
      this.mockCreateRecord(table, record);
      return record;
    }

    return null;
  }

  /**
   * ✅ Parser simple pour les objets JSON-like
   */
  private parseSimpleObject(objectStr: string): any {
    const record: any = {};
    
    // Supprimer les accolades
    const content = objectStr.slice(1, -1).trim();
    
    // Séparer par les virgules (attention aux chaînes avec virgules)
    const pairs: string[] = [];
    let current = '';
    let inQuotes = false;
    let quoteChar = '';
    
    for (let i = 0; i < content.length; i++) {
      const char = content[i]!;
      
      if ((char === '"' || char === "'") && !inQuotes) {
        inQuotes = true;
        quoteChar = char;
        current += char;
      } else if (char === quoteChar && inQuotes) {
        inQuotes = false;
        quoteChar = '';
        current += char;
      } else if (char === ',' && !inQuotes) {
        pairs.push(current.trim());
        current = '';
      } else {
        current += char;
      }
    }
    
    if (current.trim()) {
      pairs.push(current.trim());
    }
    
    // Parser chaque paire key: value
    pairs.forEach(pair => {
      const colonIndex = pair.indexOf(':');
      if (colonIndex > 0) {
        const key = pair.substring(0, colonIndex).trim();
        const value = pair.substring(colonIndex + 1).trim();
        
        // Nettoyer la clé
        const cleanKey = key.replace(/^["']|["']$/g, '');
        
        // Nettoyer la valeur
        let cleanValue: any = value;
        if (value.startsWith('"') && value.endsWith('"')) {
          cleanValue = value.slice(1, -1);
        } else if (value.startsWith("'") && value.endsWith("'")) {
          cleanValue = value.slice(1, -1);
        } else if (value === 'true') {
          cleanValue = true;
        } else if (value === 'false') {
          cleanValue = false;
        } else if (!isNaN(Number(value))) {
          cleanValue = Number(value);
        }
        
        record[cleanKey] = cleanValue;
      }
    });
    
    return record;
  }

  /**
   * ✅ Améliorer la méthode select
   */
  private mockSelect(query: string, vars?: Record<string, any>): any[] {
    // Parser SELECT * FROM table WHERE condition
    const selectMatch = query.match(/SELECT\s+\*\s+FROM\s+(\w+)(?:\s+WHERE\s+(.+))?/i);
    if (selectMatch) {
      const table = selectMatch[1]!;
      const whereClause = selectMatch[2];
      
      let data = this.getTableData(table);
      
      // Appliquer les conditions WHERE simples
      if (whereClause && vars) {
        const conditionMatch = whereClause.match(/(\w+)\s*=\s*\$(\w+)/i);
        if (conditionMatch) {
          const field = conditionMatch[1]!;
          const varName = conditionMatch[2]!;
          const value = vars[varName];
          
          data = data.filter(record => record[field] === value);
        }
      }
      
      return data;
    }

    // Fallback: retourner toutes les données de la première table trouvée
    const tableMatch = query.match(/FROM\s+(\w+)/i);
    if (tableMatch) {
      const table = tableMatch[1]!;
      return this.getTableData(table);
    }

    return [];
  }

  /**
   * ✅ Améliorer la méthode update
   */
  private mockUpdate(query: string, vars?: Record<string, any>): any {
    // Parser UPDATE table:id SET field=value
    const updateMatch = query.match(/UPDATE\s+([^:]+):([^\s]+)\s+SET\s+(.*)/i);
    if (updateMatch) {
      const table = updateMatch[1]!;
      const recordId = updateMatch[2]!;
      const setClause = updateMatch[3]!;
      const fullId = `${table}:${recordId}`;
      
      // Parser les SET clauses
      const updates: any = {};
      const assignments = setClause.split(',');
      assignments.forEach(assignment => {
        const [field, value] = assignment.split('=').map(s => s.trim());
        if (field && value) {
          let finalValue = value;
          if (value.startsWith('$') && vars) {
            const varName = value.substring(1);
            finalValue = vars[varName] || value;
          }
          if (typeof finalValue === 'string' && finalValue.startsWith('"') && finalValue.endsWith('"')) {
            finalValue = finalValue.slice(1, -1);
          }
          updates[field] = finalValue;
        }
      });
      
      return this.update(fullId, updates);
    }

    return null;
  }

  /**
   * ✅ Améliorer la méthode delete
   */
  private mockDelete(query: string, vars?: Record<string, any>): any {
    // Parser DELETE table:id ou DELETE FROM table WHERE condition
    const deleteIdMatch = query.match(/DELETE\s+([^:]+):([^\s]+)/i);
    if (deleteIdMatch) {
      const table = deleteIdMatch[1]!;
      const recordId = deleteIdMatch[2]!;
      const fullId = `${table}:${recordId}`;
      return this.delete(fullId);
    }

    const deleteWhereMatch = query.match(/DELETE\s+FROM\s+(\w+)(?:\s+WHERE\s+(.+))?/i);
    if (deleteWhereMatch) {
      const table = deleteWhereMatch[1]!;
      const whereClause = deleteWhereMatch[2];
      
      if (whereClause && vars) {
        const conditionMatch = whereClause.match(/(\w+)\s*=\s*\$(\w+)/i);
        if (conditionMatch) {
          const field = conditionMatch[1]!;
          const varName = conditionMatch[2]!;
          const value = vars[varName];
          
          const data = this.getTableData(table);
          const recordsToDelete = data.filter(record => record[field] === value);
          
          recordsToDelete.forEach(record => {
            if (record.id) {
              this.delete(record.id);
            }
          });
          
          return recordsToDelete.length;
        }
      }
    }

    return false;
  }

  private mockCreateRecord(table: string, record: any, namespace?: string): void {
    const ns = namespace || this.currentNamespace;
    
    if (!this.data.has(ns)) {
      this.data.set(ns, new Map());
    }
    
    const namespaceData = this.data.get(ns)!;
    if (!namespaceData.has(table)) {
      namespaceData.set(table, []);
    }
    
    namespaceData.get(table)!.push(record);
  }
}

/**
 * Factory pour créer une instance mock du SurrealClient
 */
export const createMockSurrealClient = (config?: Partial<SurrealConfig>): MockSurrealClient => {
  const defaultConfig: SurrealConfig = {
    url: 'ws://localhost:8000/rpc',
    user: 'test',
    pass: 'test',
    namespace: 'test',
    database: 'test',
    ...config
  };

  // Réinitialiser l'instance pour les tests
  MockSurrealClient.resetInstance();
  return MockSurrealClient.getInstance(defaultConfig);
}; 