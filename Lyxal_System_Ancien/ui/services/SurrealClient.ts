import Surreal from 'surrealdb';

type Config = {
  infrastructure: {
    surrealDbUrl: { value: string };
    surrealNamespace: { value: string };
    surrealDatabase: { value: string };
    surrealUsername: { value: string };
    surrealPassword: { value: string };
  };
};

class SurrealClientSingleton {
  private db: Surreal | null = null;
  private ns?: string;
  private dbName?: string;
  private currentConfig?: Config;

  async ensureConnected(config: Config): Promise<Surreal> {
    // Vérifier si la configuration a changé
    const configChanged = 
      !this.currentConfig ||
      this.currentConfig.infrastructure.surrealDbUrl.value !== config.infrastructure.surrealDbUrl.value ||
      this.currentConfig.infrastructure.surrealNamespace.value !== config.infrastructure.surrealNamespace.value ||
      this.currentConfig.infrastructure.surrealDatabase.value !== config.infrastructure.surrealDatabase.value ||
      this.currentConfig.infrastructure.surrealUsername.value !== config.infrastructure.surrealUsername.value ||
      this.currentConfig.infrastructure.surrealPassword.value !== config.infrastructure.surrealPassword.value;

    // Si la config a changé ou si pas de connexion, se reconnecter
    if (configChanged && this.db) {
      console.log('[SurrealClient] 🔄 Configuration changée, reconnexion...');
      try {
        await this.db.close();
      } catch (e) {
        // Ignorer les erreurs de fermeture
      }
      this.db = null;
      this.ns = undefined;
      this.dbName = undefined;
    }

    if (this.db) return this.db;
    
    const db = new Surreal();
    await db.connect(config.infrastructure.surrealDbUrl.value);
    await db.signin({
      username: config.infrastructure.surrealUsername.value,
      password: config.infrastructure.surrealPassword.value,
    });
    await db.use({
      namespace: config.infrastructure.surrealNamespace.value,
      database: config.infrastructure.surrealDatabase.value,
    });
    this.db = db;
    this.ns = config.infrastructure.surrealNamespace.value;
    this.dbName = config.infrastructure.surrealDatabase.value;
    this.currentConfig = config;
    console.log('[SurrealClient] 🔌 Connecté à:', config.infrastructure.surrealNamespace.value, '/', config.infrastructure.surrealDatabase.value);
    return db;
  }

  async query<T = unknown>(config: Config, sql: string): Promise<T> {
    console.log(`[SurrealClient] 🔍 Executing query:`, sql.substring(0, 100) + (sql.length > 100 ? '...' : ''));
    console.log(`[SurrealClient] 🔗 Connection:`, this.ns, this.dbName);

    const db = await this.ensureConnected(config);
    console.log(`[SurrealClient] ✅ Connected to DB`);

    const res = await db.query(sql);
    console.log(`[SurrealClient] 📦 Raw response:`, res);
    console.log(`[SurrealClient] 📦 Raw response type:`, typeof res);
    console.log(`[SurrealClient] 📦 Raw response is array:`, Array.isArray(res));

    // Normalisation: SurrealDB peut retourner différents formats
    let normalized: unknown = [];
    
    if (Array.isArray(res)) {
      // Format 1: [{ result: [...] }] - format standard SurrealDB
      const first = res[0] as any;
      if (first && typeof first === 'object' && 'result' in first) {
        normalized = (first as any).result ?? [];
        console.log(`[SurrealClient] 🔄 Normalized from {result: ...} format`);
      } 
      // Format 2: [[...]] - tableau de tableaux
      else if (Array.isArray(first)) {
        normalized = first;
        console.log(`[SurrealClient] 🔄 Normalized from nested array format`);
      }
      // Format 3: [{...}] - tableau d'objets (fonctions qui retournent un objet)
      else if (first && typeof first === 'object') {
        normalized = res; // Garder tout le tableau
        console.log(`[SurrealClient] 🔄 Normalized from object array format`);
      }
      // Format 4: [] - tableau vide ou avec éléments directs
      else {
        normalized = res;
        console.log(`[SurrealClient] 🔄 Normalized from direct array format`);
      }
    } else if (res && typeof res === 'object') {
      // Format 5: Objet direct (peu probable mais possible)
      normalized = res;
      console.log(`[SurrealClient] 🔄 Normalized from direct object format`);
    } else {
      // Format 6: Autre (null, undefined, etc.)
      normalized = res ?? [];
      console.log(`[SurrealClient] 🔄 Normalized from fallback format`);
    }

    console.log(`[SurrealClient] 📊 Final normalized result:`, normalized);
    console.log(`[SurrealClient] 📊 Final normalized type:`, typeof normalized);
    console.log(`[SurrealClient] 📊 Final normalized is array:`, Array.isArray(normalized));
    if (Array.isArray(normalized)) {
      console.log(`[SurrealClient] 📊 Final normalized length:`, normalized.length);
    }
    
    return normalized as T;
  }
}

export const SurrealClient = new SurrealClientSingleton();


