import { v4 as uuidv4 } from 'uuid';
import { 
  GdprEvent, 
  GdprEventType, 
  GdprMetrics, 
  Alert, 
  AlertType, 
  AlertConfig,
  LogLevel,
  MonitoringConfig
} from '../types/monitoring';
import { GdprRequest } from '../types/types';

/**
 * Service de monitoring GDPR pour suivre les activités, collecter des métriques
 * et générer des alertes liées aux demandes GDPR.
 */
export class GdprMonitor {
  private events: GdprEvent[] = [];
  private alerts: Alert[] = [];
  private metrics: GdprMetrics = this.initializeMetrics();
  private config: MonitoringConfig;
  private metricsTimer: NodeJS.Timeout | null = null;
  
  /**
   * Crée une nouvelle instance du moniteur GDPR
   */
  constructor(config?: Partial<MonitoringConfig>) {
    this.config = {
      loggingEnabled: true,
      metricsEnabled: true,
      alertsEnabled: true,
      logLevel: 'info',
      alertConfig: {
        enabled: true,
        deadlineWarningDays: 5,
        highVolumeThreshold: 50,
        longResolutionTimeThreshold: 72, // 3 jours
        recipients: []
      },
      metricsRefreshInterval: 300, // 5 minutes
      ...config
    };
    
    if (this.config.metricsEnabled) {
      this.startMetricsCollection();
    }
  }
  
  /**
   * Initialise les métriques avec des valeurs par défaut
   */
  private initializeMetrics(): GdprMetrics {
    return {
      totalRequests: 0,
      activeRequests: 0,
      completedRequests: 0,
      canceledRequests: 0,
      accessRequests: 0,
      erasureRequests: 0,
      averageResolutionTime: 0,
      overdueRequests: 0,
      complianceRate: 100
    };
  }
  
  /**
   * Démarre la collecte périodique de métriques
   */
  private startMetricsCollection(): void {
    if (this.metricsTimer) {
      clearInterval(this.metricsTimer);
    }
    
    this.metricsTimer = setInterval(() => {
      this.updateMetrics();
    }, this.config.metricsRefreshInterval * 1000);
  }
  
  /**
   * Arrête la collecte périodique de métriques
   */
  public stopMetricsCollection(): void {
    if (this.metricsTimer) {
      clearInterval(this.metricsTimer);
      this.metricsTimer = null;
    }
  }
  
  /**
   * Enregistre un événement GDPR
   */
  public logEvent(
    eventType: GdprEventType,
    details: {
      requestId?: string;
      responseId?: string;
      userId?: number;
      userEmail?: string;
      details?: Record<string, any>;
    }
  ): GdprEvent | null {
    if (!this.config.loggingEnabled) return null;
    
    const event: GdprEvent = {
      id: `gdpr_event:${uuidv4()}`,
      timestamp: Date.now(),
      eventType,
      ...details
    };
    
    this.events.push(event);
    
    // Log selon le niveau configuré
    switch (this.config.logLevel) {
      case 'debug':
        console.debug(`[GDPR Monitor] ${eventType}`, event);
        break;
      case 'info':
        if (['debug'].includes(this.config.logLevel)) break;
        console.info(`[GDPR Monitor] ${eventType}`, event);
        break;
      case 'warn':
        if (['debug', 'info'].includes(this.config.logLevel)) break;
        console.warn(`[GDPR Monitor] ${eventType}`, event);
        break;
      case 'error':
        if (['debug', 'info', 'warn'].includes(this.config.logLevel)) break;
        console.error(`[GDPR Monitor] ${eventType}`, event);
        break;
    }
    
    return event;
  }
  
  /**
   * Journalise la création d'une demande GDPR
   */
  public logRequestCreated(request: GdprRequest, userEmail?: string): void {
    this.logEvent('request_created', {
      requestId: request.id,
      userId: request.modelId,
      userEmail,
      details: {
        typeSelect: request.typeSelect === 0 ? 'access' : 'erasure',
        status: request.statusSelect
      }
    });
    
    this.updateMetrics();
    this.checkHighVolumeAlert();
  }
  
