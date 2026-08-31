/**
 * 🏛️ LYXAL OS — Types TypeScript pour le Module 07 : Availability
 * Dérivés des contrats Rust DTOs (engine/src/contracts/availability.rs)
 */

export interface AvailabilitySlotResponse {
  start_at: string;
  end_at: string;
  available_resource_ids: string[];
}

export interface AvailabilityResponse {
  slots: AvailabilitySlotResponse[];
}

export interface AvailabilityQuery {
  event_type_slug: string;
  date_from: string;
  date_to: string;
  time_zone: string;
}

export interface AvailabilityScheduleRule {
  day_of_week: number; // 0 = Dimanche, 1 = Lundi, ..., 6 = Samedi
  start_time: string;  // "09:00"
  end_time: string;    // "17:00"
}

export interface AvailabilityScheduleResponse {
  id: string;
  name: string;
  time_zone: string;
  is_default: boolean;
  rules: AvailabilityScheduleRule[];
}

export interface SaveAvailabilityScheduleRequest {
  name: string;
  time_zone: string;
  is_default: boolean;
  rules: AvailabilityScheduleRule[];
}

export interface AvailabilityOverrideResponse {
  id: string;
  date: string;
  unavailable: boolean;
  start_time?: string | null;
  end_time?: string | null;
}

export interface SaveAvailabilityOverrideRequest {
  date: string;
  unavailable: boolean;
  start_time?: string | null;
  end_time?: string | null;
}

export interface DeleteAvailabilityOverrideResponse {
  deleted: boolean;
}
