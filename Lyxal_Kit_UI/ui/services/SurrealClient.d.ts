import Surreal from 'surrealdb';
type Config = {
    infrastructure: {
        surrealDbUrl: {
            value: string;
        };
        surrealNamespace: {
            value: string;
        };
        surrealDatabase: {
            value: string;
        };
        surrealUsername: {
            value: string;
        };
        surrealPassword: {
            value: string;
        };
    };
};
declare class SurrealClientSingleton {
    private db;
    private ns?;
    private dbName?;
    private currentConfig?;
    ensureConnected(config: Config): Promise<Surreal>;
    query<T = unknown>(config: Config, sql: string): Promise<T>;
}
export declare const SurrealClient: SurrealClientSingleton;
export {};
