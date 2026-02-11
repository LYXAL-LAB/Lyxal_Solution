/**
 * Types TypeScript pour le niveau MASTER (Niveau 0)
 * 
 * Gestion de l'identité plateforme, infrastructure technique et registry
 */

// ==========================================
// TYPES DE BASE MASTER
// ==========================================

/**
 * Environnements supportés
 */
// TODO: À vérifier - Environnements cohérents avec l'infrastructure
export type Environment = 'dev' | 'staging' | 'production';

/**
 * Niveaux architecturaux dans l'écosystème LYXAL
 */
// TODO: À vérifier - Enum des niveaux hiérarchiques complet et cohérent
export enum NiveauArchitectural {
  MASTER = 0,
  INVESTOR = 1,
  BUSINESS = 2,
  DEVELOPER = 3,
  CONTRACTOR = 4,
  END_USERS = 5
}

/**
 * Thèmes DaisyUI supportés
 */
// TODO: À vérifier - Liste des thèmes DaisyUI complète et à jour
export type DaisyUITheme = 
  | 'light' | 'dark' | 'cupcake' | 'bumblebee' | 'emerald' | 'corporate' 
  | 'synthwave' | 'retro' | 'cyberpunk' | 'valentine' | 'halloween' 
  | 'garden' | 'forest' | 'aqua' | 'lofi' | 'pastel' | 'fantasy' 
  | 'wireframe' | 'black' | 'luxury' | 'dracula' | 'cmyk' | 'autumn' 
  | 'business' | 'acid' | 'lemonade' | 'night' | 'coffee' | 'winter' 
  | 'dim' | 'nord' | 'sunset';



// ==========================================
// INTERFACES CONFIGURATION MASTER
// ==========================================

/**
 * Configuration identité plateforme MASTER
 */
// TODO: À vérifier - Configuration identité MASTER cohérente avec l'architecture
export interface SystemIdentity {
  platform_name: string;
  platform_id: string;
  environment: Environment;
  platform_version: string;
  annee_construction: string;
  niveau_architectural: NiveauArchitectural.MASTER;
  theme_par_defaut: DaisyUITheme;
  theme_website: DaisyUITheme;
  ultimate: boolean;
  createdAt: Date;
  updatedAt: Date;
  createdBy?: string;
}

/**
 * Configuration infrastructure technique MASTER
 */
// TODO: À vérifier - Configuration infrastructure technique complète
export interface SystemInfrastructure {
  surreal_db_url: string;
  surreal_namespace: string;
  surreal_database: string;
  surreal_username: string;
  surreal_password: string;
  logto_master_endpoint: string;
  logto_admin_app_id: string;
  api_base_url: string;
  createdAt: Date;
  updatedAt: Date;
  createdBy?: string;
}

/**
 * Métadonnées de configuration système
 */
// TODO: À vérifier - Métadonnées de configuration pour audit et traçabilité
export interface SystemConfigMetadata {
  table_name: 'system_identity' | 'system_infrastructure';
  field_name: string;
  old_value?: string;
  new_value?: string;
  changed_by: string;
  changed_at: Date;
  change_reason: string;
  createdAt: Date;
}

// ==========================================
// INTERFACES POUR CRÉATION MASTER
// ==========================================

/**
 * Données pour création d'une plateforme MASTER
 */
// TODO: À vérifier - Données création plateforme MASTER complètes
export interface CreateMasterPlatformData {
  platform_name: string;
  platform_id: string;
  environment?: Environment;
  platform_version?: string;
  annee_construction?: string;
  theme_par_defaut?: DaisyUITheme;
  theme_website?: DaisyUITheme;
  surreal_db_url: string;
  surreal_namespace: string;
  surreal_database: string;
  surreal_username: string;
  surreal_password: string;
  logto_master_endpoint: string;
  logto_admin_app_id: string;
  api_base_url: string;
  created_by?: string;
}

/**
 * Réponse de création d'une plateforme MASTER
 */
// TODO: À vérifier - Réponse création plateforme avec toutes les métadonnées
export interface CreateMasterPlatformResponse {
  success: boolean;
  message: string;
  data: {
    identity: SystemIdentity;
    infrastructure: SystemInfrastructure;
    platform_id: string;
    created_at: Date;
  };
  metadata: {
    total_platforms: number;
    environment: Environment;
    created_by: string;
  };
}

/**
 * Données pour mise à jour configuration MASTER
 */
// TODO: À vérifier - Données mise à jour configuration avec validation
export interface UpdateMasterConfigData {
  table_name: 'system_identity' | 'system_infrastructure';
  field_name: string;
  new_value: string;
  platform_id: string;
  changed_by: string;
  reason?: string;
}

/**
 * Réponse de mise à jour configuration MASTER
 */
// TODO: À vérifier - Réponse mise à jour avec historique des changements
export interface UpdateMasterConfigResponse {
  success: boolean;
  message: string;
  field_updated: string;
  old_value: string;
  new_value: string;
  updated_at: Date;
}

// ==========================================
// INTERFACES REGISTRY MASTER
// ==========================================

/**
 * Statuts pour les enregistrements registry
 */
// TODO: À vérifier - Statuts registry cohérents avec le cycle de vie
export type RegistryStatus = 'active' | 'suspended' | 'trial' | 'expired' | 'maintenance' | 'churned';

/**
 * Plans disponibles
 */
// TODO: À vérifier - Plans disponibles cohérents avec le modèle business
export type Plan = 'trial' | 'starter' | 'professional' | 'enterprise';

/**
 * Industries supportées
 */
// TODO: À vérifier - Industries supportées complètes et à jour
export type Industry = 
  | 'restaurant' | 'ecommerce' | 'legal' | 'medical' | 'consulting' 
  | 'real_estate' | 'automotive' | 'education' | 'finance' | 'retail' | 'other';

