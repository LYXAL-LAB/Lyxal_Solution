import { z } from 'zod';
import type { StudioRoute, RouteValidationResult, Permission, GuardType } from '../../types/route';

/**
 * Schéma pour l'identité d'une route
 */
const RouteIdentitySchema = z.object({
  value: z.string()
    .regex(/^\/.*/, 'Route path must start with /')
    .min(1, 'Route path cannot be empty'),
  slug: z.string()
    .regex(/^[a-z0-9-]+$/, 'Slug must be kebab-case (lowercase, numbers, hyphens)')
    .min(1, 'Slug cannot be empty'),
  code: z.string()
    .regex(/^[a-z_]+$/, 'Code must be snake_case (lowercase, underscores)')
    .min(1, 'Code cannot be empty'),
});

/**
 * Schéma pour la référence vers une page
 */
const RoutePageRefSchema = z.object({
  identity: z.object({
    code: z.string().min(1, 'Page code cannot be empty'),
  }),
});

/**
 * Schéma pour les permissions
 */
const PermissionSchema = z.enum(['guest', 'authenticated', 'admin', 'manager']);

/**
 * Schéma pour les types de guards
 */
const GuardTypeSchema = z.enum(['auth', 'role', 'subscription', 'feature']);

/**
 * Schéma pour un guard
 */
const RouteGuardSchema = z.object({
  type: GuardTypeSchema,
  condition: z.record(z.string(), z.any()).optional(),
});

/**
 * Schéma pour les métadonnées d'une route
 */
const RouteMetadataSchema = z.object({
  title_i18n: z.string().optional(),
  description_i18n: z.string().optional(),
  icon: z.string().optional(),
  order: z.number().int().min(0).optional(),
  group: z.string().optional(),
  tags: z.array(z.string()).optional(),
}).optional();

/**
 * Schéma pour le statut d'une route
 */
const RouteStatusSchema = z.enum(['active', 'inactive', 'draft', 'deprecated']);

/**
 * Schéma principal pour une route Studio
 */
export const StudioRouteSchema = z.object({
  id: z.string().optional(),
  identity: RouteIdentitySchema,
  page: RoutePageRefSchema,
  permissions: z.array(PermissionSchema).min(1, 'At least one permission required'),
  guards: z.array(RouteGuardSchema).optional(),
  metadata: RouteMetadataSchema,
  status: RouteStatusSchema,
  created_at: z.string().datetime().optional(),
  updated_at: z.string().datetime().optional(),
  etag: z.string().optional(),
});

/**
 * Schéma pour la création d'une route (sans id et timestamps)
 */
export const CreateStudioRouteSchema = StudioRouteSchema.omit({
  id: true,
  created_at: true,
  updated_at: true,
  etag: true,
});

/**
 * Schéma pour la mise à jour d'une route (champs optionnels)
 */
export const UpdateStudioRouteSchema = StudioRouteSchema.partial().extend({
  id: z.string(),
});

/**
 * Fonction de validation d'une route
 */
export function validateRoute(data: unknown): RouteValidationResult {
  const result = StudioRouteSchema.safeParse(data);

  if (result.success) {
    return {
      success: true,
      data: result.data,
    };
  } else {
    return {
      success: false,
      errors: result.error.issues.map((err: any) => `${err.path.join('.')}: ${err.message}`),
    };
  }
}

/**
 * Fonction de validation pour création
 */
export function validateRouteCreation(data: unknown): RouteValidationResult {
  const result = CreateStudioRouteSchema.safeParse(data);

  if (result.success) {
    return {
      success: true,
      data: result.data as StudioRoute,
    };
  } else {
    return {
      success: false,
      errors: result.error.issues.map((err: any) => `${err.path.join('.')}: ${err.message}`),
    };
  }
}

/**
 * Fonction de validation pour mise à jour
 */
export function validateRouteUpdate(data: unknown): RouteValidationResult {
  const result = UpdateStudioRouteSchema.safeParse(data);

  if (result.success) {
    return {
      success: true,
      data: result.data as StudioRoute,
    };
  } else {
    return {
      success: false,
      errors: result.error.issues.map((err: any) => `${err.path.join('.')}: ${err.message}`),
    };
  }
}

/**
 * Type inféré du schéma
 */
export type StudioRouteInput = z.infer<typeof StudioRouteSchema>;
export type CreateStudioRouteInput = z.infer<typeof CreateStudioRouteSchema>;
export type UpdateStudioRouteInput = z.infer<typeof UpdateStudioRouteSchema>;
