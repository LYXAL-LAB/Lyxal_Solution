import { StudioRoute } from '../../types/route';
/**
 * Paramètres extraits d'une URL
 */
export interface RouteMatchParams {
    [key: string]: string;
}
/**
 * Résultat du matching d'une route
 */
export interface RouteMatchResult {
    route: StudioRoute;
    params: RouteMatchParams;
    query: Record<string, string>;
    matched: boolean;
    score: number;
}
/**
 * Utilitaire pour le matching des routes
 * Gère la correspondance des URLs avec les patterns de routes définis
 */
export declare class RouteMatcher {
    /**
     * Trouve la route qui correspond à une URL donnée
     */
    static matchRoute(routes: StudioRoute[], url: string): RouteMatchResult | null;
    /**
     * Vérifie si une route correspond exactement à un pattern
     */
    static matchExactRoute(routes: StudioRoute[], pathname: string): StudioRoute | null;
    /**
     * Trouve toutes les routes qui correspondent à un préfixe
     */
    static findRoutesByPrefix(routes: StudioRoute[], prefix: string): StudioRoute[];
    /**
     * Parse une URL en pathname et search params
     */
    private static parseUrl;
    /**
     * Teste si une route correspond à un pattern
     */
    private static matchRoutePattern;
    /**
     * Normalise un pathname
     */
    static normalizePath(path: string): string;
    /**
     * Valide le format d'un pathname
     */
    static isValidPath(path: string): boolean;
    /**
     * Encode les paramètres pour une URL
     */
    static encodeParams(params: RouteMatchParams): string;
    /**
     * Décode les paramètres depuis une query string
     */
    static decodeParams(queryString: string): RouteMatchParams;
    /**
     * Construit une URL complète à partir d'une route et de paramètres
     */
    static buildUrl(route: StudioRoute, params?: RouteMatchParams, query?: Record<string, string>): string;
    /**
     * Vérifie si deux URLs sont équivalentes
     */
    static areUrlsEquivalent(url1: string, url2: string): boolean;
}
