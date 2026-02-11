/**
 * Interface pour la configuration système
 */
interface SystemConfig {
    identity: {
        platformName: {
            value: string;
        };
        themeParDefaut: {
            value: string;
        };
        niveauArchitectural: {
            value: string;
        };
        anneeConstruction: {
            value: string;
        };
        nomApplication?: string;
        version?: string;
    };
    infrastructure: {
        surrealDbUrl: {
            value: string;
        };
        surrealNamespace: {
            value: string;
        };
        surrealDatabase: {
            value: string;
        };
        surrealUsername: {
            value: string;
        };
        surrealPassword: {
            value: string;
        };
    };
    ui?: {
        sidebar?: {
            defaultOpen: boolean;
        };
        modules?: Record<string, boolean>;
    };
}
/**
 * Interface pour le retour du hook
 */
interface UseSystemConfigReturn {
    config: SystemConfig;
    loading: boolean;
    error: Error | null;
    refetch: () => void;
}
/**
 * Hook personnalisé pour la gestion de la configuration système
 * Charge et gère la configuration globale de l'application
 */
export declare const useSystemConfig: () => UseSystemConfigReturn;
export {};
