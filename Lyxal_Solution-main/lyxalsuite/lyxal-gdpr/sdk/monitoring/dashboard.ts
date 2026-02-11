import { GdprMonitor } from './gdprMonitor';
import { GdprMetrics, Alert, GdprEvent } from '../types/monitoring';
import { GdprClient } from '../backend/gdprClient';

/**
 * Interface pour un tableau de bord de monitoring GDPR
 * Permet de visualiser les métriques, les alertes et les événements récents
 */
export class GdprDashboard {
  private monitor: GdprMonitor;
  private client: GdprClient;
  private updateInterval: NodeJS.Timeout | null = null;
  
  /**
   * Crée une nouvelle instance de tableau de bord
   */
  constructor(monitor: GdprMonitor, client: GdprClient) {
    this.monitor = monitor;
    this.client = client;
  }
  
  /**
   * Initialise le tableau de bord et commence la collecte de données
   */
  public async initialize(refreshInterval = 300): Promise<void> {
    // Première collecte de données
    await this.refreshData();
    
    // Configurer l'intervalle de rafraîchissement
    this.updateInterval = setInterval(async () => {
      await this.refreshData();
    }, refreshInterval * 1000);
  }
  
  /**
   * Arrête la collecte de données
   */
  public stop(): void {
    if (this.updateInterval) {
      clearInterval(this.updateInterval);
      this.updateInterval = null;
    }
  }
  
  /**
   * Rafraîchit les données du tableau de bord
   */
  public async refreshData(): Promise<void> {
    try {
      // Récupérer toutes les demandes
      const requests = await this.client.listRequests();
      
      // Mettre à jour les métriques
      this.monitor.updateMetrics(requests);
      
      // Vérifier les échéances
      this.monitor.checkDeadlines(requests);
    } catch (error) {
      console.error('[GDPR Dashboard] Erreur lors du rafraîchissement des données:', error);
    }
  }
  
  /**
   * Récupère les métriques actuelles
   */
  public getMetrics(): GdprMetrics {
    return this.monitor.getMetrics();
  }
  
  /**
   * Récupère les alertes actives
   */
  public getActiveAlerts(): Alert[] {
    return this.monitor.getActiveAlerts();
  }
  
  /**
   * Récupère l'historique des événements
   */
  public getEventHistory(limit = 50): GdprEvent[] {
    return this.monitor.getRecentEvents(limit);
  }
  
  /**
   * Reconnaît une alerte
   */
  public acknowledgeAlert(alertId: string): boolean {
    return this.monitor.acknowledgeAlert(alertId);
  }
  
  /**
   * Génère un rapport texte des métriques actuelles
   */
  public generateTextReport(): string {
    const metrics = this.getMetrics();
    const alerts = this.getActiveAlerts();
    
    return `
=== RAPPORT DE CONFORMITÉ GDPR ===
Date: ${new Date().toISOString()}

MÉTRIQUES:
- Demandes totales: ${metrics.totalRequests}
- Demandes actives: ${metrics.activeRequests}
- Demandes terminées: ${metrics.completedRequests}
- Demandes annulées: ${metrics.canceledRequests}
- Demandes d'accès: ${metrics.accessRequests}
- Demandes d'effacement: ${metrics.erasureRequests}
- Temps moyen de résolution: ${Math.round(metrics.averageResolutionTime)} heures
- Demandes en retard: ${metrics.overdueRequests}
- Taux de conformité: ${Math.round(metrics.complianceRate)}%

ALERTES ACTIVES (${alerts.length}):
${alerts.map(alert => `- [${alert.severity.toUpperCase()}] ${alert.message}`).join('\n')}
    `.trim();
  }
  
  /**
   * Affiche le tableau de bord dans la console
   * Méthode simplifiée pour démonstration
   */
  public displayConsole(): void {
    console.clear();
    console.log(this.generateTextReport());
  }
}

/**
 * Crée une instance configurée du tableau de bord GDPR
 */
export function createGdprDashboard(
  monitor: GdprMonitor,
  client: GdprClient
): GdprDashboard {
  return new GdprDashboard(monitor, client);
} 