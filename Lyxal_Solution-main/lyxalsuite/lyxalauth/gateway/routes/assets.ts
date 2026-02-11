import { Hono } from 'hono';
import * as assetService from '../logic/assetService';
import { structuredLogger as logger } from '../core/logger/structuredLogger';
import { validateAssetUpload } from '../validators/assetValidation';

const router = new Hono();

/**
 * GET /assets/service-status
 * Récupère le statut du service d'assets
 */
router.get('/service-status', async (c) => {
  try {
    logger.info('Récupération du statut du service d\'assets', 'assets');
    const result = await assetService.getAssetServiceStatus();
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la récupération du statut du service d'assets: ${error.message}`, 'assets');
    return c.json({ error: error.message }, 400);
  }
});

/**
 * POST /assets
 * Télécharge un asset vers Logto
 */
router.post('/', async (c) => {
  try {
    logger.info('Téléchargement d\'un asset', 'assets');
    
    // Récupérer le formData de la requête
    const formData = await c.req.formData();
    
    // Valider le formData avec la fonction de validation
    await validateAssetUpload(formData);
    
    // Créer un nouveau FormData pour l'envoi à Logto
    const validatedFormData = new FormData();
    validatedFormData.append('file', formData.get('file') as File);
    
    const result = await assetService.uploadAsset(validatedFormData);
    return c.json(result, 201);
  } catch (error: any) {
    logger.error(`Erreur lors du téléchargement d'un asset: ${error.message}`, 'assets');
    return c.json({ error: error.message }, 400);
  }
});

export default router; 
