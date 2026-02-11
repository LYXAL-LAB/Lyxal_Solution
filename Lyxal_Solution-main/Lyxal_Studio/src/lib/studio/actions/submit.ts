// Note: useSystemConfig ne peut pas être utilisé ici car c'est un hook React
// La config doit être passée via le contexte
import type { SurrealClient } from '../../../services/SurrealClient';

/**
 * Action de soumission de formulaire vers SurrealDB
 * 
 * Crée ou met à jour un enregistrement dans SurrealDB
 */
export interface SubmitParams {
  table: string;
  data: any;
  operation?: 'create' | 'update';
  id?: string;  // Pour UPDATE
}

export interface SubmitContext {
  config?: any;  // Config système (optionnel, sera récupéré via hook si non fourni)
}

export const submitAction = async (
  params: SubmitParams,
  context: SubmitContext = {}
): Promise<{ success: boolean; error?: any; result?: any }> => {
  const { table, data, operation = 'create', id } = params;

  if (!table) {
    console.warn('[submitAction] table is required');
    return { success: false, error: 'table is required' };
  }

  try {
    // La config doit être passée via context.config
    if (!context.config) {
      console.warn('[submitAction] Config must be provided via context.config');
      return {
        success: false,
        error: 'Config not available - must be provided via context.config',
      };
    }

    // TODO: Implémenter la logique de création/mise à jour avec SurrealClient
    // Pour l'instant, retourner un placeholder
    console.log('[submitAction] Would submit:', { table, data, operation, id });
    
    return {
      success: true,
      result: { id: id || 'new-id', ...data },
    };
  } catch (error) {
    console.error('[submitAction] Failed:', error);
    return {
      success: false,
      error,
    };
  }
};

