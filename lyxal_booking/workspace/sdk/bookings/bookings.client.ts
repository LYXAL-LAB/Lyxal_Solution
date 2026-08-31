/**
 * 🏛️ LYXAL OS — Client SDK Fortement Typé pour le Module 09 : Bookings
 */

import { HttpClient, httpClient } from '../client';
import {
  BookingResponse,
  CreateBookingRequest,
  CancelBookingRequest,
  CancelBookingResponse,
  RescheduleBookingRequest,
  PublicTokenInfoResponse,
} from './bookings.types';

export class BookingsClient {
  private client: HttpClient;

  constructor(client: HttpClient = httpClient) {
    this.client = client;
  }

  /**
   * Liste les réservations de l'utilisateur authentifié (GET /api/v1/bookings)
   */
  public async listBookings(): Promise<BookingResponse[]> {
    return this.client.get<BookingResponse[]>('/bookings');
  }

  /**
   * Récupère les détails d'une réservation (GET /api/v1/bookings/{id})
   */
  public async getBooking(id: string): Promise<BookingResponse> {
    return this.client.get<BookingResponse>(`/bookings/${encodeURIComponent(id)}`);
  }

  /**
   * Crée une nouvelle réservation (POST /api/v1/bookings)
   */
  public async createBooking(request: CreateBookingRequest): Promise<BookingResponse> {
    return this.client.post<BookingResponse>('/bookings', request);
  }

  /**
   * Annule une réservation (POST /api/v1/bookings/{id}/cancel)
   */
  public async cancelBooking(id: string, request: CancelBookingRequest = {}): Promise<CancelBookingResponse> {
    return this.client.post<CancelBookingResponse>(`/bookings/${encodeURIComponent(id)}/cancel`, request);
  }

  /**
   * Reporte une réservation (POST /api/v1/bookings/{id}/reschedule)
   */
  public async rescheduleBooking(id: string, request: RescheduleBookingRequest): Promise<BookingResponse> {
    return this.client.post<BookingResponse>(`/bookings/${encodeURIComponent(id)}/reschedule`, request);
  }

  /**
   * Confirme manuellement une réservation (POST /api/v1/bookings/{id}/confirm)
   */
  public async confirmBooking(id: string): Promise<BookingResponse> {
    return this.client.post<BookingResponse>(`/bookings/${encodeURIComponent(id)}/confirm`);
  }

  /**
   * Crée une réservation publique pour la page personnelle d'un hôte (POST /api/v1/public/users/{username}/event-types/{slug}/bookings)
   */
  public async createUserBooking(username: string, slug: string, request: CreateBookingRequest): Promise<BookingResponse> {
    return this.client.post<BookingResponse>(`/public/users/${encodeURIComponent(username)}/event-types/${encodeURIComponent(slug)}/bookings`, request);
  }

  /**
   * Crée une réservation publique pour une équipe (POST /api/v1/public/teams/{team_slug}/event-types/{slug}/bookings)
   */
  public async createTeamBooking(teamSlug: string, slug: string, request: CreateBookingRequest): Promise<BookingResponse> {
    return this.client.post<BookingResponse>(`/public/teams/${encodeURIComponent(teamSlug)}/event-types/${encodeURIComponent(slug)}/bookings`, request);
  }

  /**
   * Récupère les informations d'un token public (GET /api/v1/public/bookings/token/{token})
   */
  public async getPublicTokenInfo(token: string): Promise<PublicTokenInfoResponse> {
    return this.client.get<PublicTokenInfoResponse>(`/public/bookings/token/${encodeURIComponent(token)}`);
  }

  /**
   * Annule une réservation publique par token invité (POST /api/v1/public/bookings/cancel/{token})
   */
  public async cancelPublicBooking(token: string, request: CancelBookingRequest = {}): Promise<CancelBookingResponse> {
    return this.client.post<CancelBookingResponse>(`/public/bookings/cancel/${encodeURIComponent(token)}`, request);
  }

  /**
   * Reporte une réservation publique par token invité (POST /api/v1/public/bookings/reschedule/{token})
   */
  public async reschedulePublicBooking(token: string, request: RescheduleBookingRequest): Promise<BookingResponse> {
    return this.client.post<BookingResponse>(`/public/bookings/reschedule/${encodeURIComponent(token)}`, request);
  }

  /**
   * Approuve une réservation en attente par token hôte (POST /api/v1/public/bookings/approve/{token})
   */
  public async approvePublicBooking(token: string): Promise<BookingResponse> {
    return this.client.post<BookingResponse>(`/public/bookings/approve/${encodeURIComponent(token)}`);
  }

  /**
   * Refuse une réservation en attente par token hôte (POST /api/v1/public/bookings/decline/{token})
   */
  public async declinePublicBooking(token: string, request: CancelBookingRequest = {}): Promise<BookingResponse> {
    return this.client.post<BookingResponse>(`/public/bookings/decline/${encodeURIComponent(token)}`, request);
  }

  /**
   * Réclame une réservation disponible par membre d'équipe authentifié (POST /api/v1/public/bookings/claim/{booking_id})
   */
  public async claimBooking(bookingId: string, request: { token: string }): Promise<{ booking_id: string; claimed: boolean }> {
    return this.client.post<{ booking_id: string; claimed: boolean }>(`/public/bookings/claim/${encodeURIComponent(bookingId)}`, request);
  }
}

export const bookingsClient = new BookingsClient();
