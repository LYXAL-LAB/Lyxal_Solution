import { Hono } from 'hono';
import { structuredLogger } from '../core/logger/structuredLogger';
import * as phrasesService from '../logic/phrasesService';
import { validateZod } from '../validators/validateZod';
import { z } from 'zod';

const router = new Hono();

/**
 * Schéma pour la validation des paramètres de requête pour obtenir les phrases localisées
 */
const getLocalizedPhrasesSchema = z.object({
  lang: z.string().optional()
});

/**
 * GET /phrases
 * Récupère les phrases localisées
 */
router.get('/', validateZod({ query: getLocalizedPhrasesSchema }), async (c) => {
  try {
    structuredLogger.info('Récupération des phrases localisées', 'phrases');
    
    const params = c.get('validatedQuery');
    
    const result = await phrasesService.getLocalizedPhrases(params);
    
    return c.json(result);
  } catch (error: any) {
    structuredLogger.error('Erreur lors de la récupération des phrases localisées', 'phrases', {
      error: error.message
    });
    return c.json({ error: error.message }, 400 as 400);
  }
});

export default router;
