import { performance } from 'perf_hooks';
import { EventEmitter } from 'events';

/**
 * Métriques de performance pour les requêtes SurrealDB
 */
export interface QueryMetrics {
  query: string;
  duration: number;
  success: boolean;
  timestamp: number;
  namespace: string;
  database: string;
  cached: boolean;
  resultSize?: number;
  error?: string;
}

/**
 * Métriques agrégées de performance
 */
export interface AggregatedMetrics {
  totalQueries: number;
  successfulQueries: number;
  failedQueries: number;
  avgResponseTime: number;
  minResponseTime: number;
  maxResponseTime: number;
  cacheHitRatio: number;
  queryCount: { [namespace: string]: number };
  errorCount: { [error: string]: number };
  slowQueries: QueryMetrics[];
  recentPerformance: number[];
}

/**
 * Configuration du monitoring
 */
export interface MonitoringConfig {
  enableDetailedLogging: boolean;
  slowQueryThreshold: number; // en millisecondes
  metricsRetentionTime: number; // en millisecondes
  maxStoredQueries: number;
  alertThresholds: {
    errorRate: number; // pourcentage
    avgResponseTime: number; // millisecondes
    cacheHitRatio: number; // pourcentage
  };
}

/**
 * Moniteur de performance pour SurrealDB
 */
export class PerformanceMonitor extends EventEmitter {
  private metrics: QueryMetrics[] = [];
  private config: MonitoringConfig;
  private alertTimer: NodeJS.Timeout | null = null;

  constructor(config: Partial<MonitoringConfig> = {}) {
    super();
    
    this.config = {
      enableDetailedLogging: false,
      slowQueryThreshold: 1000, // 1 seconde
      metricsRetentionTime: 24 * 60 * 60 * 1000, // 24 heures
      maxStoredQueries: 10000,
      alertThresholds: {
        errorRate: 5, // 5%
        avgResponseTime: 500, // 500ms
        cacheHitRatio: 70 // 70%
      },
      ...config
    };

    this.startPeriodicCleanup();
    this.startPeriodicAlerts();
  }

  /**
   * Enregistrer une nouvelle métrique de requête
   */
  recordQuery(metrics: Omit<QueryMetrics, 'timestamp'>): void {
    const fullMetrics: QueryMetrics = {
      ...metrics,
      timestamp: Date.now()
    };

    this.metrics.push(fullMetrics);

    // Limiter le nombre de métriques stockées
    if (this.metrics.length > this.config.maxStoredQueries) {
      this.metrics = this.metrics.slice(-this.config.maxStoredQueries);
    }

    // Log détaillé si activé
    if (this.config.enableDetailedLogging) {
      this.logQueryMetrics(fullMetrics);
    }

    // Vérifier les requêtes lentes
    if (metrics.duration > this.config.slowQueryThreshold) {
      this.emit('slowQuery', fullMetrics);
      console.warn(`🐌 Requête lente détectée (${metrics.duration}ms): ${metrics.query.substring(0, 100)}...`);
    }

    // Vérifier les erreurs
    if (!metrics.success) {
      this.emit('queryError', fullMetrics);
    }
  }

  /**
   * Wrapper pour mesurer automatiquement les performances d'une fonction
   */
  async measureQuery<T>(
    query: string,
    namespace: string,
    database: string,
    fn: () => Promise<T>,
    cached: boolean = false
  ): Promise<T> {
    const startTime = performance.now();
    let success = true;
    let error: string | undefined;
    let result: T;
    let resultSize: number | undefined;

    try {
      result = await fn();
      
      // Estimer la taille du résultat
      try {
        resultSize = JSON.stringify(result).length;
      } catch {
        resultSize = 0;
      }

      return result;
    } catch (err) {
      success = false;
      error = err instanceof Error ? err.message : String(err);
      throw err;
    } finally {
      const duration = performance.now() - startTime;
      
      this.recordQuery({
        query: query.length > 200 ? query.substring(0, 200) + '...' : query,
        duration,
        success,
        namespace,
        database,
        cached,
        ...(resultSize !== undefined && { resultSize }),
        ...(error && { error })
      });
    }
  }

