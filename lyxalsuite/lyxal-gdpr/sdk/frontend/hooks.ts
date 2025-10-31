import { useState, useCallback } from 'react';
import { gdprClient } from './gdprClient';
import type {
  GdprRequest,
  GdprResponse,
  GdprLog,
  CreateGdprRequestInput,
  UpdateGdprRequestInput,
  CreateGdprResponseInput
} from '../types/types';

/**
 * Hook pour créer une demande GDPR
 */
export const useCreateRequest = () => {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);
  const [request, setRequest] = useState<GdprRequest | null>(null);

  const createRequest = useCallback(async (data: CreateGdprRequestInput) => {
    setLoading(true);
    setError(null);
    try {
      const result = await gdprClient.createRequest(data);
      setRequest(result);
      return result;
    } catch (err: any) {
      setError(err);
      throw err;
    } finally {
      setLoading(false);
    }
  }, []);

  return { createRequest, loading, error, request };
};

/**
 * Hook pour créer une demande d'accès aux données
 */
export const useCreateAccessRequest = () => {
  const { createRequest, loading, error, request } = useCreateRequest();

  const createAccessRequest = useCallback(async (
    userId: string | number, 
    email: string, 
    comment?: string
  ) => {
    return createRequest({
      typeSelect: 0, // ACCESS
      requestDateT: new Date(),
      dueSendingDateT: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000), // +30 jours
      statusSelect: 1, // En attente
      modelId: typeof userId === 'string' ? Number(userId) : userId,
      modelSelect: 'user',
      requestComment: comment || 'Demande d\'accès aux données personnelles',
      gdprRequestOrigin: 'gdpr_request_origin:frontend'
    });
  }, [createRequest]);

  return { createAccessRequest, loading, error, request };
};

/**
 * Hook pour créer une demande d'effacement des données
 */
export const useCreateErasureRequest = () => {
  const { createRequest, loading, error, request } = useCreateRequest();

  const createErasureRequest = useCallback(async (
    userId: string | number, 
    email: string, 
    comment?: string
  ) => {
    return createRequest({
      typeSelect: 1, // ERASURE
      requestDateT: new Date(),
      dueSendingDateT: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000), // +30 jours
      statusSelect: 1, // En attente
      modelId: typeof userId === 'string' ? Number(userId) : userId,
      modelSelect: 'user',
      requestComment: comment || 'Demande d\'effacement des données personnelles',
      gdprRequestOrigin: 'gdpr_request_origin:frontend'
    });
  }, [createRequest]);

  return { createErasureRequest, loading, error, request };
};

/**
 * Hook pour récupérer une demande spécifique
 */
export const useGetRequest = (requestId?: string) => {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);
  const [request, setRequest] = useState<GdprRequest | null>(null);

  const getRequest = useCallback(async (id?: string) => {
    const idToUse = id || requestId;
    if (!idToUse) {
      throw new Error('ID de demande non spécifié');
    }

    setLoading(true);
    setError(null);
    try {
      const result = await gdprClient.getRequest(idToUse);
      setRequest(result);
      return result;
    } catch (err: any) {
      setError(err);
      throw err;
    } finally {
      setLoading(false);
    }
  }, [requestId]);

  return { getRequest, loading, error, request };
};

/**
 * Hook pour lister toutes les demandes
 */
export const useListRequests = () => {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);
  const [requests, setRequests] = useState<GdprRequest[]>([]);

  const listRequests = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const result = await gdprClient.listRequests();
      setRequests(result);
      return result;
    } catch (err: any) {
      setError(err);
      throw err;
    } finally {
      setLoading(false);
    }
  }, []);

  return { listRequests, loading, error, requests };
};

/**
 * Hook pour mettre à jour une demande
 */
export const useUpdateRequest = (requestId?: string) => {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);
  const [updatedRequest, setUpdatedRequest] = useState<GdprRequest | null>(null);

  const updateRequest = useCallback(async (
    data: UpdateGdprRequestInput,
    id?: string
  ) => {
    const idToUse = id || requestId;
    if (!idToUse) {
      throw new Error('ID de demande non spécifié');
    }

    setLoading(true);
    setError(null);
    try {
      const result = await gdprClient.updateRequest(idToUse, data);
      setUpdatedRequest(result);
      return result;
    } catch (err: any) {
      setError(err);
      throw err;
    } finally {
      setLoading(false);
    }
  }, [requestId]);

  return { updateRequest, loading, error, updatedRequest };
};

/**
 * Hook pour créer une réponse à une demande
 */
export const useCreateResponse = (requestId?: string) => {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);
  const [response, setResponse] = useState<GdprResponse | null>(null);

  const createResponse = useCallback(async (
    data: CreateGdprResponseInput,
    id?: string
  ) => {
    const idToUse = id || requestId;
    if (!idToUse) {
      throw new Error('ID de demande non spécifié');
    }

    setLoading(true);
    setError(null);
    try {
      const result = await gdprClient.createResponse(idToUse, data);
      setResponse(result);
      return result;
    } catch (err: any) {
      setError(err);
      throw err;
    } finally {
      setLoading(false);
    }
  }, [requestId]);

  return { createResponse, loading, error, response };
};

/**
 * Hook pour lister les journaux d'audit
 */
export const useListLogs = () => {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);
  const [logs, setLogs] = useState<GdprLog[]>([]);

  const listLogs = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const result = await gdprClient.listLogs();
      setLogs(result);
      return result;
    } catch (err: any) {
      setError(err);
      throw err;
    } finally {
      setLoading(false);
    }
  }, []);

  return { listLogs, loading, error, logs };
};

/**
 * Hook pour supprimer une demande
 */
export const useDeleteRequest = (requestId?: string) => {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);
  const [deleted, setDeleted] = useState(false);

  const deleteRequest = useCallback(async (id?: string) => {
    const idToUse = id || requestId;
    if (!idToUse) {
      throw new Error('ID de demande non spécifié');
    }

    setLoading(true);
    setError(null);
    try {
      await gdprClient.deleteRequest(idToUse);
      setDeleted(true);
      return true;
    } catch (err: any) {
      setError(err);
      throw err;
    } finally {
      setLoading(false);
    }
  }, [requestId]);

  return { deleteRequest, loading, error, deleted };
}; 