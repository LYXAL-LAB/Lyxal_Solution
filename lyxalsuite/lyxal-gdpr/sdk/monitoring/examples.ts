/**
 * Exemples d'utilisation du système de monitoring GDPR
 */

import { createGdprMonitor } from './gdprMonitor';
import { createGdprDashboard } from './dashboard';
import { GdprClient } from '../backend/gdprClient';
import { HttpClient } from '../../../lyxalbase/sdk/httpClient';

/**
 * Exemple 1: Configuration de base du monitoring
 */
export function setupBasicMonitoring() {
  // Créer une instance du moniteur avec la configuration par défaut
  const monitor = createGdprMonitor();
  
  // Utiliser le moniteur pour journaliser des événements
  monitor.logEvent('request_created', { 
    requestId: 'gdpr_request:123',
    userEmail: 'user@example.com'
  });
  
  // Récupérer les métriques
  const metrics = monitor.getMetrics();
  console.log('Métriques actuelles:', metrics);
  
  return monitor;
}

/**
 * Exemple 2: Configuration avancée du monitoring
 */
export function setupAdvancedMonitoring() {
  // Créer une instance du moniteur avec une configuration personnalisée
  const monitor = createGdprMonitor({
    loggingEnabled: true,
    metricsEnabled: true,
    alertsEnabled: true,
    logLevel: 'debug',
    alertConfig: {
      enabled: true,
      deadlineWarningDays: 7,
      highVolumeThreshold: 20,
      longResolutionTimeThreshold: 96, // 4 jours
      recipients: ['gdpr-admin@example.com', 'dpo@example.com']
    },
    metricsRefreshInterval: 600 // 10 minutes
  });
  
  return monitor;
}

/**
 * Exemple 3: Intégration avec le client GDPR et tableau de bord
 */
export async function setupDashboard(apiUrl: string) {
  // Créer les clients
  const httpClient = new HttpClient(apiUrl);
  const gdprClient = new GdprClient(httpClient);
  
  // Créer le moniteur
  const monitor = createGdprMonitor();
  
  // Créer le tableau de bord
  const dashboard = createGdprDashboard(monitor, gdprClient);
  
  // Initialiser le tableau de bord (récupère les données et configure les mises à jour)
  await dashboard.initialize(60); // Rafraîchir toutes les minutes
  
  // Afficher le tableau de bord dans la console
  dashboard.displayConsole();
  
  return dashboard;
}

/**
 * Exemple 4: Journaliser des événements de demande GDPR
 */
export function logGdprRequestLifecycle(monitor: ReturnType<typeof createGdprMonitor>) {
  // Simuler une demande GDPR
  const request = {
    id: 'gdpr_request:456',
    typeSelect: 0 as const,
    modelId: 789,
    modelSelect: 'user',
    statusSelect: '0' as const,
    requestDateT: new Date().toISOString(),
    dueSendingDateT: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString(), // +30 jours
    label: "Demande d'accès - user@example.com"
  };
  
  // Journaliser la création
  monitor.logRequestCreated(request, 'user@example.com');
  
  // Simuler une mise à jour de la demande
  const updatedRequest = {
    ...request,
    statusSelect: '1' as const
  };
  
  // Journaliser la mise à jour
  monitor.logRequestUpdated(updatedRequest, '0');
  
  // Simuler une réponse
  const responseId = 'gdpr_response:789';
  monitor.logResponseCreated(request.id, responseId, 'user@example.com');
  
  // Simuler la complétion
  const completedRequest = {
    ...updatedRequest,
    statusSelect: '2' as const,
    gdprResponse: responseId
  };
  
  // Journaliser la complétion
  monitor.logRequestUpdated(completedRequest, '1');
  
  // Récupérer les événements
  const events = monitor.getRecentEvents();
  console.log(`Événements journalisés: ${events.length}`);
  
  return events;
}

/**
 * Exemple 5: Gérer les alertes
 */
export function handleAlerts(monitor: ReturnType<typeof createGdprMonitor>) {
  // Récupérer les alertes actives
  const activeAlerts = monitor.getActiveAlerts();
  
  console.log(`Alertes actives: ${activeAlerts.length}`);
  
  // Traiter chaque alerte
  activeAlerts.forEach(alert => {
    console.log(`Traitement de l'alerte: ${alert.type} - ${alert.message}`);
    
    // Simuler une action sur l'alerte
    if (alert.severity === 'high') {
      console.log('Alerte haute priorité: notification immédiate');
    }
    
    // Reconnaître l'alerte
    monitor.acknowledgeAlert(alert.id);
  });
  
  // Vérifier que toutes les alertes ont été reconnues
  const remainingAlerts = monitor.getActiveAlerts();
  console.log(`Alertes restantes: ${remainingAlerts.length}`);
  
  return activeAlerts;
}

/**
 * Exemple d'utilisation globale
 */
export async function runCompleteExample(apiUrl: string) {
  console.log('=== Démarrage de l\'exemple de monitoring GDPR ===');
  
  // Configuration du monitoring
  const monitor = setupAdvancedMonitoring();
  console.log('Moniteur configuré avec succès');
  
  // Journaliser des événements
  const events = logGdprRequestLifecycle(monitor);
  console.log(`${events.length} événements journalisés`);
  
  // Configurer le tableau de bord
  const httpClient = new HttpClient(apiUrl);
  const gdprClient = new GdprClient(httpClient);
  const dashboard = createGdprDashboard(monitor, gdprClient);
  
  // Générer un rapport
  const report = dashboard.generateTextReport();
  console.log('\nRAPPORT DE MONITORING:');
  console.log(report);
  
  console.log('\n=== Fin de l\'exemple de monitoring GDPR ===');
} 