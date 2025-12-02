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
};
