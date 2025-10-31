/**
 * @file configSchemas.ts
 * @description Schémas de validation Zod pour les routes de configuration
 */

import { z } from 'zod';

/**
 * Schéma pour la mise à jour de la configuration de la console d'administration
 */
export const updateAdminConsoleConfigSchema = z.object({
  tenantId: z.string().min(1, 'L\'ID du tenant est requis').optional(),
  organizationId: z.string().min(1, 'L\'ID de l\'organisation est requis').optional(),
  adminConsoleConfig: z.record(z.unknown()).optional()
});

/**
 * Schéma pour la création ou mise à jour d'un personnalisateur JWT
 */
export const upsertJwtCustomizerSchema = z.object({
  targetId: z.string().min(1, 'L\'ID cible est requis'),
  script: z.string().min(1, 'Le script est requis'),
  isEnabled: z.boolean().optional()
});

/**
 * Schéma pour la mise à jour partielle d'un personnalisateur JWT
 */
export const patchJwtCustomizerSchema = z.object({
  script: z.string().min(1, 'Le script est requis').optional(),
  isEnabled: z.boolean().optional()
}).refine(
  data => Object.keys(data).length > 0,
  {
    message: 'Au moins un champ doit être fourni pour la mise à jour'
  }
);

/**
 * Schéma pour tester un personnalisateur JWT
 */
export const testJwtCustomizerSchema = z.object({
  script: z.string().min(1, 'Le script est requis'),
  baseUserClaims: z.record(z.unknown()),
  userClaims: z.record(z.unknown()).optional(),
  protectedUserClaims: z.record(z.unknown()).optional()
}); 