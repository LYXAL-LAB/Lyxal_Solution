/**
 * 🏛️ LYXAL OS — Types TypeScript pour le Module 04 : Calendars
 * Dérivés des contrats Rust DTOs (engine/src/contracts/calendars.rs)
 */

export interface CalendarSourceResponse {
  id: string;
  name: string;
  provider_type: 'caldav' | 'ews' | 'google' | 'outlook' | 'ics' | string;
  auth_type: 'basic' | 'oauth2' | 'none' | string;
  server_url?: string | null;
  username?: string | null;
  active: boolean;
  status: string;
  last_synced_at?: string | null;
}

export interface CreateCalendarSourceRequest {
  name: string;
  provider_type: string;
  auth_type: string;
  server_url?: string | null;
  username?: string | null;
  secret?: string | null;
}

export interface DeleteCalendarSourceResponse {
  deleted: boolean;
}

export interface SyncCalendarSourceResponse {
  source_id: string;
  synced_events_count: number;
  success: boolean;
}

export interface SetWriteCalendarRequest {
  calendar_href: string;
}

export interface SetWriteCalendarResponse {
  source_id: string;
  write_calendar_href: string;
  updated: boolean;
}

export interface GoogleOAuthConnectResponse {
  auth_url: string;
}
