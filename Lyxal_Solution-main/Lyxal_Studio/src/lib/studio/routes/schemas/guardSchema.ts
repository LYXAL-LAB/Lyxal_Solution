import { z } from 'zod';

/**
 * Types de guards disponibles
 */
export const GuardTypeSchema = z.enum([
  'auth',
  'role',
  'subscription',
  'feature'
]);

/**
 * Structure d'un guard dans la base de données
 */
export const RouteGuardSchema = z.object({
  id: z.string().optional(),
  code: z.string()
    .regex(/^[a-z_]+$/, 'Guard code must be snake_case')
    .min(1, 'Guard code cannot be empty'),
  name_i18n: z.string()
    .min(1, 'Guard name cannot be empty'),
  type: GuardTypeSchema,
  description_i18n: z.string().optional(),
  config_schema: z.record(z.string(), z.any()).optional(), // Schéma JSON pour la configuration
  is_system: z.boolean().default(false),
  created_at: z.string().datetime().optional(),
  updated_at: z.string().datetime().optional(),
  etag: z.string().optional(),
});

/**
 * Structure d'une instance de guard appliquée à une route
 */
export const RouteGuardInstanceSchema = z.object({
  type: GuardTypeSchema,
  condition: z.record(z.string(), z.any()).optional(),
});

/**
 * Schéma pour la création d'un guard
 */
export const CreateRouteGuardSchema = RouteGuardSchema.omit({
  id: true,
  created_at: true,
  updated_at: true,
  etag: true,
});

/**
 * Schéma pour la mise à jour d'un guard
 */
export const UpdateRouteGuardSchema = RouteGuardSchema.partial().extend({
  id: z.string(),
});

/**
 * Conditions spécifiques pour chaque type de guard
 */

// Auth Guard - pas de condition spécifique
export const AuthGuardConditionSchema = z.object({}).optional();

// Role Guard
export const RoleGuardConditionSchema = z.object({
  role: z.string().min(1, 'Role cannot be empty'),
  require_all: z.boolean().optional(), // Pour multiple rôles
});

// Subscription Guard
export const SubscriptionGuardConditionSchema = z.object({
  plan: z.string().min(1, 'Plan cannot be empty'),
  feature: z.string().optional(),
});

// Feature Guard
export const FeatureGuardConditionSchema = z.object({
  feature: z.string().min(1, 'Feature cannot be empty'),
  version: z.string().optional(),
});

/**
 * Schéma de validation des conditions selon le type
 */
export function validateGuardCondition(type: z.infer<typeof GuardTypeSchema>, condition: any) {
  switch (type) {
    case 'auth':
      return AuthGuardConditionSchema.safeParse(condition);
    case 'role':
      return RoleGuardConditionSchema.safeParse(condition);
    case 'subscription':
      return SubscriptionGuardConditionSchema.safeParse(condition);
    case 'feature':
      return FeatureGuardConditionSchema.safeParse(condition);
    default:
      return { success: false, error: new Error(`Unknown guard type: ${type}`) };
  }
}

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
export function validateGuard(data: unknown) {
  return RouteGuardSchema.safeParse(data);
}

/**
 * Fonction de validation d'une instance de guard
 */
export function validateGuardInstance(data: unknown) {
  return RouteGuardInstanceSchema.safeParse(data);
}

/**
 * Fonction de validation de création de guard
 */
export function validateGuardCreation(data: unknown) {
  return CreateRouteGuardSchema.safeParse(data);
}

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
