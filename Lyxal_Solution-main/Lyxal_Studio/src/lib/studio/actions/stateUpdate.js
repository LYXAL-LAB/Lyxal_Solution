import { useStudioState } from '../store/useStudioState';
export const stateUpdateAction = (params, context = {}) => {
    const { setValue } = useStudioState.getState();
    const { target } = params;
    if (!target) {
        console.warn('[stateUpdateAction] target is required');
        return;
    }
    // Récupérer la valeur depuis l'event si disponible
    let value;
    if (context.event?.target?.value !== undefined) {
        value = context.event.target.value;
    }
    else if (context.event?.target?.checked !== undefined) {
        value = context.event.target.checked;
    }
    else {
        // Si pas d'event, essayer de récupérer depuis params
        value = params.value;
    }
    if (value !== undefined) {
        setValue(target, value);
    }
};
