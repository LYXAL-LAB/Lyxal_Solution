/**
 * Export consolidé de tous les types LYXAL Surreal
 */

// Types de base (migrés depuis model/types.d.ts)
export type {
  SurrealConfig,
  SaaSRecord,
  WorkspaceRecord,
  WorkspaceModule,
  ModuleDefinition,
  NamespaceInfo,
  RootInfo,
  ErrorDetails,
  LogContext,
  QueryMetrics,
  CacheMetrics,
  MonitoringMetrics,
  PerformanceMetrics,
  SaaSValidation,
  WorkspaceValidation,
  SaaSStatus,
  WorkspaceStatus,
  ModuleStatus,
  AggregatedMetrics,
  CachedQueryOptions,
  QueryResult,
  MonitoringConfig
} from './base.types';

// Types niveau MASTER
export type {
  Environment,
  DaisyUITheme,
  SystemIdentity,
  SystemInfrastructure,
  SystemConfigMetadata,
  CreateMasterPlatformData,
  CreateMasterPlatformResponse,
  UpdateMasterConfigData,
  UpdateMasterConfigResponse,
  RegistryStatus,
  Plan,
  Industry,
  SaaSTemplate,
  InvestorRegistry,
  BusinessRegistry,
  DeveloperRegistry,
  ContractorRegistry,
  GlobalMetrics,
  RevenueDistribution,
  HierarchyView,
  RegistryQueryOptions,
  RegistryPaginatedResult,
  RegistrySearchFilter,
  MasterValidationRules,
  ValidationResult
} from './master.types';

export { NiveauArchitectural } from './master.types';

// Types d'erreurs (migrés depuis model/errors.ts)
export type * from './errors.types'; 