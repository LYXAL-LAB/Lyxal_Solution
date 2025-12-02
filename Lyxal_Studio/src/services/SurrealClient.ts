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

  async ensureConnected(config: Config): Promise<Surreal> {
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
    return db;
  }

  async query<T = unknown>(config: Config, sql: string): Promise<T> {
    console.log(`[SurrealClient] 🔍 Executing query:`, sql.substring(0, 100) + (sql.length > 100 ? '...' : ''));
    console.log(`[SurrealClient] 🔗 Connection:`, this.ns, this.dbName);

    const db = await this.ensureConnected(config);
    console.log(`[SurrealClient] ✅ Connected to DB`);

    const res = await db.query(sql);
    console.log(`[SurrealClient] 📦 Raw response:`, res);

    // Normalisation: certains clients renvoient [{ result: [...] }], d'autres [[...]]
    let normalized: unknown = [];
    if (Array.isArray(res)) {
      const first = res[0] as any;
      if (first && typeof first === 'object' && 'result' in first) {
        normalized = (first as any).result ?? [];
        console.log(`[SurrealClient] 🔄 Normalized from {result: ...} format`);
      } else if (Array.isArray(first)) {
        normalized = first;
        console.log(`[SurrealClient] 🔄 Normalized from array format`);
      }
    }

    console.log(`[SurrealClient] 📊 Final normalized result:`, normalized);
    return normalized as T;
  }

  /**
   * Exécute une requête avec paramètres (nouveau pour RouteService)
   * Remplace automatiquement les placeholders $param par leurs valeurs
   */
  async queryWithParams<T = unknown>(
    config: Config,
    sql: string,
    params: Record<string, any> = {}
  ): Promise<T> {
    console.log(`[SurrealClient] 🔍 Executing query with params:`, sql.substring(0, 100) + (sql.length > 100 ? '...' : ''));
    console.log(`[SurrealClient] 📋 Params:`, Object.keys(params));
    console.log(`[SurrealClient] 🔗 Connection:`, this.ns, this.dbName);

    // Remplacer les paramètres dans la requête
    let processedSql = sql;
    for (const [key, value] of Object.entries(params)) {
      const placeholder = `$${key}`;
      if (processedSql.includes(placeholder)) {
        // Échapper et formater la valeur selon le type
        const formattedValue = this.formatParamValue(value);
        processedSql = processedSql.replace(new RegExp(`\\$${key}\\b`, 'g'), formattedValue);
        console.log(`[SurrealClient] 🔄 Replaced $${key} with: ${formattedValue}`);
      }
    }

    console.log(`[SurrealClient] 📝 Final query:`, processedSql);

    // Utiliser la méthode query normale
    return this.query<T>(config, processedSql);
  }

  /**
   * Formate une valeur de paramètre pour SurrealQL
   */
  private formatParamValue(value: any): string {
    if (value === null || value === undefined) {
      return 'NONE';
    }

    if (typeof value === 'string') {
      // Échapper les guillemets simples et entourer de guillemets
      return `'${value.replace(/'/g, "\\'")}'`;
    }

    if (typeof value === 'boolean') {
      return value ? 'true' : 'false';
    }

    if (typeof value === 'number') {
      return value.toString();
    }

    if (Array.isArray(value)) {
      const formattedItems = value.map(item => this.formatParamValue(item));
      return `[${formattedItems.join(', ')}]`;
    }

    if (typeof value === 'object') {
      // Pour les objets complexes, utiliser la syntaxe JSON
      return JSON.stringify(value);
    }

    // Par défaut, convertir en string
    return `'${String(value)}'`;
  }
}

export const SurrealClient = new SurrealClientSingleton();


