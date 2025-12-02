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
}

export const SurrealClient = new SurrealClientSingleton();


