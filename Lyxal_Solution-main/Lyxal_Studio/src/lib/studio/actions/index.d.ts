/**
 * Registre global des actions disponibles
 *
 * Toutes les actions définies en DB doivent être enregistrées ici
 */
export declare const ActionRegistry: {
    readonly navigate: (params: import("./navigate").NavigateParams, context: import("./navigate").NavigateContext) => void;
    readonly submit: (params: import("./submit").SubmitParams, context?: import("./submit").SubmitContext) => Promise<{
        success: boolean;
        error?: any;
        result?: any;
    }>;
    readonly state_update: (params: import("./stateUpdate").StateUpdateParams, context?: import("./stateUpdate").StateUpdateContext) => void;
};
export type ActionType = keyof typeof ActionRegistry;
/**
 * Type pour une définition d'action depuis la DB
 */
export interface ActionDefinition {
    type: 'action';
    action: ActionType;
    target?: string;
    params?: Record<string, any>;
}
