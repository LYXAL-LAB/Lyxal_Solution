/**
 * Utilitaire pour vérifier les permissions utilisateur
 * Gère la logique complexe de vérification des droits d'accès
 */
export class PermissionChecker {
    /**
     * Vérifie si un utilisateur a les permissions requises pour une route
     */
    static checkRoutePermissions(context) {
        const { user, routePermissions, requireAll = false } = context;
        // Récupérer les permissions de l'utilisateur
        const userPermissions = this.getUserPermissions(user);
        // Si pas de permissions requises, accès accordé
        if (routePermissions.length === 0) {
            return {
                granted: true,
                missingPermissions: [],
                grantedPermissions: [],
                userPermissions,
                reason: 'No permissions required'
            };
        }
        // Vérifier les permissions selon la logique (AND/OR)
        const result = requireAll
            ? this.checkAllPermissions(userPermissions, routePermissions)
            : this.checkAnyPermission(userPermissions, routePermissions);
        return {
            ...result,
            userPermissions
        };
    }
    /**
     * Vérifie les permissions avec logique AND (toutes requises)
     */
    static checkAllPermissions(userPermissions, requiredPermissions) {
        const grantedPermissions = [];
        const missingPermissions = [];
        for (const required of requiredPermissions) {
            if (userPermissions.includes(required)) {
                grantedPermissions.push(required);
            }
            else {
                missingPermissions.push(required);
            }
        }
        return {
            granted: missingPermissions.length === 0,
            missingPermissions,
            grantedPermissions,
            reason: missingPermissions.length === 0
                ? 'All permissions granted'
                : `Missing permissions: ${missingPermissions.join(', ')}`
        };
    }
    /**
     * Vérifie les permissions avec logique OR (au moins une requise)
     */
    static checkAnyPermission(userPermissions, requiredPermissions) {
        const grantedPermissions = [];
        for (const required of requiredPermissions) {
            if (userPermissions.includes(required)) {
                grantedPermissions.push(required);
                return {
                    granted: true,
                    missingPermissions: [],
                    grantedPermissions,
                    reason: `Permission granted: ${required}`
                };
            }
        }
        return {
            granted: false,
            missingPermissions: requiredPermissions,
            grantedPermissions: [],
            reason: `None of required permissions granted: ${requiredPermissions.join(', ')}`
        };
    }
    /**
     * Récupère toutes les permissions d'un utilisateur
     */
    static getUserPermissions(user) {
        if (!user) {
            return ['guest'];
        }
        const permissions = [];
        // Permissions basées sur les rôles
        for (const role of user.roles) {
            permissions.push(...this.getPermissionsForRole(role));
        }
        // Permissions explicites
        permissions.push(...user.permissions);
        // Permissions de souscription
        if (user.subscription?.active) {
            permissions.push('authenticated');
            // TODO: Ajouter des permissions basées sur le plan de souscription
        }
        // Permissions de tenant
        if (user.tenant) {
            // TODO: Ajouter des permissions basées sur le tenant
        }
        // Éliminer les doublons
        return [...new Set(permissions)];
    }
    /**
     * Récupère les permissions associées à un rôle
     */
    static getPermissionsForRole(role) {
        switch (role) {
            case 'guest':
                return ['guest'];
            case 'user':
                return ['guest', 'authenticated'];
            case 'admin':
                return ['guest', 'authenticated', 'admin'];
            case 'manager':
                return ['guest', 'authenticated', 'admin', 'manager'];
            case 'super_admin':
                return ['guest', 'authenticated', 'admin', 'manager'];
            default:
                return ['guest'];
        }
    }
    /**
     * Vérifie si un utilisateur peut accéder à une ressource spécifique
     */
    static canAccessResource(user, resourcePermissions, context) {
        return this.checkRoutePermissions({
            user,
            routePermissions: resourcePermissions,
            requireAll: false // Par défaut OR pour les ressources
        });
    }
    /**
     * Vérifie si un utilisateur a un rôle spécifique
     */
    static hasRole(user, role) {
        if (!user)
            return role === 'guest';
        return user.roles.includes(role);
    }
    /**
     * Vérifie si un utilisateur a une permission spécifique
     */
    static hasPermission(user, permission) {
        if (!user)
            return permission === 'guest';
        return this.getUserPermissions(user).includes(permission);
    }
    /**
     * Vérifie si un utilisateur a accès à une fonctionnalité
     */
    static hasFeature(user, feature) {
        if (!user)
            return false;
        // Vérifier dans les features de souscription
        if (user.subscription?.features.includes(feature)) {
            return true;
        }
        // Vérifier dans les features de tenant
        if (user.tenant?.features.includes(feature)) {
            return true;
        }
        // Vérifier les rôles spéciaux
        if (user.roles.includes('super_admin')) {
            return true;
        }
        return false;
    }
    /**
     * Récupère le niveau d'accès d'un utilisateur
     */
    static getAccessLevel(user) {
        if (!user)
            return 0; // Guest
        if (user.roles.includes('super_admin'))
            return 100;
        if (user.roles.includes('admin'))
            return 80;
        if (user.roles.includes('manager'))
            return 60;
        if (user.roles.includes('user'))
            return 40;
        return 20; // Authenticated user sans rôle spécifique
    }
    /**
     * Vérifie si un utilisateur peut effectuer une action sur un autre utilisateur
     */
    static canActOnUser(actor, target) {
        if (!actor)
            return false;
        // Super admin peut tout faire
        if (actor.roles.includes('super_admin'))
            return true;
        // Admin peut agir sur les users et managers
        if (actor.roles.includes('admin')) {
            return !target.roles.includes('admin') && !target.roles.includes('super_admin');
        }
        // Manager peut agir sur les users
        if (actor.roles.includes('manager')) {
            return target.roles.includes('user') || target.roles.length === 0;
        }
        // User ne peut agir que sur lui-même
        return actor.id === target.id;
    }
}
