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
    const db = await this.ensureConnected(config);
    const res = await db.query(sql);
    // logs de debug supprimés
    // Normalisation: certains clients renvoient [{ result: [...] }], d'autres [[...]]
    let normalized: unknown = [];
    if (Array.isArray(res)) {
      const first = res[0] as any;
      if (first && typeof first === 'object' && 'result' in first) {
        normalized = (first as any).result ?? [];
      } else if (Array.isArray(first)) {
        normalized = first;
      }
    }
    return normalized as T;
  }
}

export const SurrealClient = new SurrealClientSingleton();


