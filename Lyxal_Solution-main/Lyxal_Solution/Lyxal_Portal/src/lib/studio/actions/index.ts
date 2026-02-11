import { navigateAction } from './navigate';
import { submitAction } from './submit';
import { stateUpdateAction } from './stateUpdate';

/**
 * Registre global des actions disponibles
 * 
 * Toutes les actions définies en DB doivent être enregistrées ici
 */
export const ActionRegistry = {
  navigate: navigateAction,
  submit: submitAction,
  state_update: stateUpdateAction,
} as const;

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

