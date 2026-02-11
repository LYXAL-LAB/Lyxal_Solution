import { Next } from 'hono';

// Interface pour les options de contrôle du cache
interface CacheControlOptions {
  maxAge?: number;        // Durée maximale de mise en cache en secondes
  sMaxAge?: number;       // Durée maximale de mise en cache pour les proxies partagés
  noCache?: boolean;      // Désactive la mise en cache
  noStore?: boolean;      // Empêche le stockage des données
  mustRevalidate?: boolean; // Force la revalidation
  public?: boolean;       // Autorise la mise en cache publique
  private?: boolean;      // Autorise la mise en cache privée uniquement
}

// Middleware de contrôle du cache
export const cacheControl = (options: CacheControlOptions) => {
  return async (c: any, next: Next) => {
    const directives: string[] = [];
    
    if (options.maxAge !== undefined) {
      directives.push(`max-age=${options.maxAge}`);
    }
    
    if (options.sMaxAge !== undefined) {
      directives.push(`s-maxage=${options.sMaxAge}`);
    }
    
    if (options.noCache) {
      directives.push('no-cache');
    }
    
    if (options.noStore) {
      directives.push('no-store');
    }
    
    if (options.mustRevalidate) {
      directives.push('must-revalidate');
    }
    
    if (options.public) {
      directives.push('public');
    }
    
    if (options.private) {
      directives.push('private');
    }
    
    // Si des directives no-store ou no-cache sont présentes, ajoutons les en-têtes de sécurité
    if (options.noStore || options.noCache) {
      c.header('Pragma', 'no-cache');
      c.header('Expires', '0');
    }
    
    c.header('Cache-Control', directives.join(', '));
    
    await next();
  };
}; 