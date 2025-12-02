import { StudioRoute } from '../../types/route';
/**
 * Options de normalisation
 */
export interface RouteNormalizationOptions {
    generateCodes?: boolean;
    generateSlugs?: boolean;
    validateReferences?: boolean;
    sanitizeMetadata?: boolean;
    enforceDefaults?: boolean;
}
/**
 * Résultat de normalisation
 */
export interface RouteNormalizationResult {
    route: StudioRoute;
    changes: string[];
    warnings: string[];
    errors: string[];
}
/**
 * Utilitaire pour normaliser et valider les routes
 * Assure la cohérence et la qualité des données de routes
 */
export declare class RouteNormalizer {
    /**
     * Normalise une route complète
     */
    static normalizeRoute(route: Partial<StudioRoute>, options?: RouteNormalizationOptions): RouteNormalizationResult;
    /**
     * Normalise l'identité d'une route
     */
    private static normalizeIdentity;
    /**
     * Normalise les permissions
     */
    private static normalizePermissions;
    /**
     * Normalise les guards
     */
    private static normalizeGuards;
    /**
     * Normalise les métadonnées
     */
    private static normalizeMetadata;
    /**
     * Applique les valeurs par défaut
     */
    private static applyDefaults;
    /**
     * Valide la cohérence globale de la route
     */
    private static validateRouteConsistency;
    private static normalizePath;
    private static generateSlugFromPath;
    private static generateCodeFromPath;
    private static normalizeSlug;
    private static normalizeCode;
    private static isValidSlug;
    private static isValidCode;
}
