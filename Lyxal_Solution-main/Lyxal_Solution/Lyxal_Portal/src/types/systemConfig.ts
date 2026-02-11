/**
 * Types pour la gestion des variables système LYXAL - Niveau 0 (Plateforme)
 * 
 * Focus initial : IDENTITÉ PLATEFORME et INFRASTRUCTURE TECHNIQUE
 * Développement en mode production avec API backend
 */

// ==========================================
// TYPES DE BASE
// ==========================================

/**
 * Types de valeurs supportés pour les variables système
 */
export type SystemConfigValue = string | number | boolean | object | null;

/**
 * Types de données pour validation et interface
 */
export type SystemConfigType = 
  | 'string' 
  | 'number' 
  | 'boolean' 
  | 'url' 
  | 'email';

/**
 * Environnements supportés
 */
export type Environment = 'dev' | 'staging' | 'production';

/**
 * Niveaux architecturaux dans l'écosystème LYXAL
 */
export enum NiveauArchitectural {
  PROPRIETAIRE = 0,
  INVESTOR = 1,
  DEVELOPER = 2,
  BUSINESS = 3,
  CONTRACTOR = 4
}

export type NiveauArchitecturalType = 0 | 1 | 2 | 3 | 4;

// ==========================================
// CONFIGURATION LYXAL NIVEAU 0
// ==========================================

/**
 * Configuration IDENTITÉ PLATEFORME
 */
export interface LyxalIdentityConfig {
  /** Nom de la plateforme LYXAL */
  platformName: string;
  
  /** Identifiant unique de la plateforme */
  platformId: string;
  
  /** Environnement de déploiement */
  environment: Environment;
  
  /** Version de la plateforme */
  platformVersion: string;
  
  /** Date de déploiement */
  deploymentDate: string;
}

/**
 * Configuration INFRASTRUCTURE TECHNIQUE
 */
export interface LyxalInfrastructureConfig {
  /** URL de connexion SurrealDB maître */
  surrealDbUrl: string;
  
  /** Namespace SurrealDB pour la plateforme */
  surrealNamespace: string;
  
  /** Database SurrealDB pour le contrôle plateforme */
  surrealDatabase: string;
  
  /** Endpoint Logto maître */
  logtoMasterEndpoint: string;
  
  /** App ID Logto pour l'admin console */
  logtoAdminAppId: string;
  
  /** URL de l'API backend */
  apiBaseUrl: string;
}

/**
 * Configuration système LYXAL complète (focus initial)
 */
export interface LyxalSystemConfig {
  identity: LyxalIdentityConfig;
  infrastructure: LyxalInfrastructureConfig;
}

// ==========================================
// STRUCTURE DE CONFIGURATION DÉTAILLÉE
// ==========================================

/**
 * Structure d'une variable système individuelle
 */
export interface SystemConfigItem {
  /** Clé unique de la variable */
  key: string;
  
  /** Valeur de la variable */
  value: SystemConfigValue;
  
  /** Type de la variable pour validation */
  type: SystemConfigType;
  
  /** Namespace/catégorie de la variable */
  namespace: string;
  
  /** Description de la variable */
  description: string;
  
  /** Indique si la variable est éditable via l'interface */
  editable: boolean;
  
  /** Valeur par défaut */
  defaultValue?: SystemConfigValue;
  
  /** Validation/contraintes */
  validation?: {
    required?: boolean;
    pattern?: string;
    enum?: string[];
  };
  
  /** Métadonnées */
  metadata?: {
    createdAt: string;
    updatedAt: string;
    updatedBy?: string;
  };
}

/**
 * Configuration système organisée par namespace
 */
export interface SystemConfig {
  identity: Record<string, SystemConfigItem>;
  infrastructure: Record<string, SystemConfigItem>;
}

// ==========================================
// NAMESPACES LYXAL NIVEAU 0
// ==========================================

/**
 * Namespaces pour le niveau LYXAL (focus initial)
 */
export type LyxalConfigNamespace = 
  | 'identity'        // Identité de la plateforme
  | 'infrastructure'; // Configuration technique

// ==========================================
// VARIABLES SYSTÈME PAR DÉFAUT
// ==========================================

/**
 * Configuration par défaut pour l'identité plateforme
 */