  /**
   * Obtenir les métriques agrégées
   */
  getAggregatedMetrics(timeWindow?: number): AggregatedMetrics {
    const now = Date.now();
    const windowStart = timeWindow ? now - timeWindow : 0;
    
    const relevantMetrics = this.metrics.filter(m => m.timestamp >= windowStart);
    
    if (relevantMetrics.length === 0) {
      return this.getEmptyMetrics();
    }

    const durations = relevantMetrics.map(m => m.duration);
    const successfulQueries = relevantMetrics.filter(m => m.success);
    const cachedQueries = relevantMetrics.filter(m => m.cached);
    
    const queryCount: { [namespace: string]: number } = {};
    const errorCount: { [error: string]: number } = {};
    
    relevantMetrics.forEach(m => {
      queryCount[m.namespace] = (queryCount[m.namespace] || 0) + 1;
      if (!m.success && m.error) {
        errorCount[m.error] = (errorCount[m.error] || 0) + 1;
      }
    });

    const slowQueries = relevantMetrics
      .filter(m => m.duration > this.config.slowQueryThreshold)
      .sort((a, b) => b.duration - a.duration)
      .slice(0, 10);

    // Performance récente (dernière heure par intervalles de 5 minutes)
    const recentPerformance = this.getRecentPerformance(60 * 60 * 1000, 5 * 60 * 1000);

    return {
      totalQueries: relevantMetrics.length,
      successfulQueries: successfulQueries.length,
      failedQueries: relevantMetrics.length - successfulQueries.length,
      avgResponseTime: durations.reduce((a, b) => a + b, 0) / durations.length,
      minResponseTime: Math.min(...durations),
      maxResponseTime: Math.max(...durations),
      cacheHitRatio: relevantMetrics.length > 0 ? (cachedQueries.length / relevantMetrics.length) * 100 : 0,
      queryCount,
      errorCount,
      slowQueries,
      recentPerformance
    };
  }

  /**
   * Obtenir les métriques de performance récente
   */
  private getRecentPerformance(timeWindow: number, intervalSize: number): number[] {
    const now = Date.now();
    const intervals = Math.ceil(timeWindow / intervalSize);
    const performance: number[] = [];

    for (let i = 0; i < intervals; i++) {
      const intervalStart = now - (i + 1) * intervalSize;
      const intervalEnd = now - i * intervalSize;
      
      const intervalMetrics = this.metrics.filter(m => 
        m.timestamp >= intervalStart && 
        m.timestamp < intervalEnd &&
        m.success
      );

      const avgTime = intervalMetrics.length > 0
        ? intervalMetrics.reduce((sum, m) => sum + m.duration, 0) / intervalMetrics.length
        : 0;

      performance.unshift(avgTime);
    }

    return performance;
  }

  /**
   * Générer un rapport de performance
   */
  generateReport(timeWindow?: number): string {
    const metrics = this.getAggregatedMetrics(timeWindow);
    const timeWindowStr = timeWindow ? `dernières ${Math.round(timeWindow / (60 * 1000))} minutes` : 'toute la période';

    return `
📊 RAPPORT DE PERFORMANCE SURREALDB (${timeWindowStr})
═══════════════════════════════════════════════════════

📈 STATISTIQUES GÉNÉRALES
• Total requêtes: ${metrics.totalQueries}
• Requêtes réussies: ${metrics.successfulQueries} (${((metrics.successfulQueries / metrics.totalQueries) * 100).toFixed(1)}%)
• Requêtes échouées: ${metrics.failedQueries} (${((metrics.failedQueries / metrics.totalQueries) * 100).toFixed(1)}%)

⚡ TEMPS DE RÉPONSE
• Temps moyen: ${metrics.avgResponseTime.toFixed(2)}ms
• Temps minimum: ${metrics.minResponseTime.toFixed(2)}ms
• Temps maximum: ${metrics.maxResponseTime.toFixed(2)}ms

🚀 CACHE
• Taux de hit cache: ${metrics.cacheHitRatio.toFixed(1)}%

📊 RÉPARTITION PAR NAMESPACE
${Object.entries(metrics.queryCount)
  .map(([ns, count]) => `• ${ns}: ${count} requêtes`)
  .join('\n')}

${metrics.failedQueries > 0 ? `
❌ ERREURS PRINCIPALES
${Object.entries(metrics.errorCount)
  .sort(([,a], [,b]) => b - a)
  .slice(0, 5)
  .map(([error, count]) => `• ${error}: ${count} occurrences`)
  .join('\n')}
` : ''}

${metrics.slowQueries.length > 0 ? `
🐌 REQUÊTES LES PLUS LENTES
${metrics.slowQueries
  .slice(0, 5)
  .map(q => `• ${q.duration.toFixed(2)}ms: ${q.query}`)
  .join('\n')}
` : ''}
`;
  }

