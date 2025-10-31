import { GdprClient } from './gdprClient';
import type {
  CreateGdprRequestInput,
  UpdateGdprRequestInput,
  CreateGdprResponseInput,
  GdprRequest,
  GdprResponse,
  GdprLog,
} from '../types/types';

/**
 * Hooks GDPR pour une utilisation côté backend
 * Ces hooks fournissent une interface standardisée pour toutes les fonctionnalités GDPR
 */
export const createGdprHooks = (client: GdprClient) => {
  return {
    /**
     * Crée une demande d'accès aux données
     */
    useCreateAccessRequest: (userId: string, email: string, comment?: string) => {
      return async (): Promise<GdprRequest> => {
        try {
          const request = await client.createRequest({
            typeSelect: 0, // ACCESS
            requestDateT: new Date(),
            dueSendingDateT: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000), // +30 jours
            statusSelect: 1, // En attente
            modelId: Number(userId),
            modelSelect: 'user',
            requestComment: comment || 'Demande d\'accès aux données personnelles',
            gdprRequestOrigin: 'gdpr_request_origin:backend'
          });
          
          return request;
        } catch (error) {
          console.error('Erreur lors de la création de la demande d\'accès:', error);
          throw error;
        }
      };
    },

    /**
     * Crée une demande d'effacement des données
     */
    useCreateErasureRequest: (userId: string, email: string, comment?: string) => {
      return async (): Promise<GdprRequest> => {
        try {
          const request = await client.createRequest({
            typeSelect: 1, // ERASURE
            requestDateT: new Date(),
            dueSendingDateT: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000), // +30 jours
            statusSelect: 1, // En attente
            modelId: Number(userId),
            modelSelect: 'user',
            requestComment: comment || 'Demande d\'effacement des données personnelles',
            gdprRequestOrigin: 'gdpr_request_origin:backend'
          });
          
          return request;
        } catch (error) {
          console.error('Erreur lors de la création de la demande d\'effacement:', error);
          throw error;
        }
      };
    },

    /**
     * Récupère une demande spécifique
     */
    useGetRequest: (requestId: string) => {
      return async (): Promise<GdprRequest> => {
        try {
          return await client.getRequest(requestId);
        } catch (error) {
          console.error('Erreur lors de la récupération de la demande:', error);
          throw error;
        }
      };
    },

    /**
     * Liste toutes les demandes
     */
    useListRequests: () => {
      return async (): Promise<GdprRequest[]> => {
        try {
          return await client.listRequests();
        } catch (error) {
          console.error('Erreur lors de la récupération des demandes:', error);
          throw error;
        }
      };
    },

    /**
     * Met à jour le statut d'une demande
     */
    useUpdateRequestStatus: (requestId: string, status: '0' | '1' | '2' | '3', comment?: string) => {
      return async (): Promise<GdprRequest> => {
        try {
          return await client.updateRequest(requestId, { 
            statusSelect: status,
            ...(comment && { requestComment: comment })
          });
        } catch (error) {
          console.error('Erreur lors de la mise à jour de la demande:', error);
          throw error;
        }
      };
    },

    /**
     * Crée une réponse à une demande d'accès
     */
    useCreateAccessResponse: (requestId: string, email: string, data: any, attachmentId?: string) => {
      return async (): Promise<GdprResponse> => {
        try {
          return await client.createResponse(requestId, {
            responseEmailAddress: email,
            ...(attachmentId && { fileId: attachmentId })
          });
        } catch (error) {
          console.error('Erreur lors de la création de la réponse:', error);
          throw error;
        }
      };
    },

    /**
     * Crée une réponse à une demande d'effacement
     */
    useCreateErasureResponse: (requestId: string, email: string, anonymizationResult: string) => {
      return async (): Promise<GdprResponse> => {
        try {
          return await client.createResponse(requestId, {
            responseEmailAddress: email,
            anonymizationResult
          });
        } catch (error) {
          console.error('Erreur lors de la création de la réponse d\'effacement:', error);
          throw error;
        }
      };
    },

    /**
     * Liste les journaux d'audit
     */
    useListLogs: () => {
      return async (): Promise<GdprLog[]> => {
        try {
          return await client.listLogs();
        } catch (error) {
          console.error('Erreur lors de la récupération des logs:', error);
          throw error;
        }
      };
    }
  };
}; 