export const DEFAULT_IDENTITY_CONFIG: Record<string, SystemConfigItem> = {
  platformName: {
    key: 'platformName',
    value: 'LYXAL',
    type: 'string',
    namespace: 'identity',
    description: 'Nom officiel de la plateforme LYXAL',
    editable: true,
    defaultValue: 'LYXAL',
    validation: { required: true }
  },
  platformId: {
    key: 'platformId',
    value: 'lyxal-master-001',
    type: 'string',
    namespace: 'identity',
    description: 'Identifiant unique de la plateforme (non modifiable)',
    editable: false,
    defaultValue: 'lyxal-master-001',
    validation: { required: true }
  },
  environment: {
    key: 'environment',
    value: 'production',
    type: 'string',
    namespace: 'identity',
    description: 'Environnement de déploiement actuel',
    editable: true,
    defaultValue: 'production',
    validation: { 
      required: true,
      enum: ['dev', 'staging', 'production']
    }
  },
  platformVersion: {
    key: 'platformVersion',
    value: '1.0.0',
    type: 'string',
    namespace: 'identity',
    description: 'Version actuelle de la plateforme',
    editable: false,
    defaultValue: '1.0.0',
    validation: { required: true }
  },
  anneeConstruction: {
    key: 'anneeConstruction',
    value: '2025',
    type: 'string',
    namespace: 'identity',
    description: 'Année de construction de la plateforme',
    editable: true,
    defaultValue: '2025',
    validation: { required: true }
  },
  niveauArchitectural: {
    key: 'niveauArchitectural',
    value: 0,
    type: 'number',
    namespace: 'identity',
    description: 'Niveau architectural dans l\'écosystème LYXAL (0=PROPRIÉTAIRE, 1=INVESTOR, 2=DEVELOPER, 3=BUSINESS, 4=CONTRACTOR)',
    editable: false,
    defaultValue: 0,
    validation: { 
      required: true
    }
  },
  themeParDefaut: {
    key: 'themeParDefaut',
    value: 'corporate',
    type: 'string',
    namespace: 'identity',
    description: 'Thème par défaut de l\'application (pour les nouveaux utilisateurs)',
    editable: true,
    defaultValue: 'corporate',
    validation: { 
      required: true,
      enum: [
        'light', 'dark', 'cupcake', 'bumblebee', 'emerald', 'corporate', 'synthwave', 'retro',
        'cyberpunk', 'valentine', 'halloween', 'garden', 'forest', 'aqua', 'lofi', 'pastel',
        'fantasy', 'wireframe', 'black', 'luxury', 'dracula', 'cmyk', 'autumn', 'business',
        'acid', 'lemonade', 'night', 'coffee', 'winter', 'dim', 'nord', 'sunset'
      ]
    }
  },
  themeWebsite: {
    key: 'themeWebsite',
    value: 'corporate',
    type: 'string',
    namespace: 'identity',
    description: 'Thème fixe du site marketing (non modifiable par les utilisateurs)',
    editable: true,
    defaultValue: 'corporate',
    validation: { 
      required: true,
      enum: [
        'light', 'dark', 'cupcake', 'bumblebee', 'emerald', 'corporate', 'synthwave', 'retro',
        'cyberpunk', 'valentine', 'halloween', 'garden', 'forest', 'aqua', 'lofi', 'pastel',
        'fantasy', 'wireframe', 'black', 'luxury', 'dracula', 'cmyk', 'autumn', 'business',
        'acid', 'lemonade', 'night', 'coffee', 'winter', 'dim', 'nord', 'sunset'
      ]
    }
  },
  roleUtilisateurActuel: {
    key: 'roleUtilisateurActuel',
    value: 'admin',
    type: 'string',
    namespace: 'identity',
    description: 'Rôle de l\'utilisateur actuellement connecté (admin, user, guest)',
    editable: true,
    defaultValue: 'admin',
    validation: { 
      required: true,
      enum: ['admin', 'user', 'guest']
    }
  }
};

/**
 * Configuration par défaut pour l'infrastructure
 */
export const DEFAULT_INFRASTRUCTURE_CONFIG: Record<string, SystemConfigItem> = {
  surrealDbUrl: {
    key: 'surrealDbUrl',
    value: 'wss://accurate-horse-06bnu0f1k1tv1215mv54m347tc.aws-euw1.surreal.cloud/rpc',
    type: 'url',
    namespace: 'infrastructure',
    description: 'URL de connexion à l\'instance SurrealDB maître',
    editable: true,
    validation: { 
      required: true,
      pattern: '^wss?://.+/rpc$'
    }
  },
  surrealNamespace: {
    key: 'surrealNamespace',
    value: 'lyxal_master',
    type: 'string',
    namespace: 'infrastructure',
    description: 'Namespace SurrealDB pour la plateforme LYXAL',
    editable: true,
    defaultValue: 'lyxal_master',
    validation: { required: true }
  },
  surrealDatabase: {
    key: 'surrealDatabase',
    value: 'platform_control',
    type: 'string',
    namespace: 'infrastructure',
    description: 'Database SurrealDB pour le contrôle plateforme',
    editable: true,
    defaultValue: 'platform_control',
    validation: { required: true }
  },
  logtoMasterEndpoint: {
    key: 'logtoMasterEndpoint',
    value: 'https://lyxal-master.logto.cloud',
    type: 'url',
    namespace: 'infrastructure',
    description: 'Endpoint Logto pour l\'authentification maître',
    editable: true,
    validation: { 
      required: true,
      pattern: '^https://.+'
    }
  },
  logtoAdminAppId: {
    key: 'logtoAdminAppId',
    value: 'lyxal-admin-console',
    type: 'string',
    namespace: 'infrastructure',
    description: 'App ID Logto pour la console d\'administration',
    editable: true,
    validation: { required: true }
  },
  apiBaseUrl: {
    key: 'apiBaseUrl',
    value: 'https://api.lyxal.com',
    type: 'url',
    namespace: 'infrastructure',
    description: 'URL de base de l\'API backend LYXAL',
    editable: true,
    validation: { 
      required: true,
      pattern: '^https://.+'
    }
  },
  surrealUsername: {
    key: 'surrealUsername',
    value: 'lyxal_app_user',
    type: 'string',
    namespace: 'infrastructure',
    description: 'Nom d\'utilisateur de l\'instance application SurrealDB',
    editable: true,
    validation: { required: true }
  },
  surrealPassword: {
    key: 'surrealPassword',
    value: 'app_password_2025',
    type: 'string',
    namespace: 'infrastructure',
    description: 'Mot de passe de l\'instance application SurrealDB',
    editable: true,
    validation: { required: true }
  }
};