  /**
   * Journalise la mise à jour d'une demande GDPR
   */
  public logRequestUpdated(request: GdprRequest, previousStatus?: string): void {
    this.logEvent('request_updated', {
      requestId: request.id,
      userId: request.modelId,
      details: {
        typeSelect: request.typeSelect === 0 ? 'access' : 'erasure',
        previousStatus,
        newStatus: request.statusSelect
      }
    });
    
    // Si la demande est terminée, vérifier le temps de résolution
    if (request.statusSelect === '2' && previousStatus !== '2') {
      this.logEvent('request_completed', { requestId: request.id });
      this.checkResolutionTimeAlert(request);
    }
    
    this.updateMetrics();
  }
  
  /**
   * Journalise la création d'une réponse GDPR
   */
  public logResponseCreated(
    requestId: string,
    responseId: string,
    userEmail: string
  ): void {
    this.logEvent('response_created', {
      requestId,
      responseId,
      userEmail
    });
  }
  
  /**
   * Met à jour les métriques GDPR
   */
  public updateMetrics(requests?: GdprRequest[]): GdprMetrics {
    if (!this.config.metricsEnabled) return this.metrics;
    
    // Si des requêtes sont fournies, calculer les métriques
    if (requests && requests.length > 0) {
      const now = Date.now();
      
      // Initialiser les compteurs
      const metrics: GdprMetrics = this.initializeMetrics();
      metrics.totalRequests = requests.length;
      
      let totalResolutionTime = 0;
      let completedCount = 0;
      
      // Analyser chaque demande
      requests.forEach(request => {
        // Compter par type
        if (request.typeSelect === 0) {
          metrics.accessRequests++;
        } else {
          metrics.erasureRequests++;
        }
        
        // Compter par statut
        switch (request.statusSelect) {
          case '0': // Received
          case '1': // Confirmed
            metrics.activeRequests++;
            
            // Vérifier si en retard
            if (request.dueSendingDateT) {
              const dueDate = new Date(request.dueSendingDateT).getTime();
              if (dueDate < now) {
                metrics.overdueRequests++;
              }
            }
            break;
          case '2': // Sent
            metrics.completedRequests++;
            
            // Calculer le temps de résolution si possible
            if (request.requestDateT) {
              const requestDate = new Date(request.requestDateT).getTime();
              const sentDate = now; // Approximation
              const resolutionTime = (sentDate - requestDate) / (1000 * 60 * 60); // en heures
              totalResolutionTime += resolutionTime;
              completedCount++;
            }
            break;
          case '3': // Canceled
            metrics.canceledRequests++;
            break;
        }
      });
      
      // Calculer le temps moyen de résolution
      if (completedCount > 0) {
        metrics.averageResolutionTime = totalResolutionTime / completedCount;
      }
      
      // Calculer le taux de conformité
      const totalWithDeadline = metrics.completedRequests + metrics.overdueRequests;
      if (totalWithDeadline > 0) {
        metrics.complianceRate = (metrics.completedRequests / totalWithDeadline) * 100;
      }
      
      this.metrics = metrics;
    }
    
    return this.metrics;
  }
  
  /**
   * Génère une alerte
   */
  private createAlert(
    type: AlertType,
    message: string,
    severity: 'low' | 'medium' | 'high',
    relatedRequestIds?: string[]
  ): Alert | null {
    if (!this.config.alertsEnabled || !this.config.alertConfig.enabled) {
      return null;
    }
    
    const alert: Alert = {
      id: `gdpr_alert:${uuidv4()}`,
      timestamp: Date.now(),
      type,
      message,
      severity,
      relatedRequestIds,
      acknowledged: false
    };
    
    this.alerts.push(alert);
    
    // Journaliser l'alerte
    console.warn(`[GDPR Alert] ${alert.type}: ${alert.message}`);
    
    // Notifier les destinataires (simulation)
    this.notifyAlertRecipients(alert);
    
    return alert;
  }
  
  /**
   * Notifie les destinataires d'une alerte (simulation)
   */
  private notifyAlertRecipients(alert: Alert): void {
    if (this.config.alertConfig.recipients.length > 0) {
      console.info(`[GDPR Monitor] Alerte envoyée à ${this.config.alertConfig.recipients.join(', ')}`);
      // Dans une implémentation réelle, envoyer des emails ou notifications
    }
  }
  
  /**
   * Vérifie si une alerte de volume élevé doit être générée
   */
  private checkHighVolumeAlert(): void {
    if (this.metrics.activeRequests >= this.config.alertConfig.highVolumeThreshold) {
      this.createAlert(
        'high_volume',
        `Volume élevé de demandes GDPR: ${this.metrics.activeRequests} demandes actives`,
        'medium'
      );
    }
  }
  
