/**
 * Service de gestion de la configuration système
 * Gère les opérations de lecture/écriture de la configuration
 */
export declare class SystemConfigService {
    /**
     * Charge toute la configuration (simulation pour l'instant)
     * Retourne uniquement les clés présentes côté distant
     */
    static loadAll(): Promise<Partial<{
        identity: Partial<Record<string, {
            value: string;
        }>>;
        infrastructure: Partial<Record<string, {
            value: string;
        }>>;
        ui: {
            sidebar?: {
                defaultOpen: boolean;
            };
        };
    }>>;
    /**
     * Mettre à jour une configuration
     * @param namespace - Namespace de la configuration (ex: 'infrastructure', 'identity')
     * @param key - Clé de la configuration
     * @param value - Nouvelle valeur
     * @param reason - Raison de la modification
     */
    updateConfig(namespace: string, key: string, value: string, reason?: string): Promise<void>;
    /**
     * Récupérer une configuration
     */
    getConfig(namespace: string, key: string): Promise<string | null>;
    /**
     * Récupérer toute la configuration d'un namespace
     */
    getNamespaceConfig(namespace: string): Promise<Record<string, string>>;
}
