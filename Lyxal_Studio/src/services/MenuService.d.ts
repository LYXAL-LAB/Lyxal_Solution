export type DbMenuItem = {
    id: string;
    key: string;
    name_i18n?: string;
    tooltip_i18n?: string;
    icon_key?: string;
    module_key?: string;
    enabled: boolean;
    order: number;
    name_text?: string;
    tooltip_text?: string;
};
type ConfigLike = {
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
        modules?: Record<string, boolean>;
    };
};
export declare class MenuService {
    static listActive(config?: ConfigLike): Promise<DbMenuItem[]>;
}
export {};
