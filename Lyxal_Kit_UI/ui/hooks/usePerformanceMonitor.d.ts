/**
 * Interface pour les métriques de performance
 */
interface PerformanceMetrics {
    /** Temps de chargement initial (ms) */
    loadTime: number;
    /** Temps jusqu'au premier contenu visible (ms) */
    firstContentfulPaint: number;
    /** Temps jusqu'au plus grand contenu visible (ms) */
    largestContentfulPaint: number;
    /** Délai de première interaction (ms) */
    firstInputDelay: number;
    /** Score de stabilité visuelle cumulative */
    cumulativeLayoutShift: number;
    /** Utilisation mémoire (MB) */
    memoryUsage: number;
    /** Nombre de re-renders */
    renderCount: number;
}
/**
 * Interface pour les options du hook
 */
interface UsePerformanceMonitorOptions {
    /** Activer le monitoring (défaut: true) */
    enabled?: boolean;
    /** Intervalle de collecte des métriques (ms, défaut: 5000) */
    interval?: number;
    /** Callback appelé à chaque collecte de métriques */
    onMetricsUpdate?: (metrics: Partial<PerformanceMetrics>) => void;
}
/**
 * Hook personnalisé pour le monitoring des performances
 * Collecte automatiquement les métriques Web Vitals et autres indicateurs
 *
 * @param options - Options de configuration du monitoring
 * @returns Métriques de performance et fonctions de contrôle
 */
export declare const usePerformanceMonitor: (options?: UsePerformanceMonitorOptions) => {
    /** Métriques de performance actuelles */
    metrics: Partial<PerformanceMetrics>;
    /** État du monitoring */
    isMonitoring: boolean;
    /** Démarre le monitoring */
    startMonitoring: () => () => void;
    /** Arrête le monitoring */
    stopMonitoring: () => void;
    /** Remet à zéro les métriques */
    resetMetrics: () => void;
    /** Obtient un rapport formaté */
    getPerformanceReport: () => string;
};
export {};
