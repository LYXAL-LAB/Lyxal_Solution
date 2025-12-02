/**
 * Types TypeScript pour le système de routes dynamiques
 * Définit les structures JSON stockées dans SurrealDB
 */
/**
 * Identité d'une route
 */
export interface RouteIdentity {
    /** Chemin de la route (doit commencer par /) */
    value: string;
    /** Slug kebab-case pour l'URL */
    slug: string;
    /** Code snake_case pour les références */
    code: string;
}
/**
 * Référence vers une page
 */
export interface RoutePageRef {
    /** Code de la page référencée */
    identity: {
        code: string;
    };
}
/**
 * Types de permissions disponibles
 */
export type Permission = 'guest' | 'authenticated' | 'admin' | 'manager';
/**
 * Types de guards disponibles
 */
export type GuardType = 'auth' | 'role' | 'subscription' | 'feature';
/**
 * Structure d'un guard
 */
export interface RouteGuard {
    /** Type de guard */
    type: GuardType;
    /** Conditions spécifiques au guard */
    condition?: Record<string, any>;
}
/**
 * Métadonnées d'une route
 */
export interface RouteMetadata {
    /** Titre i18n */
    title_i18n?: string;
    /** Description i18n */
    description_i18n?: string;
    /** Icône de la route */
    icon?: string;
    /** Ordre d'affichage */
    order?: number;
    /** Groupe logique */
    group?: string;
    /** Tags pour la recherche */
    tags?: string[];
}
/**
 * Statuts possibles d'une route
 */
export type RouteStatus = 'active' | 'inactive' | 'draft' | 'deprecated';
/**
 * Structure complète d'une route dans la DB
 */
export interface StudioRoute {
    /** ID unique SurrealDB */
    id?: string;
    /** Identité de la route */
    identity: RouteIdentity;
    /** Page associée */
    page: RoutePageRef;
    /** Permissions requises */
    permissions: Permission[];
    /** Guards à exécuter */
    guards?: RouteGuard[];
    /** Métadonnées */
    metadata?: RouteMetadata;
    /** Statut de la route */
    status: RouteStatus;
    /** Timestamps */
    created_at?: string;
    updated_at?: string;
    /** ETag pour optimistic locking */
    etag?: string;
}
/**
 * Résultat de validation d'une route
 */
export interface RouteValidationResult {
    success: boolean;
    errors?: string[];
    data?: StudioRoute;
}
/**
 * Input pour création de route (sans ID et timestamps)
 */
export type CreateStudioRouteInput = Omit<StudioRoute, 'id' | 'created_at' | 'updated_at' | 'etag'>;
/**
 * Input pour mise à jour de route
 */
export type UpdateStudioRouteInput = Partial<Pick<StudioRoute, 'identity' | 'page' | 'permissions' | 'guards' | 'metadata' | 'status'>> & {
    id: string;
};
/**
 * Contexte d'exécution d'un guard
 */
export interface RouteGuardContext {
    /** Utilisateur actuel */
    user?: {
        id: string;
        roles?: string[];
        permissions?: string[];
    };
    /** Tenant actuel */
    tenant?: {
        id: string;
        features?: string[];
        subscription?: string;
    };
    /** Paramètres de l'URL */
    params?: Record<string, string>;
    /** Query parameters */
    query?: Record<string, string>;
}
/**
 * Contexte étendu pour l'exécution des guards (avec abonnement et route)
 */
export interface GuardExecutionContext extends RouteGuardContext {
    /** Informations complètes d'utilisateur */
    user?: {
        id: string;
        roles?: string[];
        permissions?: string[];
        subscription?: {
            plan: string;
            features: string[];
            active: boolean;
        };
    };
    /** Informations de route */
    route?: {
        path: string;
        params: Record<string, string>;
        query: Record<string, string>;
    };
    /** Informations de requête */
    request?: {
        method: string;
        headers: Record<string, string>;
    };
}
/**
 * Résultat d'exécution d'un guard
 */
export interface GuardExecutionResult {
    success: boolean;
    error?: string;
    redirectTo?: string;
}
/**
 * Configuration de cache pour les routes
 */
export interface RouteCacheConfig {
    /** TTL en millisecondes */
    ttl: number;
    /** Nombre maximum d'entrées */
    maxEntries: number;
    /** Stratégie de nettoyage */
    cleanupStrategy: 'lru' | 'fifo';
}
/**
 * Statistiques d'utilisation des routes
 */
export interface RouteStats {
    /** Nombre de chargements */
    loadCount: number;
    /** Temps de chargement moyen */
    avgLoadTime: number;
    /** Taux d'erreur */
    errorRate: number;
    /** Dernier accès */
    lastAccessed: string;
}
/**
 * Résultat de chargement des routes
 */
export interface UseStudioRoutesResult {
    routes: StudioRoute[];
    loading: boolean;
    error: string | null;
    refetch: () => Promise<void>;
}
/**
 * Résultat de chargement d'une route
 */
export interface UseStudioRouteResult {
    route: StudioRoute | null;
    loading: boolean;
    error: string | null;
    refetch: () => Promise<void>;
}
/**
 * Résultat d'exécution des guards
 */
export interface UseRouteGuardResult {
    isAllowed: boolean | null;
    loading: boolean;
    error: string | null;
    redirectTo?: string;
}
/**
 * Résultat de vérification des permissions
 */
export interface UseRoutePermissionsResult {
    hasPermission: boolean;
    loading: boolean;
    missingPermissions: Permission[];
}
