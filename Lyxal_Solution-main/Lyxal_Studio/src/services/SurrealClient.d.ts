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
    ensureConnected(config: Config): Promise<Surreal>;
    query<T = unknown>(config: Config, sql: string): Promise<T>;
    /**
     * Exécute une requête avec paramètres (nouveau pour RouteService)
     * Remplace automatiquement les placeholders $param par leurs valeurs
     */
    queryWithParams<T = unknown>(config: Config, sql: string, params?: Record<string, any>): Promise<T>;
    /**
     * Formate une valeur de paramètre pour SurrealQL
     */
    private formatParamValue;
}
export declare const SurrealClient: SurrealClientSingleton;
export {};
