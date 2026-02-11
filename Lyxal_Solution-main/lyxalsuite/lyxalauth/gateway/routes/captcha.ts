/**
 * @file captcha.ts
 * @description Routes pour la gestion des fournisseurs de CAPTCHA
 */

import { Hono } from 'hono';
import { structuredLogger as logger } from '../core/logger/structuredLogger';
import * as captchaService from '../logic/captchaService';
import { validateZod } from '../validators/validateZod';
import { 
  updateCaptchaProviderSchema, 
  verifyCaptchaSchema 
} from '../validators/schemas/captchaSchemas';
import { validateUpdateCaptchaProvider, validateVerifyCaptcha } from '../validators/captchaValidation';

const router = new Hono();

/**
 * @route GET /captcha
 * @description Récupère les informations du fournisseur de CAPTCHA actuel
 * @access Public
 */
router.get('/', async (c) => {
  try {
    logger.info('Récupération des informations du fournisseur de CAPTCHA', 'captcha');
    const result = await captchaService.getCaptchaProvider();
    
    logger.debug('Informations du fournisseur de CAPTCHA récupérées avec succès', 'captcha', {
      provider: result?.provider || 'none'
    });
    
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la récupération du fournisseur de CAPTCHA: ${error.message}`, 'captcha', {
      error: error.message,
      stack: error.stack
    });
    return c.json({ 
      error: 'captcha_provider_error',
      message: error.message 
    }, 400);
  }
});

/**
 * @route PUT /captcha
 * @description Met à jour ou configure le fournisseur de CAPTCHA
 * @access Protected
 */
router.put('/', validateZod({ body: updateCaptchaProviderSchema }), async (c) => {
  try {
    const data = c.get('validatedBody');
    
    logger.info('Mise à jour du fournisseur de CAPTCHA', 'captcha', {
      provider: data.provider
    });
    
    const result = await captchaService.updateCaptchaProvider(data);
    
    logger.info('Fournisseur de CAPTCHA mis à jour avec succès', 'captcha');
    
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la mise à jour du fournisseur de CAPTCHA: ${error.message}`, 'captcha', {
      error: error.message,
      stack: error.stack
    });
    return c.json({ 
      error: 'captcha_update_error',
      message: error.message 
    }, 400);
  }
});

/**
 * @route DELETE /captcha
 * @description Supprime la configuration du fournisseur de CAPTCHA
 * @access Protected
 */
router.delete('/', async (c) => {
  try {
    logger.info('Suppression du fournisseur de CAPTCHA', 'captcha');
    
    const result = await captchaService.deleteCaptchaProvider();
    
    logger.info('Fournisseur de CAPTCHA supprimé avec succès', 'captcha');
    
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la suppression du fournisseur de CAPTCHA: ${error.message}`, 'captcha', {
      error: error.message,
      stack: error.stack
    });
    return c.json({ 
      error: 'captcha_delete_error',
      message: error.message 
    }, 400);
  }
});

/**
 * @route POST /captcha/verify
 * @description Vérifie une réponse CAPTCHA
 * @access Public
 */
router.post('/verify', validateZod({ body: verifyCaptchaSchema }), async (c) => {
  try {
    const data = c.get('validatedBody');
    
    logger.info('Vérification d\'une réponse CAPTCHA', 'captcha');
    
    const result = await captchaService.verifyCaptcha(data.response, data.remoteIp);
    
    logger.debug('Réponse CAPTCHA vérifiée', 'captcha', {
      success: result.success
    });
    
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la vérification du CAPTCHA: ${error.message}`, 'captcha', {
      error: error.message,
      stack: error.stack
    });
    return c.json({ 
      error: 'captcha_verification_error',
      message: error.message,
      success: false
    }, 400);
  }
});

export default router; 
