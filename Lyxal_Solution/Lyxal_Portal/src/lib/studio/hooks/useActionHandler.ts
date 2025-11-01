import { ActionRegistry, type ActionType } from '../actions';
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
 * Fonction de navigation compatible avec le système de routing custom
 */
const customNavigate = (url: string) => {
  // Utiliser window.history pour la navigation
  window.history.pushState({}, '', url);
  // Déclencher un événement personnalisé pour notifier le router
  window.dispatchEvent(new PopStateEvent('popstate'));
};

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
export const useActionHandler = () => {
  // Utiliser la navigation custom (compatible avec AppRouter)
  const navigate = customNavigate;

  const handleAction = async (
    action: ActionDefinition,
    event?: any
  ): Promise<any> => {
    if (!action || action.type !== 'action') {
      console.warn('[useActionHandler] Invalid action:', action);
      return;
    }

    const actionFn = ActionRegistry[action.action as ActionType];

    if (!actionFn) {
      console.warn(`[useActionHandler] Unknown action: ${action.action}`);
      return;
    }

    // Contexte pour toutes les actions
    const context: ActionContext = {
      navigate,
      event,
    };

    // Appeler l'action avec ses params
    const params: any = action.params || { target: action.target };

    return await actionFn(params, context);
  };

  return { handleAction };
};

