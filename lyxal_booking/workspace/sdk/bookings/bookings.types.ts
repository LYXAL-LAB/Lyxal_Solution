/**
 * 🏛️ LYXAL OS — Types TypeScript pour le Module 09 : Bookings
 * Dérivés des contrats Rust DTOs (engine/src/contracts/bookings.rs)
 */

export interface BookingResponse {
  id: string;
  event_type_id: string;
  start_at: string;
  end_at: string;
  status: 'pending' | 'confirmed' | 'cancelled' | 'rescheduled';
  assigned_resource_id?: string | null;
  meeting_url?: string | null;
  notification_status?: string | null;
  calendar_sync_status?: string | null;
  guest_name: string;
  guest_email: string;
}

export interface CreateBookingRequest {
  event_type_slug: string;
  start_time: string;
  guest_name: string;
  guest_email: string;
  notes?: string | null;
}

export interface CancelBookingRequest {
  reason?: string | null;
}

export interface CancelBookingResponse {
  cancelled: boolean;
  booking_id: string;
}

export interface RescheduleBookingRequest {
  expected_start_at: string;
  expected_end_at: string;
  new_start_at: string;
  new_end_at: string;
}

export interface PublicTokenInfoResponse {
  action: string;
  booking_id: string;
  guest_name: string;
  guest_email: string;
  start_at: string;
  end_at: string;
  event_type_title: string;
  expires_at: string;
  is_valid: boolean;
}
