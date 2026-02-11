import type { ActionDefinition } from '../actions';
/**
 * Contexte passé aux actions
 */
export interface ActionContext {
    navigate: (url: string) => void;
    event?: any;
    [key: string]: any;
}
/**
 * Hook pour gérer les actions définies en DB
 *
 * Transforme les actions JSON définies dans SurrealDB en fonctions React exécutables.
 *
 * Compatible avec les routers custom et react-router-dom.
 *
 * @example
 * ```tsx
 * const { handleAction } = useActionHandler();
 *
 * // Action depuis DB
 * const onClick = {
 *   type: "action",
 *   action: "navigate",
 *   params: { url: "/contacts" }
 * };
 *
 * <button onClick={(e) => handleAction(onClick, e)}>Go</button>
 * ```
 */
export declare const useActionHandler: () => {
    handleAction: (action: ActionDefinition, event?: any) => Promise<any>;
};
