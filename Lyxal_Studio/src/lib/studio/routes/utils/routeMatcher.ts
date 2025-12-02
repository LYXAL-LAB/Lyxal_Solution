import { StudioRoute } from '../../types/route';

/**
 * Paramètres extraits d'une URL
 */
export interface RouteMatchParams {
  [key: string]: string;
}

/**
 * Résultat du matching d'une route
 */
export interface RouteMatchResult {
  route: StudioRoute;
  params: RouteMatchParams;
  query: Record<string, string>;
  matched: boolean;
  score: number; // Score de correspondance (plus élevé = meilleure correspondance)
}

/**
 * Utilitaire pour le matching des routes
 * Gère la correspondance des URLs avec les patterns de routes définis
 */
export class RouteMatcher {
  /**
   * Trouve la route qui correspond à une URL donnée
   */
  static matchRoute(routes: StudioRoute[], url: string): RouteMatchResult | null {
    const { pathname, searchParams } = this.parseUrl(url);
    const query = Object.fromEntries(searchParams.entries());

    let bestMatch: RouteMatchResult | null = null;
    let bestScore = -1;

    for (const route of routes) {
      const match = this.matchRoutePattern(route, pathname);
      if (match.matched && match.score > bestScore) {
        bestMatch = {
          route,
          params: match.params,
          query,
          matched: true,
          score: match.score
        };
        bestScore = match.score;
      }
    }

    return bestMatch;
  }

  /**
   * Vérifie si une route correspond exactement à un pattern
   */
  static matchExactRoute(routes: StudioRoute[], pathname: string): StudioRoute | null {
    for (const route of routes) {
      if (route.identity.value === pathname && route.status === 'active') {
        return route;
      }
    }
    return null;
  }

  /**
   * Trouve toutes les routes qui correspondent à un préfixe
   */
  static findRoutesByPrefix(routes: StudioRoute[], prefix: string): StudioRoute[] {
    return routes.filter(route =>
      route.status === 'active' &&
      route.identity.value.startsWith(prefix)
    ).sort((a, b) => a.identity.value.localeCompare(b.identity.value));
  }

  /**
   * Parse une URL en pathname et search params
   */
  private static parseUrl(url: string): { pathname: string; searchParams: URLSearchParams } {
    try {
      // Si c'est une URL relative, la convertir en URL absolue
      const fullUrl = url.startsWith('http') ? url : `http://dummy${url}`;
      const urlObj = new URL(fullUrl);
      return {
        pathname: urlObj.pathname,
        searchParams: urlObj.searchParams
      };
    } catch (error) {
      // Fallback pour les URLs malformées
      const urlParts = url.split('?');
      const pathname = urlParts[0] || '/';
      const search = urlParts[1] || '';

      const searchParams = new URLSearchParams(search);
      return { pathname, searchParams };
    }
  }

  /**
   * Teste si une route correspond à un pattern
   */
  private static matchRoutePattern(route: StudioRoute, pathname: string): {
    matched: boolean;
    params: RouteMatchParams;
    score: number;
  } {
    const routePath = route.identity.value;

    // Correspondance exacte (score maximum)
    if (routePath === pathname) {
      return {
        matched: true,
        params: {},
        score: 100
      };
    }

    // Pour l'instant, on ne gère que les correspondances exactes
    // TODO: Implémenter les patterns dynamiques (/:id, /*, etc.)
    return {
      matched: false,
      params: {},
      score: 0
    };
  }

  /**
   * Normalise un pathname
   */
  static normalizePath(path: string): string {
    // S'assurer qu'il commence par /
    let normalized = path.startsWith('/') ? path : `/${path}`;

    // Supprimer les slash multiples
    normalized = normalized.replace(/\/+/g, '/');

    // Supprimer le slash final sauf pour la racine
    if (normalized.length > 1 && normalized.endsWith('/')) {
      normalized = normalized.slice(0, -1);
    }

    return normalized;
  }

  /**
   * Valide le format d'un pathname
   */
  static isValidPath(path: string): boolean {
    // Doit commencer par /
    if (!path.startsWith('/')) return false;

    // Pas de caractères interdits
    const invalidChars = /[<>[\]{}|\\^`]/;
    if (invalidChars.test(path)) return false;

    // Pas de espaces consécutifs
    if (/\s{2,}/.test(path)) return false;

    // Pas de segments vides (//)
    if (/\/\//.test(path)) return false;

    return true;
  }

  /**
   * Encode les paramètres pour une URL
   */
  static encodeParams(params: RouteMatchParams): string {
    const encoded: string[] = [];

    for (const [key, value] of Object.entries(params)) {
      encoded.push(`${encodeURIComponent(key)}=${encodeURIComponent(value)}`);
    }

    return encoded.join('&');
  }

  /**
   * Décode les paramètres depuis une query string
   */
  static decodeParams(queryString: string): RouteMatchParams {
    const params: RouteMatchParams = {};
    const searchParams = new URLSearchParams(queryString);

    for (const [key, value] of searchParams.entries()) {
      params[key] = value;
    }

    return params;
  }

  /**
   * Construit une URL complète à partir d'une route et de paramètres
   */
  static buildUrl(route: StudioRoute, params: RouteMatchParams = {}, query: Record<string, string> = {}): string {
    let url = route.identity.value;

    // Pour l'instant, pas de substitution de paramètres dynamiques
    // TODO: Implémenter la substitution /:id -> /123

    // Ajouter les query parameters
    const queryParts: string[] = [];

    for (const [key, value] of Object.entries(query)) {
      queryParts.push(`${encodeURIComponent(key)}=${encodeURIComponent(value)}`);
    }

    for (const [key, value] of Object.entries(params)) {
      queryParts.push(`${encodeURIComponent(key)}=${encodeURIComponent(value)}`);
    }

    if (queryParts.length > 0) {
      url += `?${queryParts.join('&')}`;
    }

    return url;
  }

  /**
   * Vérifie si deux URLs sont équivalentes
   */
  static areUrlsEquivalent(url1: string, url2: string): boolean {
    const normalizeUrl = (url: string) => {
      // Supprimer le hash et normaliser
      const urlObj = new URL(url.startsWith('http') ? url : `http://dummy${url}`);
      urlObj.hash = '';
      return urlObj.toString();
    };

    try {
      return normalizeUrl(url1) === normalizeUrl(url2);
    } catch {
      // Fallback pour les URLs malformées
      return this.normalizePath(url1) === this.normalizePath(url2);
    }
  }
}
