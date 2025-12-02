/**
 * Action de mise à jour du state global
 *
 * Met à jour une valeur dans le state global du Studio Runtime
 */
export interface StateUpdateParams {
    target: string;
}
export interface StateUpdateContext {
    event?: any;
}
export declare const stateUpdateAction: (params: StateUpdateParams, context?: StateUpdateContext) => void;
