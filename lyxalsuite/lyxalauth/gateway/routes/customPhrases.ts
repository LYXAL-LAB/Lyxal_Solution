import { Hono } from 'hono';
import { structuredLogger as logger } from '../core/logger/structuredLogger';
import * as phraseService from '../logic/phraseService';
import { validateZod } from '../validators/validateZod';
import { upsertCustomPhraseSchema } from '../validators/schemas/phraseSchemas';
import { validateUpsertCustomPhrase, validateUpsertCustomPhraseWithLanguage } from '../validators/phraseValidation';

const router = new Hono();

/**
 * GET /custom-phrases
 * Récupère toutes les phrases personnalisées
 */
router.get('/', async (c) => {
  try {
    logger.info('Récupération de toutes les phrases personnalisées', 'customPhrases');
    
    const result = await phraseService.getAllCustomPhrases();
    
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la récupération des phrases personnalisées: ${error.message}`, 'customPhrases');
    return c.json({ error: error.message }, 400);
  }
});

/**
 * GET /custom-phrases/:languageTag
 * Récupère les phrases personnalisées pour une langue spécifique
 */
router.get('/:languageTag', async (c) => {
  try {
    const languageTag = c.req.param('languageTag');
    logger.info(`Récupération des phrases personnalisées pour la langue ${languageTag}`, 'customPhrases');
    
    const result = await phraseService.getCustomPhrasesByLanguage(languageTag);
    
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la récupération des phrases personnalisées: ${error.message}`, 'customPhrases');
    return c.json({ error: error.message }, 400);
  }
});

/**
 * PUT /custom-phrases/:languageTag
 * Crée ou met à jour des phrases personnalisées pour une langue spécifique
 */
router.put('/:languageTag', validateZod({ body: upsertCustomPhraseSchema }), async (c) => {
  try {
    const languageTag = c.req.param('languageTag');
    logger.info(`Mise à jour des phrases personnalisées pour la langue ${languageTag}`, 'customPhrases');
    
    const data = c.get('validatedBody');
    const updatedData = {
      languageTag,
      translation: data.translation
    };
    
    const result = await phraseService.upsertCustomPhrases(updatedData);
    
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la mise à jour des phrases personnalisées: ${error.message}`, 'customPhrases');
    return c.json({ error: error.message }, 400);
  }
});

/**
 * DELETE /custom-phrases/:languageTag
 * Supprime les phrases personnalisées pour une langue spécifique
 */
router.delete('/:languageTag', async (c) => {
  try {
    const languageTag = c.req.param('languageTag');
    logger.info(`Suppression des phrases personnalisées pour la langue ${languageTag}`, 'customPhrases');
    
    const result = await phraseService.deleteCustomPhrases(languageTag);
    
    return c.json(result);
  } catch (error: any) {
    logger.error(`Erreur lors de la suppression des phrases personnalisées: ${error.message}`, 'customPhrases');
    return c.json({ error: error.message }, 400);
  }
});

export default router;
