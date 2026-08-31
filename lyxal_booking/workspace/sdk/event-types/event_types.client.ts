/**
 * 🏛️ LYXAL OS — Client SDK Fortement Typé pour le Module 06 : EventTypes
 */

import { HttpClient, httpClient } from '../client';
import {
  EventTypeResponse,
  CreateEventTypeRequest,
  UpdateEventTypeRequest,
  DeleteEventTypeResponse,
  ToggleEventTypeResponse,
} from './event_types.types';

export class EventTypesClient {
  private client: HttpClient;

  constructor(client: HttpClient = httpClient) {
    this.client = client;
  }

  /**
   * Liste l'ensemble des créneaux / types d'événements de réservation (GET /api/v1/event-types)
   */
  public async listEventTypes(): Promise<EventTypeResponse[]> {
    return this.client.get<EventTypeResponse[]>('/event-types');
  }

  /**
   * Récupère les détails d'un créneau par son slug (GET /api/v1/event-types/{slug})
   */
  public async getEventType(slug: string): Promise<EventTypeResponse> {
    return this.client.get<EventTypeResponse>(`/event-types/${encodeURIComponent(slug)}`);
  }

  /**
   * Crée un nouveau créneau de réservation (POST /api/v1/event-types)
   */
  public async createEventType(request: CreateEventTypeRequest): Promise<EventTypeResponse> {
    return this.client.post<EventTypeResponse>('/event-types', request);
  }

  /**
   * Met à jour un créneau de réservation (PATCH /api/v1/event-types/{slug})
   */
  public async updateEventType(slug: string, request: UpdateEventTypeRequest): Promise<EventTypeResponse> {
    return this.client.patch<EventTypeResponse>(`/event-types/${encodeURIComponent(slug)}`, request);
  }

  /**
   * Supprime un créneau de réservation (DELETE /api/v1/event-types/{slug})
   */
  public async deleteEventType(slug: string): Promise<DeleteEventTypeResponse> {
    return this.client.delete<DeleteEventTypeResponse>(`/event-types/${encodeURIComponent(slug)}`);
  }

  /**
   * Bascule l'activation / le masquage d'un créneau (PATCH /api/v1/event-types/{slug}/toggle)
   */
  public async toggleEventType(slug: string): Promise<ToggleEventTypeResponse> {
    return this.client.patch<ToggleEventTypeResponse>(`/event-types/${encodeURIComponent(slug)}/toggle`);
  }

  /**
   * Récupère les ressources rattachées à un créneau (GET /api/v1/event-types/{slug}/resources)
   */
  public async getEventTypeResources(slug: string): Promise<String[]> {
    return this.client.get<String[]>(`/event-types/${encodeURIComponent(slug)}/resources`);
  }

  /**
   * Met à jour de manière atomique la sélection des ressources rattachées (PUT /api/v1/event-types/{slug}/resources)
   */
  public async updateEventTypeResources(slug: string, resource_ids: string[]): Promise<{ event_type_id: string; resource_ids: string[] }> {
    return this.client.put<{ event_type_id: string; resource_ids: string[] }>(`/event-types/${encodeURIComponent(slug)}/resources`, {
      resource_ids,
    });
  }
}

export const eventTypesClient = new EventTypesClient();
