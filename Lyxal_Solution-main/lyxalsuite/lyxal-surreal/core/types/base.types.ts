/**
 * Types de base LYXAL Surreal - Fusion des types existants
 * 
 * Contient tous les types de l'ancien système + nouveaux types modulaires
 */

// ==========================================
// CONFIGURATION LYXALSURREAL
// ==========================================

// TODO: À vérifier - Configuration de base SurrealDB compatible avec la Gateway
export interface SurrealConfig {
  url: string;
  user: string;
  pass: string;
  namespace: string;
  database: string;
}

// ==========================================
// ARCHITECTURE BICÉPHALE - INTERFACES PRINCIPALES
// ==========================================

/**
 * Interface pour une instance SaaS (équivalent namespace)
 */
// TODO: À vérifier - Structure SaaS compatible avec l'architecture hiérarchique 6 niveaux
export interface SaaSRecord {
  id: string;
  name: string;
  displayName: string;
  domain: string;
  status: 'active' | 'inactive' | 'suspended';
  createdAt: Date;
  settings: Record<string, any>;
  plan: 'starter' | 'pro' | 'enterprise';
  limits: {
    maxWorkspaces: number;
    maxUsers: number;
    maxStorage: number;
  };
}

/**
 * Interface pour un workspace (équivalent database)
 */
// TODO: À vérifier - Structure Workspace compatible avec les registries MASTER
export interface WorkspaceRecord {
  id: string;
  saasId: string;
  name: string;
  displayName: string;
  status: 'active' | 'inactive' | 'archived';
  createdAt: Date;
  lastAccessedAt: Date;
  modules: string[];
  settings: Record<string, any>;
  users: string[];
}

/**
 * Interface pour un module installé dans un workspace
 */
// TODO: À vérifier - Structure module compatible avec les templates SaaS
export interface WorkspaceModule {
  id?: string;
  workspaceId: string;
  moduleName: string;
  version: string;
  status: 'active' | 'inactive' | 'updating';
  installedAt: Date;
  lastUpdatedAt: Date;
  configuration: Record<string, any>;
}

/**
 * Interface pour la définition d'un module
 */
// TODO: À vérifier - Définition module compatible avec l'écosystème LYXAL
export interface ModuleDefinition {
  name: string;
  displayName: string;
  version: string;
  description: string;
  category: string;
  schemas: string[];
  dependencies: string[];
  requiredTables: string[];
  requiredRelations: string[];
  permissions: string[];
}

/**
 * Interface pour les informations de namespace
 */
// TODO: À vérifier - Information namespace compatible avec la navigation hiérarchique
export interface NamespaceInfo {
  [namespaceName: string]: {
    databases?: Record<string, any>;
  };
}

/**
 * Interface pour les informations root
 */
// TODO: À vérifier - Information root SurrealDB
export interface RootInfo {
  namespaces: NamespaceInfo;
  users?: Record<string, any>;
}

// ==========================================
// EXTENSIONS HONO - ARCHITECTURE BICÉPHALE
// ==========================================

import 'hono';

// TODO: À vérifier - Extensions Hono compatibles avec la Gateway unifiée
declare module 'hono' {
  interface ContextVariableMap {
    saas: SaaSRecord;
    saasCreated: boolean;
    workspace: WorkspaceRecord;
    workspaceCreated: boolean;
    workspaceModule: WorkspaceModule;
    moduleProvisioned: boolean;
    surrealClient: any; // Référence générique pour éviter les imports circulaires
  }
}

// ==========================================
// INTERFACES POUR ERREURS
// ==========================================

// TODO: À vérifier - Détails d'erreur compatibles avec errors.types.ts
export interface ErrorDetails {
  code?: string;
  context?: string;
  timestamp?: Date;
  [key: string]: any;
}

// TODO: À vérifier - Contexte de log compatible avec le monitoring
export interface LogContext {
  saas?: string;
  workspace?: string;
  module?: string;
  user?: string;
  operation?: string;
  [key: string]: any;
}

// ==========================================
// INTERFACES POUR PERFORMANCE ET MÉTRIQUES
// ==========================================

// TODO: À vérifier - Métriques de requête compatibles avec AnalyticsService
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

// TODO: À vérifier - Métriques de cache compatibles avec BaseSurrealClient
export interface CacheMetrics {
  totalHits: number;
  totalMisses: number;
  hitRatio: number;
  totalEntries: number;
  totalMemoryUsage: number;
  avgResponseTime: number;
}

// TODO: À vérifier - Métriques de monitoring compatibles avec le système global
export interface MonitoringMetrics {
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

// TODO: À vérifier - Métriques de performance globales pour la Gateway
export interface PerformanceMetrics {
  cache: {
    metadata: CacheMetrics;
    query: CacheMetrics;
  };
  monitoring: MonitoringMetrics;
}

// ==========================================
// TYPES POUR VALIDATION
// ==========================================

// TODO: À vérifier - Validation SaaS compatible avec les registries
export interface SaaSValidation {
  name: string;
  displayName: string;
  domain?: string;
  plan: 'starter' | 'pro' | 'enterprise';
}

// TODO: À vérifier - Validation Workspace compatible avec l'architecture
export interface WorkspaceValidation {
  name: string;
  displayName: string;
  saasId: string;
  workspaceId: string;
  modules?: string[];
}

// ==========================================
// TYPES ÉNUMÉRÉS
// ==========================================

// TODO: À vérifier - Statuts SaaS cohérents avec l'écosystème
export type SaaSStatus = 'active' | 'inactive' | 'suspended';

// TODO: À vérifier - Statuts Workspace cohérents
export type WorkspaceStatus = 'active' | 'inactive' | 'archived';

// TODO: À vérifier - Statuts Module cohérents
export type ModuleStatus = 'active' | 'inactive' | 'updating';

// ==========================================
// INTERFACES POUR MÉTRIQUES AGRÉGÉES
// ==========================================

// TODO: À vérifier - Métriques agrégées pour le tableau de bord global
export interface AggregatedMetrics {
  totalQueries: number;
  avgResponseTime: number;
  successRate: number;
  cacheHitRatio: number;
  errorRate: number;
  slowQueryThreshold: number;
  topSlowQueries: QueryMetrics[];
  performanceTrend: number[];
  namespacesUsage: Record<string, number>;
  databasesUsage: Record<string, number>;
}

// ==========================================
// INTERFACES POUR OPTIONS DE REQUÊTE
// ==========================================

// TODO: À vérifier - Options de requête cache compatibles avec BaseSurrealClient
export interface CachedQueryOptions {
  ttl?: number;
  cacheKey?: string;
  invalidatePattern?: string;
  skipCache?: boolean;
}

// TODO: À vérifier - Résultat de requête typé pour la Gateway
export interface QueryResult<T = any> {
  data: T;
  cached: boolean;
  duration: number;
  timestamp: number;
  namespace: string;
  database: string;
}

// ==========================================
// CONFIGURATION MONITORING
// ==========================================

// TODO: À vérifier - Configuration monitoring compatible avec l'architecture globale
export interface MonitoringConfig {
  enablePerformanceTracking: boolean;
  slowQueryThreshold: number;
  maxSlowQueries: number;
  performanceHistorySize: number;
  enableCacheMetrics: boolean;
  logLevel: 'debug' | 'info' | 'warn' | 'error';
}