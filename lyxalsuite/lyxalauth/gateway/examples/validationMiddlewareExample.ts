/**
 * @file validationMiddlewareExample.ts
 * @description Exemple d'utilisation des schémas de validation avec middleware Hono
 */

import { Context } from 'hono';
import { AppError } from '../core/errors/AppError';
import { structuredLogger } from '../core/logger/structuredLogger';
import { createApplicationSchema } from '../validators/schemas/applicationSchemas';

const logger = structuredLogger.child({ module: 'validationExample' });

/**
 * Middleware de validation générique pour les requêtes avec body
 * @param schema Schéma Zod pour la validation
 */
export function validateBody(schema: any) {
  return async (c: Context, next: () => Promise<void>) => {
    try {
      const body = await c.req.json();
      const validatedData = schema.parse(body);
      c.set('validatedData', validatedData);
      logger.info('Données validées avec succès');
      await next();
    } catch (error) {
      logger.error('Validation échouée', { error });
      throw new AppError('Données invalides', 400, error);
    }
  };
}

/**
 * Exemple d'utilisation dans une route Hono:
 * 
 * ```typescript
 * import { Hono } from 'hono';
 * import { validateBody } from '../middleware/validateBody';
 * import { createApplicationSchema } from '../validators/schemas/applicationSchemas';
 * 
 * const router = new Hono();
 * 
 * router.post('/applications', validateBody(createApplicationSchema), async (c) => {
 *   const validatedData = c.get('validatedData');
 *   // La validation a réussi, les données sont disponibles dans validatedData
 *   // Traitement de la requête...
 *   return c.json({ success: true });
 * });
 * ```
 * 
 * Avec typage TypeScript:
 * 
 * ```typescript
 * import { z } from 'zod';
 * 
 * type CreateApplicationData = z.infer<typeof createApplicationSchema>;
 * 
 * router.post('/applications', validateBody(createApplicationSchema), async (c) => {
 *   const validatedData = c.get('validatedData') as CreateApplicationData;
 *   // validatedData est correctement typé
 *   console.log(validatedData.name); // OK
 *   console.log(validatedData.type); // OK - 'web' | 'native' | 'machine'
 * });
 * ```
 */

// Exemple d'utilisation avec plusieurs schémas dans la même route

/**
 * Middleware de validation pour les paramètres de requête
 * @param schema Schéma Zod pour la validation
 */
export function validateQuery(schema: any) {
  return async (c: Context, next: () => Promise<void>) => {
    try {
      const query = c.req.query();
      const validatedQuery = schema.parse(query);
      c.set('validatedQuery', validatedQuery);
      await next();
    } catch (error) {
      throw new AppError('Paramètres de requête invalides', 400, error);
    }
  };
}

/**
 * Exemple d'utilisation combinée:
 * 
 * ```typescript
 * import { z } from 'zod';
 * 
 * const querySchema = z.object({
 *   page: z.string().transform(Number).pipe(z.number().int().positive()),
 *   limit: z.string().transform(Number).pipe(z.number().int().positive().max(100))
 * });
 * 
 * router.post('/applications', 
 *   validateQuery(querySchema),
 *   validateBody(createApplicationSchema), 
 *   async (c) => {
 *     const validatedQuery = c.get('validatedQuery');
 *     const validatedBody = c.get('validatedData');
 *     
 *     // Traitement...
 *     
 *     return c.json({ success: true });
 *   }
 * );
 * ```
 */ 
