import React, { useState, FormEvent } from 'react';
import { useCreateAccessRequest, useCreateErasureRequest } from '../hooks';

type RequestType = 'access' | 'erasure';

interface GdprRequestFormProps {
  userId: string | number;
  email: string;
  onSuccess?: (requestId: string) => void;
  onError?: (error: Error) => void;
}

/**
 * Formulaire de demande GDPR (accès ou effacement)
 */
export const GdprRequestForm: React.FC<GdprRequestFormProps> = ({
  userId,
  email,
  onSuccess,
  onError
}) => {
  const [requestType, setRequestType] = useState<RequestType>('access');
  const [comment, setComment] = useState('');
  const [submitting, setSubmitting] = useState(false);
  const [success, setSuccess] = useState(false);
  
  const { createAccessRequest, loading: accessLoading } = useCreateAccessRequest();
  const { createErasureRequest, loading: erasureLoading } = useCreateErasureRequest();
  
  const isLoading = accessLoading || erasureLoading || submitting;
  
  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();
    
    if (isLoading) return;
    
    setSubmitting(true);
    setSuccess(false);
    
    try {
      let result;
      
      if (requestType === 'access') {
        result = await createAccessRequest(userId, email, comment);
      } else {
        result = await createErasureRequest(userId, email, comment);
      }
      
      setSuccess(true);
      onSuccess?.(result.id);
    } catch (error: any) {
      onError?.(error);
    } finally {
      setSubmitting(false);
    }
  };
  
  return (
    <div className="gdpr-request-form">
      <h2>Créer une demande GDPR</h2>
      
      {success && (
        <div className="success-message">
          Votre demande a été envoyée avec succès !
        </div>
      )}
      
      <form onSubmit={handleSubmit}>
        <div className="form-group">
          <label htmlFor="request-type">Type de demande</label>
          <select
            id="request-type"
            value={requestType}
            onChange={(e) => setRequestType(e.target.value as RequestType)}
            disabled={isLoading}
          >
            <option value="access">Accès aux données</option>
            <option value="erasure">Effacement des données</option>
          </select>
        </div>
        
        <div className="form-group">
          <label htmlFor="comment">Commentaire (optionnel)</label>
          <textarea
            id="comment"
            value={comment}
            onChange={(e) => setComment(e.target.value)}
            disabled={isLoading}
            rows={4}
            placeholder="Précisez votre demande..."
          />
        </div>
        
        <div className="form-group">
          <button type="submit" disabled={isLoading}>
            {isLoading ? 'Envoi en cours...' : 'Envoyer la demande'}
          </button>
        </div>
      </form>
    </div>
  );
}; 