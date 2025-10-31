import { Hono } from 'hono';
import { structuredLogger as logger } from '../core/logger/structuredLogger';
import * as verificationByPasswordService from '../logic/verificationByPasswordService';
import { 
  validateCreateVerificationByPassword,
  validateCreateVerificationByCode,
  validateVerifyCode,
  validateCreateSocialVerification,
  validateVerifySocialVerification
} from '../validators/verificationValidation';

const router = new Hono();

/**
 * POST /verification/by-password
 * Crée un enregistrement par mot de passe
 */
router.post('/by-password', validateCreateVerificationByPassword(), async (c) => {
  try {
    logger.info('Création d\'un enregistrement par mot de passe', 'verification');
    
    const data = c.get('validatedBody');
    
    const result = await verificationByPasswordService.createVerificationByPassword(data);
    
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la création d'un enregistrement par mot de passe: ${error.message}`, 'verification');
    return c.json({ error: error.message }, 400);
  }
});

/**
 * POST /verification/by-code
 * Crée un enregistrement par code de vérification
 */
router.post('/by-code', validateCreateVerificationByCode(), async (c) => {
  try {
    logger.info('Création d\'un enregistrement par code de vérification', 'verification');
    
    const data = c.get('validatedBody');
    
    const result = await verificationByPasswordService.createVerificationByCode(data);
    
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la création d'un enregistrement par code de vérification: ${error.message}`, 'verification');
    return c.json({ error: error.message }, 400);
  }
});

/**
 * POST /verification/verify-code
 * Vérifie un code de vérification
 */
router.post('/verify-code', validateVerifyCode(), async (c) => {
  try {
    logger.info('Vérification d\'un code', 'verification');
    
    const data = c.get('validatedBody');
    
    const result = await verificationByPasswordService.verifyCode(data);
    
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la vérification d'un code: ${error.message}`, 'verification');
    return c.json({ error: error.message }, 400);
  }
});

/**
 * POST /verification/social
 * Crée un enregistrement de vérification sociale
 */
router.post('/social', validateCreateSocialVerification(), async (c) => {
  try {
    logger.info('Création d\'un enregistrement de vérification sociale', 'verification');
    
    const data = c.get('validatedBody');
    
    const result = await verificationByPasswordService.createSocialVerification(data);
    
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la création d'un enregistrement de vérification sociale: ${error.message}`, 'verification');
    return c.json({ error: error.message }, 400);
  }
});

/**
 * POST /verification/social/verify
 * Vérifie un enregistrement de vérification sociale
 */
router.post('/social/verify', validateVerifySocialVerification(), async (c) => {
  try {
    logger.info('Vérification d\'un enregistrement social', 'verification');
    
    const data = c.get('validatedBody');
    
    const result = await verificationByPasswordService.verifySocialVerification(data);
    
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la vérification d'un enregistrement social: ${error.message}`, 'verification');
    return c.json({ error: error.message }, 400);
  }
});

export default router;
