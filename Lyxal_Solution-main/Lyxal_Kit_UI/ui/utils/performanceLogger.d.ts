/**
* Utilitaire pour logger les métriques de performance
* Formatage et affichage des données de performance
*/
type PerformanceMetrics = Record<string, number>;
/**
 * Formate et affiche les métriques de performance dans la console
 * @param metrics - Les métriques de performance à afficher
 */
export declare function logPerformanceMetrics(metrics: Partial<PerformanceMetrics>): void;
/**
 * Crée un rapport de performance formaté
 * @param metrics - Les métriques de performance
 * @returns Rapport formaté
 */
export declare function createPerformanceReport(metrics: Partial<PerformanceMetrics>): string;
declare const _default: {
    logPerformanceMetrics: typeof logPerformanceMetrics;
    createPerformanceReport: typeof createPerformanceReport;
};
export default _default;
