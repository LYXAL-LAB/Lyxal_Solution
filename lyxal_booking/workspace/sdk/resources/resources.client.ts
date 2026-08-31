/**
 * 🏛️ LYXAL OS — Client SDK Fortement Typé pour le Module 05 : Resources
 */

import { HttpClient, httpClient } from '../client';
import {
  ResourceResponse,
  CreateResourceRequest,
  UpdateResourceRequest,
  DeleteResourceResponse,
  SyncResourceResponse,
} from './resources.types';

export class ResourcesClient {
  private client: HttpClient;

  constructor(client: HttpClient = httpClient) {
    this.client = client;
  }

  /**
   * Liste l'ensemble des ressources de réservation (GET /api/v1/resources)
   */
  public async listResources(): Promise<ResourceResponse[]> {
    return this.client.get<ResourceResponse[]>('/resources');
  }

  /**
   * Récupère les détails d'une ressource (GET /api/v1/resources/{id})
   */
  public async getResource(id: string): Promise<ResourceResponse> {
    return this.client.get<ResourceResponse>(`/resources/${encodeURIComponent(id)}`);
  }

  /**
   * Crée une nouvelle ressource (POST /api/v1/resources)
   */
  public async createResource(request: CreateResourceRequest): Promise<ResourceResponse> {
    return this.client.post<ResourceResponse>('/resources', request);
  }

  /**
   * Met à jour une ressource existante (PUT /api/v1/resources/{id})
   */
  public async updateResource(id: string, request: UpdateResourceRequest): Promise<ResourceResponse> {
    return this.client.put<ResourceResponse>(`/resources/${encodeURIComponent(id)}`, request);
  }

  /**
   * Supprime une ressource (DELETE /api/v1/resources/{id})
   */
  public async deleteResource(id: string): Promise<DeleteResourceResponse> {
    return this.client.delete<DeleteResourceResponse>(`/resources/${encodeURIComponent(id)}`);
  }

  /**
   * Synchronise le flux d'agenda d'une ressource (POST /api/v1/resources/{id}/sync)
   */
  public async syncResource(id: string): Promise<SyncResourceResponse> {
    return this.client.post<SyncResourceResponse>(`/resources/${encodeURIComponent(id)}/sync`);
  }
}

export const resourcesClient = new ResourcesClient();
