/**
 * @file assetSchemas.ts
 * @description Schémas de validation Zod pour les routes d'assets
 */

import { z } from 'zod';

/**
 * Validation pour le téléchargement de fichier
 */
export const assetUploadSchema = z.object({
  file: z.instanceof(File, { message: 'Un fichier valide est requis' })
});

/**
 * Type inféré du schéma de téléchargement d'asset
 */
export type AssetUpload = z.infer<typeof assetUploadSchema>; 