import { StudioRoute } from '../../types/route';
/**
 * État de chargement des routes
 */
export interface RouteLoaderState {
    isLoading: boolean;
    isLoaded: boolean;
    lastLoadTime: number | null;
    error: Error | null;
    routeCount: number;
}
/**
 * Options de chargement
 */
export interface RouteLoadOptions {
    forceRefresh?: boolean;
    backgroundLoad?: boolean;
    onProgress?: (loaded: number, total: number) => void;
    timeout?: number;
}
/**
 * Résultat de chargement
 */
export interface RouteLoadResult {
    routes: StudioRoute[];
    fromCache: boolean;
    loadTime: number;
    error?: Error;
}
/**
 * Chargeur de routes spécialisé
 * Gère le chargement intelligent des routes depuis la DB avec cache et optimisation
 */
export declare class RouteLoader {
    private state;
    private loadingPromise;
    constructor();
    /**
     * Charge toutes les routes actives
     */
    loadActiveRoutes(options?: RouteLoadOptions): Promise<RouteLoadResult>;
    /**
     * Précharge les routes en arrière-plan
     */
    preloadRoutes(): Promise<void>;
    /**
     * Charge une route spécifique par code
     */
    loadRouteByCode(code: string, options?: RouteLoadOptions): Promise<StudioRoute | null>;
    /**
     * Charge une route par chemin
     */
    loadRouteByPath(path: string, options?: RouteLoadOptions): Promise<StudioRoute | null>;
    /**
     * Rafraîchit manuellement le cache
     */
    refreshCache(): Promise<RouteLoadResult>;
    /**
     * Vérifie si les routes ont besoin d'être rechargées
     */
    needsRefresh(): boolean;
    /**
     * Obtient l'état actuel du loader
     */
    getState(): RouteLoaderState;
    /**
     * Obtient les statistiques du cache
     */
    getCacheStats(): any;
    /**
     * Nettoie le cache et réinitialise l'état
     */
    clearCache(): void;
    private performLoad;
}
export declare const routeLoader: RouteLoader;
