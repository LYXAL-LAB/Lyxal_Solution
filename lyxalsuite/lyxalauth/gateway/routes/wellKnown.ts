import { Hono } from 'hono';
import { structuredLogger } from '../core/logger/structuredLogger';
import * as wellKnownService from '../logic/wellKnownService';
import { 
  validateGetFullSignInExperience,
  validateGetWellKnownLocalizedPhrases
} from '../validators/wellKnownValidation';

const router = new Hono();

/**
 * GET /.well-known/sign-in-exp
 * Récupère la configuration complète de l'expérience de connexion
 */
router.get('/sign-in-exp', async (c) => {
  try {
    structuredLogger.info(
      'Récupération de la configuration complète de l\'expérience de connexion', 
      'wellKnown',
      { route: '/.well-known/sign-in-exp' }
    );
    
    const params = validateGetFullSignInExperience(c.req.query());
    
    const result = await wellKnownService.getFullSignInExperience(params);
    
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error(
      `Erreur lors de la récupération de la configuration complète de l'expérience de connexion: ${error.message}`,
      'wellKnown',
      { route: '/.well-known/sign-in-exp', error }
    );
    return c.json({ error: error.message }, 400);
  }
});

/**
 * GET /.well-known/phrases
 * Récupère les phrases localisées
 */
router.get('/phrases', async (c) => {
  try {
    structuredLogger.info(
      'Récupération des phrases localisées via endpoint well-known',
      'wellKnown',
      { route: '/.well-known/phrases' }
    );
    
    const params = validateGetWellKnownLocalizedPhrases(c.req.query());
    
    const result = await wellKnownService.getWellKnownLocalizedPhrases(params);
    
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error(
      `Erreur lors de la récupération des phrases localisées via endpoint well-known: ${error.message}`,
      'wellKnown',
      { route: '/.well-known/phrases', error }
    );
    return c.json({ error: error.message }, 400);
  }
});

/**
 * GET /.well-known/management-api-swagger.json
 * Récupère la documentation Swagger JSON de l'API de gestion
 */
router.get('/management-api-swagger.json', async (c) => {
  try {
    structuredLogger.info(
      'Récupération de la documentation Swagger JSON de l\'API de gestion via endpoint well-known',
      'wellKnown',
      { route: '/.well-known/management-api-swagger.json' }
    );
    
    const result = await wellKnownService.getWellKnownManagementApiSwaggerJson();
    
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error(
      `Erreur lors de la récupération de la documentation Swagger de l'API de gestion via endpoint well-known: ${error.message}`,
      'wellKnown',
      { route: '/.well-known/management-api-swagger.json', error }
    );
    return c.json({ error: error.message }, 400);
  }
});

/**
 * GET /.well-known/experience-api-swagger.json
 * Récupère la documentation Swagger JSON de l'API d'expérience
 */
router.get('/experience-api-swagger.json', async (c) => {
  try {
    structuredLogger.info(
      'Récupération de la documentation Swagger JSON de l\'API d\'expérience via endpoint well-known',
      'wellKnown',
      { route: '/.well-known/experience-api-swagger.json' }
    );
    
    const result = await wellKnownService.getWellKnownExperienceApiSwaggerJson();
    
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error(
      `Erreur lors de la récupération de la documentation Swagger de l'API d'expérience via endpoint well-known: ${error.message}`,
      'wellKnown',
      { route: '/.well-known/experience-api-swagger.json', error }
    );
    return c.json({ error: error.message }, 400);
  }
});

/**
 * GET /.well-known/user-api-swagger.json
 * Récupère la documentation Swagger JSON de l'API utilisateur
 */
router.get('/user-api-swagger.json', async (c) => {
  try {
    structuredLogger.info(
      'Récupération de la documentation Swagger JSON de l\'API utilisateur via endpoint well-known',
      'wellKnown',
      { route: '/.well-known/user-api-swagger.json' }
    );
    
    const result = await wellKnownService.getWellKnownUserApiSwaggerJson();
    
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error(
      `Erreur lors de la récupération de la documentation Swagger de l'API utilisateur via endpoint well-known: ${error.message}`,
      'wellKnown',
      { route: '/.well-known/user-api-swagger.json', error }
    );
    return c.json({ error: error.message }, 400);
  }
});

export default router; 
