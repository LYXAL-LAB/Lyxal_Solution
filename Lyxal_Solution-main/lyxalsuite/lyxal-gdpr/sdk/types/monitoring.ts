/**
 * Types pour le monitoring GDPR
 */

// Niveau de log
export type LogLevel = 'debug' | 'info' | 'warn' | 'error';

// Structure d'un événement GDPR
export type GdprEvent = {
  id: string;
  timestamp: number;
  eventType: GdprEventType;
  requestId?: string;
  responseId?: string;
  userId?: number;
  userEmail?: string;
  details?: Record<string, any>;
};

// Types d'événements GDPR
export type GdprEventType = 
  | 'request_created'
  | 'request_updated' 
  | 'request_completed'
  | 'response_created'
  | 'data_accessed'
  | 'data_erased'
  | 'compliance_report_generated'
  | 'deadline_approaching'
  | 'deadline_missed';

// Métriques GDPR
export type GdprMetrics = {
  // Métriques générales
  totalRequests: number;
  activeRequests: number;
  completedRequests: number;
  canceledRequests: number;
  
  // Métriques par type
  accessRequests: number;
  erasureRequests: number;
  
  // Métriques de performance
  averageResolutionTime: number; // en heures
  
  // Métriques de conformité
  overdueRequests: number;
  complianceRate: number; // pourcentage de demandes traitées dans les délais
};

// Configuration des alertes
export type AlertConfig = {
  enabled: boolean;
  deadlineWarningDays: number; // jours avant échéance pour alerter
  highVolumeThreshold: number; // nombre de requêtes actives considéré comme élevé
  longResolutionTimeThreshold: number; // temps en heures considéré comme long pour résoudre
  recipients: string[]; // emails des destinataires des alertes
};

// Type d'alerte
export type AlertType = 
  | 'deadline_warning'
  | 'deadline_missed'
  | 'high_volume'
  | 'long_resolution_time';

// Structure d'une alerte
export type Alert = {
  id: string;
  timestamp: number;
  type: AlertType;
  message: string;
  severity: 'low' | 'medium' | 'high';
  relatedRequestIds?: string[];
  acknowledged: boolean;
};

// Configuration du monitoring
export type MonitoringConfig = {
  loggingEnabled: boolean;
  metricsEnabled: boolean;
  alertsEnabled: boolean;
  logLevel: LogLevel;
  alertConfig: AlertConfig;
  metricsRefreshInterval: number; // en secondes
}; 