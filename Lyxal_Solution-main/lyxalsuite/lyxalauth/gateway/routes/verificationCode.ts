import { Hono } from 'hono';
import { structuredLogger as logger } from '../core/logger/structuredLogger';
import * as verificationCodeService from '../logic/verificationCodeService';
import { validateZod } from '../validators/validateZod';
import { 
  requestVerificationCodeSchema,
  verifyVerificationCodeSchema
} from '../validators/schemas';

const router = new Hono();

/**
 * POST /verification-code
 * Demande et envoie un code de vérification
 */
router.post('/', validateZod({ body: requestVerificationCodeSchema }), async (c) => {
  try {
    logger.info('Demande d\'un code de vérification', 'verificationCode');
    
    const data = c.get('validatedBody');
    
    const result = await verificationCodeService.requestVerificationCode(data);
    
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la demande d'un code de vérification: ${error.message}`, 'verificationCode');
    return c.json({ error: error.message }, 400);
  }
});

/**
 * POST /verification-code/verify
 * Vérifie un code de vérification
 */
router.post('/verify', validateZod({ body: verifyVerificationCodeSchema }), async (c) => {
  try {
    logger.info('Vérification d\'un code', 'verificationCode');
    
    const data = c.get('validatedBody');
    
    const result = await verificationCodeService.verifyVerificationCode(data);
    
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la vérification d'un code: ${error.message}`, 'verificationCode');
    return c.json({ error: error.message }, 400);
  }
});

export default router;
