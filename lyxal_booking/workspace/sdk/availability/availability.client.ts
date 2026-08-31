/**
 * 🏛️ LYXAL OS — Client SDK Fortement Typé pour le Module 07 : Availability
 */

import { HttpClient, httpClient } from '../client';
import {
  AvailabilityQuery,
  AvailabilityResponse,
  AvailabilityScheduleResponse,
  SaveAvailabilityScheduleRequest,
  AvailabilityOverrideResponse,
  SaveAvailabilityOverrideRequest,
  DeleteAvailabilityOverrideResponse,
} from './availability.types';

export class AvailabilityClient {
  private client: HttpClient;

  constructor(client: HttpClient = httpClient) {
    this.client = client;
  }

  /**
   * Calcule les créneaux libres/disponibles (GET /api/v1/availability/slots?event_type_slug=...&date_from=...&date_to=...&time_zone=...)
   */
  public async getAvailableSlots(query: AvailabilityQuery): Promise<AvailabilityResponse> {
    return this.client.get<AvailabilityResponse>('/availability/slots', {
      params: {
        event_type_slug: query.event_type_slug,
        date_from: query.date_from,
        date_to: query.date_to,
        time_zone: query.time_zone,
      },
    });
  }

  /**
   * Récupère les plannings d'ouverture configurés (GET /api/v1/availability/schedules)
   */
  public async getSchedules(): Promise<AvailabilityScheduleResponse[]> {
    return this.client.get<AvailabilityScheduleResponse[]>('/availability/schedules');
  }

  /**
   * Enregistre un planning d'ouverture (POST /api/v1/availability/schedules)
   */
  public async saveSchedule(request: SaveAvailabilityScheduleRequest): Promise<AvailabilityScheduleResponse> {
    return this.client.post<AvailabilityScheduleResponse>('/availability/schedules', request);
  }

  /**
   * Récupère les exceptions ponctuelles de disponibilité (GET /api/v1/availability/overrides)
   */
  public async getOverrides(): Promise<AvailabilityOverrideResponse[]> {
    return this.client.get<AvailabilityOverrideResponse[]>('/availability/overrides');
  }

  /**
   * Enregistre une exception ponctuelle de disponibilité (POST /api/v1/availability/overrides)
   */
  public async saveOverride(request: SaveAvailabilityOverrideRequest): Promise<AvailabilityOverrideResponse> {
    return this.client.post<AvailabilityOverrideResponse>('/availability/overrides', request);
  }

  /**
   * Supprime une exception ponctuelle par son ID (DELETE /api/v1/availability/overrides/{id})
   */
  public async deleteOverride(id: string): Promise<DeleteAvailabilityOverrideResponse> {
    return this.client.delete<DeleteAvailabilityOverrideResponse>(`/availability/overrides/${encodeURIComponent(id)}`);
  }
}

export const availabilityClient = new AvailabilityClient();
