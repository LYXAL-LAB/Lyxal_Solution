/**
 * Types pour la gestion des variables système LYXAL - Niveau 0 (Plateforme)
 *
 * Focus initial : IDENTITÉ PLATEFORME et INFRASTRUCTURE TECHNIQUE
 * Développement en mode production avec API backend
 */
/**
 * Types de valeurs supportés pour les variables système
 */
export type SystemConfigValue = string | number | boolean | object | null;
/**
 * Types de données pour validation et interface
 */
export type SystemConfigType = 'string' | 'number' | 'boolean' | 'url' | 'email';
/**
 * Environnements supportés
 */
export type Environment = 'dev' | 'staging' | 'production';
/**
 * Niveaux architecturaux dans l'écosystème LYXAL
 */
export declare enum NiveauArchitectural {
    PROPRIETAIRE = 0,
    INVESTOR = 1,
    DEVELOPER = 2,
    BUSINESS = 3,
    CONTRACTOR = 4
}
export type NiveauArchitecturalType = 0 | 1 | 2 | 3 | 4;
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
/**
 * Namespaces pour le niveau LYXAL (focus initial)
 */
export type LyxalConfigNamespace = 'identity' | 'infrastructure';
/**
 * Configuration par défaut pour l'identité plateforme
 */
export declare const DEFAULT_IDENTITY_CONFIG: Record<string, SystemConfigItem>;
/**
 * Configuration par défaut pour l'infrastructure
 */
export declare const DEFAULT_INFRASTRUCTURE_CONFIG: Record<string, SystemConfigItem>;
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
    updateConfig(namespace: LyxalConfigNamespace, key: string, value: SystemConfigValue, reason?: string): Promise<void>;
    /**
     * Valide une configuration avant sauvegarde
     */
    validateConfig(namespace: LyxalConfigNamespace, key: string, value: SystemConfigValue): Promise<boolean>;
    /**
     * Invalide le cache
     */
    invalidateCache(namespace?: LyxalConfigNamespace): void;
}
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
    updateConfig: (namespace: LyxalConfigNamespace, key: string, value: SystemConfigValue, reason?: string) => Promise<void>;
    refreshConfig: () => Promise<void>;
    getConfigValue: (namespace: LyxalConfigNamespace, key: string) => SystemConfigValue | undefined;
    isConfigEditable: (namespace: LyxalConfigNamespace, key: string) => boolean;
    getConfigDescription: (namespace: LyxalConfigNamespace, key: string) => string | undefined;
}
/**
 * Fonction utilitaire pour obtenir la configuration par défaut complète
 */
export declare function getDefaultSystemConfig(): SystemConfig;
/**
 * Fonction utilitaire pour valider un namespace
 */
export declare function isValidNamespace(namespace: string): namespace is LyxalConfigNamespace;
/**
 * Fonction utilitaire pour obtenir les clés d'un namespace
 */
export declare function getNamespaceKeys(namespace: LyxalConfigNamespace): string[];
/**
 * Fonction utilitaire pour obtenir le nom du niveau architectural
 */
export declare function getNiveauArchitecturalName(niveau: number): string;
/**
 * Fonction utilitaire pour vérifier si le niveau est PROPRIÉTAIRE
 */
export declare function isProprietaireLevel(niveau: number): boolean;
/**
 * Fonction utilitaire pour vérifier si l'utilisateur a le rôle admin
 * Utilise la configuration système pour déterminer le rôle
 */
export declare function isUserAdmin(config: Partial<SystemConfig> | null): boolean;
/**
 * Fonction utilitaire pour vérifier si l'utilisateur peut voir les identifiants sensibles
 */
export declare function canViewSensitiveCredentials(niveau: number, config: Partial<SystemConfig> | null): boolean;
export default LyxalSystemConfig;
