import { useStudioState } from '../store/useStudioState';

/**
 * Action de mise à jour du state global
 * 
 * Met à jour une valeur dans le state global du Studio Runtime
 */
export interface StateUpdateParams {
  target: string;  // Clé du state à mettre à jour (ex: "search", "user.name")
}

export interface StateUpdateContext {
  event?: any;  // Event React (pour récupérer event.target.value)
}

export const stateUpdateAction = (
  params: StateUpdateParams,
  context: StateUpdateContext = {}
): void => {
  const { setValue } = useStudioState.getState();
  const { target } = params;

  if (!target) {
    console.warn('[stateUpdateAction] target is required');
    return;
  }

  // Récupérer la valeur depuis l'event si disponible
  let value: any;
  if (context.event?.target?.value !== undefined) {
    value = context.event.target.value;
  } else if (context.event?.target?.checked !== undefined) {
    value = context.event.target.checked;
  } else {
    // Si pas d'event, essayer de récupérer depuis params
    value = (params as any).value;
  }

  if (value !== undefined) {
    setValue(target, value);
  }
};