  /**
   * Vérifier les alertes de performance
   */
  checkAlerts(): string[] {
    const alerts: string[] = [];
    const metrics = this.getAggregatedMetrics(60 * 60 * 1000); // Dernière heure

    if (metrics.totalQueries === 0) return alerts;

    const errorRate = (metrics.failedQueries / metrics.totalQueries) * 100;
    
    if (errorRate > this.config.alertThresholds.errorRate) {
      alerts.push(`🚨 Taux d'erreur élevé: ${errorRate.toFixed(1)}% (seuil: ${this.config.alertThresholds.errorRate}%)`);
    }

    if (metrics.avgResponseTime > this.config.alertThresholds.avgResponseTime) {
      alerts.push(`🚨 Temps de réponse élevé: ${metrics.avgResponseTime.toFixed(2)}ms (seuil: ${this.config.alertThresholds.avgResponseTime}ms)`);
    }

    if (metrics.cacheHitRatio < this.config.alertThresholds.cacheHitRatio) {
      alerts.push(`🚨 Taux de cache faible: ${metrics.cacheHitRatio.toFixed(1)}% (seuil: ${this.config.alertThresholds.cacheHitRatio}%)`);
    }

    return alerts;
  }

  /**
   * Log des métriques de requête
   */
  private logQueryMetrics(metrics: QueryMetrics): void {
    const status = metrics.success ? '✅' : '❌';
    const cache = metrics.cached ? '🚀' : '🔄';
    console.log(
      `${status} ${cache} [${metrics.namespace}/${metrics.database}] ` +
      `${metrics.duration.toFixed(2)}ms: ${metrics.query.substring(0, 100)}...`
    );
  }

  /**
   * Métriques vides par défaut
   */
  private getEmptyMetrics(): AggregatedMetrics {
    return {
      totalQueries: 0,
      successfulQueries: 0,
      failedQueries: 0,
      avgResponseTime: 0,
      minResponseTime: 0,
      maxResponseTime: 0,
      cacheHitRatio: 0,
      queryCount: {},
      errorCount: {},
      slowQueries: [],
      recentPerformance: []
    };
  }

  /**
   * Nettoyage périodique des anciennes métriques
   */
  private startPeriodicCleanup(): void {
    setInterval(() => {
      const cutoffTime = Date.now() - this.config.metricsRetentionTime;
      const originalLength = this.metrics.length;
      this.metrics = this.metrics.filter(m => m.timestamp > cutoffTime);
      
      if (originalLength !== this.metrics.length) {
        console.log(`🧹 Monitoring cleanup: ${originalLength - this.metrics.length} anciennes métriques supprimées`);
      }
    }, 60 * 60 * 1000); // Nettoyage toutes les heures
  }

  /**
   * Vérification périodique des alertes
   */
  private startPeriodicAlerts(): void {
    this.alertTimer = setInterval(() => {
      const alerts = this.checkAlerts();
      if (alerts.length > 0) {
        this.emit('performanceAlert', alerts);
        alerts.forEach(alert => console.warn(alert));
      }
    }, 5 * 60 * 1000); // Vérification toutes les 5 minutes
  }

  /**
   * Arrêter le monitoring
   */
  destroy(): void {
    if (this.alertTimer) {
      clearInterval(this.alertTimer);
    }
    this.removeAllListeners();
    this.metrics = [];
  }
}

/**
 * Instance globale du moniteur de performance
 */
export const performanceMonitor = new PerformanceMonitor({
  enableDetailedLogging: false,
  slowQueryThreshold: 1000,
  metricsRetentionTime: 24 * 60 * 60 * 1000,
  maxStoredQueries: 5000,
  alertThresholds: {
    errorRate: 5,
    avgResponseTime: 500,
    cacheHitRatio: 70
  }
}); 