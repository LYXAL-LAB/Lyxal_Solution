import { z } from 'zod';
import type { RouteValidationResult } from '../../types/route';
/**
 * Schéma principal pour une route Studio
 */
export declare const StudioRouteSchema: z.ZodObject<{
    id: z.ZodOptional<z.ZodString>;
    identity: z.ZodObject<{
        value: z.ZodString;
        slug: z.ZodString;
        code: z.ZodString;
    }, z.core.$strip>;
    page: z.ZodObject<{
        identity: z.ZodObject<{
            code: z.ZodString;
        }, z.core.$strip>;
    }, z.core.$strip>;
    permissions: z.ZodArray<z.ZodEnum<{
        guest: "guest";
        authenticated: "authenticated";
        admin: "admin";
        manager: "manager";
    }>>;
    guards: z.ZodOptional<z.ZodArray<z.ZodObject<{
        type: z.ZodEnum<{
            role: "role";
            auth: "auth";
            subscription: "subscription";
            feature: "feature";
        }>;
        condition: z.ZodOptional<z.ZodRecord<z.ZodString, z.ZodAny>>;
    }, z.core.$strip>>>;
    metadata: z.ZodOptional<z.ZodObject<{
        title_i18n: z.ZodOptional<z.ZodString>;
        description_i18n: z.ZodOptional<z.ZodString>;
        icon: z.ZodOptional<z.ZodString>;
        order: z.ZodOptional<z.ZodNumber>;
        group: z.ZodOptional<z.ZodString>;
        tags: z.ZodOptional<z.ZodArray<z.ZodString>>;
    }, z.core.$strip>>;
    status: z.ZodEnum<{
        active: "active";
        inactive: "inactive";
        draft: "draft";
        deprecated: "deprecated";
    }>;
    created_at: z.ZodOptional<z.ZodString>;
    updated_at: z.ZodOptional<z.ZodString>;
    etag: z.ZodOptional<z.ZodString>;
}, z.core.$strip>;
/**
 * Schéma pour la création d'une route (sans id et timestamps)
 */
export declare const CreateStudioRouteSchema: z.ZodObject<{
    metadata: z.ZodOptional<z.ZodObject<{
        title_i18n: z.ZodOptional<z.ZodString>;
        description_i18n: z.ZodOptional<z.ZodString>;
        icon: z.ZodOptional<z.ZodString>;
        order: z.ZodOptional<z.ZodNumber>;
        group: z.ZodOptional<z.ZodString>;
        tags: z.ZodOptional<z.ZodArray<z.ZodString>>;
    }, z.core.$strip>>;
    page: z.ZodObject<{
        identity: z.ZodObject<{
            code: z.ZodString;
        }, z.core.$strip>;
    }, z.core.$strip>;
    status: z.ZodEnum<{
        active: "active";
        inactive: "inactive";
        draft: "draft";
        deprecated: "deprecated";
    }>;
    identity: z.ZodObject<{
        value: z.ZodString;
        slug: z.ZodString;
        code: z.ZodString;
    }, z.core.$strip>;
    permissions: z.ZodArray<z.ZodEnum<{
        guest: "guest";
        authenticated: "authenticated";
        admin: "admin";
        manager: "manager";
    }>>;
    guards: z.ZodOptional<z.ZodArray<z.ZodObject<{
        type: z.ZodEnum<{
            role: "role";
            auth: "auth";
            subscription: "subscription";
            feature: "feature";
        }>;
        condition: z.ZodOptional<z.ZodRecord<z.ZodString, z.ZodAny>>;
    }, z.core.$strip>>>;
}, z.core.$strip>;
/**
 * Schéma pour la mise à jour d'une route (champs optionnels)
 */
export declare const UpdateStudioRouteSchema: z.ZodObject<{
    identity: z.ZodOptional<z.ZodObject<{
        value: z.ZodString;
        slug: z.ZodString;
        code: z.ZodString;
    }, z.core.$strip>>;
    page: z.ZodOptional<z.ZodObject<{
        identity: z.ZodObject<{
            code: z.ZodString;
        }, z.core.$strip>;
    }, z.core.$strip>>;
    permissions: z.ZodOptional<z.ZodArray<z.ZodEnum<{
        guest: "guest";
        authenticated: "authenticated";
        admin: "admin";
        manager: "manager";
    }>>>;
    guards: z.ZodOptional<z.ZodOptional<z.ZodArray<z.ZodObject<{
        type: z.ZodEnum<{
            role: "role";
            auth: "auth";
            subscription: "subscription";
            feature: "feature";
        }>;
        condition: z.ZodOptional<z.ZodRecord<z.ZodString, z.ZodAny>>;
    }, z.core.$strip>>>>;
    metadata: z.ZodOptional<z.ZodOptional<z.ZodObject<{
        title_i18n: z.ZodOptional<z.ZodString>;
        description_i18n: z.ZodOptional<z.ZodString>;
        icon: z.ZodOptional<z.ZodString>;
        order: z.ZodOptional<z.ZodNumber>;
        group: z.ZodOptional<z.ZodString>;
        tags: z.ZodOptional<z.ZodArray<z.ZodString>>;
    }, z.core.$strip>>>;
    status: z.ZodOptional<z.ZodEnum<{
        active: "active";
        inactive: "inactive";
        draft: "draft";
        deprecated: "deprecated";
    }>>;
    created_at: z.ZodOptional<z.ZodOptional<z.ZodString>>;
    updated_at: z.ZodOptional<z.ZodOptional<z.ZodString>>;
    etag: z.ZodOptional<z.ZodOptional<z.ZodString>>;
    id: z.ZodString;
}, z.core.$strip>;
/**
 * Fonction de validation d'une route
 */
export declare function validateRoute(data: unknown): RouteValidationResult;
/**
 * Fonction de validation pour création
 */
export declare function validateRouteCreation(data: unknown): RouteValidationResult;
/**
 * Fonction de validation pour mise à jour
 */
export declare function validateRouteUpdate(data: unknown): RouteValidationResult;
/**
 * Type inféré du schéma
 */
export type StudioRouteInput = z.infer<typeof StudioRouteSchema>;
export type CreateStudioRouteInput = z.infer<typeof CreateStudioRouteSchema>;
export type UpdateStudioRouteInput = z.infer<typeof UpdateStudioRouteSchema>;
