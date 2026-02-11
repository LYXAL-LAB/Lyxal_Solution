import { Permission, RouteGuardContext } from '../../types/route';
/**
 * Rôles utilisateur disponibles
 */
export type UserRole = 'guest' | 'user' | 'admin' | 'manager' | 'super_admin';
/**
 * Profil utilisateur pour les vérifications
 */
export interface UserProfile {
    id: string;
    roles: UserRole[];
    permissions: Permission[];
    subscription?: {
        plan: string;
        features: string[];
        active: boolean;
    };
    tenant?: {
        id: string;
        features: string[];
        restrictions: string[];
    };
}
/**
 * Contexte de vérification de permissions
 */
export interface PermissionCheckContext {
    user?: UserProfile;
    routePermissions: Permission[];
    requireAll?: boolean;
}
/**
 * Résultat de vérification de permissions
 */
export interface PermissionCheckResult {
    granted: boolean;
    missingPermissions: Permission[];
    grantedPermissions: Permission[];
    userPermissions: Permission[];
    reason?: string;
}
/**
 * Utilitaire pour vérifier les permissions utilisateur
 * Gère la logique complexe de vérification des droits d'accès
 */
export declare class PermissionChecker {
    /**
     * Vérifie si un utilisateur a les permissions requises pour une route
     */
    static checkRoutePermissions(context: PermissionCheckContext): PermissionCheckResult;
    /**
     * Vérifie les permissions avec logique AND (toutes requises)
     */
    private static checkAllPermissions;
    /**
     * Vérifie les permissions avec logique OR (au moins une requise)
     */
    private static checkAnyPermission;
    /**
     * Récupère toutes les permissions d'un utilisateur
     */
    private static getUserPermissions;
    /**
     * Récupère les permissions associées à un rôle
     */
    private static getPermissionsForRole;
    /**
     * Vérifie si un utilisateur peut accéder à une ressource spécifique
     */
    static canAccessResource(user: UserProfile | undefined, resourcePermissions: Permission[], context?: RouteGuardContext): PermissionCheckResult;
    /**
     * Vérifie si un utilisateur a un rôle spécifique
     */
    static hasRole(user: UserProfile | undefined, role: UserRole): boolean;
    /**
     * Vérifie si un utilisateur a une permission spécifique
     */
    static hasPermission(user: UserProfile | undefined, permission: Permission): boolean;
    /**
     * Vérifie si un utilisateur a accès à une fonctionnalité
     */
    static hasFeature(user: UserProfile | undefined, feature: string): boolean;
    /**
     * Récupère le niveau d'accès d'un utilisateur
     */
    static getAccessLevel(user?: UserProfile): number;
    /**
     * Vérifie si un utilisateur peut effectuer une action sur un autre utilisateur
     */
    static canActOnUser(actor: UserProfile | undefined, target: UserProfile): boolean;
}
