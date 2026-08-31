/**
 * 🏛️ LYXAL OS — Types TypeScript pour le Module 06 : EventTypes
 * Dérivés des contrats Rust DTOs (engine/src/contracts/event_types.rs)
 */

export interface EventTypeResponse {
  id: string;
  title: string;
  slug: string;
  duration_minutes: number;
  description?: string | null;
  before_buffer_minutes?: number;
  after_buffer_minutes?: number;
  location_type?: string;
  scheduling_type?: string;
  resource_ids?: string[];
  active: boolean;
}

export interface CreateEventTypeRequest {
  title: string;
  slug: string;
  duration_minutes: number;
  description?: string | null;
  before_buffer_minutes?: number;
  after_buffer_minutes?: number;
  location_type?: string;
  scheduling_type?: string;
  resource_ids?: string[];
}

export interface UpdateEventTypeRequest {
  title?: string | null;
  slug?: string | null;
  duration_minutes?: number | null;
  description?: string | null;
  before_buffer_minutes?: number | null;
  after_buffer_minutes?: number | null;
  location_type?: string | null;
  scheduling_type?: string | null;
  resource_ids?: string[] | null;
  active?: boolean | null;
}

export interface ToggleEventTypeResponse {
  event_type_id: string;
  active: boolean;
}

export interface DeleteEventTypeResponse {
  deleted: boolean;
}
