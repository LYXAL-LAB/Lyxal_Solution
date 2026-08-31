/**
 * 🏛️ LYXAL OS — Client SDK Fortement Typé pour le Module 04 : Calendars
 */

import { HttpClient, httpClient } from '../client';
import {
  CalendarSourceResponse,
  CreateCalendarSourceRequest,
  DeleteCalendarSourceResponse,
  SyncCalendarSourceResponse,
  SetWriteCalendarRequest,
  SetWriteCalendarResponse,
  GoogleOAuthConnectResponse,
} from './calendars.types';

export class CalendarsClient {
  private client: HttpClient;

  constructor(client: HttpClient = httpClient) {
    this.client = client;
  }

  /**
   * Liste l'ensemble des sources de calendriers connectées (GET /api/v1/calendars)
   */
  public async listSources(): Promise<CalendarSourceResponse[]> {
    return this.client.get<CalendarSourceResponse[]>('/calendars');
  }

  /**
   * Récupère les détails d'une source de calendrier (GET /api/v1/calendars/{id})
   */
  public async getSource(id: string): Promise<CalendarSourceResponse> {
    return this.client.get<CalendarSourceResponse>(`/calendars/${encodeURIComponent(id)}`);
  }

  /**
   * Connecte une nouvelle source CalDAV / EWS / ICS (POST /api/v1/calendars)
   */
  public async createSource(request: CreateCalendarSourceRequest): Promise<CalendarSourceResponse> {
    return this.client.post<CalendarSourceResponse>('/calendars', request);
  }

  /**
   * Déclenche la synchronisation manuelle d'un agenda distant (POST /api/v1/calendars/{id}/sync)
   */
  public async syncSource(id: string): Promise<SyncCalendarSourceResponse> {
    return this.client.post<SyncCalendarSourceResponse>(`/calendars/${encodeURIComponent(id)}/sync`);
  }

  /**
   * Supprime une source de calendrier (DELETE /api/v1/calendars/{id})
   */
  public async deleteSource(id: string): Promise<DeleteCalendarSourceResponse> {
    return this.client.delete<DeleteCalendarSourceResponse>(`/calendars/${encodeURIComponent(id)}`);
  }

  /**
   * Définit le calendrier d'écriture pour l'insertion de rendez-vous (PUT /api/v1/calendars/{id}/write)
   */
  public async setWriteCalendar(id: string, calendarHref: string): Promise<SetWriteCalendarResponse> {
    const request: SetWriteCalendarRequest = { calendar_href: calendarHref };
    return this.client.put<SetWriteCalendarResponse>(`/calendars/${encodeURIComponent(id)}/write`, request);
  }

  /**
   * Obtenir l'URL de connexion OAuth2 Google (GET /api/v1/calendars/google/connect)
   */
  public async getGoogleOAuthUrl(): Promise<GoogleOAuthConnectResponse> {
    return this.client.get<GoogleOAuthConnectResponse>('/calendars/google/connect');
  }
}

export const calendarsClient = new CalendarsClient();
