import { z } from 'zod';
/**
 * Types de permissions disponibles dans le système
 */
export const PermissionTypeSchema = z.enum([
    'guest',
    'authenticated',
    'admin',
    'manager'
]);
/**
 * Structure d'une permission dans la base de données
 */
export const RoutePermissionSchema = z.object({
    id: z.string().optional(),
    code: z.string()
        .regex(/^[a-z_]+$/, 'Permission code must be snake_case')
        .min(1, 'Permission code cannot be empty'),
    name_i18n: z.string()
        .min(1, 'Permission name cannot be empty'),
    category: z.string()
        .min(1, 'Permission category cannot be empty'),
    description_i18n: z.string().optional(),
    is_system: z.boolean().default(false),
    created_at: z.string().datetime().optional(),
    updated_at: z.string().datetime().optional(),
    etag: z.string().optional(),
});
/**
 * Schéma pour la création d'une permission
 */
export const CreateRoutePermissionSchema = RoutePermissionSchema.omit({
    id: true,
    created_at: true,
    updated_at: true,
    etag: true,
});
/**
 * Schéma pour la mise à jour d'une permission
 */
export const UpdateRoutePermissionSchema = RoutePermissionSchema.partial().extend({
    id: z.string(),
});
/**
 * Fonction utilitaire pour vérifier les permissions
 */
export function checkPermissions(check) {
    const { userPermissions, requiredPermissions, requireAll = false } = check;
    const grantedPermissions = [];
    const missingPermissions = [];
    if (requireAll) {
        // Mode AND : toutes les permissions requises
        for (const required of requiredPermissions) {
            if (userPermissions.includes(required)) {
                grantedPermissions.push(required);
            }
            else {
                missingPermissions.push(required);
            }
        }
        return {
            hasPermission: missingPermissions.length === 0,
            missingPermissions,
            grantedPermissions,
        };
    }
    else {
        // Mode OR : au moins une permission requise
        for (const required of requiredPermissions) {
            if (userPermissions.includes(required)) {
                grantedPermissions.push(required);
                return {
                    hasPermission: true,
                    missingPermissions: [],
                    grantedPermissions,
                };
            }
        }
        return {
            hasPermission: false,
            missingPermissions: requiredPermissions,
            grantedPermissions: [],
        };
    }
}
/**
 * Validation d'une permission
 */
export function validatePermission(data) {
    return RoutePermissionSchema.safeParse(data);
}
/**
 * Validation de création de permission
 */
export function validatePermissionCreation(data) {
    return CreateRoutePermissionSchema.safeParse(data);
}
