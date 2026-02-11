import { performance } from 'perf_hooks';

/**
 * Interface pour les entrées de cache
 */
interface CacheEntry<T> {
  data: T;
  timestamp: number;
  ttl: number;
  hits: number;
  lastAccessed: number;
}

/**
 * Métriques de performance du cache
 */
export interface CacheMetrics {
  totalHits: number;
  totalMisses: number;
  hitRatio: number;
  totalEntries: number;
  totalMemoryUsage: number;
  avgResponseTime: number;
}

/**
 * Configuration du cache
 */
export interface CacheConfig {
  defaultTTL: number; // en millisecondes
  maxEntries: number;
  cleanupInterval: number; // en millisecondes
  enableMetrics: boolean;
}

/**
 * Cache intelligent avec TTL et métriques de performance
 */
export class IntelligentCache {
  private cache = new Map<string, CacheEntry<any>>();
  private metrics = {
    hits: 0,
    misses: 0,
    totalResponseTime: 0,
    requestCount: 0
  };
  private cleanupTimer: NodeJS.Timeout | null = null;
  private config: CacheConfig;

  constructor(config: Partial<CacheConfig> = {}) {
    this.config = {
      defaultTTL: 5 * 60 * 1000, // 5 minutes par défaut
      maxEntries: 1000,
      cleanupInterval: 60 * 1000, // 1 minute
      enableMetrics: true,
      ...config
    };

    this.startCleanupTimer();
  }

  /**
   * Récupérer une valeur du cache
   */
  get<T>(key: string): T | null {
    const startTime = performance.now();
    const entry = this.cache.get(key);

    if (!entry) {
      this.metrics.misses++;
      this.updateResponseTime(startTime);
      return null;
    }

    const now = Date.now();
    if (now - entry.timestamp > entry.ttl) {
      // Entrée expirée
      this.cache.delete(key);
      this.metrics.misses++;
      this.updateResponseTime(startTime);
      return null;
    }

    // Mise à jour des métriques d'accès
    entry.hits++;
    entry.lastAccessed = now;
    this.metrics.hits++;
    this.updateResponseTime(startTime);

    return entry.data as T;
  }

  /**
   * Stocker une valeur dans le cache
   */
  set<T>(key: string, data: T, customTTL?: number): void {
    const now = Date.now();
    const ttl = customTTL || this.config.defaultTTL;

    // Vérifier la limite d'entrées
    if (this.cache.size >= this.config.maxEntries && !this.cache.has(key)) {
      this.evictLeastUsed();
    }

    const entry: CacheEntry<T> = {
      data,
      timestamp: now,
      ttl,
      hits: 0,
      lastAccessed: now
    };

    this.cache.set(key, entry);
  }

  /**
   * Supprimer une entrée du cache
   */
  delete(key: string): boolean {
    return this.cache.delete(key);
  }

  /**
   * Vider le cache
   */
  clear(): void {
    this.cache.clear();
    this.resetMetrics();
  }

  /**
   * Invalider les entrées par pattern
   */
  invalidatePattern(pattern: string): number {
    const regex = new RegExp(pattern);
    let count = 0;

    for (const key of this.cache.keys()) {
      if (regex.test(key)) {
        this.cache.delete(key);
        count++;
      }
    }

    return count;
  }

  /**
   * Récupérer les métriques de performance
   */
  getMetrics(): CacheMetrics {
    const totalRequests = this.metrics.hits + this.metrics.misses;
    
    return {
      totalHits: this.metrics.hits,
      totalMisses: this.metrics.misses,
      hitRatio: totalRequests > 0 ? this.metrics.hits / totalRequests : 0,
      totalEntries: this.cache.size,
      totalMemoryUsage: this.estimateMemoryUsage(),
      avgResponseTime: this.metrics.requestCount > 0 
        ? this.metrics.totalResponseTime / this.metrics.requestCount 
        : 0
    };
  }

  /**
   * Wrapper pour les fonctions avec cache automatique
   */
  async cached<T>(
    key: string, 
    fn: () => Promise<T>, 
    ttl?: number
  ): Promise<T> {
    // Vérifier le cache
    const cached = this.get<T>(key);
    if (cached !== null) {
      return cached;
    }

    // Exécuter la fonction et mettre en cache
    const result = await fn();
    this.set(key, result, ttl);
    return result;
  }

  /**
   * Nettoyage automatique des entrées expirées
   */
  private cleanup(): void {
    const now = Date.now();
    const expiredKeys: string[] = [];

    for (const [key, entry] of this.cache.entries()) {
      if (now - entry.timestamp > entry.ttl) {
        expiredKeys.push(key);
      }
    }

    for (const key of expiredKeys) {
      this.cache.delete(key);
    }

    console.log(`🧹 Cache cleanup: ${expiredKeys.length} entrées expirées supprimées`);
  }

  /**
   * Éviction de l'entrée la moins utilisée (LRU)
   */
  private evictLeastUsed(): void {
    let lruKey: string | null = null;
    let lruScore = Infinity;

    for (const [key, entry] of this.cache.entries()) {
      // Score basé sur les hits et l'âge de l'accès
      const score = entry.hits / (Date.now() - entry.lastAccessed + 1);
      if (score < lruScore) {
        lruScore = score;
        lruKey = key;
      }
    }

    if (lruKey) {
      this.cache.delete(lruKey);
      console.log(`🗑️ Éviction LRU: ${lruKey}`);
    }
  }

  /**
   * Démarrer le timer de nettoyage automatique
   */
  private startCleanupTimer(): void {
    if (this.cleanupTimer) {
      clearInterval(this.cleanupTimer);
    }

    this.cleanupTimer = setInterval(() => {
      this.cleanup();
    }, this.config.cleanupInterval);
  }

  /**
   * Arrêter le timer de nettoyage
   */
  public stopCleanupTimer(): void {
    if (this.cleanupTimer) {
      clearInterval(this.cleanupTimer);
      this.cleanupTimer = null;
    }
  }

  /**
   * Mettre à jour les métriques de temps de réponse
   */
  private updateResponseTime(startTime: number): void {
    if (this.config.enableMetrics) {
      const responseTime = performance.now() - startTime;
      this.metrics.totalResponseTime += responseTime;
      this.metrics.requestCount++;
    }
  }

  /**
   * Estimer l'utilisation mémoire
   */
  private estimateMemoryUsage(): number {
    let size = 0;
    for (const [key, entry] of this.cache.entries()) {
      size += key.length * 2; // UTF-16
      size += JSON.stringify(entry).length * 2;
    }
    return size;
  }

  /**
   * Réinitialiser les métriques
   */
  private resetMetrics(): void {
    this.metrics = {
      hits: 0,
      misses: 0,
      totalResponseTime: 0,
      requestCount: 0
    };
  }

  /**
   * Destructor pour nettoyer les ressources
   */
  public destroy(): void {
    this.stopCleanupTimer();
    this.clear();
  }
}

/**
 * Instance globale du cache pour les métadonnées
 */
export const metadataCache = new IntelligentCache({
  defaultTTL: 5 * 60 * 1000, // 5 minutes pour les métadonnées
  maxEntries: 500,
  cleanupInterval: 60 * 1000,
  enableMetrics: true
});

/**
 * Instance globale du cache pour les requêtes
 */
export const queryCache = new IntelligentCache({
  defaultTTL: 2 * 60 * 1000, // 2 minutes pour les requêtes
  maxEntries: 1000,
  cleanupInterval: 30 * 1000,
  enableMetrics: true
}); 