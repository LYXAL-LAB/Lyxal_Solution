import { GdprClient } from '../backend/gdprClient';
import { HttpClient } from '../../../lyxalbase/sdk/httpClient';
import type {
  GdprRequest,
  GdprResponse,
  GdprLog,
  CreateGdprRequestInput,
  UpdateGdprRequestInput,
  CreateGdprResponseInput
} from '../types/types';

/**
 * Interface agent IA pour interagir avec les fonctionnalités GDPR
 * Version simplifiée optimisée pour l'utilisation par un agent IA
 */
export class GdprAgent {
  private client: GdprClient;
  
  constructor(client: GdprClient) {
    this.client = client;
  }
  
  /**
   * Créer une demande d'accès aux données
   * @param userId - ID de l'utilisateur
   * @param email - Email de l'utilisateur
   * @param comment - Commentaire optionnel
   * @returns Demande créée
   */
  async createAccessRequest(userId: string | number, email: string, comment?: string): Promise<GdprRequest> {
    const numericUserId = typeof userId === 'string' ? Number(userId) : userId;
    
    return this.client.createRequest({
      typeSelect: 0, // ACCESS
      requestDateT: new Date(),
      dueSendingDateT: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000), // +30 jours
      statusSelect: 1, // En attente
      modelId: numericUserId,
      modelSelect: 'user',
      requestComment: comment || 'Demande d\'accès aux données personnelles',
      gdprRequestOrigin: 'gdpr_request_origin:agent',
      label: `Demande d'accès - ${email}`
    });
  }
  
  /**
   * Créer une demande d'effacement des données
   * @param userId - ID de l'utilisateur
   * @param email - Email de l'utilisateur
   * @param comment - Commentaire optionnel
   * @returns Demande créée
   */
  async createErasureRequest(userId: string | number, email: string, comment?: string): Promise<GdprRequest> {
    const numericUserId = typeof userId === 'string' ? Number(userId) : userId;
    
    return this.client.createRequest({
      typeSelect: 1, // ERASURE
      requestDateT: new Date(),
      dueSendingDateT: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000), // +30 jours
      statusSelect: 1, // En attente
      modelId: numericUserId,
      modelSelect: 'user',
      requestComment: comment || 'Demande d\'effacement des données personnelles',
      gdprRequestOrigin: 'gdpr_request_origin:agent',
      label: `Demande d'effacement - ${email}`
    });
  }
  
  /**
   * Obtenir une demande par son ID
   */
  async getRequest(requestId: string): Promise<GdprRequest> {
    return this.client.getRequest(requestId);
  }
  
  /**
   * Lister toutes les demandes
   */
  async listRequests(): Promise<GdprRequest[]> {
    return this.client.listRequests();
  }
  
  /**
   * Rechercher des demandes par utilisateur
   * @param userId - ID de l'utilisateur
   */
  async findRequestsByUser(userId: string | number): Promise<GdprRequest[]> {
    const requests = await this.client.listRequests();
    const numericUserId = typeof userId === 'string' ? Number(userId) : userId;
    
    return requests.filter(request => request.modelId === numericUserId);
  }
  
  /**
   * Rechercher des demandes par email
   * @param email - Email à rechercher dans les libellés
   */
  async findRequestsByEmail(email: string): Promise<GdprRequest[]> {
    const requests = await this.client.listRequests();
    const lowerEmail = email.toLowerCase();
    
    return requests.filter(request => 
      request.label?.toLowerCase().includes(lowerEmail)
    );
  }
  
  /**
   * Mettre à jour le statut d'une demande
   * @param requestId - ID de la demande
   * @param status - Nouveau statut
   * @param comment - Commentaire optionnel
   */
  async updateRequestStatus(requestId: string, status: '0' | '1' | '2' | '3', comment?: string): Promise<GdprRequest> {
    return this.client.updateRequest(requestId, {
      statusSelect: status,
      ...(comment && { requestComment: comment })
    });
  }
  
  /**
   * Créer une réponse à une demande d'accès
   * @param requestId - ID de la demande
   * @param email - Email du destinataire
   * @param fileId - ID du fichier attaché (optionnel)
   */
  async createAccessResponse(requestId: string, email: string, fileId?: string): Promise<GdprResponse> {
    return this.client.createResponse(requestId, {
      responseEmailAddress: email,
      ...(fileId && { fileId })
    });
  }
  
  /**
   * Créer une réponse à une demande d'effacement
   * @param requestId - ID de la demande
   * @param email - Email du destinataire
   * @param anonymizationResult - Résultat de l'anonymisation
   */
  async createErasureResponse(requestId: string, email: string, anonymizationResult: string): Promise<GdprResponse> {
    return this.client.createResponse(requestId, {
      responseEmailAddress: email,
      anonymizationResult
    });
  }
  
  /**
   * Obtenir les logs d'audit
   */
  async getAuditLogs(): Promise<GdprLog[]> {
    return this.client.listLogs();
  }
  
  /**
   * Supprimer une demande
   */
  async deleteRequest(requestId: string): Promise<void> {
    return this.client.deleteRequest(requestId);
  }
  
  /**
   * Méthode simplifiée pour obtenir un rapport de conformité GDPR
   * Renvoie un résumé des demandes actives et leur statut
   */
  async getComplianceReport(): Promise<{
    totalRequests: number;
    pendingRequests: number;
    completedRequests: number;
    overdueRequests: number;
    requestsByType: Record<string, number>;
    requestsByStatus: Record<string, number>;
  }> {
    const requests = await this.client.listRequests();
    const now = new Date();
    
    // Initialiser les compteurs
    const report = {
      totalRequests: requests.length,
      pendingRequests: 0,
      completedRequests: 0,
      overdueRequests: 0,
      requestsByType: { 'access': 0, 'erasure': 0 },
      requestsByStatus: { 'received': 0, 'confirmed': 0, 'sent': 0, 'canceled': 0 }
    };
    
    // Analyser chaque demande
    for (const request of requests) {
      // Compter par type
      if (request.typeSelect === 0) {
        report.requestsByType['access']++;
      } else {
        report.requestsByType['erasure']++;
      }
      
      // Compter par statut
      switch (request.statusSelect) {
        case '0':
          report.requestsByStatus['received']++;
          report.pendingRequests++;
          break;
        case '1':
          report.requestsByStatus['confirmed']++;
          report.pendingRequests++;
          break;
        case '2':
          report.requestsByStatus['sent']++;
          report.completedRequests++;
          break;
        case '3':
          report.requestsByStatus['canceled']++;
          break;
      }
      
      // Vérifier si la demande est en retard
      if (['0', '1'].includes(request.statusSelect) && request.dueSendingDateT) {
        const dueDate = new Date(request.dueSendingDateT);
        if (dueDate < now) {
          report.overdueRequests++;
        }
      }
    }
    
    return report;
  }
}

/**
 * Créer une instance GdprAgent avec un client configuré
 */
export function createGdprAgent(baseUrl: string, apiKey?: string): GdprAgent {
  const httpClient = new HttpClient(baseUrl);
  const client = new GdprClient(httpClient);
  
  return new GdprAgent(client);
} 