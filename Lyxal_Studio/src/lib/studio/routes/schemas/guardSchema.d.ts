import { z } from 'zod';
/**
 * Types de guards disponibles
 */
export declare const GuardTypeSchema: z.ZodEnum<{
    role: "role";
    auth: "auth";
    subscription: "subscription";
    feature: "feature";
}>;
/**
 * Structure d'un guard dans la base de données
 */
export declare const RouteGuardSchema: z.ZodObject<{
    id: z.ZodOptional<z.ZodString>;
    code: z.ZodString;
    name_i18n: z.ZodString;
    type: z.ZodEnum<{
        role: "role";
        auth: "auth";
        subscription: "subscription";
        feature: "feature";
    }>;
    description_i18n: z.ZodOptional<z.ZodString>;
    config_schema: z.ZodOptional<z.ZodRecord<z.ZodString, z.ZodAny>>;
    is_system: z.ZodDefault<z.ZodBoolean>;
    created_at: z.ZodOptional<z.ZodString>;
    updated_at: z.ZodOptional<z.ZodString>;
    etag: z.ZodOptional<z.ZodString>;
}, z.core.$strip>;
/**
 * Structure d'une instance de guard appliquée à une route
 */
export declare const RouteGuardInstanceSchema: z.ZodObject<{
    type: z.ZodEnum<{
        role: "role";
        auth: "auth";
        subscription: "subscription";
        feature: "feature";
    }>;
    condition: z.ZodOptional<z.ZodRecord<z.ZodString, z.ZodAny>>;
}, z.core.$strip>;
/**
 * Schéma pour la création d'un guard
 */
export declare const CreateRouteGuardSchema: z.ZodObject<{
    code: z.ZodString;
    type: z.ZodEnum<{
        role: "role";
        auth: "auth";
        subscription: "subscription";
        feature: "feature";
    }>;
    name_i18n: z.ZodString;
    description_i18n: z.ZodOptional<z.ZodString>;
    config_schema: z.ZodOptional<z.ZodRecord<z.ZodString, z.ZodAny>>;
    is_system: z.ZodDefault<z.ZodBoolean>;
}, z.core.$strip>;
/**
 * Schéma pour la mise à jour d'un guard
 */
export declare const UpdateRouteGuardSchema: z.ZodObject<{
    code: z.ZodOptional<z.ZodString>;
    name_i18n: z.ZodOptional<z.ZodString>;
    type: z.ZodOptional<z.ZodEnum<{
        role: "role";
        auth: "auth";
        subscription: "subscription";
        feature: "feature";
    }>>;
    description_i18n: z.ZodOptional<z.ZodOptional<z.ZodString>>;
    config_schema: z.ZodOptional<z.ZodOptional<z.ZodRecord<z.ZodString, z.ZodAny>>>;
    is_system: z.ZodOptional<z.ZodDefault<z.ZodBoolean>>;
    created_at: z.ZodOptional<z.ZodOptional<z.ZodString>>;
    updated_at: z.ZodOptional<z.ZodOptional<z.ZodString>>;
    etag: z.ZodOptional<z.ZodOptional<z.ZodString>>;
    id: z.ZodString;
}, z.core.$strip>;
/**
 * Conditions spécifiques pour chaque type de guard
 */
export declare const AuthGuardConditionSchema: z.ZodOptional<z.ZodObject<{}, z.core.$strip>>;
export declare const RoleGuardConditionSchema: z.ZodObject<{
    role: z.ZodString;
    require_all: z.ZodOptional<z.ZodBoolean>;
}, z.core.$strip>;
export declare const SubscriptionGuardConditionSchema: z.ZodObject<{
    plan: z.ZodString;
    feature: z.ZodOptional<z.ZodString>;
}, z.core.$strip>;
export declare const FeatureGuardConditionSchema: z.ZodObject<{
    feature: z.ZodString;
    version: z.ZodOptional<z.ZodString>;
}, z.core.$strip>;
/**
 * Schéma de validation des conditions selon le type
 */
export declare function validateGuardCondition(type: z.infer<typeof GuardTypeSchema>, condition: any): z.ZodSafeParseSuccess<Record<string, never> | undefined> | z.ZodSafeParseSuccess<{
    role: string;
    require_all?: boolean | undefined;
}> | z.ZodSafeParseSuccess<{
    plan: string;
    feature?: string | undefined;
}> | z.ZodSafeParseSuccess<{
    feature: string;
    version?: string | undefined;
}> | {
    success: boolean;
    error: Error;
};
/**
 * Contexte d'exécution d'un guard
 */
export interface GuardExecutionContext {
    user?: {
        id: string;
        roles?: string[];
        permissions?: string[];
        subscription?: {
            plan: string;
            features: string[];
        };
    };
    tenant?: {
        id: string;
        features?: string[];
        subscription?: string;
    };
    route?: {
        path: string;
        params: Record<string, string>;
        query: Record<string, string>;
    };
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
    metadata?: Record<string, any>;
}
/**
 * Fonction de validation d'un guard
 */
export declare function validateGuard(data: unknown): z.ZodSafeParseResult<{
    code: string;
    name_i18n: string;
    type: "role" | "auth" | "subscription" | "feature";
    is_system: boolean;
    id?: string | undefined;
    description_i18n?: string | undefined;
    config_schema?: Record<string, any> | undefined;
    created_at?: string | undefined;
    updated_at?: string | undefined;
    etag?: string | undefined;
}>;
/**
 * Fonction de validation d'une instance de guard
 */
export declare function validateGuardInstance(data: unknown): z.ZodSafeParseResult<{
    type: "role" | "auth" | "subscription" | "feature";
    condition?: Record<string, any> | undefined;
}>;
/**
 * Fonction de validation de création de guard
 */
export declare function validateGuardCreation(data: unknown): z.ZodSafeParseResult<{
    code: string;
    type: "role" | "auth" | "subscription" | "feature";
    name_i18n: string;
    is_system: boolean;
    description_i18n?: string | undefined;
    config_schema?: Record<string, any> | undefined;
}>;
/**
 * Types exportés
 */
export type GuardType = z.infer<typeof GuardTypeSchema>;
export type RouteGuard = z.infer<typeof RouteGuardSchema>;
export type RouteGuardInstance = z.infer<typeof RouteGuardInstanceSchema>;
export type CreateRouteGuard = z.infer<typeof CreateRouteGuardSchema>;
export type UpdateRouteGuard = z.infer<typeof UpdateRouteGuardSchema>;
export type AuthGuardCondition = z.infer<typeof AuthGuardConditionSchema>;
export type RoleGuardCondition = z.infer<typeof RoleGuardConditionSchema>;
export type SubscriptionGuardCondition = z.infer<typeof SubscriptionGuardConditionSchema>;
export type FeatureGuardCondition = z.infer<typeof FeatureGuardConditionSchema>;