  /**
   * Vérifie si une alerte de temps de résolution long doit être générée
   */
  private checkResolutionTimeAlert(request: GdprRequest): void {
    if (!request.requestDateT) return;
    
    const requestDate = new Date(request.requestDateT).getTime();
    const completionDate = Date.now();
    const resolutionTime = (completionDate - requestDate) / (1000 * 60 * 60); // en heures
    
    if (resolutionTime > this.config.alertConfig.longResolutionTimeThreshold) {
      this.createAlert(
        'long_resolution_time',
        `Temps de résolution long pour la demande ${request.id}: ${Math.floor(resolutionTime)} heures`,
        'low',
        [request.id]
      );
    }
  }
  
  /**
   * Vérifie les demandes avec échéance proche ou dépassée
   */
  public checkDeadlines(requests: GdprRequest[]): void {
    if (!this.config.alertsEnabled) return;
    
    const now = Date.now();
    const warningThreshold = now + (this.config.alertConfig.deadlineWarningDays * 24 * 60 * 60 * 1000);
    
    const approachingDeadlines: string[] = [];
    const missedDeadlines: string[] = [];
    
    requests.forEach(request => {
      // Ignorer les demandes terminées ou annulées
      if (request.statusSelect === '2' || request.statusSelect === '3') return;
      
      if (request.dueSendingDateT) {
        const dueDate = new Date(request.dueSendingDateT).getTime();
        
        // Vérifier les échéances dépassées
        if (dueDate < now) {
          missedDeadlines.push(request.id);
          this.logEvent('deadline_missed', { requestId: request.id });
        } 
        // Vérifier les échéances approchantes
        else if (dueDate < warningThreshold) {
          approachingDeadlines.push(request.id);
          this.logEvent('deadline_approaching', { requestId: request.id });
        }
      }
    });
    
    // Créer des alertes si nécessaire
    if (missedDeadlines.length > 0) {
      this.createAlert(
        'deadline_missed',
        `${missedDeadlines.length} demandes GDPR ont dépassé leur échéance`,
        'high',
        missedDeadlines
      );
    }
    
    if (approachingDeadlines.length > 0) {
      this.createAlert(
        'deadline_warning',
        `${approachingDeadlines.length} demandes GDPR approchent de leur échéance`,
        'medium',
        approachingDeadlines
      );
    }
  }
  
  /**
   * Marque une alerte comme reconnue
   */
  public acknowledgeAlert(alertId: string): boolean {
    const alertIndex = this.alerts.findIndex(alert => alert.id === alertId);
    if (alertIndex >= 0) {
      this.alerts[alertIndex].acknowledged = true;
      return true;
    }
    return false;
  }
  
  /**
   * Récupère les métriques actuelles
   */
  public getMetrics(): GdprMetrics {
    return this.metrics;
  }
  
  /**
   * Récupère les événements récents
   */
  public getRecentEvents(limit = 50): GdprEvent[] {
    return this.events
      .sort((a, b) => b.timestamp - a.timestamp)
      .slice(0, limit);
  }
  
  /**
   * Récupère les alertes actives (non reconnues)
   */
  public getActiveAlerts(): Alert[] {
    return this.alerts
      .filter(alert => !alert.acknowledged)
      .sort((a, b) => b.timestamp - a.timestamp);
  }
  
  /**
   * Récupère toutes les alertes
   */
  public getAllAlerts(): Alert[] {
    return this.alerts
      .sort((a, b) => b.timestamp - a.timestamp);
  }
  
  /**
   * Configure le moniteur
   */
  public configure(config: Partial<MonitoringConfig>): void {
    this.config = {
      ...this.config,
      ...config,
      alertConfig: {
        ...this.config.alertConfig,
        ...(config.alertConfig || {})
      }
    };
    
    // Redémarrer la collecte de métriques si nécessaire
    if (this.config.metricsEnabled) {
      this.startMetricsCollection();
    } else {
      this.stopMetricsCollection();
    }
  }
}

/**
 * Crée une instance configurée du moniteur GDPR
 */
export function createGdprMonitor(config?: Partial<MonitoringConfig>): GdprMonitor {
  return new GdprMonitor(config);
} 