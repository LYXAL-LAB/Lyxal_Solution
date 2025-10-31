/**
 * @file assetValidation.ts
 * @description Fonctions de validation pour les routes d'assets
 */

import { Context } from 'hono';
import { assetUploadSchema, AssetUpload } from './schemas/assetSchemas';
import { structuredLogger as logger } from '../core/logger/structuredLogger';

/**
 * Valide le téléchargement d'un asset
 * @param formData Les données du formulaire contenant le fichier
 * @returns Les données validées ou lance une erreur
 */
export const validateAssetUpload = async (formData: FormData): Promise<AssetUpload> => {
  const file = formData.get('file') as File;
  
  if (!file) {
    logger.error('Aucun fichier fourni dans la requête', 'assetValidation');
    throw new Error('Aucun fichier fourni');
  }
  
  const result = assetUploadSchema.parse({ file });
  return result;
}; 