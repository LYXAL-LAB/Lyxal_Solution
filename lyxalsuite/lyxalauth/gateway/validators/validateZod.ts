/**
 * @file validateZod.ts
 * @description Utilitaire de validation Zod pour les endpoints de l'API
 */

import { Context, Next } from 'hono';
import { z } from 'zod';

/**
 * Types de validation supportés
 */
export enum ValidationType {
  BODY = 'body',
  QUERY = 'query',
  PARAMS = 'params',
}

/**
 * Options de validation
 */
export interface ValidationOptions {
  body?: z.ZodSchema;
  query?: z.ZodSchema;
  params?: z.ZodSchema;
}

// Étendre l'interface Context de Hono pour inclure nos propriétés validées
declare module 'hono' {
  interface ContextVariableMap {
    validatedBody: any;
    validatedQuery: any;
    validatedParams: any;
  }
}

/**
 * Middleware de validation Zod pour les requêtes HTTP
 * 
 * @param options Options de validation avec schémas Zod pour body, query et/ou params
 * @returns Middleware Hono
 */
export function validateZod(options: ValidationOptions) {
  return async (c: Context, next: Next) => {
    try {
      // Valider le corps de la requête si un schéma est fourni
      if (options.body) {
        const body = await c.req.json().catch(() => ({}));
        const validatedBody = options.body.parse(body);
        c.set('validatedBody', validatedBody);
      }

      // Valider les paramètres de requête si un schéma est fourni
      if (options.query) {
        const query = Object.fromEntries(new URL(c.req.url).searchParams);
        const validatedQuery = options.query.parse(query);
        c.set('validatedQuery', validatedQuery);
      }

      // Valider les paramètres d'URL si un schéma est fourni
      if (options.params) {
        const params = c.req.param();
        const validatedParams = options.params.parse(params);
        c.set('validatedParams', validatedParams);
      }

      await next();
    } catch (error) {
      // Gérer les erreurs Zod
      if (error instanceof z.ZodError) {
        const issues = error.errors.map(issue => ({
          path: issue.path.join('.'),
          message: issue.message,
          code: issue.code
        }));
        
        return c.json({
          error: 'validation_error',
          error_description: 'Validation des données échouée',
          issues
        }, 400);
      }
      
      throw error;
    }
  };
}