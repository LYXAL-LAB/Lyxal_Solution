import { StudioRoute, RouteCacheConfig } from '../../types/route';
/**
 * Statistiques du cache
 */
interface CacheStats {
    totalEntries: number;
    activeEntries: number;
    cacheHits: number;
    cacheMisses: number;
    evictions: number;
    avgLoadTime: number;
    lastCleanup: number;
}
/**
 * Registre centralisé pour la gestion des routes avec cache intelligent
 * Optimise les accès à la base de données tout en maintenant la fraîcheur des données
 */
export declare class RouteRegistry {
    private cache;
    private config;
    private stats;
    private cleanupInterval;
    constructor(config?: Partial<RouteCacheConfig>);
    /**
     * Récupère une route par son code depuis le cache ou la DB
     */
    getRouteByCode(code: string): Promise<StudioRoute | null>;
    /**
     * Récupère une route par son chemin depuis le cache ou la DB
     */
    getRouteByPath(path: string): Promise<StudioRoute | null>;
    /**
     * Récupère toutes les routes actives avec cache intelligent
     */
    getActiveRoutes(forceRefresh?: boolean): Promise<StudioRoute[]>;
    /**
     * Invalide le cache pour une route spécifique
     */
    invalidateRoute(code: string): void;
    /**
     * Invalide tout le cache
     */
    invalidateAll(): void;
    /**
     * Met à jour une route dans le cache
     */
    updateRouteInCache(route: StudioRoute): void;
    /**
     * Supprime une route du cache
     */
    removeRouteFromCache(code: string): void;
    /**
     * Récupère les statistiques du cache
     */
    getStats(): CacheStats & {
        hitRate: number;
    };
    /**
     * Force un nettoyage du cache
     */
    forceCleanup(): void;
    /**
     * Nettoie les ressources
     */
    destroy(): void;
    private getFromCache;
    private getFromCacheByPath;
    private setInCache;
    private hasValidCache;
    private getActiveRoutesFromCache;
    private updateActiveRoutesCache;
    private ensureCapacity;
    private performCleanup;
    private cleanupLRU;
    private cleanupFIFO;
    private updateLoadTimeStats;
    private startCleanupInterval;
}
export declare const routeRegistry: RouteRegistry;
export {};