// ==========================================
// INTERFACES DE SERVICE
// ==========================================

/**
 * Interface pour le service de configuration LYXAL
 */
export interface ILyxalSystemConfigService {
  /**
   * Charge la configuration complète
   */
  loadConfig(): Promise<SystemConfig>;
  
  /**
   * Récupère une variable spécifique
   */
  getConfig(namespace: LyxalConfigNamespace, key: string): Promise<SystemConfigItem | null>;
  
  /**
   * Récupère toutes les variables d'un namespace
   */
  getNamespaceConfig(namespace: LyxalConfigNamespace): Promise<Record<string, SystemConfigItem>>;
  
  /**
   * Met à jour une variable
   */
  updateConfig(
    namespace: LyxalConfigNamespace, 
    key: string, 
    value: SystemConfigValue,
    reason?: string
  ): Promise<void>;
  
  /**
   * Valide une configuration avant sauvegarde
   */
  validateConfig(namespace: LyxalConfigNamespace, key: string, value: SystemConfigValue): Promise<boolean>;
  
  /**
   * Invalide le cache
   */
  invalidateCache(namespace?: LyxalConfigNamespace): void;
}

// ==========================================
// TYPES POUR HOOKS REACT
// ==========================================

/**
 * État du hook useSystemConfig
 */
export interface SystemConfigState {
  config: Partial<SystemConfig> | null;
  loading: boolean;
  error: Error | null;
}

/**
 * Actions disponibles dans le hook
 */
export interface SystemConfigActions {
  updateConfig: (
    namespace: LyxalConfigNamespace, 
    key: string, 
    value: SystemConfigValue,
    reason?: string
  ) => Promise<void>;
  refreshConfig: () => Promise<void>;
  getConfigValue: (namespace: LyxalConfigNamespace, key: string) => SystemConfigValue | undefined;
  isConfigEditable: (namespace: LyxalConfigNamespace, key: string) => boolean;
  getConfigDescription: (namespace: LyxalConfigNamespace, key: string) => string | undefined;
}

// ==========================================
// UTILITAIRES
// ==========================================

/**
 * Fonction utilitaire pour obtenir la configuration par défaut complète
 */
export function getDefaultSystemConfig(): SystemConfig {
  return {
    identity: DEFAULT_IDENTITY_CONFIG,
    infrastructure: DEFAULT_INFRASTRUCTURE_CONFIG
  };
}

/**
 * Fonction utilitaire pour valider un namespace
 */
export function isValidNamespace(namespace: string): namespace is LyxalConfigNamespace {
  return ['identity', 'infrastructure'].includes(namespace);
}

/**
 * Fonction utilitaire pour obtenir les clés d'un namespace
 */
export function getNamespaceKeys(namespace: LyxalConfigNamespace): string[] {
  const config = getDefaultSystemConfig();
  return Object.keys(config[namespace]);
}

/**
 * Fonction utilitaire pour obtenir le nom du niveau architectural
 */
export function getNiveauArchitecturalName(niveau: number): string {
  switch (niveau) {
    case NiveauArchitectural.PROPRIETAIRE:
      return 'PROPRIÉTAIRE';
    case NiveauArchitectural.INVESTOR:
      return 'INVESTOR';
    case NiveauArchitectural.DEVELOPER:
      return 'DEVELOPER';
    case NiveauArchitectural.BUSINESS:
      return 'BUSINESS';
    case NiveauArchitectural.CONTRACTOR:
      return 'CONTRACTOR';
    default:
      return 'INCONNU';
  }
}

/**
 * Fonction utilitaire pour vérifier si le niveau est PROPRIÉTAIRE
 */
export function isProprietaireLevel(niveau: number): boolean {
  return niveau === NiveauArchitectural.PROPRIETAIRE;
}

/**
 * Fonction utilitaire pour vérifier si l'utilisateur a le rôle admin
 * Utilise la configuration système pour déterminer le rôle
 */
export function isUserAdmin(config: Partial<SystemConfig> | null): boolean {
  const userRole = config?.identity?.roleUtilisateurActuel?.value;
  return userRole === 'admin';
}

/**
 * Fonction utilitaire pour vérifier si l'utilisateur peut voir les identifiants sensibles
 */
export function canViewSensitiveCredentials(niveau: number, config: Partial<SystemConfig> | null): boolean {
  return isProprietaireLevel(niveau) && isUserAdmin(config);
}

export default LyxalSystemConfig;