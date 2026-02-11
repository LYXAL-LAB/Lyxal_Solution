import { StudioRoute, CreateStudioRouteInput, UpdateStudioRouteInput } from '../lib/studio/types/route';
/**
 * Service principal pour la gestion des routes dynamiques
 * Fournit toutes les opérations CRUD sur les routes en base de données
 */
export declare class RouteService {
    private static client;
    /**
     * Récupère toutes les routes actives
     */
    static getActiveRoutes(): Promise<StudioRoute[]>;
    /**
     * Récupère une route par son code
     */
    static getRouteByCode(code: string): Promise<StudioRoute | null>;
    /**
     * Récupère une route par son chemin
     */
    static getRouteByPath(path: string): Promise<StudioRoute | null>;
    /**
     * Récupère une route par son ID
     */
    static getRouteById(id: string): Promise<StudioRoute | null>;
    /**
     * Crée une nouvelle route
     */
    static createRoute(input: CreateStudioRouteInput): Promise<StudioRoute>;
    /**
     * Met à jour une route existante
     */
    static updateRoute(id: string, input: UpdateStudioRouteInput): Promise<StudioRoute>;
    /**
     * Supprime une route
     */
    static deleteRoute(id: string): Promise<boolean>;
    /**
     * Change le statut d'une route
     */
    static setRouteStatus(id: string, status: StudioRoute['status']): Promise<StudioRoute>;
}
/**
 * Erreur de validation personnalisée
 */
export declare class ValidationError extends Error {
    errors: string[];
    constructor(message: string, errors?: string[]);
}
