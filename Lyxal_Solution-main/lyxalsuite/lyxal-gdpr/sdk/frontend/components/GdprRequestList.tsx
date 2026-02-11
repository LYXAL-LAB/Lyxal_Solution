import React, { useEffect, useState } from 'react';
import { useListRequests, useUpdateRequest, useDeleteRequest } from '../hooks';
import { GdprRequest } from '../../types/types';

interface GdprRequestListProps {
  onViewRequest?: (requestId: string) => void;
  onDeleteSuccess?: (requestId: string) => void;
  onUpdateSuccess?: (request: GdprRequest) => void;
  onError?: (error: Error) => void;
  autoRefresh?: boolean;
  refreshInterval?: number;
}

/**
 * Liste des demandes GDPR avec actions
 */
export const GdprRequestList: React.FC<GdprRequestListProps> = ({
  onViewRequest,
  onDeleteSuccess,
  onUpdateSuccess,
  onError,
  autoRefresh = false,
  refreshInterval = 60000, // 1 minute par défaut
}) => {
  const { listRequests, loading, error, requests } = useListRequests();
  const { updateRequest, loading: updateLoading } = useUpdateRequest();
  const { deleteRequest, loading: deleteLoading } = useDeleteRequest();
  
  const [selectedRequest, setSelectedRequest] = useState<string | null>(null);
  
  // Chargement initial
  useEffect(() => {
    listRequests().catch(err => onError?.(err));
  }, [listRequests, onError]);
  
  // Actualisation automatique
  useEffect(() => {
    if (!autoRefresh) return;
    
    const interval = setInterval(() => {
      listRequests().catch(err => console.error('Erreur de rafraîchissement :', err));
    }, refreshInterval);
    
    return () => clearInterval(interval);
  }, [autoRefresh, listRequests, refreshInterval]);
  
  // Formatage de la date
  const formatDate = (dateString: string) => {
    const date = new Date(dateString);
    return new Intl.DateTimeFormat('fr-FR', {
      day: '2-digit',
      month: '2-digit', 
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    }).format(date);
  };
  
  // Obtenir le libellé du statut
  const getStatusLabel = (status: string) => {
    switch (status) {
      case '0': return 'Reçue';
      case '1': return 'Confirmée';
      case '2': return 'Envoyée';
      case '3': return 'Annulée';
      default: return 'Inconnu';
    }
  };
  
  // Obtenir le libellé du type de demande
  const getTypeLabel = (type: number) => {
    return type === 0 ? 'Accès aux données' : 'Effacement des données';
  };
  
  // Gestionnaire de mise à jour du statut
  const handleStatusChange = async (requestId: string, newStatus: '0' | '1' | '2' | '3') => {
    try {
      const updatedRequest = await updateRequest({ statusSelect: newStatus }, requestId);
      onUpdateSuccess?.(updatedRequest);
      listRequests(); // Actualiser la liste
    } catch (err: any) {
      onError?.(err);
    }
  };
  
  // Gestionnaire de suppression
  const handleDelete = async (requestId: string) => {
    if (!window.confirm('Êtes-vous sûr de vouloir supprimer cette demande ?')) {
      return;
    }
    
    try {
      await deleteRequest(requestId);
      onDeleteSuccess?.(requestId);
      listRequests(); // Actualiser la liste
    } catch (err: any) {
      onError?.(err);
    }
  };
  
  if (error) {
    return <div className="error-message">Erreur: {error.message}</div>;
  }
  
  return (
    <div className="gdpr-request-list">
      <h2>Demandes GDPR</h2>
      
      <div className="controls">
        <button 
          onClick={() => listRequests().catch(err => onError?.(err))}
          disabled={loading}
        >
          {loading ? 'Actualisation...' : 'Actualiser'}
        </button>
      </div>
      
      {loading && <div className="loading">Chargement des demandes...</div>}
      
      {!loading && requests.length === 0 && (
        <div className="empty-list">Aucune demande trouvée</div>
      )}
      
      {requests.length > 0 && (
        <table className="gdpr-table">
          <thead>
            <tr>
              <th>ID</th>
              <th>Type</th>
              <th>Date de demande</th>
              <th>Échéance</th>
              <th>Statut</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {requests.map(request => (
              <tr key={request.id} className={selectedRequest === request.id ? 'selected' : ''}>
                <td>{request.id.split(':')[1]}</td>
                <td>{getTypeLabel(request.typeSelect)}</td>
                <td>{formatDate(request.requestDateT)}</td>
                <td>{request.dueSendingDateT ? formatDate(request.dueSendingDateT) : '-'}</td>
                <td>
                  <span className={`status status-${request.statusSelect}`}>
                    {getStatusLabel(request.statusSelect)}
                  </span>
                </td>
                <td className="actions">
                  <button 
                    onClick={() => onViewRequest?.(request.id)}
                    title="Voir les détails"
                  >
                    Voir
                  </button>
                  
                  <select
                    value={request.statusSelect}
                    onChange={(e) => handleStatusChange(request.id, e.target.value as any)}
                    disabled={updateLoading}
                    title="Changer le statut"
                  >
                    <option value="0">Reçue</option>
                    <option value="1">Confirmée</option>
                    <option value="2">Envoyée</option>
                    <option value="3">Annulée</option>
                  </select>
                  
                  <button 
                    onClick={() => handleDelete(request.id)}
                    disabled={deleteLoading}
                    className="delete-btn"
                    title="Supprimer"
                  >
                    Supprimer
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </div>
  );
}; 