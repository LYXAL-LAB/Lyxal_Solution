import { z } from 'zod';
/**
 * Types de permissions disponibles dans le système
 */
export declare const PermissionTypeSchema: z.ZodEnum<{
    guest: "guest";
    authenticated: "authenticated";
    admin: "admin";
    manager: "manager";
}>;
/**
 * Structure d'une permission dans la base de données
 */
export declare const RoutePermissionSchema: z.ZodObject<{
    id: z.ZodOptional<z.ZodString>;
    code: z.ZodString;
    name_i18n: z.ZodString;
    category: z.ZodString;
    description_i18n: z.ZodOptional<z.ZodString>;
    is_system: z.ZodDefault<z.ZodBoolean>;
    created_at: z.ZodOptional<z.ZodString>;
    updated_at: z.ZodOptional<z.ZodString>;
    etag: z.ZodOptional<z.ZodString>;
}, z.core.$strip>;
/**
 * Schéma pour la création d'une permission
 */
export declare const CreateRoutePermissionSchema: z.ZodObject<{
    code: z.ZodString;
    name_i18n: z.ZodString;
    description_i18n: z.ZodOptional<z.ZodString>;
    is_system: z.ZodDefault<z.ZodBoolean>;
    category: z.ZodString;
}, z.core.$strip>;
/**
 * Schéma pour la mise à jour d'une permission
 */
export declare const UpdateRoutePermissionSchema: z.ZodObject<{
    code: z.ZodOptional<z.ZodString>;
    name_i18n: z.ZodOptional<z.ZodString>;
    category: z.ZodOptional<z.ZodString>;
    description_i18n: z.ZodOptional<z.ZodOptional<z.ZodString>>;
    is_system: z.ZodOptional<z.ZodDefault<z.ZodBoolean>>;
    created_at: z.ZodOptional<z.ZodOptional<z.ZodString>>;
    updated_at: z.ZodOptional<z.ZodOptional<z.ZodString>>;
    etag: z.ZodOptional<z.ZodOptional<z.ZodString>>;
    id: z.ZodString;
}, z.core.$strip>;
/**
 * Vérification de permissions utilisateur
 */
export interface PermissionCheck {
    userPermissions: string[];
    requiredPermissions: string[];
    requireAll?: boolean;
}
/**
 * Résultat de vérification de permissions
 */
export interface PermissionCheckResult {
    hasPermission: boolean;
    missingPermissions: string[];
    grantedPermissions: string[];
}
/**
 * Fonction utilitaire pour vérifier les permissions
 */
export declare function checkPermissions(check: PermissionCheck): PermissionCheckResult;
/**
 * Validation d'une permission
 */
export declare function validatePermission(data: unknown): z.ZodSafeParseResult<{
    code: string;
    name_i18n: string;
    category: string;
    is_system: boolean;
    id?: string | undefined;
    description_i18n?: string | undefined;
    created_at?: string | undefined;
    updated_at?: string | undefined;
    etag?: string | undefined;
}>;
/**
 * Validation de création de permission
 */
export declare function validatePermissionCreation(data: unknown): z.ZodSafeParseResult<{
    code: string;
    name_i18n: string;
    is_system: boolean;
    category: string;
    description_i18n?: string | undefined;
}>;
/**
 * Types exportés
 */
export type PermissionType = z.infer<typeof PermissionTypeSchema>;
export type RoutePermission = z.infer<typeof RoutePermissionSchema>;
export type CreateRoutePermission = z.infer<typeof CreateRoutePermissionSchema>;
export type UpdateRoutePermission = z.infer<typeof UpdateRoutePermissionSchema>;
