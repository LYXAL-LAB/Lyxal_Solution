import { StudioRoute } from '../../types/route';
import { RouteService } from '../../../../services/RouteService';
import { routeRegistry } from './RouteRegistry';

/**
 * État de chargement des routes
 */
export interface RouteLoaderState {
  isLoading: boolean;
  isLoaded: boolean;
  lastLoadTime: number | null;
  error: Error | null;
  routeCount: number;
}

/**
 * Options de chargement
 */
export interface RouteLoadOptions {
  forceRefresh?: boolean;
  backgroundLoad?: boolean;
  onProgress?: (loaded: number, total: number) => void;
  timeout?: number;
}

/**
 * Résultat de chargement
 */
export interface RouteLoadResult {
  routes: StudioRoute[];
  fromCache: boolean;
  loadTime: number;
  error?: Error;
}

/**
 * Chargeur de routes spécialisé
 * Gère le chargement intelligent des routes depuis la DB avec cache et optimisation
 */
export class RouteLoader {
  private state: RouteLoaderState;
  private loadingPromise: Promise<RouteLoadResult> | null = null;

  constructor() {
    this.state = {
      isLoading: false,
      isLoaded: false,
      lastLoadTime: null,
      error: null,
      routeCount: 0
    };
  }

  /**
   * Charge toutes les routes actives
   */
  async loadActiveRoutes(options: RouteLoadOptions = {}): Promise<RouteLoadResult> {
    const {
      forceRefresh = false,
      backgroundLoad = false,
      onProgress,
      timeout = 30000
    } = options;

    // Si déjà en cours de chargement et pas en arrière-plan, attendre
    if (this.loadingPromise && !backgroundLoad) {
      console.log('[RouteLoader] ⚠️ Load already in progress, waiting...');
      return await this.loadingPromise;
    }

    // Créer la promesse de chargement
    this.loadingPromise = this.performLoad(forceRefresh, timeout);

    try {
      const result = await this.loadingPromise;

      // Mettre à jour l'état
      this.state.isLoaded = true;
      this.state.lastLoadTime = Date.now();
      this.state.error = result.error || null;
      this.state.routeCount = result.routes.length;

      if (result.error) {
        console.error('[RouteLoader] ❌ Load failed:', result.error);
      } else {
        console.log(`[RouteLoader] ✅ Loaded ${result.routes.length} routes in ${result.loadTime}ms (${result.fromCache ? 'from cache' : 'from DB'})`);
      }

      return result;
    } catch (error) {
      this.state.error = error instanceof Error ? error : new Error('Unknown load error');
      throw error;
    } finally {
      this.loadingPromise = null;
      this.state.isLoading = false;
    }
  }

  /**
   * Précharge les routes en arrière-plan
   */
  async preloadRoutes(): Promise<void> {
    if (this.state.isLoaded && !this.needsRefresh()) {
      console.log('[RouteLoader] ℹ️ Routes already loaded and fresh');
      return;
    }

    console.log('[RouteLoader] 🔄 Preloading routes in background...');
    try {
      await this.loadActiveRoutes({
        backgroundLoad: true,
        timeout: 15000 // Timeout plus court pour le preload
      });
    } catch (error) {
      console.warn('[RouteLoader] ⚠️ Background preload failed:', error);
      // Ne pas throw pour ne pas casser le flux principal
    }
  }

  /**
   * Charge une route spécifique par code
   */
  async loadRouteByCode(code: string, options: RouteLoadOptions = {}): Promise<StudioRoute | null> {
    const { forceRefresh = false } = options;

    console.log(`[RouteLoader] 🔍 Loading route by code: ${code}`);

    try {
      const route = await routeRegistry.getRouteByCode(code);

      if (route) {
        console.log(`[RouteLoader] ✅ Found route: ${code}`);
        return route;
      }

      // Si pas dans le cache et pas de refresh forcé, essayer la DB directement
      if (!forceRefresh) {
        console.log(`[RouteLoader] 🔄 Loading from DB: ${code}`);
        return await RouteService.getRouteByCode(code);
      }

      return null;
    } catch (error) {
      console.error(`[RouteLoader] ❌ Failed to load route ${code}:`, error);
      return null;
    }
  }

  /**
   * Charge une route par chemin
   */
  async loadRouteByPath(path: string, options: RouteLoadOptions = {}): Promise<StudioRoute | null> {
    const { forceRefresh = false } = options;

    console.log(`[RouteLoader] 🔍 Loading route by path: ${path}`);

    try {
      const route = await routeRegistry.getRouteByPath(path);

      if (route) {
        console.log(`[RouteLoader] ✅ Found route: ${path}`);
        return route;
      }

      // Si pas dans le cache, essayer la DB directement
      if (!forceRefresh) {
        console.log(`[RouteLoader] 🔄 Loading from DB: ${path}`);
        return await RouteService.getRouteByPath(path);
      }

      return null;
    } catch (error) {
      console.error(`[RouteLoader] ❌ Failed to load route ${path}:`, error);
      return null;
    }
  }

  /**
   * Rafraîchit manuellement le cache
   */
  async refreshCache(): Promise<RouteLoadResult> {
    console.log('[RouteLoader] 🔄 Refreshing route cache...');
    return await this.loadActiveRoutes({ forceRefresh: true });
  }

  /**
   * Vérifie si les routes ont besoin d'être rechargées
   */
  needsRefresh(): boolean {
    if (!this.state.lastLoadTime) return true;

    // Recharger si plus de 5 minutes
    const CACHE_DURATION = 5 * 60 * 1000; // 5 minutes
    return Date.now() - this.state.lastLoadTime > CACHE_DURATION;
  }

  /**
   * Obtient l'état actuel du loader
   */
  getState(): RouteLoaderState {
    return { ...this.state };
  }

  /**
   * Obtient les statistiques du cache
   */
  getCacheStats(): any {
    return routeRegistry.getStats();
  }

  /**
   * Nettoie le cache et réinitialise l'état
   */
  clearCache(): void {
    routeRegistry.invalidateAll();
    this.state = {
      isLoading: false,
      isLoaded: false,
      lastLoadTime: null,
      error: null,
      routeCount: 0
    };
    console.log('[RouteLoader] 🗑️ Cache cleared');
  }

  // === MÉTHODES PRIVÉES ===

  private async performLoad(forceRefresh: boolean, timeout: number): Promise<RouteLoadResult> {
    const startTime = Date.now();
    this.state.isLoading = true;

    try {
      // Configuration du timeout
      const timeoutPromise = new Promise<never>((_, reject) => {
        setTimeout(() => reject(new Error(`Route loading timeout after ${timeout}ms`)), timeout);
      });

      // Chargement des routes
      const loadPromise = routeRegistry.getActiveRoutes(forceRefresh);
      const routes = await Promise.race([loadPromise, timeoutPromise]);

      const loadTime = Date.now() - startTime;

      return {
        routes,
        fromCache: !forceRefresh && routeRegistry.getStats().cacheHits > 0,
        loadTime
      };

    } catch (error) {
      const loadTime = Date.now() - startTime;

      return {
        routes: [],
        fromCache: false,
        loadTime,
        error: error instanceof Error ? error : new Error('Unknown load error')
      };
    }
  }
}

// Instance globale du loader
export const routeLoader = new RouteLoader();
