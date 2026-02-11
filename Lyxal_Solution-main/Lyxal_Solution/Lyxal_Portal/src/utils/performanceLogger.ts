 /**
 * Utilitaire pour logger les métriques de performance
 * Formatage et affichage des données de performance
 */

// Utilise le type du hook pour éviter les conflits
type PerformanceMetrics = Record<string, number>;
  
  /**
   * Formate et affiche les métriques de performance dans la console
   * @param metrics - Les métriques de performance à afficher
   */
  export function logPerformanceMetrics(metrics: Partial<PerformanceMetrics>): void {
    if (process.env.NODE_ENV !== 'development') return;
  
    console.group('🚀 Métriques de Performance LYXAL');
    
    // Core Web Vitals
    if (metrics.fcp) {
      const fcpScore = metrics.fcp < 1800 ? '✅' : metrics.fcp < 3000 ? '⚠️' : '❌';
      console.log(`${fcpScore} First Contentful Paint: ${metrics.fcp.toFixed(2)}ms`);
    }
    
    if (metrics.lcp) {
      const lcpScore = metrics.lcp < 2500 ? '✅' : metrics.lcp < 4000 ? '⚠️' : '❌';
      console.log(`${lcpScore} Largest Contentful Paint: ${metrics.lcp.toFixed(2)}ms`);
    }
    
    if (metrics.fid) {
      const fidScore = metrics.fid < 100 ? '✅' : metrics.fid < 300 ? '⚠️' : '❌';
      console.log(`${fidScore} First Input Delay: ${metrics.fid.toFixed(2)}ms`);
    }
    
    if (metrics.cls) {
      const clsScore = metrics.cls < 0.1 ? '✅' : metrics.cls < 0.25 ? '⚠️' : '❌';
      console.log(`${clsScore} Cumulative Layout Shift: ${metrics.cls.toFixed(3)}`);
    }
    
    // Métriques supplémentaires
    if (metrics.ttfb) {
      const ttfbScore = metrics.ttfb < 800 ? '✅' : metrics.ttfb < 1800 ? '⚠️' : '❌';
      console.log(`${ttfbScore} Time to First Byte: ${metrics.ttfb.toFixed(2)}ms`);
    }
    
    if (metrics.renderTime) {
      console.log(`⏱️ Render Time: ${metrics.renderTime.toFixed(2)}ms`);
    }
    
    if (metrics.domLoadTime) {
      console.log(`📄 DOM Load Time: ${metrics.domLoadTime.toFixed(2)}ms`);
    }
    
    if (metrics.resourceLoadTime) {
      console.log(`📦 Resource Load Time: ${metrics.resourceLoadTime.toFixed(2)}ms`);
    }
    
    // Recommandations
    const recommendations = getPerformanceRecommendations(metrics);
    if (recommendations.length > 0) {
      console.group('💡 Recommandations');
      recommendations.forEach(rec => console.log(`• ${rec}`));
      console.groupEnd();
    }
    
    console.groupEnd();
  }
  
  /**
   * Génère des recommandations basées sur les métriques
   * @param metrics - Les métriques de performance
   * @returns Liste des recommandations
   */
  function getPerformanceRecommendations(metrics: Partial<PerformanceMetrics>): string[] {
    const recommendations: string[] = [];
    
    if (metrics.fcp && metrics.fcp > 3000) {
      recommendations.push('Optimiser le First Contentful Paint (lazy loading, code splitting)');
    }
    
    if (metrics.lcp && metrics.lcp > 4000) {
      recommendations.push('Optimiser le Largest Contentful Paint (images, fonts)');
    }
    
    if (metrics.fid && metrics.fid > 300) {
      recommendations.push('Réduire le First Input Delay (optimiser JavaScript)');
    }
    
    if (metrics.cls && metrics.cls > 0.25) {
      recommendations.push('Améliorer le Cumulative Layout Shift (tailles fixes)');
    }
    
    if (metrics.ttfb && metrics.ttfb > 1800) {
      recommendations.push('Optimiser le Time to First Byte (CDN, cache)');
    }
    
    return recommendations;
  }
  
  /**
   * Crée un rapport de performance formaté
   * @param metrics - Les métriques de performance
   * @returns Rapport formaté
   */
  export function createPerformanceReport(metrics: Partial<PerformanceMetrics>): string {
    const report = [
      '📊 RAPPORT DE PERFORMANCE LYXAL',
      '================================',
      ''
    ];
    
    if (metrics.fcp) report.push(`FCP: ${metrics.fcp.toFixed(2)}ms`);
    if (metrics.lcp) report.push(`LCP: ${metrics.lcp.toFixed(2)}ms`);
    if (metrics.fid) report.push(`FID: ${metrics.fid.toFixed(2)}ms`);
    if (metrics.cls) report.push(`CLS: ${metrics.cls.toFixed(3)}`);
    if (metrics.ttfb) report.push(`TTFB: ${metrics.ttfb.toFixed(2)}ms`);
    
    const recommendations = getPerformanceRecommendations(metrics);
    if (recommendations.length > 0) {
      report.push('', 'Recommandations:', ...recommendations.map(r => `• ${r}`));
    }
    
      return report.join('\n');
}

export default { logPerformanceMetrics, createPerformanceReport };