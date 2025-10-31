import { Hono } from 'hono';
import { structuredLogger as logger } from '../core/logger/structuredLogger';
import * as signInExperienceService from '../logic/signInExperienceService';
import { 
  validateUpdateSignInExperience,
  validateGetSignInExperience, 
  validateCheckPasswordPolicy 
} from '../validators/signInExperienceValidation';

const router = new Hono();

/**
 * GET /sign-in-experience
 * Récupère les paramètres d'expérience de connexion par défaut
 */
router.get('/', validateGetSignInExperience(), async (c) => {
  try {
    logger.info('Récupération des paramètres d\'expérience de connexion par défaut', 'signInExperience');
    
    const result = await signInExperienceService.getDefaultSignInExperience();
    
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la récupération des paramètres d'expérience de connexion: ${error.message}`, 'signInExperience');
    return c.json({ error: error.message }, 400);
  }
});

/**
 * PATCH /sign-in-experience
 * Met à jour les paramètres d'expérience de connexion par défaut
 */
router.patch('/', validateUpdateSignInExperience(), async (c) => {
  try {
    logger.info('Mise à jour des paramètres d\'expérience de connexion par défaut', 'signInExperience');
    
    const data = c.get('validatedBody');
    
    const result = await signInExperienceService.updateDefaultSignInExperience(data);
    
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la mise à jour des paramètres d'expérience de connexion: ${error.message}`, 'signInExperience');
    return c.json({ error: error.message }, 400);
  }
});

/**
 * POST /sign-in-experience/password-policy
 * Vérifie si un mot de passe respecte la politique de mot de passe
 */
router.post('/password-policy', validateCheckPasswordPolicy(), async (c) => {
  try {
    logger.info('Vérification de la politique de mot de passe', 'signInExperience');
    
    const data = c.get('validatedBody');
    
    const result = await signInExperienceService.checkPasswordPolicy(data);
    
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la vérification de la politique de mot de passe: ${error.message}`, 'signInExperience');
    return c.json({ error: error.message }, 400);
  }
});

/**
 * POST /sign-in-experience/custom-ui-assets
 * Télécharge des assets UI personnalisés
 */
router.post('/custom-ui-assets', async (c) => {
  try {
    logger.info('Téléchargement d\'assets UI personnalisés', 'signInExperience');
    
    const formData = await c.req.formData();
    
    const result = await signInExperienceService.uploadCustomUIAssets(formData);
    
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors du téléchargement d'assets UI personnalisés: ${error.message}`, 'signInExperience');
    return c.json({ error: error.message }, 400);
  }
});

export default router; 
