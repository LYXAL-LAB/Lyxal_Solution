import { StudioRoute, RouteCacheConfig } from '../../types/route';
import { RouteService } from '../../../../services/RouteService';

/**
 * Configuration par défaut du cache
 */
const DEFAULT_CACHE_CONFIG: RouteCacheConfig = {
  ttl: 5 * 60 * 1000, // 5 minutes
  maxEntries: 1000,
  cleanupStrategy: 'lru'
};

/**
 * Entrée de cache avec métadonnées
 */
interface CacheEntry {
  route: StudioRoute;
  timestamp: number;
  accessCount: number;
  lastAccessed: number;
}

/**
 * Statistiques du cache
 */
interface CacheStats {
  totalEntries: number;
  activeEntries: number;
  cacheHits: number;
  cacheMisses: number;
  evictions: number;
  avgLoadTime: number;
  lastCleanup: number;
}

/**
 * Registre centralisé pour la gestion des routes avec cache intelligent
 * Optimise les accès à la base de données tout en maintenant la fraîcheur des données
 */
export class RouteRegistry {
  private cache = new Map<string, CacheEntry>();
  private config: RouteCacheConfig;
  private stats: CacheStats;
  private cleanupInterval: NodeJS.Timeout | null = null;

  constructor(config: Partial<RouteCacheConfig> = {}) {
    this.config = { ...DEFAULT_CACHE_CONFIG, ...config };
    this.stats = {
      totalEntries: 0,
      activeEntries: 0,
      cacheHits: 0,
      cacheMisses: 0,
      evictions: 0,
      avgLoadTime: 0,
      lastCleanup: Date.now()
    };

    // Démarrage du nettoyage automatique
    this.startCleanupInterval();
  }

  /**
   * Récupère une route par son code depuis le cache ou la DB
   */
  async getRouteByCode(code: string): Promise<StudioRoute | null> {
    const cached = this.getFromCache(code);
    if (cached) {
      console.log(`[RouteRegistry] ✅ Cache hit for route: ${code}`);
      this.stats.cacheHits++;
      return cached.route;
    }

    console.log(`[RouteRegistry] ❌ Cache miss for route: ${code}`);
    this.stats.cacheMisses++;

    try {
      const startTime = Date.now();
      const route = await RouteService.getRouteByCode(code);
      const loadTime = Date.now() - startTime;

      // Mise à jour des statistiques de performance
      this.updateLoadTimeStats(loadTime);

      if (route) {
        this.setInCache(code, route);
      }

      return route;
    } catch (error) {
      console.error(`[RouteRegistry] Failed to load route ${code}:`, error);
      return null;
    }
  }

  /**
   * Récupère une route par son chemin depuis le cache ou la DB
   */
  async getRouteByPath(path: string): Promise<StudioRoute | null> {
    // Recherche d'abord dans le cache par chemin
    const cached = this.getFromCacheByPath(path);
    if (cached) {
      console.log(`[RouteRegistry] ✅ Cache hit for path: ${path}`);
      this.stats.cacheHits++;
      return cached.route;
    }

    console.log(`[RouteRegistry] ❌ Cache miss for path: ${path}`);
    this.stats.cacheMisses++;

    try {
      const startTime = Date.now();
      const route = await RouteService.getRouteByPath(path);
      const loadTime = Date.now() - startTime;

      this.updateLoadTimeStats(loadTime);

      if (route) {
        this.setInCache(route.identity.code, route);
      }

      return route;
    } catch (error) {
      console.error(`[RouteRegistry] Failed to load route by path ${path}:`, error);
      return null;
    }
  }

  /**
   * Récupère toutes les routes actives avec cache intelligent
   */
  async getActiveRoutes(forceRefresh = false): Promise<StudioRoute[]> {
    // Vérifier si on peut utiliser le cache
    if (!forceRefresh && this.hasValidCache()) {
      console.log('[RouteRegistry] ✅ Using cached active routes');
      this.stats.cacheHits++;
      return this.getActiveRoutesFromCache();
    }

    console.log('[RouteRegistry] ❌ Loading active routes from DB');
    this.stats.cacheMisses++;

    try {
      const startTime = Date.now();
      const routes = await RouteService.getActiveRoutes();
      const loadTime = Date.now() - startTime;

      this.updateLoadTimeStats(loadTime);

      // Mettre à jour le cache
      this.updateActiveRoutesCache(routes);

      console.log(`[RouteRegistry] ✅ Loaded ${routes.length} active routes`);
      return routes;
    } catch (error) {
      console.error('[RouteRegistry] Failed to load active routes:', error);

      // En cas d'erreur, retourner le cache si disponible
      if (this.hasValidCache()) {
        console.warn('[RouteRegistry] ⚠️ Using stale cache due to DB error');
        return this.getActiveRoutesFromCache();
      }

      throw error;
    }
  }

  /**
   * Invalide le cache pour une route spécifique
   */
  invalidateRoute(code: string): void {
    const entry = this.cache.get(code);
    if (entry) {
      this.cache.delete(code);
      this.stats.activeEntries--;
      console.log(`[RouteRegistry] 🗑️ Invalidated cache for route: ${code}`);
    }
  }

  /**
   * Invalide tout le cache
   */
  invalidateAll(): void {
    const previousCount = this.stats.activeEntries;
    this.cache.clear();
    this.stats.activeEntries = 0;
    console.log(`[RouteRegistry] 🗑️ Invalidated all cache (${previousCount} entries)`);
  }

  /**
   * Met à jour une route dans le cache
   */
  updateRouteInCache(route: StudioRoute): void {
    this.setInCache(route.identity.code, route);
    console.log(`[RouteRegistry] ✏️ Updated cache for route: ${route.identity.code}`);
  }

