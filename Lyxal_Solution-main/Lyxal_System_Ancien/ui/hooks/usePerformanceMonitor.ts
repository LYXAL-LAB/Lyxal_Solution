import { useEffect, useRef, useState } from 'react';

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
export const usePerformanceMonitor = (options: UsePerformanceMonitorOptions = {}) => {
  const {
    enabled = true,
    interval = 5000,
    onMetricsUpdate
  } = options;

  const [metrics, setMetrics] = useState<Partial<PerformanceMetrics>>({});
  const [isMonitoring, setIsMonitoring] = useState(false);
  const renderCountRef = useRef(0);
  const intervalRef = useRef<NodeJS.Timeout | null>(null);

  // Incrémenter le compteur de renders
  useEffect(() => {
    renderCountRef.current += 1;
  });

  /**
   * Collecte les métriques de performance Web Vitals
   */
  const collectWebVitals = (): Partial<PerformanceMetrics> => {
    const navigation = performance.getEntriesByType('navigation')[0] as PerformanceNavigationTiming;
    const paint = performance.getEntriesByType('paint');
    
    const metrics: Partial<PerformanceMetrics> = {
      renderCount: renderCountRef.current
    };

    // Temps de chargement
    if (navigation) {
      metrics.loadTime = navigation.loadEventEnd - navigation.fetchStart;
    }

    // First Contentful Paint
    const fcp = paint.find(entry => entry.name === 'first-contentful-paint');
    if (fcp) {
      metrics.firstContentfulPaint = fcp.startTime;
    }

    // Utilisation mémoire (si disponible)
    if ('memory' in performance) {
      const memory = (performance as any).memory;
      metrics.memoryUsage = memory.usedJSHeapSize / (1024 * 1024); // Conversion en MB
    }

    return metrics;
  };

  /**
   * Collecte les métriques LCP via PerformanceObserver
   */
  const observeLCP = () => {
    if ('PerformanceObserver' in window) {
      try {
        const observer = new PerformanceObserver((list) => {
          const entries = list.getEntries();
          const lastEntry = entries[entries.length - 1];
          
          setMetrics(prev => ({
            ...prev,
            largestContentfulPaint: lastEntry.startTime
          }));
        });
        
        observer.observe({ entryTypes: ['largest-contentful-paint'] });
        return observer;
      } catch (error) {
        console.warn('LCP observation failed:', error);
      }
    }
    return null;
  };

  /**
   * Collecte les métriques FID via PerformanceObserver
   */
  const observeFID = () => {
    if ('PerformanceObserver' in window) {
      try {
        const observer = new PerformanceObserver((list) => {
          const entries = list.getEntries();
          entries.forEach((entry) => {
            const eventEntry = entry as PerformanceEventTiming;
            setMetrics(prev => ({
              ...prev,
              firstInputDelay: eventEntry.processingStart - eventEntry.startTime
            }));
          });
        });
        
        observer.observe({ entryTypes: ['first-input'] });
        return observer;
      } catch (error) {
        console.warn('FID observation failed:', error);
      }
    }
    return null;
  };

  /**
   * Collecte les métriques CLS via PerformanceObserver
   */
  const observeCLS = () => {
    if ('PerformanceObserver' in window) {
      try {
        let clsValue = 0;
        const observer = new PerformanceObserver((list) => {
          const entries = list.getEntries();
          entries.forEach((entry: any) => {
            if (!entry.hadRecentInput) {
              clsValue += entry.value;
              setMetrics(prev => ({
                ...prev,
                cumulativeLayoutShift: clsValue
              }));
            }
          });
        });
        
        observer.observe({ entryTypes: ['layout-shift'] });
        return observer;
      } catch (error) {
        console.warn('CLS observation failed:', error);
      }
    }
    return null;
  };

  /**
   * Démarre le monitoring des performances
   */
  const startMonitoring = () => {
    if (!enabled || isMonitoring) return () => {};

    setIsMonitoring(true);
    
    // Collecte initiale
    const initialMetrics = collectWebVitals();
    setMetrics(initialMetrics);
    onMetricsUpdate?.(initialMetrics);

    // Observers pour Web Vitals
    const lcpObserver = observeLCP();
    const fidObserver = observeFID();
    const clsObserver = observeCLS();

    // Collecte périodique
    intervalRef.current = setInterval(() => {
      const currentMetrics = collectWebVitals();
      setMetrics(prev => {
        const updatedMetrics = { ...prev, ...currentMetrics };
        onMetricsUpdate?.(updatedMetrics);
        return updatedMetrics;
      });
    }, interval);

    // Fonction de nettoyage
    const cleanup = () => {
      lcpObserver?.disconnect();
      fidObserver?.disconnect();
      clsObserver?.disconnect();
      if (intervalRef.current) {
        clearInterval(intervalRef.current);
      }
    };

    return cleanup;
  };

  /**
   * Arrête le monitoring des performances
   */
  const stopMonitoring = () => {
    setIsMonitoring(false);
    if (intervalRef.current) {
      clearInterval(intervalRef.current);
      intervalRef.current = null;
    }
  };

  /**
   * Remet à zéro les métriques
   */
  const resetMetrics = () => {
    setMetrics({});
    renderCountRef.current = 0;
  };

  /**
   * Obtient un rapport de performance formaté
   */
  const getPerformanceReport = (): string => {
    const report = [];
    
    if (metrics.loadTime) {
      report.push(`Temps de chargement: ${Math.round(metrics.loadTime)}ms`);
    }
    
    if (metrics.firstContentfulPaint) {
      report.push(`FCP: ${Math.round(metrics.firstContentfulPaint)}ms`);
    }
    
    if (metrics.largestContentfulPaint) {
      report.push(`LCP: ${Math.round(metrics.largestContentfulPaint)}ms`);
    }
    
    if (metrics.firstInputDelay) {
      report.push(`FID: ${Math.round(metrics.firstInputDelay)}ms`);
    }
    
    if (metrics.cumulativeLayoutShift) {
      report.push(`CLS: ${metrics.cumulativeLayoutShift.toFixed(3)}`);
    }
    
    if (metrics.memoryUsage) {
      report.push(`Mémoire: ${Math.round(metrics.memoryUsage)}MB`);
    }
    
    if (metrics.renderCount) {
      report.push(`Renders: ${metrics.renderCount}`);
    }
    
    return report.join(' | ');
  };

  // Démarrage automatique si activé
  useEffect(() => {
    if (enabled) {
      const cleanup = startMonitoring();
      return cleanup;
    }
    return () => {}; // Retourner une fonction vide si pas activé
  }, [enabled, interval]);

  // Nettoyage au démontage
  useEffect(() => {
    return () => {
      stopMonitoring();
    };
  }, []);

  return {
    /** Métriques de performance actuelles */
    metrics,
    /** État du monitoring */
    isMonitoring,
    /** Démarre le monitoring */
    startMonitoring,
    /** Arrête le monitoring */
    stopMonitoring,
    /** Remet à zéro les métriques */
    resetMetrics,
    /** Obtient un rapport formaté */
    getPerformanceReport
  };
}; 