/**
 * Templates SaaS disponibles
 */
// TODO: À vérifier - Templates SaaS disponibles cohérents avec les industries
export type SaaSTemplate = 
  | 'restaurant-full' | 'restaurant-lite' | 'ecommerce-full' | 'ecommerce-lite' 
  | 'legal-full' | 'crm-basic' | 'erp-full' | 'custom';

/**
 * Enregistrement INVESTOR dans le registry
 */
// TODO: À vérifier - Structure registry INVESTOR complète avec infrastructure
export interface InvestorRegistry {
  investor_id: string;
  display_name: string;
  namespace: string;
  infrastructure: {
    surrealdb_instance: string;
    logto_tenant: string;
    hosting_provider: string;
    domain_root: string;
    ssl_certificates: string[];
    backup_strategy: string;
    monitoring_endpoints: string[];
  };
  plan: Plan;
  status: RegistryStatus;
  total_revenue: number;
  business_count: number;
  contact: {
    email: string;
    company: string;
    phone: string;
    address: Record<string, any>;
  };
  created_at: Date;
  updated_at: Date;
}

/**
 * Enregistrement BUSINESS dans le registry
 */
// TODO: À vérifier - Structure registry BUSINESS avec relation hiérarchique
export interface BusinessRegistry {
  business_id: string;
  parent_investor_id: string;
  display_name: string;
  namespace: string;
  plan: Exclude<Plan, 'trial'>;
  monthly_fee: number;
  status: RegistryStatus;
  developer_count: number;
  saas_count: number;
  created_at: Date;
  updated_at: Date;
}

/**
 * Enregistrement DEVELOPER dans le registry
 */
// TODO: À vérifier - Structure registry DEVELOPER avec templates et metrics
export interface DeveloperRegistry {
  developer_id: string;
  parent_business_id: string;
  parent_investor_id: string;
  display_name: string;
  namespace: string;
  industry: Industry;
  saas_template: SaaSTemplate;
  monthly_subscription: number;
  status: RegistryStatus;
  contractor_count: number;
  end_users_count: number;
  created_at: Date;
  updated_at: Date;
}

/**
 * Enregistrement CONTRACTOR dans le registry
 */
// TODO: À vérifier - Structure registry CONTRACTOR avec métriques usage
export interface ContractorRegistry {
  contractor_id: string;
  parent_developer_id: string;
  parent_business_id: string;
  parent_investor_id: string;
  display_name: string;
  saas_type: string;
  domain: string;
  monthly_subscription: number;
  status: RegistryStatus;
  active_users: number;
  storage_used_gb: number;
  created_at: Date;
  updated_at: Date;
}

// ==========================================
// INTERFACES ANALYTICS MASTER
// ==========================================

/**
 * Métriques globales temps réel
 */
// TODO: À vérifier - Métriques globales temps réel complètes
export interface GlobalMetrics {
  timestamp: Date;
  total_investors: number;
  total_businesses: number;
  total_developers: number;
  total_contractors: number;
  total_end_users: number;
  total_revenue_daily: number;
  platform_health_score: number;
}

/**
 * Distribution des revenus par niveau
 */
// TODO: À vérifier - Distribution revenus cohérente avec le modèle business
export interface RevenueDistribution {
  date: Date;
  investor_revenue: number;
  business_revenue: number;
  developer_revenue: number;
  contractor_revenue: number;
  platform_commission: number;
}

/**
 * Vue hiérarchique complète
 */
// TODO: À vérifier - Vue hiérarchique récursive complète
export interface HierarchyView {
  level: NiveauArchitectural;
  total_count: number;
  active_count: number;
  revenue_total: number;
  revenue_monthly: number;
  children?: HierarchyView[];
}

// ==========================================
// TYPES UTILITAIRES
// ==========================================

/**
 * Options pour requêtes registry
 */
// TODO: À vérifier - Options requêtes registry complètes pour pagination/filtrage
export interface RegistryQueryOptions {
  status?: RegistryStatus;
  plan?: Plan;
  industry?: Industry;
  limit?: number;
  offset?: number;
  sortBy?: string;
  sortOrder?: 'asc' | 'desc';
}

/**
 * Résultat paginé pour registry
 */
// TODO: À vérifier - Résultat paginé compatible avec les DataTables
export interface RegistryPaginatedResult<T> {
  data: T[];
  total: number;
  page: number;
  pageSize: number;
  hasNext: boolean;
  hasPrev: boolean;
}

/**
 * Filtre de recherche registry
 */
// TODO: À vérifier - Filtre recherche registry complet pour analytics
export interface RegistrySearchFilter {
  searchTerm?: string;
  dateFrom?: Date;
  dateTo?: Date;
  status?: RegistryStatus[];
  plans?: Plan[];
  industries?: Industry[];
}

// ==========================================
// TYPES POUR VALIDATION
// ==========================================

/**
 * Règles de validation pour création MASTER
 */
// TODO: À vérifier - Règles validation MASTER complètes et sécurisées
export interface MasterValidationRules {
  platform_name: {
    minLength: number;
    maxLength: number;
    pattern?: RegExp;
  };
  platform_id: {
    minLength: number;
    maxLength: number;
    pattern: RegExp;
  };
  surreal_db_url: {
    pattern: RegExp;
  };
  surreal_namespace: {
    minLength: number;
    pattern: RegExp;
  };
  passwords: {
    minLength: number;
  };
}

/**
 * Résultat de validation
 */
// TODO: À vérifier - Résultat validation avec erreurs et warnings détaillés
export interface ValidationResult {
  isValid: boolean;
  errors: string[];
  warnings?: string[];
} 