  /**
   * Supprime une route du cache
   */
  removeRouteFromCache(code: string): void {
    this.invalidateRoute(code);
  }

  /**
   * Récupère les statistiques du cache
   */
  getStats(): CacheStats & { hitRate: number } {
    const totalRequests = this.stats.cacheHits + this.stats.cacheMisses;
    const hitRate = totalRequests > 0 ? (this.stats.cacheHits / totalRequests) * 100 : 0;

    return {
      ...this.stats,
      hitRate
    };
  }

  /**
   * Force un nettoyage du cache
   */
  forceCleanup(): void {
    this.performCleanup();
  }

  /**
   * Nettoie les ressources
   */
  destroy(): void {
    if (this.cleanupInterval) {
      clearInterval(this.cleanupInterval);
      this.cleanupInterval = null;
    }
    this.invalidateAll();
  }

  // === MÉTHODES PRIVÉES ===

  private getFromCache(code: string): CacheEntry | null {
    const entry = this.cache.get(code);
    if (!entry) return null;

    // Vérifier si l'entrée n'est pas expirée
    if (Date.now() - entry.timestamp > this.config.ttl) {
      this.cache.delete(code);
      this.stats.activeEntries--;
      this.stats.evictions++;
      return null;
    }

    // Mettre à jour les statistiques d'accès
    entry.accessCount++;
    entry.lastAccessed = Date.now();

    return entry;
  }

  private getFromCacheByPath(path: string): CacheEntry | null {
    // Recherche linéaire par chemin (peu optimal mais nécessaire)
    for (const [code, entry] of this.cache.entries()) {
      if (entry.route.identity.value === path) {
        return this.getFromCache(code); // Utilise la logique de cache normale
      }
    }
    return null;
  }

  private setInCache(code: string, route: StudioRoute): void {
    // Nettoyer si nécessaire avant d'ajouter
    this.ensureCapacity();

    const entry: CacheEntry = {
      route,
      timestamp: Date.now(),
      accessCount: 0,
      lastAccessed: Date.now()
    };

    this.cache.set(code, entry);
    this.stats.activeEntries++;
    this.stats.totalEntries++;
  }

  private hasValidCache(): boolean {
    if (this.cache.size === 0) return false;

    // Vérifier si le cache le plus ancien n'est pas trop vieux
    const oldestEntry = Math.min(...Array.from(this.cache.values()).map(e => e.timestamp));
    return Date.now() - oldestEntry < this.config.ttl;
  }

  private getActiveRoutesFromCache(): StudioRoute[] {
    const activeRoutes: StudioRoute[] = [];

    for (const entry of this.cache.values()) {
      if (entry.route.status === 'active') {
        // Vérifier si toujours valide
        if (Date.now() - entry.timestamp <= this.config.ttl) {
          activeRoutes.push(entry.route);
        }
      }
    }

    // Trier par ordre puis par chemin
    return activeRoutes.sort((a, b) => {
      const orderA = a.metadata?.order ?? 999;
      const orderB = b.metadata?.order ?? 999;
      if (orderA !== orderB) return orderA - orderB;
      return a.identity.value.localeCompare(b.identity.value);
    });
  }

  private updateActiveRoutesCache(routes: StudioRoute[]): void {
    // Invalider les anciennes routes actives qui ne sont plus actives
    for (const [code, entry] of this.cache.entries()) {
      const stillActive = routes.some(r => r.identity.code === code && r.status === 'active');
      if (!stillActive) {
        this.cache.delete(code);
        this.stats.activeEntries--;
      }
    }

    // Mettre à jour/ajouter les nouvelles routes actives
    for (const route of routes) {
      if (route.status === 'active') {
        this.setInCache(route.identity.code, route);
      }
    }
  }

  private ensureCapacity(): void {
    if (this.stats.activeEntries >= this.config.maxEntries) {
      this.performCleanup();
    }
  }

  private performCleanup(): void {
    if (this.config.cleanupStrategy === 'lru') {
      this.cleanupLRU();
    } else {
      this.cleanupFIFO();
    }

    this.stats.lastCleanup = Date.now();
  }

  private cleanupLRU(): void {
    // Least Recently Used - supprimer les moins récemment utilisés
    const entries = Array.from(this.cache.entries());
    entries.sort(([, a], [, b]) => a.lastAccessed - b.lastAccessed);

    const toRemove = Math.ceil(entries.length * 0.2); // Supprimer 20%
    for (let i = 0; i < toRemove && i < entries.length; i++) {
      const [code] = entries[i];
      this.cache.delete(code);
      this.stats.activeEntries--;
      this.stats.evictions++;
    }
  }

  private cleanupFIFO(): void {
    // First In First Out - supprimer les plus anciens
    const entries = Array.from(this.cache.entries());
    entries.sort(([, a], [, b]) => a.timestamp - b.timestamp);

    const toRemove = Math.ceil(entries.length * 0.2); // Supprimer 20%
    for (let i = 0; i < toRemove && i < entries.length; i++) {
      const [code] = entries[i];
      this.cache.delete(code);
      this.stats.activeEntries--;
      this.stats.evictions++;
    }
  }

  private updateLoadTimeStats(loadTime: number): void {
    // Moyenne mobile des temps de chargement
    const alpha = 0.1; // Facteur de lissage
    this.stats.avgLoadTime = this.stats.avgLoadTime * (1 - alpha) + loadTime * alpha;
  }

  private startCleanupInterval(): void {
    // Nettoyage automatique toutes les 10 minutes
    this.cleanupInterval = setInterval(() => {
      this.performCleanup();
    }, 10 * 60 * 1000);
  }
}

// Instance globale du registry
export const routeRegistry = new RouteRegistry();
